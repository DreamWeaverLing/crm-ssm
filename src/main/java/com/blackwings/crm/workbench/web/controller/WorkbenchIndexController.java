package com.blackwings.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class WorkbenchIndexController {
    @RequestMapping("workbench/index.do")
    public String index(){
        return "workbench/index";
    }

    @RequestMapping("main/index.do")
    public String mainIndex(){
        return "workbench/main/index";
    }

    @RequestMapping("activity/index.do")
    public String activityIndex(){
        return "workbench/activity/index";
    }
}
