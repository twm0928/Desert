function [] = data_output(result,prvc_index,filePath,j,k)
%输出数据

% xlswrite(strcat(filePath,'\output\火电启停状态.xlsx'),result.x,prvc_index);
% xlswrite(strcat(filePath,'\output\火电输出功率.xlsx'),result.P_CG,prvc_index);
% xlswrite(strcat(filePath,'\output\燃气机组输出功率.xlsx'),result.P_GS,prvc_index);
% xlswrite(strcat(filePath,'\output\生物质机组输出功率.xlsx'),result.P_BO,prvc_index);
% xlswrite(strcat(filePath,'\output\储能充电功率.xlsx'),result.P_ESSC,prvc_index);
% xlswrite(strcat(filePath,'\output\储能放电功率.xlsx'),result.P_ESSD,prvc_index);
% xlswrite(strcat(filePath,'\output\不平衡功率.xlsx'),[result.sg; result.dg],prvc_index);
% xlswrite(strcat(filePath,'\output\不平衡功率占比.xlsx'),[result.sg_ratio; result.dg_ratio],prvc_index);
% xlswrite(strcat(filePath,'\output\碳排放量.xlsx'),result.year.C_emmission,1,strcat('A',num2str(prvc_index)));
% 
% xlswrite(strcat(filePath,'\output\风电输出功率.xlsx'),result.P_WD,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\光伏输出功率.xlsx'),result.P_PV,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\水电输出功率.xlsx'),result.P_HD,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\核电输出功率.xlsx'),result.P_NC,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\光热输出功率.xlsx'),result.P_CS,1,strcat('A',num2str(prvc_index)));
% 
% xlswrite(strcat(filePath,'\output\风电弃电功率.xlsx'),result.wind_cutl,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\光伏弃电功率.xlsx'),result.photo_cutl,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\水电弃电功率.xlsx'),result.hydro_cutl,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\光热弃电功率.xlsx'),result.csp_cutl,1,strcat('A',num2str(prvc_index)));
% 
% xlswrite(strcat(filePath,'\output\风电弃电率.xlsx'),result.year.wdcutl_ratio,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\光伏弃电率.xlsx'),result.year.pvcutl_ratio,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\水电弃电率.xlsx'),result.year.hdcutl_ratio,1,strcat('A',num2str(prvc_index)));
% xlswrite(strcat(filePath,'\output\光热弃电率.xlsx'),result.year.cscutl_ratio,1,strcat('A',num2str(prvc_index)));

% %全年计算碳排量 煤耗 气耗 生物质耗量 负荷量 风电 光伏 水电 核电 光热 联络线净输出量 火电发电量 燃气发电量 生物质发电量 平均碳排放率
% xlswrite(strcat(filePath,'\output\全年功率计算.xlsx'),[result.year.C_emmission result.year.coal_consumption result.year.gas_consumption result.year.bio_consumption result.year.load result.year.wind result.year.photo result.year.hydro result.year.nuclear result.year.csp result.year.Lflow result.year.CG result.year.GS result.year.BO result.year.Ceratio],1,strcat('A',num2str(prvc_index)));
% 
% %结果统计
% xlswrite(strcat(filePath,'\output\统计计算.xlsx'),[result.generation_v result.generation_avertime result.generation_cutlratio result.generation_powerratio result.year.Lflow],1,strcat('A',num2str(prvc_index)));

%总体结果输出 全年计算碳排量 负荷量 平均碳排放因子 装机（煤 燃气 生物质 风电 光伏 核电 水电 光热） 发电小时数（煤 燃气 生物质 风电 光伏 核电 水电 光热）
%弃电率（风电 光伏 水电 光热） 资源消耗（煤耗 气耗 生物质耗量） 可调资源爬坡（煤 燃气 储能 抽蓄） 成本（煤 气 生物质 储能 弃电）
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

