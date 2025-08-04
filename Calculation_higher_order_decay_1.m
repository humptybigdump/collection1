%
%calculation of higher order decay
%dC/dt=rC
k=0.01;
dt=0.5/k;
time=0;
I= 50;% mg/m3
M=5;% mg/m3
C_ini=1/10*I;
n_time=100;
tmax=n_time*dt;
C=zeros(n_time,1);
C2=zeros(n_time,1);
C3=zeros(n_time,1);
C4=zeros(n_time,1);
t_vec=zeros(n_time,1);

C(1)=C_ini;
C2(1)=C_ini;
C3(1)=C_ini;
C4(1)=C_ini;
t_vec(1)=time;

for i=1:n_time-1 
    C(i+1)=C(i)-(k*C(i))*C(i)/(M+C(i))*I/(I+C(i))*dt;
    C2(i+1)=C2(i)-(k*C2(i))*C2(i)/(M+C2(i))*dt;
    C3(i+1)=C3(i)-(k*C3(i))*dt;
    time=time+dt;
    C4(i+1)=C4(i)-(k*C4(i))*I/(I+C4(i))*dt;
    t_vec(i+1)=dt*i;
end


figure;
h1=plot(t_vec,C,'r-','linewidth',2);
hold on;
h2=plot(t_vec,C2,'b-','linewidth',2);
h3=plot(t_vec,C3,'g-','linewidth',2);
h4=plot(t_vec,C4,'k-','linewidth',2);
titel=['C_i_n_i = ' num2str(C_ini) 'kg /m^3, M = ' num2str(M) ' kg /m^3, I = ' num2str(I)  ' kg /m^3'];
title(titel,'fontsize',14);
ylabel(' Concentration in water phase [g/m^3]','fontsize',14);
xlabel(' time [h] ','fontsize',14);
set(gca,'fontsize',14,'linewidth',2);
legend([h1 h2 h3 h4],'First*Mono*Inib','First*Mono','First','First*Ini');
%legend('First*Mono*Inib','First*Mono','First','First*Ini');
