function [result] = annual_generation(Powerdata,result)
%通过典型周计算结果推算年情况

global parameter;

%典型周弃光率计算
week_photo_cutl=sum(result.spring.photo_cutl)+sum(result.summer.photo_cutl)+sum(result.autumn.photo_cutl)+sum(result.winter.photo_cutl);
week_photo_power=sum(result.spring.P_PV)+sum(result.summer.P_PV)+sum(result.autumn.P_PV)+sum(result.winter.P_PV);
if week_photo_power==0
    photo_cutl_ratio=0;
else
    photo_cutl_ratio=week_photo_cutl/(week_photo_cutl+week_photo_power);
end

%典型周弃风率计算
week_wind_cutl=sum(result.spring.wind_cutl)+sum(result.summer.wind_cutl)+sum(result.autumn.wind_cutl)+sum(result.winter.wind_cutl);
week_wind_power=sum(result.spring.P_WD)+sum(result.summer.P_WD)+sum(result.autumn.P_WD)+sum(result.winter.P_WD);
if week_wind_power==0
    wind_cutl_ratio=0;
else
    wind_cutl_ratio=(week_wind_cutl)/(week_wind_cutl+week_wind_power);
end

%典型周弃水率计算
week_hydro_cutl=sum(result.spring.hydro_cutl)+sum(result.summer.hydro_cutl)+sum(result.autumn.hydro_cutl)+sum(result.winter.hydro_cutl);
week_hydro_power=sum(result.spring.P_HD)+sum(result.summer.P_HD)+sum(result.autumn.P_HD)+sum(result.winter.P_HD);
if week_hydro_power==0
    hydro_cutl_ratio=0;
else
    hydro_cutl_ratio=(week_hydro_cutl)/(week_hydro_cutl+week_hydro_power);
end

%典型周光热弃电率计算
week_csp_cutl=sum(result.spring.csp_cutl)+sum(result.summer.csp_cutl)+sum(result.autumn.csp_cutl)+sum(result.winter.csp_cutl);
week_csp_power=sum(result.spring.P_CS)+sum(result.summer.P_CS)+sum(result.autumn.P_CS)+sum(result.winter.P_CS);
if week_csp_power==0
    csp_cutl_ratio=0;
else
    csp_cutl_ratio=(week_csp_cutl)/(week_csp_cutl+week_csp_power);
end

%全年发电机发电量推算
Y_sumload=sum(Powerdata.load(:)); %全年总负荷计算
Y_sumwind=sum(Powerdata.wind(:))*(1-wind_cutl_ratio); %全年风电发电量推算
Y_sumphoto=sum(Powerdata.photo(:))*(1-photo_cutl_ratio); %全年光伏发电量推算
Y_sumhydro=sum(Powerdata.hydro(:))*(1-hydro_cutl_ratio); %全年水电发电量计算
Y_sumnuclear=sum(Powerdata.nuclear(:)); %全年核电发电量计算
Y_sumcsp=sum(Powerdata.csp(:))*(1-csp_cutl_ratio);
Y_sumLflow=sum(Powerdata.Lflow(:)); %全年联络线输出功率计算
Y_sumgen=Y_sumload+Y_sumLflow-Y_sumwind-Y_sumphoto-Y_sumhydro-Y_sumnuclear-Y_sumcsp; %全年火电发电量推算

%典型周发电机发电量推算全年燃料消耗 碳排放量
%运行煤耗
week_sumcoal=result.spring.operation_coal+result.summer.operation_coal+result.autumn.operation_coal+result.winter.operation_coal;
week_sumCG=sum(result.spring.P_CG(:))+sum(result.summer.P_CG(:))+sum(result.autumn.P_CG(:))+sum(result.winter.P_CG(:));
week_sumGS=sum(result.spring.P_GS(:))+sum(result.summer.P_GS(:))+sum(result.autumn.P_GS(:))+sum(result.winter.P_GS(:));
week_sumBO=sum(result.spring.P_BO(:))+sum(result.summer.P_BO(:))+sum(result.autumn.P_BO(:))+sum(result.winter.P_BO(:));
%启停煤耗
week_sumupdowncoal=result.spring.updown_cost+result.summer.updown_cost+result.autumn.updown_cost+result.winter.updown_cost;
%全年煤耗计算
Y_coal_consumption=week_sumcoal*Y_sumgen/(week_sumCG+week_sumGS+week_sumBO)+week_sumupdowncoal*parameter.day_num/(size(parameter.dayindex,1)*size(parameter.dayindex,2));
%燃气耗量
week_sumgas=result.spring.operation_gas+result.summer.operation_gas+result.autumn.operation_gas+result.winter.operation_gas;
%全年燃气耗量计算
Y_gas_consumption=week_sumgas*Y_sumgen/(week_sumCG+week_sumGS+week_sumBO);
%生物质耗量
week_sumbio=result.spring.operation_bio+result.summer.operation_bio+result.autumn.operation_bio+result.winter.operation_bio;
%全年生物质耗量计算
Y_bio_consumption=week_sumbio*Y_sumgen/(week_sumCG+week_sumGS+week_sumBO);

%全年数据保存
result.year.C_emmission=Y_coal_consumption*parameter.Cemission+Y_gas_consumption*parameter.GSemission+Y_bio_consumption*parameter.BOemission; %碳排量单位：千克
result.year.coal_consumption=Y_coal_consumption;
result.year.gas_consumption=Y_gas_consumption;
result.year.bio_consumption=Y_bio_consumption;
result.year.load=Y_sumload;
result.year.wind=Y_sumwind;
result.year.photo=Y_sumphoto;
result.year.hydro=Y_sumhydro;
result.year.nuclear=Y_sumnuclear;
result.year.csp=Y_sumcsp;
result.year.Lflow=Y_sumLflow;
result.year.CG=Y_sumgen*week_sumCG/(week_sumCG+week_sumGS+week_sumBO);
result.year.GS=Y_sumgen*week_sumGS/(week_sumCG+week_sumGS+week_sumBO);
result.year.BO=Y_sumgen*week_sumBO/(week_sumCG+week_sumGS+week_sumBO);

%典型周数据保存
result.week.sumcoal=week_sumcoal+week_sumupdowncoal; %典型周煤耗之和
result.week.sumgas=week_sumgas; %典型周燃气耗量之和
result.week.sumbio=week_sumbio; %典型周生物质耗量之和
result.week.sumCG=week_sumCG; %典型周火电功率
result.week.sumGS=week_sumGS; %典型周燃气功率
result.week.sumBO=week_sumBO; %典型周生物质功率
result.week.photo_cutl=week_photo_cutl; %典型周弃光
result.week.photo=week_photo_power; %典型周光伏功率
result.week.photo_cutl_ratio=photo_cutl_ratio; %典型周弃光率
result.week.wind_cutl=week_wind_cutl; %典型周弃风
result.week.wind=week_wind_power; %典型周风电功率
result.week.wind_cutl_ratio=wind_cutl_ratio; %典型周弃风率
result.week.hydro_cutl=week_hydro_cutl; %典型周弃水
result.week.hydro=week_hydro_power; %典型周水电功率
result.week.hydro_cutl_ratio=hydro_cutl_ratio; %典型周弃水率
result.week.csp_cutl=week_csp_cutl; %典型周光热弃电
result.week.csp=week_csp_power; %典型周光热功率
result.week.csp_cutl_ratio=csp_cutl_ratio; %典型周光热弃电率

end

