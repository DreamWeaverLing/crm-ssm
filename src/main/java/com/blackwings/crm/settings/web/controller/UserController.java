package com.blackwings.crm.settings.web.controller;

import com.blackwings.crm.commons.contants.Contants;
import com.blackwings.crm.commons.domain.ReturnObj;
import com.blackwings.crm.commons.utils.DateUtils;
import com.blackwings.crm.settings.domain.User;
import com.blackwings.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sound.midi.Soundbank;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {

    @Autowired
    private UserService userService;

    @RequestMapping("settings/qx/user/tologin.do")
    public String toLogin(){
        return "settings/qx/user/login";
    }

    /**
     * 用户登录
     */
    @RequestMapping("settings/qx/user/login.do")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd,
                        HttpServletRequest request, HttpServletResponse response, HttpSession session){
        // 封装参数
        Map<String,String> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
        // 查询用户，调用service方法
        User user = userService.queryUserByLoginActAndPwd(map);

        ReturnObj returnObj = new ReturnObj();
        if (user == null) {
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("用户名或密码错误！");
        } else if(DateUtils.fomateDateTime(new Date()).compareTo(user.getExpireTime())>0){
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("账户已过期！");
        } else if("0".equals(user.getLockState())){
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("账户已被锁定，请联系管理员！");
        } else if (!user.getAllowIps().contains(request.getRemoteAddr())){
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObj.setMessage("IP受限，请联系管理员！");
        } else {
            // System.out.println("登录IP为"+request.getRemoteAddr());
            // 登录成功
            returnObj.setCode(Contants.RETURN_OBJECT_CODE_SUCCESSS);
            // 保存session
            session.setAttribute(Contants.SESSION_USER,user);

            // 记住密码
            if ("true".equals(isRemPwd)){
                Cookie cookie1 = new Cookie(Contants.COOKIE_LOGIN_ACT,user.getLoginAct());
                Cookie cookie2 = new Cookie(Contants.COOKIE_LOGIN_PWD,user.getLoginPwd());
                cookie1.setMaxAge(60*60*24*10);
                cookie2.setMaxAge(60*60*24*10);
                response.addCookie(cookie1);
                response.addCookie(cookie2);
            } else {
                // 无需记住密码则清除cookie
                Cookie cookie1 = new Cookie(Contants.COOKIE_LOGIN_ACT,"0");
                Cookie cookie2 = new Cookie(Contants.COOKIE_LOGIN_PWD,"0");
                cookie1.setMaxAge(0);
                cookie2.setMaxAge(0);
                response.addCookie(cookie1);
                response.addCookie(cookie2);
            }
        }
        return returnObj;
    }

    /**
     * 安全退出
     */
    @RequestMapping("settings/qx/user/logout.do")
    public String logout(HttpServletResponse response,HttpSession session){
        Cookie cookie1 = new Cookie(Contants.COOKIE_LOGIN_ACT,"0");
        Cookie cookie2 = new Cookie(Contants.COOKIE_LOGIN_PWD,"0");
        cookie1.setMaxAge(0);
        cookie2.setMaxAge(0);
        response.addCookie(cookie1);
        response.addCookie(cookie2);
        session.invalidate();
        return "redirect:/";
    }
}
