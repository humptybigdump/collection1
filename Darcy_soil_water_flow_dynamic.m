% function to calculate soil water flux and change in soil moisture
% based on given soil moisture data in different depths
% makes use of van-Genuchten-Mualem and Pedo transferfunction of Carsel and
% Parrisch

% Define soil hydraulic functions
%-----------------------------------------------------------------------
%   soil typ after  Carsel & Parrish (1988)
%   Van-Genuchten(1980)-Mualem(1976)-Parametrization
%
%     Typ  Silt Sand clay   thr     ths   alpha    n       ks
%                          [-]     [-]   [1/cm]  [-]    [cm/h]
%
%   1    C   30  15  55   0.068   0.38   0.008   1.09    0.200
%   2   CL   37  30  33   0.095   0.41   0.019   1.31    0.258
%   3    L   40  40  20   0.078   0.43   0.036   1.56    1.042
%   4   LS   13  81   6   0.057   0.43   0.124   2.28   14.592
%   5    S    4  93   3   0.045   0.43   0.145   2.68   29.700
%   6   SC   11  48  41   0.100   0.38   0.027   1.23    0.121
%   7  SCL   19  54  27   0.100   0.39   0.059   1.48    1.308
%   8   SI   85   6   9   0.034   0.46   0.016   1.37    0.250
%   9  SIC   48   6  46   0.070   0.36   0.005   1.09    0.021
%  10 SICL   59   8  33   0.089   0.43   0.010   1.23    0.071
%  11  SIL   65  17  18   0.067   0.45   0.020   1.41    0.450
%  12   SL   26  63  11   0.065   0.41   0.075   1.89    4.421
%-----------------------------------------------------------------------


%----------------Intialisation 
% Select soil hydraulic parameter of soil of interest Sand S 
thr=0.045; % residual water content 
ths=0.43; % saturated soil water content
alpha=1.41;
n_vg=2.68;
ks= 29.7    /(100*3600);% saturated hydraulic conductivity
l_vg=0.5;
t_max= 1500;% maximum simulation time
t_start=0; %start of the simulation
dt=10;
i_time=1; % a counter for each times
% define and initialize variables of interest
z=-[0.05:0.05:1]'; % vertical coordinate of grid nodes/ TDR probes
dim=length(z);


% specify initial soil moisture profile 
ip=find(z >=-0.1); 
theta_high=0.40;
theta_low=0.1;
d_theta=(theta_high-theta_low)/length(ip);
theta_l=theta_low*ones(dim,1);
theta_l(ip)=[theta_high:-d_theta:theta_low+d_theta]; % observed soil water content
% C
psi_l=zeros(dim,1); % matric potential
k_l=zeros(dim,1); % soil hydraulic conductivity
q_geo=zeros(dim-1,1); % soil water flux using the geometric mean
q_har=zeros(dim-1,1); % soil water flux using the harmonic mean
q_ari=zeros(dim-1,1); % soil water flux using the aritmetric mean

% Process "loop??" 
time=t_start; % initialise simulation time

figure;
while time < t_max
%Calculate psi and k based on theta values for all nodes within z 
 
for i=1:dim
    [k_l(i) psi_l(i)]=k_psi_theta(theta_l(i),thr,ths,alpha,n_vg,l_vg,ks);
end
% 
% calculate Darcy flux at inner nodes
for i=1:dim-1
    % flux based on the geometric mean 
    q_geo(i)=-sqrt(k_l(i)*k_l(i+1))*((psi_l(i+1)-psi_l(i))/(z(i+1)-z(i))+1);
    % flux based on the aritmetric mean 
    q_ari(i)=-0.5*(k_l(i)+k_l(i+1))*((psi_l(i+1)-psi_l(i))/(z(i+1)-z(i))+1);
    
end

% Update soil water content
for i=2:dim-1
    % flux based on the geometric mean 
    theta_l(i)=theta_l(i)-dt*(q_geo(i-1)-q_geo(i))/(z(i-1)-z(i));
end
time=time+dt;
subplot(2,2,1);
plot(theta_l,z,'b-');
xlabel('Soil water content [-]','fontsize',16);
ylabel(' z [m]','fontsize',16);
set(gca,'linewidth',2, 'fontsize',16);
axis([thr ths 1.1*min(z) 0.9*max(z) ]);
title([ num2str(time) ' s'], 'fontsize', 16);
subplot(2,2,2);
plot(psi_l,z,'g-','linewidth',2);
xlabel('Matric potential [m]','fontsize',16);
axis([1.1*min(psi_l) 0.9*max(psi_l)  1.1*min(z) 0.9*max(z) ]);
ylabel(' z[m]','fontsize',16);
set(gca,'linewidth',2, 'fontsize',16);

subplot(2,2,3);
plot(q_geo(1:dim-1),z(1:dim-1),'r-','linewidth',2);
ylim([1.1*min(z) 0.9*max(z)]);
xlabel('Darcy flux [m/s]','fontsize',16);
ylabel('z[m]','fontsize',16);
set(gca,'linewidth',2, 'fontsize',16);

subplot(2,2,4);
plot(q_geo(1:dim-1)./theta_l(1:dim-1),z(1:dim-1),'r-','linewidth',2);
ylim([1.1*min(z) 0.9*max(z)]);
xlabel('v [m/s]','fontsize',16);
ylabel('z[m]','fontsize',16);
set(gca,'linewidth',2, 'fontsize',16);
MM(i_time)=getframe;
i_time=i_time+1;
end
% Predict soil moisture change within model domain using Darcy fluxes and boundary fluxes 



% subplot(2,2,1);
% plot(theta_l,z,'o');
% xlabel('Soil water content [-]','fontsize',16);
% ylabel(' z [m]','fontsize',16);
% set(gca,'linewidth',2, 'fontsize',16);
% axis([thr ths 1.1*min(z) 0.9*max(z) ]);
% subplot(2,2,2);
% plot(psi_l,z,'x','linewidth',2);
% xlabel('Matric potential [m]','fontsize',16);
% axis([1.1*min(psi_l) 0.9*max(psi_l)  1.1*min(z) 0.9*max(z) ]);
% ylabel(' z[m]','fontsize',16);
% set(gca,'linewidth',2, 'fontsize',16);
% 
% subplot(2,2,3);
% plot(q_geo(1:dim-1),z(1:dim-1),'rx','linewidth',2);
% hold on;
% plot(q_ari(1:dim-1),z(1:dim-1),'bo','linewidth',2);
% ylim([1.1*min(z) 0.9*max(z)]);
% xlabel('Darcy flux [m/s]','fontsize',16);
% ylabel('z[m]','fontsize',16);
% set(gca,'linewidth',2, 'fontsize',16);