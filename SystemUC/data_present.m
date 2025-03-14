function [] = data_present(filePath,Powerdata,prvc_index)
%����ʡȫ�귢���������ֵ�����ֵ �븺����Ƚ�

global parameter;
dayindex=parameter.dayindex; %������ѡȡ
%��󷢵�������磩
high_generation=sum(Powerdata.generation_cv(:,1))*ones(parameter.day_num,parameter.time_num);
%��С����������磩
low_generation=zeros(parameter.day_num,parameter.time_num);
%����Ӧ����
PGload=Powerdata.load-Powerdata.wind-Powerdata.photo-Powerdata.nuclear-Powerdata.hydro-Powerdata.csp+Powerdata.Lflow;

curve1=[];
curve2=[];
curve3=[];
for w=1:size(dayindex,1)
    for d=1:size(dayindex,2)
        curve1=[curve1 high_generation(dayindex(w,d),:)];%��߷������
        curve2=[curve2 low_generation(dayindex(w,d),:)];%��ͷ������
        curve3=[curve3 PGload(dayindex(w,d),:)];%��������
    end
end

plot(1:numel(dayindex)*24, curve3,'g');
hold on;
plot(1:numel(dayindex)*24, curve1, '--b');
hold on;
plot(1:numel(dayindex)*24, curve2, '--r');
hold on;

saveas(gcf,[strcat(filePath,'\output\','Load',num2str(prvc_index),'.jpg')]);
close all;
% xlswrite(strcat(filePath,'\output\��縺��',num2str(prvc_index),'.xlsx'),PGload,1,'A1');

%���������������
% xlswrite(strcat(filePath,'\output\������������.xlsx'),Powerdata.generation_cv,prvc_index,'A1');

% %���ȫ�����Ӧ����
% PG_line_load=[];
% for i=1:365
%     PG_line_load=[PG_line_load PGload(i,:)];
% end
% xlswrite(strcat(filePath,'\output\��縺��.xlsx'),PG_line_load,1,strcat('A',num2str(prvc_index)));


end
