function [result] = UC_optimize(Powerdata)
%一年中机组组合优化
%输入：选取为典型场景的日期（包含四周）   发电数据{光伏、风电、水电、核电、负荷、净输出功率(365*24矩阵)、火电机组容量与煤耗}
%输出：火电启停、运行成本 虚拟机惩罚成本 弃光、弃风量 火电、光伏、风电、水电、核电发电量

global parameter;
dayindex=parameter.dayindex; %典型日选取
Y_PPV=Powerdata.photo; %全年光伏发电
Y_PWD=Powerdata.wind; %全年风电发电
Y_PHD=Powerdata.hydro; %全年水电
Y_PNC=Powerdata.nuclear; %全年核电
Y_PCS=Powerdata.csp; %全年光热
Y_PLD=Powerdata.load; %全年负荷
Y_PTL=Powerdata.Lflow; %全年联络线输出
generation_cv=Powerdata.generation_cv; %火电装机与煤耗
generation_gas=Powerdata.generation_gas; %燃气装机与气耗
generation_bio=Powerdata.generation_bio; %生物质装机与耗量
storage=Powerdata.storage; %生物质装机与耗量
coal_price=Powerdata.coal_price;
gas_price=Powerdata.gas_price;
bio_price=Powerdata.bio_price;
ce_price=Powerdata.ce_price;

result=struct; %初始化输出结果结构体

Pre_xCG=-ones(size(generation_cv,1),1); %输入第一天初始时刻的启停状态 若对其不做规定 则所有变量均赋值-1

%数据存储
x=[]; %机组启停变量
sg=[]; %出力不足
dg=[]; %出力剩余
costoutput=zeros(9,1);%存储一周输出启停、运行、惩罚成本
%存储弃光、弃风、火光风水核发电量
PV_cutl=[];
WD_cutl=[];
HD_cutl=[];
CS_cutl=[];
PCG=[];%燃煤
PGS=[];%燃气
PBO=[];%生物质
PESSC=[];%储能充电功率
PESSD=[];%储能放电功率
PPV=[];
PWD=[];
PHD=[];
PNC=[];
PCS=[];
    
for d=1:parameter.day_num%典型周中的每一天
    %从一年的数据中提取典型日的相关参数 光伏、风电、水电、核电、光热、负荷、联络线净输出功率
    D_PPV=Y_PPV(d,:);
    D_PWD=Y_PWD(d,:);
    D_PHD=Y_PHD(d,:);
    D_PNC=Y_PNC(d,:);
    D_PCS=Y_PCS(d,:);
    D_PLD=Y_PLD(d,:);
    D_PTL=Y_PTL(d,:);
    
    for t=1:24
        if isnan(D_PNC(t))
            D_PNC(t)=0;
        end
    end

    %进行一天内的机组组合优化
    [dayoutput] = UC_day(D_PPV,D_PWD,D_PHD,D_PNC,D_PCS,D_PLD,D_PTL,Pre_xCG,generation_cv,generation_gas,generation_bio,storage,coal_price,gas_price,bio_price,ce_price);

    %火电机组启停变量传递给下一天
    Pre_xCG=dayoutput.Last_XCG;
    %启停变量储存
    x=[x,dayoutput.x_CG];

    %不平衡出力统计
    sg=[sg dayoutput.P_SG];
    dg=[dg dayoutput.P_DG];

    %成本输出
    costoutput(1)=costoutput(1)+dayoutput.updowncost;
    costoutput(2)=costoutput(2)+dayoutput.operation_coal;
    costoutput(3)=costoutput(3)+dayoutput.penalty;
    costoutput(4)=costoutput(4)+dayoutput.Ecv;
    costoutput(5)=costoutput(5)+dayoutput.operation_gas;
    costoutput(6)=costoutput(6)+dayoutput.operation_bio;
    costoutput(7)=costoutput(7)+dayoutput.Egas;
    costoutput(8)=costoutput(8)+dayoutput.Ebio;
    costoutput(9)=costoutput(9)+dayoutput.ESS;

    %弃风弃光弃水输出
    PV_cutl=[PV_cutl dayoutput.PV_cutl];
    WD_cutl=[WD_cutl dayoutput.WD_cutl];
    HD_cutl=[HD_cutl dayoutput.HD_cutl];
    CS_cutl=[CS_cutl dayoutput.CS_cutl];

    %能源出力输出
    PCG=[PCG dayoutput.P_CG];
    PGS=[PGS dayoutput.P_GS];
    PBO=[PBO dayoutput.P_BO];
    PESSC=[PESSC dayoutput.P_ESSC];
    PESSD=[PESSD dayoutput.P_ESSD];
    PPV=[PPV dayoutput.P_PV];
    PWD=[PWD dayoutput.P_WD];
    PHD=[PHD dayoutput.P_HD];
    PNC=[PNC dayoutput.P_NC];
    PCS=[PCS dayoutput.P_CS];

end
   
%输出结构保存在结构体
result.updown_cost=costoutput(1);
result.operation_coal=costoutput(2);
result.penalty_cost=costoutput(3);
result.Ecv=costoutput(4);
result.operation_gas=costoutput(5);
result.operation_bio=costoutput(6);
result.Egas=costoutput(7);
result.Ebio=costoutput(8);
result.ESS=costoutput(9);

%弃风弃光保存
result.photo_cutl=PV_cutl;
result.wind_cutl=WD_cutl;
result.hydro_cutl=HD_cutl;
result.csp_cutl=CS_cutl;

%能源出力保存
result.P_CG=PCG;
result.P_GS=PGS;
result.P_BO=PBO;
result.P_ESSC=PESSC;
result.P_ESSD=PESSD;
result.P_PV=PPV;
result.P_WD=PWD;
result.P_HD=PHD;
result.P_NC=PNC;
result.P_CS=PCS;

%机组启停、出力不平衡保存
result.x=x;
result.sg=sg;
result.dg=dg;

%不平衡功率占比计算
result.sg_ratio=sum(sg)/(sum(Y_PLD(:))); %负荷
result.dg_ratio=sum(dg)/(sum(Y_PLD(:)));

end

