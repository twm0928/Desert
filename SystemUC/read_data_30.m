function [Powerdata] = read_data_30(filePath,prvc_index,j,k)
%��ȡһ��ʡ������
%���룺��ȡ·�� ʡ��ţ�1~31��
%���������ˮ����������ɡ���������ʡ����װ�������Լ���Ӧú��

%% �������
global parameter;
raw_parameter=xlsread(strcat(filePath,'\','�������'),1); %�������
parameter.chart_num=2; %�������ݶ�Ӧ�����
parameter.day_num=raw_parameter(2); %һ��������
parameter.time_num=raw_parameter(3); %һ������Ż���ʱ����
parameter.minPCG=raw_parameter(4); %��������С����ϵ��
parameter.upcost=raw_parameter(5); %��������ɱ�ϵ��
parameter.downcost=raw_parameter(6); %���ͣ���ɱ�ϵ��
parameter.minTU=raw_parameter(7); %��������С����ʱ��
parameter.minTD=raw_parameter(8); %��������Сͣ��ʱ��
parameter.minPGS=raw_parameter(9); %ȼ��������С����ϵ��
parameter.minPBO=raw_parameter(10); %�����ʻ�����С����ϵ��
parameter.penalty=raw_parameter(11); %��ƽ�⹦�ʳͷ��ɱ�
parameter.Cemission=raw_parameter(12); %ȼú̼�ŷ�ϵ��
parameter.GSemission=raw_parameter(13); %ȼ��̼�ŷ�ϵ��
parameter.BOemission=raw_parameter(14); %������̼�ŷ�ϵ��
parameter.WD_cutl_penalty=raw_parameter(15); %�������ͷ�
parameter.PV_cutl_penalty=raw_parameter(16); %�������ͷ�
parameter.HD_cutl_penalty=raw_parameter(17); %ˮ������ͷ�
parameter.CS_cutl_penalty=raw_parameter(18); %��������ͷ�
parameter.dayindex=xlsread(strcat(filePath,'\','�������'),2); %ѡȡ������
parameter.averhour=xlsread(strcat(filePath,'\','�������'),3); %����ƽ������Сʱ��

%��ʱ��ת��Ϊexcel����
sumT1=parameter.day_num*parameter.time_num+1;
columnend1=column_change(sumT1);

sumT2=parameter.day_num*parameter.time_num;
columnend2=column_change(sumT2);


%% ���빦������
wind_power=xlsread(strcat(filePath,'\','3-����ʡ����ȷ�������-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %�����繦�� ��Ϊʡ ��ΪСʱ
photo_power=xlsread(strcat(filePath,'\','3-�����ʡ����ȷ�������-GM20-ȥ�ֲ�ʽ'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1)))...
  +xlsread(strcat(filePath,'\','6-�����������'),j,strcat('A',num2str(k)))*xlsread(strcat(filePath,'\','6-�����������'),j,strcat('B',num2str(k),':',columnend1,num2str(k))); %���������� ��Ϊʡ ��ΪСʱ
nuclear_power=xlsread(strcat(filePath,'\','3-�˵��ʡ����ȷ�������-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %����˵繦�� ��Ϊʡ ��ΪСʱ
hydro_power=xlsread(strcat(filePath,'\','3-ˮ���ʡ����ȷ�������-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %����ˮ�繦�� ��Ϊʡ ��ΪСʱ
csp_power=xlsread(strcat(filePath,'\','3-���ȷ�ʡ����ȷ�������-GM20'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1))); %����ˮ�繦�� ��Ϊʡ ��ΪСʱ
load_power=xlsread(strcat(filePath,'\','5-���ɷ�ʡ���������-GM20-ȥ�ֲ�ʽ'),parameter.chart_num,strcat('B',num2str(prvc_index+1),':',columnend1,num2str(prvc_index+1)));%...%; %���븺�ɹ��� ��Ϊʡ ��ΪСʱ
   %-xlsread(strcat(filePath,'\','6-�����������'),j,strcat('A',num2str(k)))*xlsread(strcat(filePath,'\','6-�����������'),j,strcat('B',num2str(k),':',columnend1,num2str(k))); %���������� ��Ϊʡ ��ΪСʱ
% load_power(load_power<0)=0;
Lflow=xlsread(strcat(filePath,'\','2030ȫ���ʡ���������'),1,strcat('A',num2str(prvc_index),':',columnend2,num2str(prvc_index)));%�����ʡ�䳱��

%% ��ʡ�۸�
coal_price=xlsread(strcat(filePath,'\','0-��ʡ����۸�'),1,strcat('B',num2str(prvc_index+1)))/1000; %�����ʡ��ú�۸�
gas_price=xlsread(strcat(filePath,'\','0-��ʡ����۸�'),1,strcat('C',num2str(prvc_index+1))); %�����ʡȼ���۸�
bio_price=xlsread(strcat(filePath,'\','0-��ʡ����۸�'),1,strcat('D',num2str(prvc_index+1)))/1000; %�����ʡ������ȼ�ϼ۸�
ce_price=xlsread(strcat(filePath,'\','̼��'),1,strcat('B',num2str(prvc_index+1)))/1000; %�����ʡ������ȼ�ϼ۸� ��λ��Ԫ/ǧ��
%% ȼú�����������ȡ
generation_cv=xlsread(strcat(filePath,'\','2-����ʡú��̼������-2030-GM20'),prvc_index);%���� װ������ ú

%% ȼ�������������ȡ
generation_gas=xlsread(strcat(filePath,'\','2-�����ʡ����̼������-2030-GM20'),prvc_index);%���� װ������ ����
generation_gas(:,2)=generation_gas(:,2)*1000;

%% �����ʷ����������ȡ
generation_bio=xlsread(strcat(filePath,'\','2-�����ʷ�ʡ�ʺ�̼������-2030-GM20'),prvc_index);%���� װ������ ����������

%% ���ܲ�����ȡ
storage=xlsread(strcat(filePath,'\','4-���ܷ�ʡ����-2030-GM20'),prvc_index);%���� ���ܹ��� �������� ���Ч�� ��ųɱ�ϵ��

%% װ��������ȡ
cv_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),1,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %������װ��
gas_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),2,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %����ȼ��װ��
bio_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),3,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %����������װ��
wind_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),4,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %������װ��
photo_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),5,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %������װ��
nuclear_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),6,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %����˵�װ��
hydro_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),7,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %����ˮ��װ��
csp_v=xlsread(strcat(filePath,'\','��Դ����װ��ͳ��'),8,strcat('A'+parameter.chart_num,num2str(prvc_index+1))); %���뼯��װ��

%% ���෢�縺������ת��Ϊ������*һ��ʱ����������
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

