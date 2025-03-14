index=[2 3 4 5 7 8 10 12 15 16 17 20 21 22 23 24 25 27 28 29 30 31]; %调整省份编号
price=xlsread('0-分省逐年价格','B2:D32');
punish=xlsread('输入参数','B15:B18');% RMB/MWh
cost_b=3200000; % RMB/MW
cost_p=6000000; % RMB/MW
ann_b=0.1530;
ann_p=0.0884;
cost_decline=[0.62 0.55 0.47];
ramping=[0.60 	0.55 	0.85 	0.40 	0.70 	0.70 	0.60 	0.65 	0.40 	0.30 	0.40 	0.40 	0.60 	0.57 	0.60 	0.65 	0.66 	0.60 	0.50 	0.50 	0.80 	0.55];
coal_switch=50; %kg/MWh
coal_price=0.8; %RMB/kg
% E_cost1, energy consumption
% E_cost2, storage
% E_cost3, surplus

% baseline
basedata=xlsread('UC-8','A1:AI1');
demand=basedata(2);% MWh
E_CEF_base=basedata(3);% kg/MWh

E_coal_switch_base=(basedata(21)-basedata(1)*basedata(9))/314; %kg
E_coal_base=basedata(21)-E_coal_switch_base*(1000-coal_switch)/1000;% kg
E_carbon_base=2.85*E_coal_base;% kg
E_flexibility_base=sum(basedata(end-6:end-5));% 储能MWh
E_cost1_base=coal_price*E_coal_base+sum(basedata(end-3:end-2)); %RMB
E_cost2_base=basedata(end-1); %RMB
E_cost3_base=basedata(end);

PVtG_carbon=zeros(7,4);
PVtG_cost=zeros(7,4);

for j=1:7
    for k=1:4
                data=xlsread(strcat('UC-',num2str(j),'.xlsx'),1,strcat('A',num2str(k),':','AI',num2str(k)));
                E_CEF=data(3);% kg/MWh
                E_coal_switch=(data(21)-data(1)*data(9))/314; %kg
                E_coal=data(21)-E_coal_switch*(1000-coal_switch)/1000;% kg
                E_carbon=2.85*E_coal;% kg
%                 E_carbon=data(1);% kg
%                 E_coal=data(21); %kg
%                 E_coal_switch=(E_coal-data(1)*data(9))/314; %kg
                E_flexibility=sum(data(end-6:end-5));% 储能MWh
                E_cost1=coal_price*E_coal+sum(data(end-3:end-2)); %RMB
                E_cost2=data(end-1); %RMB
                E_cost3=data(end);

%                 
%                 cd C:\Users\LJR\Desktop\论文\24-光伏治沙\光伏治沙\风光氢氨规划软件\省内程序NM
%                 Profile_charge=xlsread(strcat('ESSC-',num2str(j),'.xlsx'),1,strcat('A',num2str(k*2-1),':','LXX',num2str(k*2)));
%                 Profile_discharge=xlsread(strcat('ESSD-',num2str(j),'.xlsx'),1,strcat('A',num2str(k*2-1),':','LXX',num2str(k*2)));
%                 Profile_chargebase_p=xlsread(strcat('储能充电功率',num2str(y*10+2020)),index(i),'A1:LXX1');
%                 Profile_chargebase_b=xlsread(strcat('储能充电功率',num2str(y*10+2020)),index(i),'A2:LXX2');
%                 Profile_dischargebase_p=xlsread(strcat('储能放电功率',num2str(y*10+2020)),index(i),'A1:LXX1');
%                 Profile_dischargebase_b=xlsread(strcat('储能放电功率',num2str(y*10+2020)),index(i),'A2:LXX2');
%                 
%                 1 按功率算，抽蓄过于离谱
%                 Profile_p=Profile_charge(1,:)*0.75-Profile_discharge(1,:)/0.75-(Profile_chargebase_p*0.75-Profile_dischargebase_p/0.75);
%                 Profile_b=Profile_charge(2,:)*0.9-Profile_discharge(2,:)/0.9-(Profile_chargebase_b*0.9-Profile_dischargebase_b/0.9);
%                 SOC_p=cumsum(Profile_p);
%                 SOC_b=cumsum(Profile_b);
%                 cap_p=max(abs(Profile_p));
%                 cap_b=max(abs(Profile_b));
%                 cap_p=((max(SOC_p)-min(SOC_p)))/8;
%                 cap_b=((max(SOC_b)-min(SOC_b)))/2;
%                 
%                 2 按能量算，又很小
%                 Profile_p_base=(Profile_chargebase_p*0.75-Profile_dischargebase_p/0.75);
%                 Profile_b_base=(Profile_chargebase_b*0.9-Profile_dischargebase_b/0.9);
%                 SOC_p_base=cumsum(Profile_p_base);
%                 SOC_b_base=cumsum(Profile_b_base);
%                 Profile_p=Profile_charge(1,:)*0.75-Profile_discharge(1,:)/0.75;
%                 Profile_b=Profile_charge(2,:)*0.9-Profile_discharge(2,:)/0.9;
%                 SOC_p=cumsum(Profile_p);
%                 SOC_b=cumsum(Profile_b);
%                 cap_p=max(-((max(SOC_p_base)-min(SOC_p_base))-(max(SOC_p)-min(SOC_p)))/8,0);
%                 cap_b=max(-((max(SOC_b_base)-min(SOC_b_base))-(max(SOC_b)-min(SOC_b)))/2,0);
%                 
%                 LCOS_p=cap_p*ann_p*cost_p;
%                 LCOS_b=cap_b*ann_b*cost_b*cost_decline(y);
%                 E_cost4=LCOS_p+LCOS_b;
%                 
%                 
%                 还是按辅助服务来算
%                 Profile_pbase=(Profile_chargebase_p-Profile_dischargebase_p);
%                 Profile_bbase=(Profile_chargebase_b-Profile_dischargebase_b);
%                 Profile_base=Profile_pbase+Profile_bbase;
%                 Profile_p=Profile_charge(1,:)-Profile_discharge(1,:);
%                 Profile_b=Profile_charge(2,:)-Profile_discharge(2,:);
%                 Profile=Profile_p+Profile_b;
%                 E_cost4_base=sum(abs(Profile_base)*ramping(i)*1e3);
%                 E_cost4=sum(abs(Profile)*ramping(i)*1e3);

                
                data=[demand E_carbon-E_carbon_base E_flexibility-E_flexibility_base E_cost1-E_cost1_base E_cost2-E_cost2_base E_cost3-E_cost3_base];
                PVtG_carbon(j,k)=(E_carbon_base-E_carbon)/1e9; %Mt
                PVtG_coal(j,k)=(E_coal_base-E_coal)/1e9; %Mt
                PVtG_cost1(j,k)=-(E_cost1-E_cost1_base+E_cost3-E_cost3_base)/1e9; %billionRMB
                PVtG_cost2(j,k)=-(E_cost2-E_cost2_base)/1e9; %billionRMB
                % 输出文件的名称
                filename =strcat('Power-',num2str(j),'.xlsx');
                % 工作表名称
                sheet = string(j);
                % 要写入的单元格起始位置（例如：'A1'）
                startCell = strcat('A',num2str(k));
                % 将数组写入 Excel 文件
                writematrix(data, filename, 'Sheet', sheet, 'Range', startCell);

    end
end


%% PV value
PV_value=zeros(7,4);
for j=1:7
    for k=1:4
        spotprice=xlsread(strcat('spotprice-',num2str(j),'.xlsx'),k,'A1:A8760');
        PV_profile=xlsread('6-新增光伏曲线',j,strcat('A',num2str(k)))*xlsread('6-新增光伏曲线',j,strcat('B',num2str(k),':','LXY',num2str(k)));% MW
        PV_value(j,k)=sum(spotprice.*PV_profile'*1e3)/1e9;
    end
end
