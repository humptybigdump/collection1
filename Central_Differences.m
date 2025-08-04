clc
clear
close all

lw = 2;
fs = 14;

%% Parameters
par.D  = 0.0;
par.om = 1;


%% Simulation
tspan = [0 100];
IC    = [1 0];

options = odeset();
options.StepWidth = 2/par.om+0.1;
options.par = par;


[t0,y0]    = ode45(          @(t,y) test_ode(t,y,par),tspan,IC,options);
[t1,y1]    = CentralDiff( @(t,y) test_ode(t,y,par),tspan,IC,options);


%% Plotting
figure(1);
pos = get(gcf,'position');
set(gcf,'Color','white','Position',[0.25*pos(1) 0.25*pos(2) 2*pos(3) 2*pos(4)]);

subplot(2,1,1);
p(1) = plot(t1,y1(:,1),'-.','LineWidth',lw);
hold on;
grid on;
p(end+1) = plot(t0,y0(:,1),'LineWidth',lw);
xlabel("time t [s]",'FontSize',fs);
ylabel("state variable z [-]",'FontSize',fs);
title("Results for different numerical integration methods")
set(gca,'fontsize',fs);
l = legend(p,"Central Differences","ode45");
set(l,'fontsize',fs,'Location','southeast');
%axis([tspan -3.5*IC(1) 3.5*IC(1)])

y0I = interp1(t0,y0,t1);
% 
subplot(2,1,2);
plot(t1,abs(y1(:,1)-y0I(:,1)),'-.','LineWidth',lw);
hold on;
grid on;
xlabel("time t [s]",'FontSize',fs);
ylabel("difference |uCD - u45| [-]",'FontSize',fs);
title("Difference between CD Method and ODE45")
set(gca,'fontsize',fs);
% l = legend(p2,"CD","AM2","AM3","AM4");
% set(l,'fontsize',fs,'Location','southeast');
axis([tspan 0 1])

%% Functions
function dy = test_ode(t,y,par)
 dy = [y(2);
       -2*par.D*par.om*y(2)-par.om^2*y(1)];
end

function [t,y] = CentralDiff(ode,tspan,IC,options)
 h = options.StepWidth;
 par = options.par;
 foptions = optimset('Display','off');
 t = tspan(1):h:tspan(2);
 y = zeros(length(t),size(IC,2));
 y(1,:) = IC;
 for i1=1:length(t)-1 % Main time loop
    y(i1+1,:) = fsolve(@(x) CDImplicit(x,y,par,h,i1,IC),y(i1,:),foptions);  
 end
end

function res = CDImplicit(x,y,par,h,i1,IC)
   if i1==1
     ym1 = -IC(2)*h+IC(1);
     res = (x - 2*y(i1,:) + ym1) +par.D*par.om*h*(x-ym1)+par.om^2*h^2*y(i1,:);
   else
     res = (x - 2*y(i1,:) + y(i1-1,:)) +par.D*par.om*h*(x-y(i1-1,:))+par.om^2*h^2*y(i1,:);
   end
end

