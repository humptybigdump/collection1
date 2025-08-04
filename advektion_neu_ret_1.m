% Routine zur berechnung eines expliziten upstreaming verfahrens

% Definiere Gitter
dx=0.01;
x=[0:dx:2];
deltax=diff(x);
% Definiere parameter, Fliessgeschwindigkeit
v=1e-5;

lambda=0;%1/1000;% first order decay
b=0.5; % freundlich exponent
Kf=7.; % freundlich parameter characterising adsorption
C_lim=0.00001;
Cmax=1.1;
% Definiere Anfangszustand

C=zeros(1, length(x));
C_alt=zeros(1, length(x));
R=ones(1, length(x));
C_r=zeros(1, length(x));
C_ralt=zeros(1, length(x));

ip=find(x <= 0.5); 
C(ip)=Cmax*sin(pi*x(ip)/0.5);
C_alt=C;
C_r(ip)=C(ip);
C_ralt=C;
% Definiere Zeitschritte (denke an Courant)
tmax=5*86400; % maximum time
time=0.; % start time
itime=1;
C_ave=1;
C_amp=0.5;

%courant criterion
dt=1*min(deltax)/v;

% Zeitschleife, loese Arbeitsgleichung

figure;

while time < tmax
    % Definiere Randbedingungen (0.5
    C(1)=0; % for all times
  % C(1)=C_ave+C_amp*sin(pi*time/1000);%*rand(1) ;
    C(length(x))=C_alt(length(x)-1);
    for j=2:length(x)-1
        if b <1
            if C_ralt(j) > C_lim
                R(j)=1+b*Kf/(C_ralt(j))^(b);
            else
                R(j)=1+b*Kf/(C_lim)^(b);
            end
        else 
            R(j)=1+Kf;
        end
        C(j)=C_alt(j)-dt*v/(x(j)-x(j-1))*(C_alt(j)-C_alt(j-1))-dt*lambda*C_alt(j);
        C_r(j)=C_ralt(j)-dt*v/(R(j)*(x(j)-x(j-1)))*(C_ralt(j)-C_ralt(j-1))-dt*lambda*C_ralt(j);
        if C(j) < 0
            C(j)=0;
        end
        if C_r(j) < 0
            C_r(j)=0;
        end
    end
    C_alt=C;
    C_ralt=C_r;
    % Visualisierung
      plot(x,C,'b-','linewidth',2);
    hold on,
    plot(x,C_r,'r-','linewidth',2);
    xlim([0 2]);
    title([num2str(time/3600) ' h']);
    hold off;
    xlabel('x [m]');
    ylabel('C [kg/m^3]');
    axis([0 x(length(x)) 0 Cmax]);
    M(itime)=getframe;
    time=time+dt;
       itime=itime+1;
end


