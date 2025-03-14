function [result]=season_classification(result,costoutput,W_PV_cutl,W_WD_cutl,W_HD_cutl,W_CS_cutl,W_PCG,W_PGS,W_PBO,W_PESSC,W_PESSD,W_PPV,W_PWD,W_PHD,W_PNC,W_PCS,x,sg,dg,season_index)
%机组组合输出结果储存至不同季节的结构体

if season_index==1
    result.spring.updown_cost=costoutput(1);
    result.spring.operation_coal=costoutput(2);
    result.spring.penalty_cost=costoutput(3);
    result.spring.Ecv=costoutput(4);
    result.spring.operation_gas=costoutput(5);
    result.spring.operation_bio=costoutput(6);
    result.spring.Egas=costoutput(7);
    result.spring.Ebio=costoutput(8);
    result.spring.ESS=costoutput(9);
    
    %弃风弃光保存
    result.spring.photo_cutl=W_PV_cutl;
    result.spring.wind_cutl=W_WD_cutl;
    result.spring.hydro_cutl=W_HD_cutl;
    result.spring.csp_cutl=W_CS_cutl;
    
    %能源出力保存
    result.spring.P_CG=W_PCG;
    result.spring.P_GS=W_PGS;
    result.spring.P_BO=W_PBO;
    result.spring.P_ESSC=W_PESSC;
    result.spring.P_ESSD=W_PESSD;
    result.spring.P_PV=W_PPV;
    result.spring.P_WD=W_PWD;
    result.spring.P_HD=W_PHD;
    result.spring.P_NC=W_PNC;
    result.spring.P_CS=W_PCS;
    
    %机组启停、出力不平衡保存
    result.spring.x=x;
    result.spring.sg=sg;
    result.spring.dg=dg;
    
    %不平衡功率占比计算
    result.spring.sg_ratio=sum(sg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
    result.spring.dg_ratio=sum(dg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
elseif season_index==2
    result.summer.updown_cost=costoutput(1);
    result.summer.operation_coal=costoutput(2);
    result.summer.penalty_cost=costoutput(3);
    result.summer.Ecv=costoutput(4);
    result.summer.operation_gas=costoutput(5);
    result.summer.operation_bio=costoutput(6);
    result.summer.Egas=costoutput(7);
    result.summer.Ebio=costoutput(8);
    result.summer.ESS=costoutput(9);
    
    %弃风弃光弃水保存
    result.summer.photo_cutl=W_PV_cutl;
    result.summer.wind_cutl=W_WD_cutl;
    result.summer.hydro_cutl=W_HD_cutl;
    result.summer.csp_cutl=W_CS_cutl;
    
    %能源出力保存
    result.summer.P_CG=W_PCG;
    result.summer.P_GS=W_PGS;
    result.summer.P_BO=W_PBO;
    result.summer.P_ESSC=W_PESSC;
    result.summer.P_ESSD=W_PESSD;
    result.summer.P_PV=W_PPV;
    result.summer.P_WD=W_PWD;
    result.summer.P_HD=W_PHD;
    result.summer.P_NC=W_PNC;
    result.summer.P_CS=W_PCS;
    
    %机组启停、出力不平衡保存
    result.summer.x=x;
    result.summer.sg=sg;
    result.summer.dg=dg;
    
    %不平衡功率占比计算
    result.summer.sg_ratio=sum(sg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
    result.summer.dg_ratio=sum(dg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
elseif season_index==3
    result.autumn.updown_cost=costoutput(1);
    result.autumn.operation_coal=costoutput(2);
    result.autumn.penalty_cost=costoutput(3);
    result.autumn.Ecv=costoutput(4);
    result.autumn.operation_gas=costoutput(5);
    result.autumn.operation_bio=costoutput(6);
    result.autumn.Egas=costoutput(7);
    result.autumn.Ebio=costoutput(8);
    result.autumn.ESS=costoutput(9);
    
    %弃风弃光保存
    result.autumn.photo_cutl=W_PV_cutl;
    result.autumn.wind_cutl=W_WD_cutl;
    result.autumn.hydro_cutl=W_HD_cutl;
    result.autumn.csp_cutl=W_CS_cutl;
    
    %能源出力保存
    result.autumn.P_CG=W_PCG;
    result.autumn.P_GS=W_PGS;
    result.autumn.P_BO=W_PBO;
    result.autumn.P_ESSC=W_PESSC;
    result.autumn.P_ESSD=W_PESSD;
    result.autumn.P_PV=W_PPV;
    result.autumn.P_WD=W_PWD;
    result.autumn.P_HD=W_PHD;
    result.autumn.P_NC=W_PNC;
    result.autumn.P_CS=W_PCS;
    
    %机组启停、出力不平衡保存
    result.autumn.x=x;
    result.autumn.sg=sg;
    result.autumn.dg=dg;
    
    %不平衡功率占比计算
    result.autumn.sg_ratio=sum(sg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
    result.autumn.dg_ratio=sum(dg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
elseif season_index==4
    result.winter.updown_cost=costoutput(1);
    result.winter.operation_coal=costoutput(2);
    result.winter.penalty_cost=costoutput(3);
    result.winter.Ecv=costoutput(4);
    result.winter.operation_gas=costoutput(5);
    result.winter.operation_bio=costoutput(6);
    result.winter.Egas=costoutput(7);
    result.winter.Ebio=costoutput(8);
    result.winter.ESS=costoutput(9);
    
    %弃风弃光保存
    result.winter.photo_cutl=W_PV_cutl;
    result.winter.wind_cutl=W_WD_cutl;
    result.winter.hydro_cutl=W_HD_cutl;
    result.winter.csp_cutl=W_CS_cutl;
    
    %能源出力保存
    result.winter.P_CG=W_PCG;
    result.winter.P_GS=W_PGS;
    result.winter.P_BO=W_PBO;
    result.winter.P_ESSC=W_PESSC;
    result.winter.P_ESSD=W_PESSD;
    result.winter.P_PV=W_PPV;
    result.winter.P_WD=W_PWD;
    result.winter.P_HD=W_PHD;
    result.winter.P_NC=W_PNC;
    result.winter.P_CS=W_PCS;
    
    %机组启停、出力不平衡保存
    result.winter.x=x;
    result.winter.sg=sg;
    result.winter.dg=dg;
    
    %不平衡功率占比计算
    result.winter.sg_ratio=sum(sg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
    result.winter.dg_ratio=sum(dg)/(sum(W_PCG(:)) + sum(W_PGS(:)) + sum(W_PBO(:)));
end
    
end

