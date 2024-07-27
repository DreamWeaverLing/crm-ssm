import com.blackwings.crm.commons.contants.Flag;
import com.blackwings.crm.commons.utils.DateUtils;
import org.junit.Test;

import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import java.util.UUID;

public class Test1 {
    @Test
    public void test11(){
        int m = 1;
        System.out.println(m++);
    }
    @Test
    public void test22(){
        int m = 1;
        System.out.println(++m);
    }
    @Test
    public void test33(){
        System.out.println(DateUtils.fomateDateTime(new Date()).compareTo("2018-11-27 21:50:05")>0);
        System.out.println(DateUtils.fomateDateTime(new Date()));
    }

    @Test
    public void test44(){
        FileWriter fileWriter = null;
        try {
            fileWriter = new FileWriter("file");
            char[] chars = {'我','是','中','国','人'};
            fileWriter.write(chars,2,2);
            fileWriter.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void test111(){
        Object o = UUID.randomUUID();
        System.out.println(o);
        System.out.println(String.valueOf(o));
        System.out.println((String.valueOf(o)).replace("-",""));
    }

    @Test
    public void test123(){
        boolean a = true;
        String b = a+"";
        String c = String.valueOf(a);
        System.out.println(b);
        System.out.println(c);
    }

    @Test
    public void testEnum(){
        System.out.println(Flag.SUCCESS);;
        System.out.println(Flag.SUCCESS.getFlag());;
    }

    @Test
    public void smallestString() {
        String s = "azvbfadgha";
        String leftA = new String();
        while (s.startsWith("a")) {
            if ("a".equals(s)){
                leftA = leftA+"z";
                s ="";
                break;
            }
            if (s.length()>1){
                s = s.substring(1);
            }
            leftA=leftA+"a";
        }
        byte[] bytes = new byte[0];
        if (s.length()!=0) {
            bytes = s.getBytes();
            for (int i = 0; i < s.length(); i++) {
                if (bytes[i]==97){
                    break;
                }
                bytes[i]= (byte) (bytes[i]- 1);
            }
        }
        String newS = leftA + new String(bytes);
        System.out.println(newS);
    }

    @Test
    public void smallestString1() {
        String s = "leetcode";
/*        while (s.startsWith("a")) {
            if ("a".equals(s)){
                leftA = leftA+"z";
                s ="";
                break;
            }
            if (s.length()>1){
                s = s.substring(1);
            }
            leftA=leftA+"a";
        }*/
        byte[] bytes = s.getBytes();

        for (int i = 0; i < s.length(); i++) {
            if (bytes[i]==97){
                continue;
            }
            while (i< s.length() && bytes[i]>97){
                bytes[i]--;
                i++;
            }
            System.out.println(new String(bytes));
            return;
        }
        bytes[s.length()-1]='z';
        System.out.println(new String(bytes));
    }
}
