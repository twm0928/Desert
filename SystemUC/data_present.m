function [] = data_present(filePath,Powerdata,prvc_index)
%画各省全年发电量的最高值与最低值 与负荷相比较

global parameter;
dayindex=parameter.dayindex; %典型日选取
%最大发电量（火电）
high_generation=sum(Powerdata.generation_cv(:,1))*ones(parameter.day_num,parameter.time_num);
%最小发电量（火电）
low_generation=zeros(parameter.day_num,parameter.time_num);
%火电对应负荷
PGload=Powerdata.load-Powerdata.wind-Powerdata.photo-Powerdata.nuclear-Powerdata.hydro-Powerdata.csp+Powerdata.Lflow;

curve1=[];
curve2=[];
curve3=[];
for w=1:size(dayindex,1)
    for d=1:size(dayindex,2)
        curve1=[curve1 high_generation(dayindex(w,d),:)];%最高发电出力
        curve2=[curve2 low_generation(dayindex(w,d),:)];%最低发电出力
        curve3=[curve3 PGload(dayindex(w,d),:)];%负荷曲线
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
% xlswrite(strcat(filePath,'\output\火电负荷',num2str(prvc_index),'.xlsx'),PGload,1,'A1');

%输出火电各机组容量
% xlswrite(strcat(filePath,'\output\火电各机组容量.xlsx'),Powerdata.generation_cv,prvc_index,'A1');

% %输出全年火电对应负荷
% PG_line_load=[];
% for i=1:365
%     PG_line_load=[PG_line_load PGload(i,:)];
% end
% xlswrite(strcat(filePath,'\output\火电负荷.xlsx'),PG_line_load,1,strcat('A',num2str(prvc_index)));


end
