clc;
clear;
close all;

%% -----------------------------
% OPEN CIRCUIT TEST
%% -----------------------------

Voc = 221677;
Ioc = 74448;
Poc = (Voc * Ioc)/2;

%% -----------------------------
% SHORT CIRCUIT TEST
%% -----------------------------

Vsc = (72781 + 76115)/5;
Isc = 72781 + 76115*3;
Psc = (Vsc * Isc)/5;

%% -----------------------------
% EQUIVALENT CIRCUIT (PRIMARY)
%% -----------------------------

Rc = Voc^2 / Poc;
Iw = Poc / Voc;
Im = sqrt(Ioc^2 - Iw^2);
Xm = Voc / Im;

Zeq = Vsc / Isc;
Req = Psc / Isc^2;
Xeq = sqrt(Zeq^2 - Req^2);

disp('PRIMARY REFERRED PARAMETERS')
fprintf('Rc = %.6f Ohm\n',Rc);
fprintf('Xm = %.6f Ohm\n',Xm);
fprintf('Req = %.6f Ohm\n',Req);
fprintf('Xeq = %.6f Ohm\n',Xeq);

%% -----------------------------
% SECONDARY REFERRED
%% -----------------------------

V1 = Voc + 60;
V2 = V1 * 4;
a = V1 / V2;

Rc2 = Rc / a^2;
Xm2 = Xm / a^2;
Req2 = Req / a^2;
Xeq2 = Xeq / a^2;

disp('SECONDARY REFERRED PARAMETERS')
fprintf('Rc2 = %.6f Ohm\n',Rc2);
fprintf('Xm2 = %.6f Ohm\n',Xm2);
fprintf('Req2 = %.6f Ohm\n',Req2);
fprintf('Xeq2 = %.6f Ohm\n',Xeq2);

%% -----------------------------
% LOAD STUDY
%% -----------------------------

S = 2000:100:5000;
pf = [1 0.8 0.8];
phi = [0 acos(0.8) -acos(0.8)];
labels = ["Unity","Lagging","Leading"];

Pcore = Poc;

for k = 1:3
    
    for i = 1:length(S)
        
        I2(i) = S(i)/V2;
        Pout(i) = S(i)*pf(k);
        Pcu(i) = I2(i)^2 * Req;
        
        eta(i) = Pout(i)/(Pout(i)+Pcore+Pcu(i));
        
        VR(i) = (I2(i)*Req*cos(phi(k)) + ...
                 I2(i)*Xeq*sin(phi(k))) / V2 * 100;
    end
    
    % Efficiency
    figure
    plot(I2,eta,'LineWidth',2)
    grid on
    xlabel('Load Current (A)')
    ylabel('Efficiency')
    title(['Efficiency - ',char(labels(k))])
    savefig(['Efficiency_',char(labels(k)),'.fig'])
    
    % Voltage Regulation
    figure
    plot(I2,VR,'LineWidth',2)
    grid on
    xlabel('Load Current (A)')
    ylabel('Voltage Regulation (%)')
    title(['Voltage Regulation - ',char(labels(k))])
    savefig(['VoltageReg_',char(labels(k)),'.fig'])
    
    % Losses
    figure
    plot(I2,Pcu,'r','LineWidth',2)
    hold on
    plot(I2,ones(size(I2))*Pcore,'b','LineWidth',2)
    grid on
    legend('Copper Loss','Core Loss')
    xlabel('Load Current (A)')
    ylabel('Loss (W)')
    title(['Losses - ',char(labels(k))])
    savefig(['Losses_',char(labels(k)),'.fig'])
end