clc
clear
close all

fs = 14;

c0 = 5000;

figure(1);
set(gcf,'color','white')
load("CT_ode23t.mat");
semilogx(c0*alpha_a,at,'marker','o','linewidth',2)
hold on
grid on

load("CT_ode45.mat")
semilogx(c0*alpha_a,at,'marker','o','linewidth',2)
hold on
grid on
axis([5*1e2 0.5*1e7 0 50])

set(gca,'fontsize',fs)
title("computational time vs. stiffness",'fontsize',fs)
xlabel("c [N/m]",'fontsize',fs);
ylabel("computation time [s]",'fontsize',fs);
L = legend("ode23t","ode45");
set(L,'fontsize',fs);
xticks([1e2 1e3 1e4 1e5 1e6 1e7])