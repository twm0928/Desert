clc;clear;
tic
filePath=uigetdir({},'choose your filepath'); %��ȡexcel�ļ��洢Ŀ¼
mkdir(strcat(filePath,'\output'));%�½�����ļ���
time=zeros(31,1);
for y=2030 % ������readdata����һ��
    for i=4 % ����       
        for j=8 % case
            for k=1 % ����
                adjust_prvc_index=[2 3 4 5 7 8 10 12 15 16 17 20 21 22 23 24 25 27 28 29 30 31]; %�������ߵ���ʡ�ݱ��
                prvc_index=adjust_prvc_index(i);
                
                %��ȡ����ˮ���繦�ʡ����ɡ������߾�������ʡ������װ����ú�����ݣ���ͬ����޸Ķ�ȡ������׺
                [Powerdata] = read_data_30(filePath,prvc_index,j,k);
                
                %���硢������������
                data_present(filePath,Powerdata,prvc_index);
                
                %ѡȡ�����ܽ��л�������Ż� �����ܽ�����
                [result] = UC_optimize(Powerdata);
                
                %�����ܽ������ȫ��̼�ŷ�
                [result] = annual_calculation(Powerdata,result);
                
                %������
                data_output(result,prvc_index,filePath,j,k);% �����ʱֻ���ֶ��������
            end
        end
    end
end
toc
