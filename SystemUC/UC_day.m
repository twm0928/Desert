function [dayoutput] = UC_day(D_PPV,D_PWD,D_PHD,D_PNC,D_PCS,D_PLD,D_PTL,Pre_xCG,generation_cv,generation_gas,generation_bio,storage,coal_price,gas_price,bio_price,ce_price)
%24小时的机组组合优化
%输入：一天中 光伏、风电、水电、核电、负荷、净输出功率、机组初始启停状态、机组容量与煤耗
%输出：一天中 火电启停、运行成本 虚拟机惩罚成本 弃光、弃风量 火电、光伏、风电、水电、核电发电量 一天中最后时刻火电机组启停状态

global parameter;

T=parameter.time_num; %一天内时段数
PCG_max=generation_cv(:,1);%火电装机
coal_cost=generation_cv(:,2);%煤耗
N_CG=size(PCG_max,1);%火电机组数量
PCG_min=parameter.minPCG*PCG_max;%火电机组最小出力
costU=parameter.upcost*PCG_max;%单次启动煤耗成本
costD=parameter.downcost*PCG_max;%单次停机煤耗成本
cv_daypower=parameter.averhour(1,1)/8760*PCG_max*24; %预估平均出力
cv_penalty=parameter.averhour(1,2); %出力偏差惩罚

%启停时间调整
TUmin=parameter.minTU;%最小开启时间
TDmin=parameter.minTD;%最小关闭时间

%燃气&生物质
PGS_max=generation_gas(:,1);%燃气装机
PGS_min=parameter.minPGS*PGS_max;%燃气机组最小出力
gas_cost=generation_gas(:,2);%燃气机组气耗
N_GS=size(PGS_max,1);%燃气机组数量
gs_daypower=parameter.averhour(2,1)/8760*PGS_max*24; %预估平均出力
gs_penalty=parameter.averhour(2,2); %出力偏差惩罚
PBO_max=generation_bio(:,1);%生物质装机
PBO_min=parameter.minPBO*PBO_max;%生物质机组最小出力
bio_cost=generation_bio(:,2);%生物质机组消耗
N_BO=size(PBO_max,1);%生物质机组数量
bo_daypower=parameter.averhour(3,1)/8760*PBO_max*24; %预估平均出力
bo_penalty=parameter.averhour(3,2); %出力偏差惩罚

%储能
PESS_max=storage(:,1);%储能最大功率
SOC_max=storage(:,2);%储能容量
ef_ESS=storage(:,3);%储能充放效率
PESS_Ecost=storage(:,4);%储能充放经济成本
N_ESS=size(PESS_max,1);%储能数量

%优化变量
P_CG=sdpvar(N_CG,T,'full');%火电
P_GS=sdpvar(N_GS,T,'full');%燃气
P_BO=sdpvar(N_BO,T,'full');%生物质
P_ESSC=sdpvar(N_ESS,T,'full');%储能充电功率
P_ESSD=sdpvar(N_ESS,T,'full');%储能放电功率
SOC=sdpvar(N_ESS,T+1,'full');%储能放电功率
P_PV=sdpvar(1,T,'full');%光伏
P_WD=sdpvar(1,T,'full');%风电
P_HD=sdpvar(1,T,'full');%水电
P_NC=sdpvar(1,T,'full');%核电
P_CS=sdpvar(1,T,'full');%光热
%原始数据存在偏差，依靠虚拟机组补偿偏差，保证功率平衡
P_SG=sdpvar(1,T,'full'); %供电侧虚拟机
P_DG=sdpvar(1,T,'full'); %需求侧虚拟机
x_CG=binvar(N_CG,T,'full');%火电启停状态
x_GS=binvar(N_GS,T,'full');%燃气启停状态
% x_BO=binvar(N_BO,T,'full');%生物质启停状态
costH=sdpvar(N_CG,T,'full');%启动成本
costJ=sdpvar(N_CG,T,'full');%停机成本
PV_cutl=sdpvar(1,T,'full');%弃光
WD_cutl=sdpvar(1,T,'full');%弃风
HD_cutl=sdpvar(1,T,'full');%弃水
CS_cutl=sdpvar(1,T,'full');%光热弃电
CG_less=sdpvar(N_CG,1,'full');%火电少出力
CG_more=sdpvar(N_CG,1,'full');%火电多出力
GS_less=sdpvar(N_GS,1,'full');%气电少出力
GS_more=sdpvar(N_GS,1,'full');%气电多出力
BO_less=sdpvar(N_BO,1,'full');%生物质少出力
BO_more=sdpvar(N_BO,1,'full');%生物质多出力

st=[];

%火电出力约束
for t=1:T
    for i=1:N_CG
        st=[st,x_CG(i,t)*PCG_min(i)<=P_CG(i,t)<=x_CG(i,t)*PCG_max(i)];
    end
end

%燃气机组出力约束
for t=1:T
    for i=1:N_GS
        st=[st,x_GS(i,t)*PGS_min(i)<=P_GS(i,t)<=x_GS(i,t)*PGS_max(i)];
    end
end

%生物质机组出力约束
for t=1:T
    for i=1:N_BO
%         st=[st,x_BO(i,t)*PBO_min(i)<=P_BO(i,t)<=x_BO(i,t)*PBO_max(i)];
        st=[st,PBO_min(i)<=P_BO(i,t)<=PBO_max(i)];
    end
end

%储能功率约束
for t=1:T
    for i=1:N_ESS
        st=[st,0<=P_ESSC(i,t)<=PESS_max(i)];
        st=[st,0<=P_ESSD(i,t)<=PESS_max(i)];
    end
end

%储能能量转换约束
for t=1:T
    for i=1:N_ESS
        st=[st,SOC(i,t+1)==SOC(i,t)+ef_ESS(i)*P_ESSC(i,t)-P_ESSD(i,t)/ef_ESS(i)];
    end
end
for i=1:N_ESS
    st=[st,SOC(i,T+1)==SOC(i,1)];
end

%储能容量约束
for t=1:T
    for i=1:N_ESS
        st=[st,0<=SOC(i,t)<=SOC_max(i)];
    end
end

%虚拟机功率非负
for t=1:T
    st=[st, 0<=P_SG(1,t)];
    st=[st, 0<=P_DG(1,t)];
end

%风光水核出力约束
for t=1:T
    st=[st,0<=P_PV(1,t)<=D_PPV(1,t)];
    st=[st,0<=P_WD(1,t)<=D_PWD(1,t)];
    st=[st,0<=P_HD(1,t)<=D_PHD(1,t)];
    st=[st,P_NC(1,t)==D_PNC(1,t)];
    st=[st,0<=P_CS(1,t)<=D_PCS(1,t)];
    st=[st,PV_cutl(1,t)==D_PPV(1,t)-P_PV(1,t)];
    st=[st,WD_cutl(1,t)==D_PWD(1,t)-P_WD(1,t)];
    st=[st,HD_cutl(1,t)==D_PHD(1,t)-P_HD(1,t)];
    st=[st,CS_cutl(1,t)==D_PCS(1,t)-P_CS(1,t)];
end

%功率平衡约束
for t=1:T
    st=[st,sum(P_CG(:,t))+sum(P_GS(:,t))+sum(P_BO(:,t))+sum(P_ESSD(:,t))-sum(P_ESSC(:,t))+P_PV(1,t)+P_WD(1,t)+P_HD(1,t)+P_NC(1,t)+P_CS(1,t)+P_SG(1,t)==D_PLD(1,t)+D_PTL(1,t)+P_DG(1,t)];
end

%火电机组启停时间约束
for t=2:T
    for i=1:N_CG
        indicator=x_CG(i,t)-x_CG(i,t-1);
        range=t:min(T,t+TUmin-1);
        st=[st,x_CG(i,range)>=indicator];
    end
end
for t=2:T
    for i=1:N_CG
        indicator=x_CG(i,t-1)-x_CG(i,t);
        range=t:min(T,t+TDmin-1);
        st=[st,x_CG(i,range)<=1-indicator];
    end
end

%各时刻是否产生启停成本判断
for t=1:T   
    for i=1:N_CG
        st=[st,costH(i,t)>=0]; 
        st=[st,costJ(i,t)>=0];
        if t==1
            st=[st,costH(i,t)==0]; 
            st=[st,costJ(i,t)==0];
        end
    end
end
for t=2:T
   for i=1:N_CG
         st=[st,costH(i,t)>=costU(i,1)*(x_CG(i,t)-x_CG(i,t-1))];
         st=[st,costJ(i,t)>=costD(i,1)*(x_CG(i,t-1)-x_CG(i,t))];
   end
end

%机组启停状态为前一天最后时刻的状态
if Pre_xCG(1,1)~=-1 %若对初始时刻状态变量不做规定 则状态变量均为-1 此时本约束无效
    for i=1:N_CG
        st=[st,x_CG(i,1)==Pre_xCG(i,1)];
    end
end

%启停煤耗累加
updown_cost=0; %启停成本初始化
for t=1:T
    for i=1:N_CG
        updown_cost=updown_cost+costH(i,t)+costJ(i,t);
    end
end

%运行成本以及惩罚成本累加
operation_coal=0; %运行成本初始化
operation_gas=0;
operation_bio=0;
operation_ESS=0;%储能运行经济成本初始化
operation_penalty=0; %惩罚成本初始化
WDcutl_penalty=0;
PVcutl_penalty=0;
HDcutl_penalty=0;
CScutl_penalty=0;

%碳排放成本
ce_Ecoal=0;
ce_Egas=0;
ce_Ebio=0;

for t=1:T
    %虚拟机惩罚成本
    operation_penalty=operation_penalty+parameter.penalty*(P_SG(1,t)+P_DG(1,t));
    %弃风惩罚成本
    WDcutl_penalty=WDcutl_penalty+parameter.WD_cutl_penalty*WD_cutl(1,t);
    %弃光惩罚成本
    PVcutl_penalty=PVcutl_penalty+parameter.PV_cutl_penalty*PV_cutl(1,t);
    %弃水惩罚成本
    HDcutl_penalty=WDcutl_penalty+parameter.HD_cutl_penalty*HD_cutl(1,t);
    %光热弃电惩罚成本
    CScutl_penalty=CScutl_penalty+parameter.CS_cutl_penalty*CS_cutl(1,t);
    
    %火电运行成本
    for i=1:N_CG
        operation_coal=operation_coal+P_CG(i,t)*coal_cost(i);
        ce_Ecoal=ce_Ecoal+P_CG(i,t)*coal_cost(i)*parameter.Cemission*ce_price;
    end
    
    %燃气运行成本
    for i=1:N_GS
        operation_gas=operation_gas+P_GS(i,t)*gas_cost(i);
        ce_Egas=ce_Egas+P_GS(i,t)*parameter.GSemission*ce_price;
    end
    
    %生物质运行成本
    for i=1:N_BO
        operation_bio=operation_bio+P_BO(i,t)*bio_cost(i);
        ce_Ebio=ce_Ebio+P_BO(i,t)*parameter.BOemission*ce_price;
    end
    
    %储能运行经济成本
    for i=1:N_ESS
        operation_ESS=operation_ESS+P_ESSC(i,t)*PESS_Ecost(i)+P_ESSD(i,t)*PESS_Ecost(i);
    end
end

% 出力偏差惩罚
for i=1:N_CG
    st=[st,sum(P_CG(i,:))+CG_less(i,1)==cv_daypower(i,1)+CG_more(i,1)];
    st=[st,CG_less(i,1)>=0];
    st=[st,CG_more(i,1)>=0];
end
cv_dvpenalty=cv_penalty*(sum(CG_less(:,1))+sum(CG_more(:,1)));
for i=1:N_GS
    st=[st,sum(P_GS(i,:))+GS_less(i,1)==gs_daypower(i,1)+GS_more(i,1)];
    st=[st,GS_less(i,1)>=0];
    st=[st,GS_more(i,1)>=0];
end
gs_dvpenalty=gs_penalty*(sum(GS_less(:,1))+sum(GS_more(:,1)));
for i=1:N_BO
    st=[st,sum(P_BO(i,:))+BO_less(i,1)==bo_daypower(i,1)+BO_more(i,1)];
    st=[st,BO_less(i,1)>=0];
    st=[st,BO_more(i,1)>=0];
end
bo_dvpenalty=bo_penalty*(sum(BO_less(:,1))+sum(BO_more(:,1)));

%机组经济成本计算
operation_Ecv=(updown_cost+operation_coal)*coal_price;
operation_Egas=operation_gas*gas_price;
operation_Ebio=operation_bio*bio_price;

objective=operation_Ecv+operation_Egas+operation_Ebio+cv_dvpenalty+gs_dvpenalty+bo_dvpenalty+ce_Ecoal+ce_Egas+ce_Ebio+operation_ESS+operation_penalty+WDcutl_penalty+PVcutl_penalty+HDcutl_penalty+CScutl_penalty;%目标函数包括启停成本、煤耗成本、虚拟机惩罚成本
ops = sdpsettings('solver','cplex','verbose',2);
ops.cplex.mip.tolerances.mipgap=1e-3; 
Solver= optimize(st,objective,ops);

%启停煤耗、运行煤耗、虚拟机惩罚成本 火电机组经济成本
dayoutput.updowncost=value(updown_cost);
dayoutput.operation_coal=value(operation_coal);
dayoutput.penalty=value(operation_penalty);
dayoutput.Ecv=value(operation_Ecv);
dayoutput.operation_gas=value(operation_gas);
dayoutput.operation_bio=value(operation_bio);
dayoutput.Egas=value(operation_Egas);
dayoutput.Ebio=value(operation_Ebio);
dayoutput.ESS=value(operation_ESS);

%一天中的弃电量
dayoutput.PV_cutl=value(PV_cutl);
dayoutput.WD_cutl=value(WD_cutl);
dayoutput.HD_cutl=value(HD_cutl);
dayoutput.CS_cutl=value(CS_cutl);

%一天中各能源发电量
dayoutput.P_CG=value(P_CG);
dayoutput.P_GS=value(P_GS);
dayoutput.P_BO=value(P_BO);
dayoutput.P_ESSC=value(P_ESSC);
dayoutput.P_ESSD=value(P_ESSD);
dayoutput.P_PV=value(P_PV);
dayoutput.P_WD=value(P_WD);
dayoutput.P_HD=value(P_HD);
dayoutput.P_NC=value(P_NC);
dayoutput.P_CS=value(P_CS);

%所有火电机组最后时刻的启停状态
dayoutput.x_CG=value(x_CG);
dayoutput.Last_XCG=value(x_CG(:,T));

%松弛变量（不平衡出力）
dayoutput.P_SG=value(P_SG);
dayoutput.P_DG=value(P_DG);

end
