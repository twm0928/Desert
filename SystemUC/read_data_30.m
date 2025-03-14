function [Powerdata] = read_data_30(filePath,prvc_index,j,k)
%读取一个省的数据
%输入：读取路径 省序号（1~31）
%输出：风光核水电出力、负荷、净输出功率、火电装机容量以及相应煤耗

%% 读入参数
global parameter;
raw_parameter=xlsread(strcat(filePath,'\','输入参数'),1); %读入参数
parameter.chart_num=2; %发电数据对应表格编号
parameter.day_num=raw_parameter(2); %一年中天数
parameter.time_num=raw_parameter(3); %一天进行优化的时段数
parameter.minPCG=raw_parameter(4); %火电机组最小出力系数
parameter.upcost=raw_parameter(5); %火电启动成本系数
parameter.downcost=raw_parameter(6); %火电停机成本系数
parameter.minTU=raw_parameter(7); %火电机组最小开机时间
parameter.minTD=raw_parameter(8); %火电机组最小停机时间
parameter.minPGS=raw_parameter(9); %燃气机组最小出力系数
parameter.minPBO=raw_parameter(10); %生物质机组最小出力系数
parameter.penalty=raw_parameter(11); %不平衡功率惩罚成本
parameter.Cemission=raw_parameter(12); %燃煤碳排放系数
parameter.GSemission=raw_parameter(13); %燃气碳排放系数
parameter.BOemission=raw_parameter(14); %生物质碳排放系数
parameter.WD_cutl_penalty=raw_parameter(15); %风电弃电惩罚
parameter.PV_cutl_penalty=raw_parameter(16); %光伏弃电惩罚
parameter.HD_cutl_penalty=raw_parameter(17); %水电弃电惩罚
parameter.CS_cutl_penalty=raw_parameter(18); %光热弃电惩罚
parameter.dayindex=xlsread(strcat(filePath,'\','输入参数'),2); %选取典型日
parameter.averhour=xlsread(strcat(filePath,'\','输入参数'),3); %读入平均利用小时数

%年时段转化为excel列数
sumT1=parameter.day_num*parameter.time_num+1;
columnend1=column_change(sumT1);

sumT2=parameter.day_num*parameter.time_num;
columnend2=column_change(sumT2);


%% 读入功率数据
wind_power=xlsread(strcat(filePath,'\','3-风电分省分年度发电曲线-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %读入风电功率 行为省 列为小时
photo_power=xlsread(strcat(filePath,'\','3-光伏分省分年度发电曲线-GM20-去分布式'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1)))...
  +xlsread(strcat(filePath,'\','6-新增光伏曲线'),j,strcat('A',num2str(k)))*xlsread(strcat(filePath,'\','6-新增光伏曲线'),j,strcat('B',num2str(k),':',columnend1,num2str(k))); %读入光伏功率 行为省 列为小时
nuclear_power=xlsread(strcat(filePath,'\','3-核电分省分年度发电曲线-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %读入核电功率 行为省 列为小时
hydro_power=xlsread(strcat(filePath,'\','3-水电分省分年度发电曲线-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %读入水电功率 行为省 列为小时
csp_power=xlsread(strcat(filePath,'\','3-光热分省分年度发电曲线-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %读入水电功率 行为省 列为小时
load_power=xlsread(strcat(filePath,'\','5-负荷分省分年度曲线-GM20-去分布式'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1)));%...%; %读入负荷功率 行为省 列为小时
   %-xlsread(strcat(filePath,'\','6-新增光伏曲线'),j,strcat('A',num2str(k)))*xlsread(strcat(filePath,'\','6-新增光伏曲线'),j,strcat('B',num2str(k),':',columnend1,num2str(k))); %读入光伏功率 行为省 列为小时
% load_power(load_power<0)=0;
Lflow=xlsread(strcat(filePath,'\','2030全年各省净输出功率'),1,strcat('A',num2str(prvc_index),':',columnend2,num2str(prvc_index)));%读入各省间潮流

%% 分省价格
coal_price=xlsread(strcat(filePath,'\','0-分省逐年价格'),1,strcat('B',num2str(prvc_index+1)))/1000; %读入各省电煤价格
gas_price=xlsread(strcat(filePath,'\','0-分省逐年价格'),1,strcat('C',num2str(prvc_index+1))); %读入各省燃气价格
bio_price=xlsread(strcat(filePath,'\','0-分省逐年价格'),1,strcat('D',num2str(prvc_index+1)))/1000; %读入各省生物质燃料价格
ce_price=xlsread(strcat(filePath,'\','碳价'),1,strcat('B',num2str(prvc_index+1)))/1000; %读入各省生物质燃料价格 单位：元/千克
%% 燃煤发电机参数读取
generation_cv=xlsread(strcat(filePath,'\','2-火电分省煤耗碳排数据-2030-GM20'),prvc_index);%读入 装机容量 煤

%% 燃气发电机参数获取
generation_gas=xlsread(strcat(filePath,'\','2-气电分省气耗碳排数据-2030-GM20'),prvc_index);%读入 装机容量 气耗
generation_gas(:,2)=generation_gas(:,2)*1000;

%% 生物质发电机参数获取
generation_bio=xlsread(strcat(filePath,'\','2-生物质分省质耗碳排数据-2030-GM20'),prvc_index);%读入 装机容量 生物质消耗

%% 储能参数获取
storage=xlsread(strcat(filePath,'\','4-储能分省数据-2030-GM20'),prvc_index);%读入 储能功率 储能容量 充放效率 充放成本系数

%% 装机容量获取
cv_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),1,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入火电装机
gas_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),2,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入燃气装机
bio_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),3,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入生物质装机
wind_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),4,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入风电装机
photo_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),5,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入光伏装机
nuclear_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),6,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入核电装机
hydro_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),7,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入水电装机
csp_v=xlsread(strcat(filePath,'\','能源逐年装机统计'),8,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %读入集热装机

%% 各类发电负荷数据转化为（天数*一天时段数）矩阵
wind_mP=zeros(parameter.day_num,parameter.time_num);
photo_mP=zeros(parameter.day_num,parameter.time_num);
nuclear_mP=zeros(parameter.day_num,parameter.time_num);
hydro_mP=zeros(parameter.day_num,parameter.time_num);
csp_mP=zeros(parameter.day_num,parameter.time_num);
load_mP=zeros(parameter.day_num,parameter.time_num);
Lflow_mP=zeros(parameter.day_num,parameter.time_num);
for i=1:parameter.day_num
    for j=1:parameter.time_num
        wind_mP(i,j)=wind_power((i-1)*parameter.time_num+j);
        photo_mP(i,j)=photo_power((i-1)*parameter.time_num+j);
        nuclear_mP(i,j)=nuclear_power((i-1)*parameter.time_num+j);
        hydro_mP(i,j)=hydro_power((i-1)*parameter.time_num+j);
        csp_mP(i,j)=csp_power((i-1)*parameter.time_num+j);
        load_mP(i,j)=load_power((i-1)*parameter.time_num+j);
        Lflow_mP(i,j)=Lflow((i-1)*parameter.time_num+j);
    end
end

Powerdata.wind=wind_mP;
Powerdata.photo=photo_mP;
Powerdata.nuclear=nuclear_mP;
Powerdata.hydro=hydro_mP;
Powerdata.csp=csp_mP;
Powerdata.load=load_mP;
Powerdata.Lflow=Lflow_mP;
Powerdata.generation_cv=generation_cv;
Powerdata.generation_gas=generation_gas;
Powerdata.generation_bio=generation_bio;
Powerdata.storage=storage;
Powerdata.coal_price=coal_price;
Powerdata.gas_price=gas_price;
Powerdata.bio_price=bio_price;
Powerdata.ce_price=ce_price;

Powerdata.cv_v=cv_v;
Powerdata.gas_v=gas_v;
Powerdata.bio_v=bio_v;
Powerdata.wind_v=wind_v;
Powerdata.photo_v=photo_v;
Powerdata.nuclear_v=nuclear_v;
Powerdata.hydro_v=hydro_v;
Powerdata.csp_v=csp_v;
end

