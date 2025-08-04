clc
clear
close all

lw = 2;
fs = 12;
rL = 0.05;
phiL = 0:0.25*pi:2*pi;

%% Parameters (SI Units)
par.L         = 1;
par.gamma     = 10;
par.m         = 1;

par.beta      = 10;

tspan     = [0 10];
psi0      = 1/2*pi;


%% Baumgarte DAE

options = odeset('Mass',@(t,y) Mass(t,y,par));
%options = odeset('Mass',@(t,y) Mass(t,y,par),'RelTol',1e-8,'AbsTol',1e-8);
[t0,sol0] = ode15s(@(t,y) dae_BG(t,y,par),tspan,[par.L*sin(psi0) par.L*cos(psi0) 0 0 0],options);

%% Minimal Coordinates
[tm,solm] = ode45(@(t,y) ode_min(t,y,par),tspan,[psi0 0]);


%% Interpolation
t    = linspace(tspan(1),tspan(2),length(tm));
sol0 = interp1(t0,sol0,t);
solm = interp1(tm,solm,t);

x0      = sol0(:,1);
y0      = sol0(:,2);
vx0     = sol0(:,3);
vy0     = sol0(:,4);
lambda0 = sol0(:,5);
xm      =  par.L*sin(solm(:,1));
ym      = -par.L*cos(solm(:,1));
vxm     =  par.L*solm(:,2).*cos(solm(:,1));
vym     =  par.L*solm(:,2).*sin(solm(:,1));

%% Animation
figure(1);
pos = get(gcf,'Position');
set(gcf,'color','white','position',[0.25*pos(1) 0.5*pos(2) 2*pos(3) pos(4)]);

% plot(t,xm);
% hold on;
% plot(t,x0,'-.');
% 
% legend("Minimal","Baumgarte")

for it=1:1%length(t)
clf

subplot(1,2,1)
fill(rL*par.L*cos(phiL),rL*par.L*sin(phiL),'black')
hold on
grid on
plot([0 x0(it)],[0 -y0(it)],'linewidth',2)
fill(x0(it)+rL*par.L*cos(phiL),-y0(it)+rL*par.L*sin(phiL),'red','EdgeColor','red')
plot(x0(1:it),-y0(1:it),'-.','color',[0.6 0.6 0.6]);
axis equal
axis([-1.5*par.L 1.5*par.L -1.5*par.L 1.5*par.L]);
xlabel("x-coordinate [m]",'FontSize',fs);
ylabel("y-coordinate [m]",'FontSize',fs);
title("Baumgarte DAE",'FontSize',fs);
set(gca,'FontSize',fs)

subplot(1,2,2)
fill(rL*par.L*cos(phiL),rL*par.L*sin(phiL),'black')
hold on
grid on
plot([0 par.L*sin(solm(it,1))],[0 -par.L*cos(solm(it,1))],'linewidth',2)
fill(par.L*sin(solm(it,1))+rL*par.L*cos(phiL),-par.L*cos(solm(it,1))+rL*par.L*sin(phiL),'red','EdgeColor','red')
plot(xm(1:it),ym(1:it),'-.','color',[0.6 0.6 0.6]);
axis equal
axis([-1.5*par.L 1.5*par.L -1.5*par.L 1.5*par.L]);
xlabel("x-coordinate [m]",'FontSize',fs);
ylabel("y-coordinate [m]",'FontSize',fs);
title("Minimal Coordinates",'FontSize',fs);
set(gca,'FontSize',fs)
drawnow
end


figure(2);
pos = get(gcf,'Position');
set(gcf,'color','white','position',[0.5*pos(1) 0.5*pos(2) 1.5*pos(3) pos(4)]);
plot(t,(par.m*par.L*solm(:,2).^2+par.m*par.gamma*cos(solm(:,1))).*sin(solm(:,1)),'blue','linewidth',lw);
hold on;
grid on;
plot(t,(par.m*par.L*solm(:,2).^2+par.m*par.gamma*cos(solm(:,1))).*cos(solm(:,1)),'red','linewidth',lw);
Z0 = lambda0.*[2*x0 2*y0];
plot(t,-Z0(:,1),'-.','color',[0 0.7 1],'linewidth',lw);
plot(t,-Z0(:,2),'-.','color',[1 0.7 0],'linewidth',lw);
l = legend("Minimal Coordinates Zx","Minimal Coordinates Zy","Baumgarte Zx","Baumgarte Zy");
set(l,'location','southoutside','Orientation','horizontal')
xlabel("time t [s]",'FontSize',fs);
ylabel("Reaction Force Z [N]",'FontSize',fs);
title("Reaction Force over Time (Index 1 (hidden) Constraint)",'FontSize',fs);
set(gca,'FontSize',fs)
axis([0 t(end) -40 80])


figure(3);
pos = get(gcf,'Position');
set(gcf,'color','white','position',[0.5*pos(1) 0.5*pos(2) 2*pos(3) pos(4)]);

subplot(1,2,1);
plot(t,2*xm.*vxm + 2*ym.*vym,'linewidth',lw);
hold on;
grid on;
plot(t,2*x0.*vx0 + 2*y0.*vy0,'-.','linewidth',lw);
axis([0 t(end) -2 2])
l = legend("Minimal Coordinates","Baumgarte");
set(l,'Location','southWest');
xlabel("time t [s]",'FontSize',fs);
ylabel("Constraint Value [m^2/s]",'FontSize',fs);
title("Index 2 (hidden) Constraint",'FontSize',fs);
set(gca,'FontSize',fs)

subplot(1,2,2);
plot(t,xm.^2 + ym.^2-par.L^2,'linewidth',lw);
hold on;
grid on;
plot(t,x0.^2 + y0.^2-par.L^2,'-.','linewidth',lw);
axis([0 t(end) -2 2])
l = legend("Minimal Coordinates","Baumgarte");
set(l,'Location','southWest');
xlabel("time t [s]",'FontSize',fs);
ylabel("Constraint Value [m^2]",'FontSize',fs);
title("Index 3 (hidden) Constraint",'FontSize',fs);
set(gca,'FontSize',fs)


%% Functions
function M = Mass(t,y,par)
 M  = zeros(5,5);
 M(1:2,1:2) = eye(2,2);
 M(3:4,3:4) = par.m*eye(2,2);
 M(5,3:4)   = [2*y(1) 2*y(2)];
end
function dy = dae_BG(t,y,par)
 % y = [x y vx vy lambda]
 g      = y(1)^2+y(2)^2-par.L^2;
 G      = [2*y(1) 2*y(2)];
 dG     = [2*y(3) 2*y(4)]; 
 dy = [ y(3);
        y(4);
        G.'*y(5)+[0;par.gamma];
        -dG*y(3:4)-2*par.beta*G*y(3:4)-par.beta^2*g];

end
function dy = ode_min(t,y,par)
 dy = [y(2);
       -par.gamma/par.L*sin(y(1))];
end