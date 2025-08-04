% Simulates solute transport under steady state conditions

clear all;
close all;

% set model parameters
D=1e-6 ;    % dispersion coefficient m^2/s -> come from tracer experiments (method of moments)
v= 5e-7/0.45;    % average transport velocity m/s -> come from tracer experiments (method of moments)
lambda=0/86400%
Z_fix=1;   % select depth for plotting C(Z_fix,time)
dt= 0.1*86400;% timestep with in s
max_time= 30*86400; % maximum transport time s
dz=0.01; %grid  size m
maxz=5; %maximum depth m
z_crit=Z_fix; %critical depth

z=[0+dz:dz:maxz]'; % simulation grid
C_sim_cons=zeros(length(z),floor(max_time/dt)); % transport of the conservative tracer allocate memory

%time=zeros((max_time/dt),1);

% Initialise transport time
t_trans=0; %s

figure;
n=1; %set counter for movieframe

while t_trans < max_time;
time(n)=t_trans;
for i=1:length(z)
    % code the Gaussiaon solution here
   % C_sim_cons(i,n)=; % correspondes to Cw*theta/m0
end

plot(C_sim_cons(:,n),-z,'r-','linewidth',2);

hold off;
xlabel(' normalized Concentration [1/m^3],','fontsize',14);
xlim([0 15]);
ylabel(' z [m]','fontsize',14);
title(['Concentration profile at time ' num2str(t_trans/3600) ' h,'],'fontsize',14);
set(gca,'fontsize',14,'linewidth',2);
t_trans=t_trans+dt;  % increase transport time 

Mbla(n)=getframe;                  %Frame to capture a movie (sequence of plots) --> if not, plots are not visualized during runtime
n=n+1;                             %increase counter for movieframe
end

idepth=find(abs(z-Z_fix) <0.01);

figure;
h2=plot(time(:)/3600,C_sim_cons(idepth,:),'r-','linewidth',2);
title(['Concentration in depth ' num2str(Z_fix) ' m as function of time'],'fontsize',14);
xlabel(' time [h]','fontsize',14);
ylabel(' normalized Concentration [1/m^3],','fontsize',14);
set(gca,'fontsize',14,'linewidth',2);

