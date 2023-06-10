package com.blackwings.crm.commons.domain;

public class ReturnObj {
    private String code;//处理结果标记：1.成功；0.失败
    private String message;//提示信息
    private Object retData;//返回对象

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getRetData() {
        return retData;
    }

    public void setRetData(Object retData) {
        this.retData = retData;
    }
}
