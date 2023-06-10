package com.blackwings.crm.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.ss.usermodel.Cell;

public class CellValue {
    /**
     * 设置工作表单元格的值
     * @param row 行
     * @param num 列
     * @param value 值
     */
    public static void setCellValue(HSSFRow row, int num, String value){
        HSSFCell cell = row.createCell(num);
        cell.setCellValue(value);
    }

    public static String getCellValue(HSSFCell cell){
        String str = "";
        if (cell.getCellType() == Cell.CELL_TYPE_NUMERIC){
            str = String.valueOf(cell.getNumericCellValue());
        } else if (cell.getCellType() == Cell.CELL_TYPE_FORMULA){
            str = cell.getCellFormula();
        } else if (cell.getCellType() == Cell.CELL_TYPE_STRING){
            str = cell.getStringCellValue();
        } else if (cell.getCellType() == Cell.CELL_TYPE_BOOLEAN){
            str = cell.getBooleanCellValue()+"";
        }
        return str;
    }
}
