clc;clear;
tic
filePath=uigetdir({},'choose your filepath'); %获取excel文件存储目录
mkdir(strcat(filePath,'\output'));%新建输出文件夹
time=zeros(31,1);
for y=2030 % 和下面readdata保持一致
    for i=4 % 内蒙       
        for j=8 % case
            for k=1 % 容量
                adjust_prvc_index=[2 3 4 5 7 8 10 12 15 16 17 20 21 22 23 24 25 27 28 29 30 31]; %负荷曲线调整省份编号
                prvc_index=adjust_prvc_index(i);
                
                %获取风光核水发电功率、负荷、联络线净输出功率、发电机装机与煤耗数据，不同年份修改读取函数后缀
                [Powerdata] = read_data_30(filePath,prvc_index,j,k);
                
                %发电、负荷数据评估
                data_present(filePath,Powerdata,prvc_index);
                
                %选取典型周进行机组组合优化 典型周结果输出
                [result] = UC_optimize(Powerdata);
                
                %典型周结果推算全年碳排放
                [result] = annual_calculation(Powerdata,result);
                
                %输出结果
                data_output(result,prvc_index,filePath,j,k);% 输出暂时只能手动设置年份
            end
        end
    end
end
toc
