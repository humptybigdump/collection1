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
% Select soil hydraulic parameter of soil of interest  
thr=0.045; % residual water content of the soil
ths=0.43; % Porosity of the soil, water content at saturation
alpha=1.45; % Air entry value in 1/m
n_vg=2.68; % width ot the pore size distribution
ks= 29.7    /(100*3600);% saturated hydraulic conductivity
l_vg=0.5;

% Set parameters for time loop
dt=5; % time step in seconds

% define and initialize variables of interest
z=-[0.05:0.05:1]'; % vertical coordinate of grid nodes
dim=length(z);

% specify initial soil moisture profile 
ip=find(z >=-0.3); 
theta_high=0.4;
theta_low=0.2;
d_theta=(theta_high-theta_low)/length(ip);
theta_l=theta_low*ones(dim,1);
theta_l(ip)=[theta_high:-d_theta:theta_low+d_theta]; % observed soil water content

% define variables of interest
psi_l=zeros(dim,1); % matric potential
k_l=zeros(dim,1); % soil hydraulic conductivity
q_geo=zeros(dim-1,1); % soil water flux using the geometric mean
q_har=zeros(dim-1,1); % soil water flux using the harmonic mean
q_ari=zeros(dim-1,1); % soil water flux using the aritmetric mean

%Calculate soil hydraulic conductivity and the soil water potential as
%function of soil water content

for j=1:dim
    [k_l(j) psi_l(j)]=k_psi_theta(theta_l(j),thr,ths,alpha,n_vg,l_vg,ks);

end

% calculate the darcy flux the flow velocity using forward finite
% differences

for j=1:dim-1 
    q_geo(j)=-sqrt(k_l(j+1)*k_l(j))*((psi_l(j+1)-psi_l(j))/(z(j+1)-z(j))+1);
    v(j)=q_geo(j)/theta_l(j);
end    

for j=2:dim-1
    theta_l(j)=theta_l(j)-dt/(z(j)-z(j-1))*(q_geo(j)-q_geo(j-1));
end

bla=1;