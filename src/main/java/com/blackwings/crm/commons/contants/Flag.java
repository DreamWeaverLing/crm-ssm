package com.blackwings.crm.commons.contants;

public enum Flag {
    SUCCESS(1),FAIL(0);

    private int flag;

    Flag(int flag) {
        this.flag = flag;
    }

    public int getFlag(){
        return flag;
    }
}
