clear;
clc;
%% parameters
M1 = 1e10;
M2 = 1e7;
T = 8760;
% PV
cap_PV = 1.28*1e6; % kW
% HS
HSrate = 0.95; % 效率
% ES
ESrate = 0.95; % 效率
EShour = 2;
% EL
P2G = 5; % kWh/Nm3
G2W = 25/11200; % Nm3/Nm3
% hydrogen production
% 可以作为大程序的接口变量，利用分配系数估算年产量
production_h = 4.5e8; % 年产量约4万吨下限
% economic
rateDiscount = 0.06; % 折现率
OperationYears = [20,20,20,20]; % PV,EL,HS,ES
ann = 1./(1/rateDiscount-1./ (rateDiscount.* (1+rateDiscount).^OperationYears));
Invest = [4200*cap_PV,2100,210,1000]; % kW,kW,Nm3,kWh
OM = [2,3,3,3]/100; % 百分比
priceH2O = 6; % 水价，典型值9元/吨
%% 拓扑部分
% 研究区域经纬度范围
loc=[106 38;112 41.5];%510km(102),330km(77)row=5;
% 水域经纬度范围
waterarea=[106.1 107;40 41];
% 沙漠经纬度范围
desert=[107.8 108.5;39.5 40.4];
% 坐标变换
col=(loc(2,2)-loc(1,2))*110/5;
row=(loc(2,1)-loc(1,1))*85/5;
row_ws=ceil((waterarea(1,1)-loc(1,1))*85/5);
row_we=ceil((waterarea(1,2)-loc(1,1))*85/5);
col_ws=ceil((waterarea(2,1)-loc(1,2))*110/5);
col_we=ceil((waterarea(2,2)-loc(1,2))*110/5);
row_ds=ceil((desert(1,1)-loc(1,1))*85/5);
row_de=ceil((desert(1,2)-loc(1,1))*85/5);
col_ds=ceil((desert(2,1)-loc(1,2))*110/5);
col_de=ceil((desert(2,2)-loc(1,2))*110/5);
% 参数
node=row*col;
branch=2*node;
% OgStH坐标点及参数
eligible=xlsread('eligible','B2:C4725');
YN=zeros(col,row);
for c=1:col
    for r=1:row
        for i=1:length(eligible)
            if (eligible(i,1)-loc(1,1))*85/5>=r && (eligible(i,1)-loc(1,1))*85/5<r+1 && (eligible(i,2)-loc(1,2))*110/5>=c && (eligible(i,2)-loc(1,2))*110/5<c+1
                YN(c,r)=1;
            end
        end
    end
end        
N_S=zeros(col,row);
N_S(col_ds:col_de,row_ds:row_de)=1;
N_S=production_h/8760*YN.*N_S;
F_D=N_S*G2W;
% 障碍坐标点
barrier=M2*ones(col,row);
% 水源坐标点及参数
F_S=zeros(col,row);
F_S(col_ws:col_we,row_ws:row_we)=10000;
% 负荷坐标点及参数
N_D=zeros(col,row);
demand=xlsread('demand','B2:D14');
demand=demand(1:11,:);
FLH_D=8000;% 工厂开工小时数
for c=1:col
    for r=1:row
        for i=1:length(demand(:,1))
            if loc(1,1)+(r-1)/85*5<=demand(i,1)
                if loc(1,1)+r/85*5>demand(i,1)
                    if loc(1,2)+(c-1)/110*5<=demand(i,2)
                        if loc(1,2)+c/110*5>demand(i,2)
                            N_D(c,r)=N_D(c,r)+demand(i,3)*1e4/FLH_D;
                        end
                    end
                end
            end
        end
    end
end
num_OgStH = ceil(sum(sum(N_D))/(production_h/8760))*1.2;
%% OgStH
tic;
disp('建立优化模型');
solar = xlsread('solar.xlsx');
% Variables
% X=[g_gen,g_in,g_out,g_HS,e_in,e_out,e_ES,w_con,cap_EL,cap_HS,cap_ES];
%   [Nm3,  Nm3, Nm3,  Nm3, kWh, kWh,  kWh, Nm3,  kW,    Nm3,   kW];
g_gen = zeros(1,T);
g_in = zeros(1,T);
g_out = zeros(1,T);
g_HS = zeros(1,T);
e_in = zeros(1,T);
e_out = zeros(1,T);
e_ES = zeros(1,T);
w_con = zeros(1,T);
charge = zeros(1,T);
cap_EL = zeros(1,1);
cap_HS = zeros(1,1);
cap_ES = zeros(1,1);

sigma=zeros(col,row);
flag_ws=zeros(col,row);
flag_w=zeros(col,row);
flag_h=zeros(col,row);
pw=zeros(col,row);
ph=zeros(col,row);
n_up=zeros(col,row);
n_left=zeros(col,row);
n_upleft=zeros(col,row);
n_upright=zeros(col,row);
f_up=zeros(col,row);
f_left=zeros(col,row);
f_upleft=zeros(col,row);
f_upright=zeros(col,row);

f_s=zeros(col,row);
f_d=zeros(col,row);
n_s=zeros(col,row);
n_up_abs=zeros(col,row);
n_left_abs=zeros(col,row);
n_upleft_abs=zeros(col,row);
n_upright_abs=zeros(col,row);
f_up_abs=zeros(col,row);
f_left_abs=zeros(col,row);
f_upleft_abs=zeros(col,row);
f_upright_abs=zeros(col,row);

lb = zeros(9*T+3+22*node,1);
ub = zeros(9*T+3+22*node,1);
ctype = char(9*T+3+22*node,1);

count = 0;
for t=1:T
    count=count+1;
    g_gen(1,t)=count;
    lb(count)=0;
    ub(count)=M1;
    ctype(count)='C';
    g_in(1,t)=count+T;
    lb(count+T)=0;
    ub(count+T)=M1;
    ctype(count+T)='C';
    g_out(1,t)=count+2*T;
    lb(count+2*T)=0;
    ub(count+2*T)=M1;
    ctype(count+2*T)='C';
    g_HS(1,t)=count+3*T;
    lb(count+3*T)=0;
    ub(count+3*T)=M1;
    ctype(count+3*T)='C';
    e_in(1,t)=count+4*T;
    lb(count+4*T)=0;
    ub(count+4*T)=M1;
    ctype(count+4*T)='C';
    e_out(1,t)=count+5*T;
    lb(count+5*T)=0;
    ub(count+5*T)=M1;
    ctype(count+5*T)='C';
    e_ES(1,t)=count+6*T;
    lb(count+6*T)=0;
    ub(count+6*T)=M1;
    ctype(count+6*T)='C';
    w_con(1,t)=count+7*T;
    lb(count+7*T)=0;
    ub(count+7*T)=M1;
    ctype(count+7*T)='C';
    charge(1,t)=count+8*T;
    lb(count+8*T)=0;
    ub(count+8*T)=M1;
    ctype(count+8*T)='B';
end
count = count+8*T;
count = count+1;
cap_EL(1)=count;
lb(count)=0;
ub(count)=M1;
ctype(count)='C';
cap_HS(1)=count+1;
lb(count+1)=0;
ub(count+1)=M1;
ctype(count+1)='C';
cap_ES(1)=count+2;
lb(count+2)=0;
ub(count+2)=M1;
ctype(count+2)='C';
count=count+2;
for c=1:col
    for r=1:row
        count=count+1;
        sigma(c,r)=count;
        lb(count)=0;
        ub(count)=1;
        ctype(count)='B';
        n_up(c,r)=count+node;
        lb(count+node)=-barrier(c,r);
        ub(count+node)=barrier(c,r);
        ctype(count+node)='C';        
        n_left(c,r)=count+node*2;
        lb(count+node*2)=-barrier(c,r);
        ub(count+node*2)=barrier(c,r);
        ctype(count+node*2)='C';
        f_up(c,r)=count+node*3;
        lb(count+node*3)=-barrier(c,r);
        ub(count+node*3)=barrier(c,r);
        ctype(count+node*3)='C';
        f_left(c,r)=count+node*4;
        lb(count+node*4)=-barrier(c,r);
        ub(count+node*4)=barrier(c,r);
        ctype(count+node*4)='C';
        f_s(c,r)=count+node*5;
        lb(count+node*5)=0;
        ub(count+node*5)=F_S(c,r);
        ctype(count+node*5)='C';
        f_d(c,r)=count+node*6;
        lb(count+node*6)=0;
        ub(count+node*6)=F_D(c,r);
        ctype(count+node*6)='C';
        n_s(c,r)=count+node*7;
        lb(count+node*7)=0;
        ub(count+node*7)=N_S(c,r);
        ctype(count+node*7)='C';
        n_up_abs(c,r)=count+node*8;
        lb(count+node*8)=0;
        ub(count+node*8)=barrier(c,r);
        ctype(count+node*8)='C';        
        n_left_abs(c,r)=count+node*9;
        lb(count+node*9)=0;
        ub(count+node*9)=barrier(c,r);
        ctype(count+node*9)='C';
        f_up_abs(c,r)=count+node*10;
        lb(count+node*10)=0;
        ub(count+node*10)=barrier(c,r);
        ctype(count+node*10)='C';
        f_left_abs(c,r)=count+node*11;
        lb(count+node*11)=0;
        ub(count+node*11)=barrier(c,r);
        ctype(count+node*11)='C';
        n_upleft(c,r)=count+node*12;
        lb(count+node*12)=-barrier(c,r);
        ub(count+node*12)=barrier(c,r);
        ctype(count+node*12)='C';        
        n_upright(c,r)=count+node*13;
        lb(count+node*13)=-barrier(c,r);
        ub(count+node*13)=barrier(c,r);
        ctype(count+node*13)='C';
        f_upleft(c,r)=count+node*14;
        lb(count+node*14)=-barrier(c,r);
        ub(count+node*14)=barrier(c,r);
        ctype(count+node*14)='C';
        f_upright(c,r)=count+node*15;
        lb(count+node*15)=-barrier(c,r);
        ub(count+node*15)=barrier(c,r);
        ctype(count+node*15)='C';
        n_upleft_abs(c,r)=count+node*16;
        lb(count+node*16)=-barrier(c,r);
        ub(count+node*16)=barrier(c,r);
        ctype(count+node*16)='C';        
        n_upright_abs(c,r)=count+node*17;
        lb(count+node*17)=-barrier(c,r);
        ub(count+node*17)=barrier(c,r);
        ctype(count+node*17)='C';
        f_upleft_abs(c,r)=count+node*18;
        lb(count+node*18)=-barrier(c,r);
        ub(count+node*18)=barrier(c,r);
        ctype(count+node*18)='C';
        f_upright_abs(c,r)=count+node*19;
        lb(count+node*19)=-barrier(c,r);
        ub(count+node*19)=barrier(c,r);
        ctype(count+node*19)='C';
        flag_w(c,r)=count+node*20;
        lb(count+node*20)=0;
        ub(count+node*20)=1;
        ctype(count+node*20)='B';
        pw(c,r)=count+node*21;
        lb(count+node*21)=0;
        ub(count+node*21)=10;
        ctype(count+node*21)='C';
        ph(c,r)=count+node*22;
        lb(count+node*22)=18;
        ub(count+node*22)=20;
        ctype(count+node*22)='C';
        flag_h(c,r)=count+node*23;
        lb(count+node*23)=0;
        ub(count+node*23)=1;
        ctype(count+node*23)='B';
        flag_ws(c,r)=count+node*24;
        lb(count+node*24)=0;
        ub(count+node*24)=1;
        ctype(count+node*24)='B';
    end
end
count=count+node*24;
num=count;
% constraints
Aeq=sparse(4*T+1,num);
Beq=sparse(4*T+1,1);
req=0;
% hydrogen storage
% g_gen=g_in
Aeq(req+1:req+T,g_gen(1,1):g_gen(1,T))=eye(T);
Aeq(req+1:req+T,g_in(1,1):g_in(1,T))=-eye(T);
req=req+T;
% SOC(t)=SOC(t-1)+g_in(t)*eff-g_out(t)/eff
Aeq(req+1,g_HS(1,1))=1;
Aeq(req+1,g_HS(1,T))=-1;
Aeq(req+1,g_out(1,1))=1/HSrate;
Aeq(req+1,g_in(1,1))=-1*HSrate;
Aeq(req+2:req+T,g_HS(1,2):g_HS(1,T))=eye(T-1);
Aeq(req+2:req+T,g_HS(1,1):g_HS(1,T-1))=Aeq(req+2:req+T,g_HS(1,1):g_HS(1,T-1))-eye(T-1);
Aeq(req+2:req+T,g_out(1,2):g_out(1,T))=eye(T-1)/HSrate;
Aeq(req+2:req+T,g_in(1,2):g_in(1,T))=-eye(T-1)*HSrate;
req=req+T;
% g_out(t)=g_out(t-1) 稳定供氢
Aeq(req+1,g_out(1,1))=1;
Aeq(req+1,g_out(1,T))=-1;
Aeq(req+2:req+T,g_out(1,2):g_out(1,T))=eye(T-1);
Aeq(req+2:req+T,g_out(1,1):g_out(1,T-1))=Aeq(req+2:req+T,g_out(1,1):g_out(1,T-1))-eye(T-1);
req=req+T;
% energy storage
% SOC(t)=SOC(t-1)+e_in(t)*eff-e_out(t)/eff
Aeq(req+1,e_ES(1,1))=1;
Aeq(req+1,e_ES(1,T))=-1;
Aeq(req+1,e_out(1,1))=1/ESrate;
Aeq(req+1,e_in(1,1))=-1*ESrate;
Aeq(req+2:req+T,e_ES(1,2):e_ES(1,T))=eye(T-1);
Aeq(req+2:req+T,e_ES(1,1):e_ES(1,T-1))=Aeq(req+2:req+T,e_ES(1,1):e_ES(1,T-1))-eye(T-1);
Aeq(req+2:req+T,e_out(1,2):e_out(1,T))=eye(T-1)/ESrate;
Aeq(req+2:req+T,e_in(1,2):e_in(1,T))=-eye(T-1)*ESrate;
req=req+T;
% 日内平衡
for d = 1:floor(T/24)
    Aeq(req+1,e_ES(1,(d-1)*24+1))=1;
    Aeq(req+1,e_ES(1,d*24))=-1;
    req=req+1;
end
% water consumption
for t = 1:T
    Aeq(req+1,w_con(1,t))=1;
    Aeq(req+1,g_gen(1,t))=-G2W;
    Beq(req+1)=0;
    req=req+1;
end
rineq=0;
Aineq=sparse(10*T+1,num);
Bineq=sparse(10*T+1,1);
% energy storage
% e_in<=Cap_ES
Aineq(rineq+1:rineq+T,e_in(1,1):e_in(1,T))=eye(T);
Bineq(rineq+1:rineq+T)=cap_PV*solar;
rineq=rineq+T;
% e_in<=PV_out
Aineq(rineq+1:rineq+T,e_in(1,1):e_in(1,T))=eye(T);
Aineq(rineq+1:rineq+T,cap_ES(1))=-1;
rineq=rineq+T;
% e_out<=Cap_ES
Aineq(rineq+1:rineq+T,e_out(1,1):e_out(1,T))=eye(T);
Aineq(rineq+1:rineq+T,cap_ES(1))=-1;
rineq=rineq+T;
% e_ES<=Cap_ES*EShour
Aineq(rineq+1:rineq+T,e_ES(1,1):e_ES(1,T))=eye(T);
Aineq(rineq+1:rineq+T,cap_ES(1))=-1*EShour;
rineq=rineq+T;
% -M*charge<=e_in<=M*charge
% -M*(1-charge)<=e_out<=M*(1-charge);
Aineq(rineq+1:rineq+T,e_in(1,1):e_in(1,T))=eye(T);
Aineq(rineq+1:rineq+T,charge(1,1):charge(1,T))=-M1*eye(T);
rineq=rineq+T;
Aineq(rineq+1:rineq+T,e_in(1,1):e_in(1,T))=-eye(T);
Aineq(rineq+1:rineq+T,charge(1,1):charge(1,T))=M1*eye(T);
rineq=rineq+T;
Aineq(rineq+1:rineq+T,e_out(1,1):e_out(1,T))=eye(T);
Aineq(rineq+1:rineq+T,charge(1,1):charge(1,T))=M1*eye(T);
Bineq(rineq+1:rineq+T)=M1;
rineq=rineq+T;
Aineq(rineq+1:rineq+T,e_out(1,1):e_out(1,T))=-eye(T);
Aineq(rineq+1:rineq+T,charge(1,1):charge(1,T))=M1*eye(T);
Bineq(rineq+1:rineq+T)=M1;
rineq=rineq+T;
% hydrogen production
% PDC<=PV_out-e_in+e_out
for t = 1:T
    Aineq(rineq+1,g_gen(1,t))=P2G;
    Aineq(rineq+1,e_in(1,t))=1;
    Aineq(rineq+1,e_out(1,t))=-1;
    Bineq(rineq+1)=cap_PV*solar(t);
    rineq=rineq+1;
end
% PDC<=cap_EL
for t = 1:T
    Aineq(rineq+1,g_gen(1,t))=P2G;
    Aineq(rineq+1,cap_EL(1))=-1;
    rineq=rineq+1;
end
% hydrogen storage
Aineq(rineq+1:rineq+T,cap_HS(1))=-1;
Aineq(rineq+1:rineq+T,g_HS(1,1):g_HS(1,T))=eye(T);
rineq=rineq+T;
% 产量约束
Aineq(rineq+1,g_gen(1,1):g_gen(1,T))=-1;
Bineq(rineq+1,1)=-production_h/(8760/T);%约4万吨/年产量下限
rineq=rineq+1;
%% 拓扑部分
%% 氢
for c=2:col-1
    for r=2:row-1
        Aeq(req+1,n_up(c,r))=-1;
        Aeq(req+1,n_left(c,r))=-1;
        Aeq(req+1,n_upleft(c,r))=-1;
        Aeq(req+1,n_upright(c,r))=-1;
        Aeq(req+1,n_up(c,r-1))=1;
        Aeq(req+1,n_left(c+1,r))=1;
        Aeq(req+1,n_upright(c-1,r-1))=1;
        Aeq(req+1,n_upleft(c+1,r-1))=1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=1
    for r=2:row-1
        Aeq(req+1,n_up(c,r))=-1;
        Aeq(req+1,n_left(c+1,r))=1;
        Aeq(req+1,n_upright(c,r))=-1;
        Aeq(req+1,n_up(c,r-1))=1;
        Aeq(req+1,n_upleft(c+1,r-1))=1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=col
    for r=2:row-1
        Aeq(req+1,n_up(c,r))=-1;
        Aeq(req+1,n_upleft(c,r))=-1;
        Aeq(req+1,n_up(c,r-1))=1;
        Aeq(req+1,n_left(c,r))=-1;
        Aeq(req+1,n_upright(c-1,r-1))=1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=2:col-1
    for r=1
        Aeq(req+1,n_up(c,r))=-1;
        Aeq(req+1,n_left(c,r))=-1;
        Aeq(req+1,n_upleft(c,r))=-1;
        Aeq(req+1,n_upright(c,r))=-1;
        Aeq(req+1,n_left(c+1,r))=1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=2:col-1
    for r=row
        Aeq(req+1,n_left(c,r))=-1;
        Aeq(req+1,n_up(c,r-1))=1;
        Aeq(req+1,n_left(c+1,r))=1;
        Aeq(req+1,n_upright(c-1,r-1))=1;
        Aeq(req+1,n_upleft(c+1,r-1))=1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=1
    for r=1
        Aeq(req+1,n_up(c,r))=-1;
        Aeq(req+1,n_left(c+1,r))=1;
        Aeq(req+1,n_upright(c,r))=-1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=1
    for r=row
        Aeq(req+1,n_left(c+1,r))=1;
        Aeq(req+1,n_up(c,r-1))=1;
        Aeq(req+1,n_upleft(c+1,r-1))=1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=col
    for r=1
        Aeq(req+1,n_up(c,r))=-1;
        Aeq(req+1,n_upleft(c,r))=-1;
        Aeq(req+1,n_left(c,r))=-1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
for c=col
    for r=row
        Aeq(req+1,n_up(c,r-1))=1;
        Aeq(req+1,n_left(c,r))=-1;
        Aeq(req+1,n_upright(c-1,r-1))=1;
        Aeq(req+1,n_s(c,r))=1;
        Beq(req+1,1)=N_D(c,r);
        req=req+1;
    end
end
%% 水
for c=2:col-1
    for r=2:row-1
        Aeq(req+1,f_up(c,r))=-1;
        Aeq(req+1,f_left(c,r))=-1;
        Aeq(req+1,f_upleft(c,r))=-1;
        Aeq(req+1,f_upright(c,r))=-1;
        Aeq(req+1,f_up(c,r-1))=1;
        Aeq(req+1,f_left(c+1,r))=1;
        Aeq(req+1,f_upright(c-1,r-1))=1;
        Aeq(req+1,f_upleft(c+1,r-1))=1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=1
    for r=2:row-1
        Aeq(req+1,f_up(c,r))=-1;
        Aeq(req+1,f_left(c+1,r))=1;
        Aeq(req+1,f_upright(c,r))=-1;
        Aeq(req+1,f_up(c,r-1))=1;
        Aeq(req+1,f_upleft(c+1,r-1))=1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=col
    for r=2:row-1
        Aeq(req+1,f_up(c,r))=-1;
        Aeq(req+1,f_upleft(c,r))=-1;
        Aeq(req+1,f_up(c,r-1))=1;
        Aeq(req+1,f_left(c,r))=-1;
        Aeq(req+1,f_upright(c-1,r-1))=1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=2:col-1
    for r=1
        Aeq(req+1,f_up(c,r))=-1;
        Aeq(req+1,f_left(c,r))=-1;
        Aeq(req+1,f_upleft(c,r))=-1;
        Aeq(req+1,f_upright(c,r))=-1;
        Aeq(req+1,f_left(c+1,r))=1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=2:col-1
    for r=row
        Aeq(req+1,f_left(c,r))=-1;
        Aeq(req+1,f_up(c,r-1))=1;
        Aeq(req+1,f_left(c+1,r))=1;
        Aeq(req+1,f_upright(c-1,r-1))=1;
        Aeq(req+1,f_upleft(c+1,r-1))=1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=1
    for r=1
        Aeq(req+1,f_up(c,r))=-1;
        Aeq(req+1,f_left(c+1,r))=1;
        Aeq(req+1,f_upright(c,r))=-1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=1
    for r=row
        Aeq(req+1,f_left(c+1,r))=1;
        Aeq(req+1,f_up(c,r-1))=1;
        Aeq(req+1,f_upleft(c+1,r-1))=1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=col
    for r=1
        Aeq(req+1,f_up(c,r))=-1;
        Aeq(req+1,f_upleft(c,r))=-1;
        Aeq(req+1,f_left(c,r))=-1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
for c=col
    for r=row
        Aeq(req+1,f_up(c,r-1))=1;
        Aeq(req+1,f_left(c,r))=-1;
        Aeq(req+1,f_upright(c-1,r-1))=1;
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,f_s(c,r))=1;
        req=req+1;
    end
end
% n_s=f_d
for c=1:col
    for r=1:row
        Aeq(req+1,f_d(c,r))=-1;
        Aeq(req+1,n_s(c,r))=G2W;
        Beq(req+1,1)=0;
        req=req+1;
    end
end
%%
% n_s<=g_out
for c=1:col
    for r=1:row
        Aineq(rineq+1,n_s(c,r))=1;
        Aineq(rineq+1,g_out(1,1))=-1*YN(c,r);
        rineq=rineq+1;
    end
end
% f_d
Aineq(rineq+1:rineq+node,f_d(1,1):f_d(col,row))=eye(node);
Aineq(rineq+1:rineq+node,sigma(1,1):sigma(col,row))=-diag(reshape(F_D',node,1));
rineq=rineq+node;
% n_s
Aineq(rineq+1:rineq+node,n_s(1,1):n_s(col,row))=eye(node);
Aineq(rineq+1:rineq+node,sigma(1,1):sigma(col,row))=-diag(reshape(N_S',node,1));
rineq=rineq+node;
% abs
Aineq(rineq+1:rineq+node,n_up(1,1):n_up(col,row))=eye(node);
Aineq(rineq+1:rineq+node,n_up_abs(1,1):n_up_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_up(1,1):n_up(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,n_up_abs(1,1):n_up_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_left(1,1):n_left(col,row))=eye(node);
Aineq(rineq+1:rineq+node,n_left_abs(1,1):n_left_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_left(1,1):n_left(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,n_left_abs(1,1):n_left_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_up(1,1):f_up(col,row))=eye(node);
Aineq(rineq+1:rineq+node,f_up_abs(1,1):f_up_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_up(1,1):f_up(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,f_up_abs(1,1):f_up_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_left(1,1):f_left(col,row))=eye(node);
Aineq(rineq+1:rineq+node,f_left_abs(1,1):f_left_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_left(1,1):f_left(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,f_left_abs(1,1):f_left_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_upleft(1,1):n_upleft(col,row))=eye(node);
Aineq(rineq+1:rineq+node,n_upleft_abs(1,1):n_upleft_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_upleft(1,1):n_upleft(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,n_upleft_abs(1,1):n_upleft_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_upright(1,1):n_upright(col,row))=eye(node);
Aineq(rineq+1:rineq+node,n_upright_abs(1,1):n_upright_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_upright(1,1):n_upright(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,n_upright_abs(1,1):n_upright_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_upleft(1,1):f_upleft(col,row))=eye(node);
Aineq(rineq+1:rineq+node,f_upleft_abs(1,1):f_upleft_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_upleft(1,1):f_upleft(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,f_upleft_abs(1,1):f_upleft_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_upright(1,1):f_upright(col,row))=eye(node);
Aineq(rineq+1:rineq+node,f_upright_abs(1,1):f_upright_abs(col,row))=-eye(node);
rineq=rineq+node;
Aineq(rineq+1:rineq+node,f_upright(1,1):f_upright(col,row))=-eye(node);
Aineq(rineq+1:rineq+node,f_upright_abs(1,1):f_upright_abs(col,row))=-eye(node);
Bineq(rineq+1:rineq+node,1)=0;
rineq=rineq+node;
% sum(abs)<=flag
Aineq(rineq+1:rineq+node,f_up_abs(1,1):f_up_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,f_left_abs(1,1):f_left_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,f_upright_abs(1,1):f_upright_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,f_upleft_abs(1,1):f_upleft_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,flag_w(1,1):flag_w(col,row))=-M2*eye(node);
Bineq(rineq+1:rineq+node,1)=0;
rineq=rineq+node;
Aineq(rineq+1:rineq+node,n_up_abs(1,1):n_up_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,n_left_abs(1,1):n_left_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,n_upright_abs(1,1):n_upright_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,n_upleft_abs(1,1):n_upleft_abs(col,row))=eye(node);
Aineq(rineq+1:rineq+node,flag_h(1,1):flag_h(col,row))=-M2*eye(node);
Bineq(rineq+1:rineq+node,1)=0;
rineq=rineq+node;
% sum(sigma)<=num_OgStH
Aineq(rineq+1,sigma(1,1):sigma(col,row))=ones(1,col*row);
Bineq(rineq+1)=num_OgStH;
rineq=rineq+1;
% f_s<flag_ws
Aineq(rineq+1:rineq+node,f_s(1,1):f_s(col,row))=eye(node);
Aineq(rineq+1:rineq+node,flag_ws(1,1):flag_ws(col,row))=-M2*eye(node);
rineq=rineq+node;
Aineq(rineq+1,flag_ws(1,1):flag_ws(col,row))=1;
Bineq(rineq+1,1)=1;%一个水源
Aeq(req+1,flag_ws(1,1)+5014)=1;
Beq(req+1,1)=1;
%%
f=zeros(num,1);
f(n_up_abs(1,1):n_up_abs(col,row))=1*5000*0.0017*5.11;
f(n_left_abs(1,1):n_left_abs(col,row))=1*5000*0.0017*5.11;
f(n_upleft_abs(1,1):n_upleft_abs(col,row))=5000*1.414*0.0017*5.11;
f(n_upright_abs(1,1):n_upright_abs(col,row))=5000*1.414*0.0017*5.11;
f(f_up_abs(1,1):f_up_abs(col,row))=1*5000*0.04*5.11;
f(f_left_abs(1,1):f_left_abs(col,row))=1*5000*0.04*5.11;
f(f_upleft_abs(1,1):f_upleft_abs(col,row))=1.414*5000*0.04*5.11;
f(f_upright_abs(1,1):f_upright_abs(col,row))=1.414*5000*0.04*5.11;
f(flag_w(1,1):flag_w(col,row))=1e7;
f(flag_h(1,1):flag_h(col,row))=1e7;
f(sigma(1,1):sigma(col,row))=1e7; %个数尽量少
f(cap_EL(1))=Invest(2)*(ann(2)+OM(2))*num_OgStH;
f(cap_HS(1))=Invest(3)*(ann(3)+OM(3))*num_OgStH;
f(cap_ES(1))=Invest(4)*(ann(4)+OM(4))*EShour*num_OgStH;
f(w_con(1,1):w_con(1,T))=priceH2O*num_OgStH;
opt=cplexoptimset; %参数设置
opt.ExportModel='model.lp';
opt.Display='on';
opt.mip.tolerances.mipgap=0.01;
opt.timelimit=1000;
toc;
disp(['模型建立时长：',num2str(toc)]);
tic;
[x,fval,exitflag]=cplexmilp(f,Aineq,Bineq,Aeq,Beq,[],[],[],lb,ub,ctype',[],opt);
%% 结果统计
cap_EL=x(cap_EL(1));
cap_HS=x(cap_HS(1));
cap_ES=x(cap_ES(1));
production=sum(x(g_gen(1,1):g_gen(1,T)))*8760/T/11.2;
LCOH_PV=(Invest(1).*(ann(1)+OM(1)))/production; %RMB/kg
LCOH_EL=cap_EL*Invest(2).*(ann(2)+OM(2))/production;
LCOH_HS=cap_HS*Invest(3).*(ann(3)+OM(3))/production;
LCOH_ES=cap_ES*Invest(4).*(ann(4)+OM(4))*EShour/production;
LCOH_OgStH=LCOH_PV+LCOH_EL+LCOH_HS+LCOH_ES;
n_OgStH=sum(sum(x(sigma)));
LCOH_HP=(sum(sum(x(n_up_abs)+x(n_left_abs)))*1*5000*0.0017*5.11+sum(sum(x(n_upleft_abs)+x(n_upright_abs)))*1.414*5000*0.0017*5.11)/(production*n_OgStH);
LCOH_WP=(sum(sum(x(f_up_abs)+x(f_left_abs)))*1*5000*0.04*5.11+sum(sum(x(f_upleft_abs)+x(f_upright_abs)))*1.414*5000*0.04*5.11)/(production*n_OgStH);
LCOH_tot=LCOH_OgStH+LCOH_HP+LCOH_WP;
g_gen=x(g_gen);
ES=x(e_ES);
e_in=x(e_in);
e_out=x(e_out);
g_in=x(g_in);
g_out=x(g_out);
g_HS=x(g_HS);
toc;
disp(['微观模型求解时长：',num2str(toc)]);
%% 画图
figure(1)
for c=1:col
    for r=1:row
        if F_S(c,r)~=0
            fill([r-0.5 r+0.5 r+0.5 r-0.5],[c-0.5 c-0.5 c+0.5 c+0.5],[.9 .9 .9]);
            hold on
        end  
        if N_S(c,r)~=0
            fill([r-0.5 r+0.5 r+0.5 r-0.5],[c-0.5 c-0.5 c+0.5 c+0.5],'r','FaceAlpha',N_S(c,r)/2/max(max(N_S)));
            hold on
        end     
        if barrier(c,r)==0
            fill([r-0.5 r+0.5 r+0.5 r-0.5],[c-0.5 c-0.5 c+0.5 c+0.5],[.6 .6 .6]);
            hold on
        end
        if x(n_up_abs(c,r))>1
            plot([r,r+1],[c,c],'b-','linewidth',2);
            hold on
        end
        if x(n_left_abs(c,r))>1
            plot([r,r],[c,c-1],'b-','linewidth',2);
            hold on
        end
        if x(n_upleft_abs(c,r))>1
            plot([r,r+1],[c,c-1],'b-','linewidth',2);
            hold on
        end
        if x(n_upright_abs(c,r))>1
            plot([r,r+1],[c,c+1],'b-','linewidth',2);
            hold on
        end
        if x(f_up_abs(c,r))>1
            plot([r,r+1],[c,c],'k-','linewidth',2);
            hold on
        end
        if x(f_left_abs(c,r))>1
            plot([r,r],[c,c-1],'k-','linewidth',2);
            hold on
        end
        if x(f_upleft_abs(c,r))>1
            plot([r,r+1],[c,c-1],'k-','linewidth',2);
            hold on
        end
        if x(f_upright_abs(c,r))>1
            plot([r,r+1],[c,c+1],'k-','linewidth',2);
            hold on
        end
        if x(f_s(c,r))>1
            plot(r,c,'o','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','k');
            hold on
        end
        if N_D(c,r)~=0
            plot(r,c,'s','MarkerSize',5,'MarkerEdgeColor','b','MarkerFaceColor','b');
            hold on
        end
        if x(sigma(c,r))>0.1
            plot(r,c,'d','MarkerSize',5,'MarkerEdgeColor','g','MarkerFaceColor','g');
            hold on
        end
    end
end
axis([0.5 row+0.5 0.5 col+0.5]);
box on
grid
set(gca,'xtick',0.5:17:102.5);
set(gca,'ytick',0.5:11:77.5);
set(gca,'xticklabel',{'106','107','108','109','110','111','112'},'FontName','Times New Roman')
set(gca,'yticklabel',{'38','38.5','39','39.5','40','40.5','41','41.5'},'FontName','Times New Roman')

save topology.mat x;
toc;
disp(['拓扑模型求解时长：',num2str(toc)]);
