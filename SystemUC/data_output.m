function [] = data_output(result,prvc_index,filePath,j,k)
%�������

% xlswrite(strcat(filePath,'\output\�����ͣ״̬.xlsx'),result.x,prvc_index);
% xlswrite(strcat(filePath,'\output\����������.xlsx'),result.P_CG,prvc_index);
% xlswrite(strcat(filePath,'\output\ȼ�������������.xlsx'),result.P_GS,prvc_index);
% xlswrite(strcat(filePath,'\output\�����ʻ����������.xlsx'),result.P_BO,prvc_index);
% xlswrite(strcat(filePath,'\output\���ܳ�繦��.xlsx'),result.P_ESSC,prvc_index);
% xlswrite(strcat(filePath,'\output\���ܷŵ繦��.xlsx'),result.P_ESSD,prvc_index);
% xlswrite(strcat(filePath,'\output\��ƽ�⹦��.xlsx'),[result.sg; result.dg],prvc_index);
% xlswrite(strcat(filePath,'\output\��ƽ�⹦��ռ��.xlsx'),[result.sg_ratio; result.dg_ratio],prvc_index);
% xlswrite(strcat(filePath,'\output\̼�ŷ���.xlsx'),result.year.C_emmission,1,strcat('A',num2str(prvc_index)));
% 
% xlswrite(strcat(filePath,'\output\����������.xlsx'),result.P_WD,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\����������.xlsx'),result.P_PV,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\ˮ���������.xlsx'),result.P_HD,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\�˵��������.xlsx'),result.P_NC,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\�����������.xlsx'),result.P_CS,1,strcat('A',num2str(prvc_index)));
% 
% xlswrite(strcat(filePath,'\output\������繦��.xlsx'),result.wind_cutl,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\������繦��.xlsx'),result.photo_cutl,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\ˮ�����繦��.xlsx'),result.hydro_cutl,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\�������繦��.xlsx'),result.csp_cutl,1,strcat('A',num2str(prvc_index)));
% 
% xlswrite(strcat(filePath,'\output\���������.xlsx'),result.year.wdcutl_ratio,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\���������.xlsx'),result.year.pvcutl_ratio,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\ˮ��������.xlsx'),result.year.hdcutl_ratio,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\����������.xlsx'),result.year.cscutl_ratio,1,strcat('A',num2str(prvc_index)));

% %ȫ�����̼���� ú�� ���� �����ʺ��� ������ ��� ��� ˮ�� �˵� ���� �����߾������ ��緢���� ȼ�������� �����ʷ����� ƽ��̼�ŷ���
% xlswrite(strcat(filePath,'\output\ȫ�깦�ʼ���.xlsx'),[result.year.C_emmission result.year.coal_consumption result.year.gas_consumption result.year.bio_consumption result.year.load result.year.wind result.year.photo result.year.hydro result.year.nuclear result.year.csp result.year.Lflow result.year.CG result.year.GS result.year.BO result.year.Ceratio],1,strcat('A',num2str(prvc_index)));
% 
% %���ͳ��
% xlswrite(strcat(filePath,'\output\ͳ�Ƽ���.xlsx'),[result.generation_v result.generation_avertime result.generation_cutlratio result.generation_powerratio result.year.Lflow],1,strcat('A',num2str(prvc_index)));

%��������� ȫ�����̼���� ������ ƽ��̼�ŷ����� װ����ú ȼ�� ������ ��� ��� �˵� ˮ�� ���ȣ� ����Сʱ����ú ȼ�� ������ ��� ��� �˵� ˮ�� ���ȣ�
%�����ʣ���� ��� ˮ�� ���ȣ� ��Դ���ģ�ú�� ���� �����ʺ����� �ɵ���Դ���£�ú ȼ�� ���� ��� �ɱ���ú �� ������ ���� ���磩
UC_result=[result.year.C_emmission result.year.load result.year.Ceratio result.generation_v result.generation_avertime result.generation_cutlratio result.year.coal_consumption result.year.gas_consumption result.year.bio_consumption result.power_rmp result.Ecv result.Egas result.Ebio result.ESS result.penalty_cost];
xlswrite(strcat('UC-',num2str(j),'.xlsx'),UC_result,1,strcat('A',num2str(k)));
xlswrite(strcat('ESSC-',num2str(j),'.xlsx'),result.P_ESSC',k,'A1:B8760');
xlswrite(strcat('ESSD-',num2str(j),'.xlsx'),result.P_ESSD',k,'A1:B8760');
xlswrite(strcat('CG-',num2str(j),'.xlsx'),result.P_CG',k,'A1:C8760');
xlswrite(strcat('GS-',num2str(j),'.xlsx'),result.P_GS',k,'A1:A8760');
xlswrite(strcat('BO-',num2str(j),'.xlsx'),result.P_BO',k,'A1:A8760');
xlswrite(strcat('WD-',num2str(j),'.xlsx'),result.P_WD',k,'A1:A8760');
xlswrite(strcat('PV-',num2str(j),'.xlsx'),result.P_PV',k,'A1:A8760');
xlswrite(strcat('HD-',num2str(j),'.xlsx'),result.P_HD',k,'A1:A8760');
xlswrite(strcat('NC-',num2str(j),'.xlsx'),result.P_NC',k,'A1:A8760');
xlswrite(strcat('CS-',num2str(j),'.xlsx'),result.P_CS',k,'A1:A8760');

end

