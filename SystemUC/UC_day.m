function [dayoutput] = UC_day(D_PPV,D_PWD,D_PHD,D_PNC,D_PCS,D_PLD,D_PTL,Pre_xCG,generation_cv,generation_gas,generation_bio,storage,coal_price,gas_price,bio_price,ce_price)
%24Сʱ�Ļ�������Ż�
%���룺һ���� �������硢ˮ�硢�˵硢���ɡ���������ʡ������ʼ��ͣ״̬������������ú��
%�����һ���� �����ͣ�����гɱ� ������ͷ��ɱ� ���⡢������ ��硢�������硢ˮ�硢�˵緢���� һ�������ʱ�̻�������ͣ״̬

global parameter;

T=parameter.time_num; %һ����ʱ����
PCG_max=generation_cv(:,1);%���װ��
coal_cost=generation_cv(:,2);%ú��
N_CG=size(PCG_max,1);%����������
PCG_min=parameter.minPCG*PCG_max;%��������С����
costU=parameter.upcost*PCG_max;%��������ú�ĳɱ�
costD=parameter.downcost*PCG_max;%����ͣ��ú�ĳɱ�
cv_daypower=parameter.averhour(1,1)/8760*PCG_max*24; %Ԥ��ƽ������
cv_penalty=parameter.averhour(1,2); %����ƫ��ͷ�

%��ͣʱ�����
TUmin=parameter.minTU;%��С����ʱ��
TDmin=parameter.minTD;%��С�ر�ʱ��

%ȼ��&������
PGS_max=generation_gas(:,1);%ȼ��װ��
PGS_min=parameter.minPGS*PGS_max;%ȼ��������С����
gas_cost=generation_gas(:,2);%ȼ����������
N_GS=size(PGS_max,1);%ȼ����������
gs_daypower=parameter.averhour(2,1)/8760*PGS_max*24; %Ԥ��ƽ������
gs_penalty=parameter.averhour(2,2); %����ƫ��ͷ�
PBO_max=generation_bio(:,1);%������װ��
PBO_min=parameter.minPBO*PBO_max;%�����ʻ�����С����
bio_cost=generation_bio(:,2);%�����ʻ�������
N_BO=size(PBO_max,1);%�����ʻ�������
bo_daypower=parameter.averhour(3,1)/8760*PBO_max*24; %Ԥ��ƽ������
bo_penalty=parameter.averhour(3,2); %����ƫ��ͷ�

%����
PESS_max=storage(:,1);%���������
SOC_max=storage(:,2);%��������
ef_ESS=storage(:,3);%���ܳ��Ч��
PESS_Ecost=storage(:,4);%���ܳ�ž��óɱ�
N_ESS=size(PESS_max,1);%��������

%�Ż�����
P_CG=sdpvar(N_CG,T,'full');%���
P_GS=sdpvar(N_GS,T,'full');%ȼ��
P_BO=sdpvar(N_BO,T,'full');%������
P_ESSC=sdpvar(N_ESS,T,'full');%���ܳ�繦��
P_ESSD=sdpvar(N_ESS,T,'full');%���ܷŵ繦��
SOC=sdpvar(N_ESS,T+1,'full');%���ܷŵ繦��
P_PV=sdpvar(1,T,'full');%���
P_WD=sdpvar(1,T,'full');%���
P_HD=sdpvar(1,T,'full');%ˮ��
P_NC=sdpvar(1,T,'full');%�˵�
P_CS=sdpvar(1,T,'full');%����
%ԭʼ���ݴ���ƫ�����������鲹��ƫ���֤����ƽ��
P_SG=sdpvar(1,T,'full'); %����������
P_DG=sdpvar(1,T,'full'); %����������
x_CG=binvar(N_CG,T,'full');%�����ͣ״̬
x_GS=binvar(N_GS,T,'full');%ȼ����ͣ״̬
% x_BO=binvar(N_BO,T,'full');%��������ͣ״̬
costH=sdpvar(N_CG,T,'full');%�����ɱ�
costJ=sdpvar(N_CG,T,'full');%ͣ���ɱ�
PV_cutl=sdpvar(1,T,'full');%����
WD_cutl=sdpvar(1,T,'full');%����
HD_cutl=sdpvar(1,T,'full');%��ˮ
CS_cutl=sdpvar(1,T,'full');%��������
CG_less=sdpvar(N_CG,1,'full');%����ٳ���
CG_more=sdpvar(N_CG,1,'full');%�������
GS_less=sdpvar(N_GS,1,'full');%�����ٳ���
GS_more=sdpvar(N_GS,1,'full');%��������
BO_less=sdpvar(N_BO,1,'full');%�������ٳ���
BO_more=sdpvar(N_BO,1,'full');%�����ʶ����

st=[];

%������Լ��
for t=1:T
    for i=1:N_CG
        st=[st,x_CG(i,t)*PCG_min(i)<=P_CG(i,t)<=x_CG(i,t)*PCG_max(i)];
    end
end

%ȼ���������Լ��
for t=1:T
    for i=1:N_GS
        st=[st,x_GS(i,t)*PGS_min(i)<=P_GS(i,t)<=x_GS(i,t)*PGS_max(i)];
    end
end

%�����ʻ������Լ��
for t=1:T
    for i=1:N_BO
%         st=[st,x_BO(i,t)*PBO_min(i)<=P_BO(i,t)<=x_BO(i,t)*PBO_max(i)];
        st=[st,PBO_min(i)<=P_BO(i,t)<=PBO_max(i)];
    end
end

%���ܹ���Լ��
for t=1:T
    for i=1:N_ESS
        st=[st,0<=P_ESSC(i,t)<=PESS_max(i)];
        st=[st,0<=P_ESSD(i,t)<=PESS_max(i)];
    end
end

%��������ת��Լ��
for t=1:T
    for i=1:N_ESS
        st=[st,SOC(i,t+1)==SOC(i,t)+ef_ESS(i)*P_ESSC(i,t)-P_ESSD(i,t)/ef_ESS(i)];
    end
end
for i=1:N_ESS
    st=[st,SOC(i,T+1)==SOC(i,1)];
end

%��������Լ��
for t=1:T
    for i=1:N_ESS
        st=[st,0<=SOC(i,t)<=SOC_max(i)];
    end
end

%��������ʷǸ�
for t=1:T
    st=[st, 0<=P_SG(1,t)];
    st=[st, 0<=P_DG(1,t)];
end

%���ˮ�˳���Լ��
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

%����ƽ��Լ��
for t=1:T
    st=[st,sum(P_CG(:,t))+sum(P_GS(:,t))+sum(P_BO(:,t))+sum(P_ESSD(:,t))-sum(P_ESSC(:,t))+P_PV(1,t)+P_WD(1,t)+P_HD(1,t)+P_NC(1,t)+P_CS(1,t)+P_SG(1,t)==D_PLD(1,t)+D_PTL(1,t)+P_DG(1,t)];
end

%��������ͣʱ��Լ��
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

%��ʱ���Ƿ������ͣ�ɱ��ж�
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

%������ͣ״̬Ϊǰһ�����ʱ�̵�״̬
if Pre_xCG(1,1)~=-1 %���Գ�ʼʱ��״̬���������涨 ��״̬������Ϊ-1 ��ʱ��Լ����Ч
    for i=1:N_CG
        st=[st,x_CG(i,1)==Pre_xCG(i,1)];
    end
end

%��ͣú���ۼ�
updown_cost=0; %��ͣ�ɱ���ʼ��
for t=1:T
    for i=1:N_CG
        updown_cost=updown_cost+costH(i,t)+costJ(i,t);
    end
end

%���гɱ��Լ��ͷ��ɱ��ۼ�
operation_coal=0; %���гɱ���ʼ��
operation_gas=0;
operation_bio=0;
operation_ESS=0;%�������о��óɱ���ʼ��
operation_penalty=0; %�ͷ��ɱ���ʼ��
WDcutl_penalty=0;
PVcutl_penalty=0;
HDcutl_penalty=0;
CScutl_penalty=0;

%̼�ŷųɱ�
ce_Ecoal=0;
ce_Egas=0;
ce_Ebio=0;

for t=1:T
    %������ͷ��ɱ�
    operation_penalty=operation_penalty+parameter.penalty*(P_SG(1,t)+P_DG(1,t));
    %����ͷ��ɱ�
    WDcutl_penalty=WDcutl_penalty+parameter.WD_cutl_penalty*WD_cutl(1,t);
    %����ͷ��ɱ�
    PVcutl_penalty=PVcutl_penalty+parameter.PV_cutl_penalty*PV_cutl(1,t);
    %��ˮ�ͷ��ɱ�
    HDcutl_penalty=WDcutl_penalty+parameter.HD_cutl_penalty*HD_cutl(1,t);
    %��������ͷ��ɱ�
    CScutl_penalty=CScutl_penalty+parameter.CS_cutl_penalty*CS_cutl(1,t);
    
    %������гɱ�
    for i=1:N_CG
        operation_coal=operation_coal+P_CG(i,t)*coal_cost(i);
        ce_Ecoal=ce_Ecoal+P_CG(i,t)*coal_cost(i)*parameter.Cemission*ce_price;
    end
    
    %ȼ�����гɱ�
    for i=1:N_GS
        operation_gas=operation_gas+P_GS(i,t)*gas_cost(i);
        ce_Egas=ce_Egas+P_GS(i,t)*parameter.GSemission*ce_price;
    end
    
    %���������гɱ�
    for i=1:N_BO
        operation_bio=operation_bio+P_BO(i,t)*bio_cost(i);
        ce_Ebio=ce_Ebio+P_BO(i,t)*parameter.BOemission*ce_price;
    end
    
    %�������о��óɱ�
    for i=1:N_ESS
        operation_ESS=operation_ESS+P_ESSC(i,t)*PESS_Ecost(i)+P_ESSD(i,t)*PESS_Ecost(i);
    end
end

% ����ƫ��ͷ�
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

%���龭�óɱ�����
operation_Ecv=(updown_cost+operation_coal)*coal_price;
operation_Egas=operation_gas*gas_price;
operation_Ebio=operation_bio*bio_price;

objective=operation_Ecv+operation_Egas+operation_Ebio+cv_dvpenalty+gs_dvpenalty+bo_dvpenalty+ce_Ecoal+ce_Egas+ce_Ebio+operation_ESS+operation_penalty+WDcutl_penalty+PVcutl_penalty+HDcutl_penalty+CScutl_penalty;%Ŀ�꺯��������ͣ�ɱ���ú�ĳɱ���������ͷ��ɱ�
ops = sdpsettings('solver','cplex','verbose',2);
ops.cplex.mip.tolerances.mipgap=1e-3; 
Solver= optimize(st,objective,ops);

%��ͣú�ġ�����ú�ġ�������ͷ��ɱ� �����龭�óɱ�
dayoutput.updowncost=value(updown_cost);
dayoutput.operation_coal=value(operation_coal);
dayoutput.penalty=value(operation_penalty);
dayoutput.Ecv=value(operation_Ecv);
dayoutput.operation_gas=value(operation_gas);
dayoutput.operation_bio=value(operation_bio);
dayoutput.Egas=value(operation_Egas);
dayoutput.Ebio=value(operation_Ebio);
dayoutput.ESS=value(operation_ESS);

%һ���е�������
dayoutput.PV_cutl=value(PV_cutl);
dayoutput.WD_cutl=value(WD_cutl);
dayoutput.HD_cutl=value(HD_cutl);
dayoutput.CS_cutl=value(CS_cutl);

%һ���и���Դ������
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

%���л��������ʱ�̵���ͣ״̬
dayoutput.x_CG=value(x_CG);
dayoutput.Last_XCG=value(x_CG(:,T));

%�ɳڱ�������ƽ�������
dayoutput.P_SG=value(P_SG);
dayoutput.P_DG=value(P_DG);

end
