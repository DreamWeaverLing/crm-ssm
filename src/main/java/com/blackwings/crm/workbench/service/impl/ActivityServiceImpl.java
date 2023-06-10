package com.blackwings.crm.workbench.service.impl;

import com.blackwings.crm.workbench.domain.Activity;
import com.blackwings.crm.workbench.mapper.ActivityMapper;
import com.blackwings.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ActivityServiceImpl implements ActivityService {

    @Autowired
    private ActivityMapper activityMapper;

    @Override
    public Integer queryActivityNumbers(Activity activity) {
        return activityMapper.queryActivityNumbers(activity);
    }

    @Override
    public List<Activity> queryActivityListByCondition(Map map) {
        return activityMapper.queryActivityListByCondition(map);
    }

    @Override
    public int saveActivity(Activity activity) {
        return activityMapper.saveActivity(activity);
    }

    @Override
    public Activity queryActivityDetails(String id) {
        return activityMapper.queryActivityDetails(id);
    }

    @Override
    public int saveEditActivity(Activity activity) {
        return activityMapper.saveEditActivity(activity);
    }

    @Override
    public int deleteActivity(String[] ids) {
        return activityMapper.deleteActivity(ids);
    }

    @Override
    public List<Activity> queryAllActivity() {
        return activityMapper.queryAllActivity();
    }

    @Override
    public int saveImportActivity(List<Activity> activityList) {
        return activityMapper.saveImportActivity(activityList);
    }
}
