function [result] = annual_calculation(Powerdata,result)
%����ȫ�������
global parameter;

coal_consumption=result.updown_cost+result.operation_coal;
gas_consumption=result.operation_gas;
bio_consumption=result.operation_bio;
sumPV_cutl=sum(result.photo_cutl(:)); %ȫ����������
sumWD_cutl=sum(result.wind_cutl(:)); %ȫ����������
sumHD_cutl=sum(result.hydro_cutl(:)); %ȫ��ˮ��������
sumCS_cutl=sum(result.csp_cutl(:)); %ȫ�����������

%ȫ�����ݱ���
result.year.C_emmission=coal_consumption*parameter.Cemission+gas_consumption*parameter.GSemission+bio_consumption*parameter.BOemission; %̼������λ��ǧ��
result.year.coal_consumption=coal_consumption;
result.year.gas_consumption=gas_consumption;
result.year.bio_consumption=bio_consumption;
result.year.load=sum(Powerdata.load(:)); %ȫ���ܸ��ɼ���
result.year.wind=sum(result.P_WD(:)); %ȫ���緢��������
result.year.photo=sum(result.P_PV(:)); %ȫ��������������
result.year.hydro=sum(result.P_HD(:)); %ȫ��ˮ�緢��������
result.year.nuclear=sum(result.P_NC(:)); %ȫ��˵緢��������
result.year.csp=sum(result.P_CS(:)); %ȫ����ȷ���������
result.year.Lflow=sum(Powerdata.Lflow(:)); %ȫ��������������ʼ���
result.year.CG=sum(result.P_CG(:));
result.year.GS=sum(result.P_GS(:));
result.year.BO=sum(result.P_BO(:));

if sum(Powerdata.wind(:))~=0
    result.year.wdcutl_ratio=sumWD_cutl/sum(Powerdata.wind(:)); %ȫ����������
else
    result.year.wdcutl_ratio=0;
end
if sum(Powerdata.photo(:))~=0
    result.year.pvcutl_ratio=sumPV_cutl/sum(Powerdata.photo(:)); %ȫ����������
else
    result.year.pvcutl_ratio=0;
end
if sum(Powerdata.photo(:))~=0
    result.year.hdcutl_ratio=sumHD_cutl/sum(Powerdata.hydro(:)); %ȫ��ˮ��������
else
    result.year.hdcutl_ratio=0;
end
if sum(Powerdata.csp(:))~=0
    result.year.cscutl_ratio=sumCS_cutl/sum(Powerdata.csp(:)); %ȫ�����������
else
    result.year.cscutl_ratio=0;
end

%ƽ��̼�ŷ��� ��λ��kg/MWh
result.year.Ceratio=result.year.C_emmission/(result.year.wind+result.year.photo+result.year.hydro+result.year.nuclear+result.year.csp+result.year.CG+result.year.GS+result.year.BO);


% ȫ��ͳ��
%��װ�� ú ȼ�� ������ �� �� �� ˮ ����
result.generation_v=[Powerdata.cv_v Powerdata.gas_v Powerdata.bio_v Powerdata.wind_v Powerdata.photo_v Powerdata.nuclear_v Powerdata.hydro_v Powerdata.csp_v];
%����Сʱ��
if Powerdata.cv_v~=0 %ú��
    cv_avertime=result.year.CG/Powerdata.cv_v;
else
    cv_avertime=0;
end
if Powerdata.gas_v~=0 %ȼ��
    gas_avertime=result.year.GS/Powerdata.gas_v;
else
    gas_avertime=0;
end
if Powerdata.bio_v~=0 %������
    bio_avertime=result.year.BO/Powerdata.bio_v;
else
    bio_avertime=0;
end
if Powerdata.wind_v~=0 %���
    wind_avertime=result.year.wind/Powerdata.wind_v;
else
    wind_avertime=0;
end
if Powerdata.photo_v~=0 %���
    photo_avertime=result.year.photo/Powerdata.photo_v;
else
    photo_avertime=0;
end
if Powerdata.hydro_v~=0 %ˮ��
    hydro_avertime=result.year.hydro/Powerdata.hydro_v;
else
    hydro_avertime=0;
end
if Powerdata.nuclear_v~=0 %�˵�
    nuclear_avertime=result.year.nuclear/Powerdata.nuclear_v;
else
    nuclear_avertime=0;
end
if Powerdata.csp_v~=0 %����
    csp_avertime=result.year.csp/Powerdata.csp_v;
else
    csp_avertime=0;
end
result.generation_avertime=[cv_avertime gas_avertime bio_avertime wind_avertime photo_avertime nuclear_avertime hydro_avertime csp_avertime];
%������ �� �� ˮ ����
result.generation_cutlratio=[result.year.wdcutl_ratio result.year.pvcutl_ratio result.year.hdcutl_ratio result.year.cscutl_ratio];
%ȫ�����ռ�� ú ȼ�� ������ �� �� �� ˮ ����
all_power=result.year.wind+result.year.photo+result.year.hydro+result.year.nuclear+result.year.csp+result.year.CG+result.year.GS+result.year.BO;
result.generation_powerratio=[result.year.CG/all_power result.year.GS/all_power result.year.BO/all_power result.year.wind/all_power...
    result.year.photo/all_power result.year.nuclear/all_power result.year.hydro/all_power result.year.csp/all_power];

%���¼���
%ú��
cv_rmp=0;
for i=1:size(result.P_CG,1)
    for j=1:size(result.P_CG,2)-1
        cv_rmp=cv_rmp+abs(result.P_CG(i,j+1)-result.P_CG(i,j));
    end
end
%ȼ��
gas_rmp=0;
for i=1:size(result.P_GS,1)
    for j=1:size(result.P_GS,2)-1
        gas_rmp=gas_rmp+abs(result.P_GS(i,j+1)-result.P_GS(i,j));
    end
end
%����
battary_rmp=0;
for j=1:size(result.P_ESSC,2)-1
    battary_rmp=battary_rmp+abs(result.P_ESSC(2,j+1)-result.P_ESSD(2,j+1)-(result.P_ESSC(2,j)-result.P_ESSD(2,j)));
end
%����
pumps_rmp=0;
for j=1:size(result.P_ESSC,2)-1
    pumps_rmp=pumps_rmp+abs(result.P_ESSC(1,j+1)-result.P_ESSD(1,j+1)-(result.P_ESSC(1,j)-result.P_ESSD(1,j)));
end
result.power_rmp=[cv_rmp gas_rmp battary_rmp pumps_rmp];


end

