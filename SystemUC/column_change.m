function [column_letter] = column_change(column_num)
%表格数字列数转化为excel字母型列数

column_letter='';
while column_num>26
    res=rem(column_num,26);
    if res==0
        res=26; %刚好被26整除时 保留最低位的26（z）
    end
    
    column_letter=[char(64+res),column_letter];
    
    if res==26
        column_num=floor(column_num/26)-1; %刚好被26整除时 高位数不接受进位
    else
        column_num=floor(column_num/26);
    end
end

column_letter=[char(64+column_num),column_letter];

end

