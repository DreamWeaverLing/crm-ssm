package com.blackwings.crm.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 处理Date类型数据的工具类
 */
public class DateUtils {
    /**
     * 格式化日期对象为 yyyy-MM-dd HH:mm:ss 格式
     * @param date
     * @return
     */
    public static String fomateDateTime(Date date){
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String dateStr = simpleDateFormat.format(date);
        return dateStr;
    }

    /**
     * 格式化日期对象为 yyyy-MM-dd 格式
     * @param date
     * @return
     */
    public static String fomateDate(Date date){
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        String dateStr = simpleDateFormat.format(date);
        return dateStr;
    }

    /**
     * 格式化日期对象为 HH:mm:ss 格式
     * @param date
     * @return
     */
    public static String fomateTime(Date date){
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("HH:mm:ss");
        String dateStr = simpleDateFormat.format(date);
        return dateStr;
    }
}
