function [column_letter] = column_change(column_num)
%�����������ת��Ϊexcel��ĸ������

column_letter='';
while column_num>26
    res=rem(column_num,26);
    if res==0
        res=26; %�պñ�26����ʱ �������λ��26��z��
    end
    
    column_letter=[char(64+res),column_letter];
    
    if res==26
        column_num=floor(column_num/26)-1; %�պñ�26����ʱ ��λ�������ܽ�λ
    else
        column_num=floor(column_num/26);
    end
end

column_letter=[char(64+column_num),column_letter];

end

