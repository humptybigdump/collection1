     % Simulates solute transport under steady state conditions

clear all;
close all;

% set model parameters
D=7.9e-9;    % dispersion coefficient m^2/s -> come from tracer experiments (method of moments)
v=1e-7/0.35 ;    % average transport velocity m/s -> come from tracer experiments (method of moments)
Z_fix=1;   % select depth for plotting C(Z_fix,time)
dt= 1*86400;% timestep with in s
max_time= 100*86400; % maximum transport time s
dz=0.05; %grid  size m
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
   C_sim_cons(i,n)=1/(sqrt(4*pi*D*t_trans))...
       *exp(-(z(i)-v*t_trans)^2/(4*D*t_trans));

end

plot(C_sim_cons(:,n),-z,'r-','linewidth',2);

hold off;
xlabel(' normalized Concentration [1/m^3],','fontsize',14);
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

