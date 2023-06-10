package com.blackwings.crm.workbench.web.controller;

import com.blackwings.crm.commons.contants.Contants;
import com.blackwings.crm.commons.domain.ReturnObj;
import com.blackwings.crm.commons.utils.CellValue;
import com.blackwings.crm.commons.utils.DateUtils;
import com.blackwings.crm.settings.domain.User;
import com.blackwings.crm.settings.service.UserService;
import com.blackwings.crm.workbench.domain.Activity;
import com.blackwings.crm.workbench.service.ActivityService;
import org.apache.logging.log4j.core.util.UuidUtil;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.*;

@Controller
public class ActivityController {

    @Autowired
    private ActivityService activityService;

    @Autowired
    private UserService userService;

    /**
     * 根据条件查找市场活动列表
     * @return 返回市场活动列表activityList及总条数totals
     */
    @RequestMapping("/workbench/activity/queryActivityListByCondition.do")
    public @ResponseBody Object queryActivityListByCondition(Activity activity,String pageNo,String pageSize){
        Map map = new HashMap<>();
        int beginNo = (Integer.valueOf(pageNo) - 1) * Integer.valueOf(pageSize);
        ReturnObj returnObj = new ReturnObj();

        map.put("name",activity.getName());
        map.put("owner",activity.getOwner());
        map.put("startDate",activity.getStartDate());
        map.put("endDate",activity.getEndDate());
        map.put("beginNo",beginNo);
        map.put("pageSize",Integer.parseInt(pageSize));

        List<Activity> activityList = activityService.queryActivityListByCondition(map);
        // 条数为0则返回失败信息
        if (activityList.size() == 0){
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("没有符合条件的结果");
            return returnObj;
        }

        Integer totals = activityService.queryActivityNumbers(activity);
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("activityList",activityList);
        retMap.put("totals",totals);

        returnObj.setCode(Contants.RETURN_OBJECT_CODE_SUCCESSS);
        returnObj.setRetData(retMap);

        return returnObj;
    }

    /**
     * 打开创建市场活动列表
     * @return 所有者owner的集合
     */
    @RequestMapping("/workbench/activity/queryOwner.do")
    public @ResponseBody Object queryOwner(){
        List<User> userList = userService.queryOwner();
        ReturnObj returnObj = new ReturnObj();
        returnObj.setRetData(userList);
        return returnObj;
    }

    /**
     * 保存市场活动
     * @return 成功“1”，失败“0”
     */
    @RequestMapping("/workbench/activity/saveActivity.do")
    public @ResponseBody Object saveActivity(Activity activity, HttpSession session){
        // 将键值保存到activity对象中
        String id = (String.valueOf(UUID.randomUUID())).replace("-","");
        String createTime = DateUtils.fomateDateTime(new Date());
        String createBy = ((User)session.getAttribute(Contants.SESSION_USER)).getId();
        activity.setId(id);
        activity.setCreateTime(createTime);
        activity.setCreateBy(createBy);
        // 调用service层保存activity
        int num = activityService.saveActivity(activity);
        // 根据返回值向前端传递保存成功与否信息
        ReturnObj returnObj = new ReturnObj();
        if (num == 1){
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_SUCCESSS);
        } else {
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("系统忙，请稍后重试！");
        }
        return returnObj;
    }

    /**
     * 打开修改市场活动窗口
     * @param id 根据id获取选中市场活动详情
     * @return 所有者（所有用户）名单及所选市场活动详情
     */
    @RequestMapping("/workbench/activity/getEditActivityDetails.do")
    public @ResponseBody Object getEditActivityDetails(String id){
        List<User> userList = userService.queryOwner();
        Activity activity = activityService.queryActivityDetails(id);
        ReturnObj returnObj = new ReturnObj();
        Map<String,Object> map = new HashMap<>();
        map.put("ownerList",userList);
        map.put("activity",activity);
        returnObj.setRetData(map);
        return returnObj;
    }

    /**
     * 保存修改市场活动的内容
     */
    @RequestMapping("/workbench/activity/saveEditActivity.do")
    public @ResponseBody Object saveEditActivity(Activity activity,HttpSession session){
        String editTime = DateUtils.fomateDateTime(new Date());
        String editBy = ((User)session.getAttribute(Contants.SESSION_USER)).getId();
        activity.setEditTime(editTime);
        activity.setEditBy(editBy);
        int num = activityService.saveEditActivity(activity);
        ReturnObj returnObj = new ReturnObj();
        if (num == 1){
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_SUCCESSS);
        } else {
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("保存失败，请稍后重试！");
        }
        return returnObj;
    }

    /**
     * 删除市场活动
     * @param id 根据id删除
     */
    @RequestMapping("/workbench/activity/deleteActivity.do")
    public @ResponseBody Object deleteActivity(String[] id){
        int num = activityService.deleteActivity(id);
        ReturnObj returnObj = new ReturnObj();
        if (num > 0 && num == id.length){
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_SUCCESSS);
            returnObj.setMessage("已成功删除"+num+"条记录");
        } else {
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("系统繁忙，请稍后重试！");
        }
        return returnObj;
    }

    /**
     * 导出市场活动
     */
    @RequestMapping("/workbench/activity/exportAllActivity.do")
    public void exportAllActivity(HttpServletResponse response) throws IOException {
        // 获取所有市场活动列表
        List<Activity> activityList = activityService.queryAllActivity();
        // 创建一个工作表来存储市场活动
        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("市场活动");
        HSSFRow row = sheet.createRow(0);
        CellValue.setCellValue(row,0,"ID");
        CellValue.setCellValue(row,1,"所有者");
        CellValue.setCellValue(row,2,"名称");
        CellValue.setCellValue(row,3,"开始日期");
        CellValue.setCellValue(row,4,"结束日期");
        CellValue.setCellValue(row,5,"成本");
        CellValue.setCellValue(row,6,"描述");
        CellValue.setCellValue(row,7,"创建日期");
        CellValue.setCellValue(row,8,"创建者");
        CellValue.setCellValue(row,9,"修改日期");
        CellValue.setCellValue(row,10,"修改者");
        for (int i = 1; i <= activityList.size(); i++){
            Activity activity = activityList.get(i-1);
            row = sheet.createRow(i);
            CellValue.setCellValue(row,0,activity.getId());
            CellValue.setCellValue(row,1,activity.getOwner());
            CellValue.setCellValue(row,2,activity.getName());
            CellValue.setCellValue(row,3,activity.getStartDate());
            CellValue.setCellValue(row,4,activity.getEndDate());
            CellValue.setCellValue(row,5,activity.getCost());
            CellValue.setCellValue(row,6,activity.getDescription());
            CellValue.setCellValue(row,7,activity.getCreateTime());
            CellValue.setCellValue(row,8,activity.getCreateBy());
            CellValue.setCellValue(row,9,activity.getEditTime());
            CellValue.setCellValue(row,10,activity.getEditBy());
        }
        // 设置响应字符集和响应头
        response.setContentType("application/octet-stream;charset=utf-8");
        response.addHeader("Content-Disposition","attachment;filename=activityList.xls");
        // 开启输出流，输出到前端
        OutputStream outputStream = response.getOutputStream();
        workbook.write(outputStream);
        // 关闭流
        workbook.close();
        outputStream.flush();
    }

    /**
     * 导入市场活动
     * @param activityFile 从前端拿到的市场活动文件
     */
    @RequestMapping("/workbench/activity/importActivity.do")
    public @ResponseBody Object importActivity(MultipartFile activityFile,HttpSession session){
        // 获取登录用户
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        // 根据输入流新建市场活动的集合
        List<Activity> activityList = new ArrayList<>();
        Activity activity = null;
        ReturnObj returnObj = new ReturnObj();
        try {
            InputStream inputStream = activityFile.getInputStream();
            HSSFWorkbook workbook = new HSSFWorkbook(inputStream);
            HSSFSheet sheet = workbook.getSheetAt(0);
            HSSFRow row = null;
            HSSFCell cell = null;
            for (int i = 1; i <= sheet.getLastRowNum(); i++){
                // activity对象一定要在for循环体内new，在外部new会使新的覆盖旧的，list里的所有activity对象就都一样了
                activity = new Activity();
                row = sheet.getRow(i);
                activity.setId((String.valueOf(UUID.randomUUID())).replace("-",""));
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.fomateDateTime(new Date()));
                activity.setCreateBy(user.getId());
                for (int j = 0; j < row.getLastCellNum(); j++){
                    cell = row.getCell(j);
                    String cellValue = CellValue.getCellValue(cell);
                    if (j==0){
                        activity.setName(cellValue);
                    } else if (j==1){
                        activity.setStartDate(cellValue);
                    } else if (j==2){
                        activity.setEndDate(cellValue);
                    } else if (j==3){
                        activity.setCost(cellValue);
                    } else if (j==4){
                        activity.setDescription(cellValue);
                    }
                }
                activityList.add(activity);
            }
            // 将集合写入数据库
            int num = activityService.saveImportActivity(activityList);
            if (num == activityList.size()){
                returnObj.setCode(Contants.RETURN_OBJECT_CODE_SUCCESSS);
                returnObj.setMessage("成功保存"+num+"条记录！");
            }
        } catch (IOException e) {
            e.printStackTrace();
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("系统繁忙，请稍后重试！");
        }
        return returnObj;
    }
}
