price=zeros(7,4,8760);

for j=1:7 % case
    for k=1:4 % 容量
        OPEX_ESS=[37 40];% RMB/MW
        price_fuel=[0.478 0.478 0.478 2.63 1.26];% RMB/kg RMB/Nm3 RMB/kg
        OPEX_fuel=[363 293 322 110 615];% kg/MWh Nm3/MWh kg/MWh
        CEF_fuel=[1035 835 919 312 350];% kg/MWh
        CAP=[269241 221466 39056];% MW
        CAPEX=[6e6*0.7 4e6*0.62 0e6*0.62];% RMB/MW
        P_ESSC=xlsread(strcat('ESSC-',num2str(j),'.xlsx'),k,'A1:B8760');
        P_ESSD=xlsread(strcat('ESSD-',num2str(j),'.xlsx'),k,'A1:B8760');
        P_CG=xlsread(strcat('CG-',num2str(j),'.xlsx'),k,'A1:C8760');
        P_GS=xlsread(strcat('GS-',num2str(j),'.xlsx'),k,'A1:A8760');
        P_BO=xlsread(strcat('BO-',num2str(j),'.xlsx'),k,'A1:A8760');
        P_WD=xlsread(strcat('WD-',num2str(j),'.xlsx'),k,'A1:A8760');
        P_PV=xlsread(strcat('PV-',num2str(j),'.xlsx'),k,'A1:A8760');
        P_CS=xlsread(strcat('CS-',num2str(j),'.xlsx'),k,'A1:A8760');

        for t=1:8760
            price(j,k,t)=((P_ESSC(t,1)+P_ESSD(t,1))*OPEX_ESS(1)+(P_ESSC(t,2)+P_ESSD(t,2))*OPEX_ESS(2)+...
                sum([P_CG(t,:) P_GS(t) P_BO(t)].*price_fuel.*OPEX_fuel))/(sum([P_CG(t,:) P_GS(t) P_BO(t)])+sum(P_ESSD(t,:))-sum(P_ESSC(t,:))+1e-8)+...
                sum(CAP.*CAPEX*0.02*0.0872./sum([P_WD P_PV P_CS],1));
        end
        price(j,k,:)=price(j,k,:)*0.2829*8760/sum(price(j,k,:));% RMB/kWh
        
        xlswrite(strcat('spotprice-',num2str(j),'.xlsx'),reshape(price(j,k,:),8760,1),k,'A1:A8760');
    end
end