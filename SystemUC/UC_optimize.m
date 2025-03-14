function [result] = UC_optimize(Powerdata)
%һ���л�������Ż�
%���룺ѡȡΪ���ͳ��������ڣ��������ܣ�   ��������{�������硢ˮ�硢�˵硢���ɡ����������(365*24����)��������������ú��}
%����������ͣ�����гɱ� ������ͷ��ɱ� ���⡢������ ��硢�������硢ˮ�硢�˵緢����

global parameter;
dayindex=parameter.dayindex; %������ѡȡ
Y_PPV=Powerdata.photo; %ȫ��������
Y_PWD=Powerdata.wind; %ȫ���緢��
Y_PHD=Powerdata.hydro; %ȫ��ˮ��
Y_PNC=Powerdata.nuclear; %ȫ��˵�
Y_PCS=Powerdata.csp; %ȫ�����
Y_PLD=Powerdata.load; %ȫ�긺��
Y_PTL=Powerdata.Lflow; %ȫ�����������
generation_cv=Powerdata.generation_cv; %���װ����ú��
generation_gas=Powerdata.generation_gas; %ȼ��װ��������
generation_bio=Powerdata.generation_bio; %������װ�������
storage=Powerdata.storage; %������װ�������
coal_price=Powerdata.coal_price;
gas_price=Powerdata.gas_price;
bio_price=Powerdata.bio_price;
ce_price=Powerdata.ce_price;

result=struct; %��ʼ���������ṹ��

Pre_xCG=-ones(size(generation_cv,1),1); %�����һ���ʼʱ�̵���ͣ״̬ �����䲻���涨 �����б�������ֵ-1

%���ݴ洢
x=[]; %������ͣ����
sg=[]; %��������
dg=[]; %����ʣ��
costoutput=zeros(9,1);%�洢һ�������ͣ�����С��ͷ��ɱ�
%�洢���⡢���硢����ˮ�˷�����
PV_cutl=[];
WD_cutl=[];
HD_cutl=[];
CS_cutl=[];
PCG=[];%ȼú
PGS=[];%ȼ��
PBO=[];%������
PESSC=[];%���ܳ�繦��
PESSD=[];%���ܷŵ繦��
PPV=[];
PWD=[];
PHD=[];
PNC=[];
PCS=[];
    
for d=1:parameter.day_num%�������е�ÿһ��
    %��һ�����������ȡ�����յ���ز��� �������硢ˮ�硢�˵硢���ȡ����ɡ������߾��������
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

    %����һ���ڵĻ�������Ż�
    [dayoutput] = UC_day(D_PPV,D_PWD,D_PHD,D_PNC,D_PCS,D_PLD,D_PTL,Pre_xCG,generation_cv,generation_gas,generation_bio,storage,coal_price,gas_price,bio_price,ce_price);

    %��������ͣ�������ݸ���һ��
    Pre_xCG=dayoutput.Last_XCG;
    %��ͣ��������
    x=[x,dayoutput.x_CG];

    %��ƽ�����ͳ��
    sg=[sg dayoutput.P_SG];
    dg=[dg dayoutput.P_DG];

    %�ɱ����
    costoutput(1)=costoutput(1)+dayoutput.updowncost;
    costoutput(2)=costoutput(2)+dayoutput.operation_coal;
    costoutput(3)=costoutput(3)+dayoutput.penalty;
    costoutput(4)=costoutput(4)+dayoutput.Ecv;
    costoutput(5)=costoutput(5)+dayoutput.operation_gas;
    costoutput(6)=costoutput(6)+dayoutput.operation_bio;
    costoutput(7)=costoutput(7)+dayoutput.Egas;
    costoutput(8)=costoutput(8)+dayoutput.Ebio;
    costoutput(9)=costoutput(9)+dayoutput.ESS;

    %����������ˮ���
    PV_cutl=[PV_cutl dayoutput.PV_cutl];
    WD_cutl=[WD_cutl dayoutput.WD_cutl];
    HD_cutl=[HD_cutl dayoutput.HD_cutl];
    CS_cutl=[CS_cutl dayoutput.CS_cutl];

    %��Դ�������
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
   
%����ṹ�����ڽṹ��
result.updown_cost=costoutput(1);
result.operation_coal=costoutput(2);
result.penalty_cost=costoutput(3);
result.Ecv=costoutput(4);
result.operation_gas=costoutput(5);
result.operation_bio=costoutput(6);
result.Egas=costoutput(7);
result.Ebio=costoutput(8);
result.ESS=costoutput(9);

%�������Ᵽ��
result.photo_cutl=PV_cutl;
result.wind_cutl=WD_cutl;
result.hydro_cutl=HD_cutl;
result.csp_cutl=CS_cutl;

%��Դ��������
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

%������ͣ��������ƽ�Ᵽ��
result.x=x;
result.sg=sg;
result.dg=dg;

%��ƽ�⹦��ռ�ȼ���
result.sg_ratio=sum(sg)/(sum(Y_PLD(:))); %����
result.dg_ratio=sum(dg)/(sum(Y_PLD(:)));

end

