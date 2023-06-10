package com.blackwings.crm.workbench.service;


import com.blackwings.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    Integer queryActivityNumbers(Activity activity);

    List<Activity> queryActivityListByCondition(Map map);

    int saveActivity(Activity activity);

    Activity queryActivityDetails(String id);

    int saveEditActivity(Activity activity);

    int deleteActivity(String[] ids);

    List<Activity> queryAllActivity();

    int saveImportActivity(List<Activity> activityList);
}
