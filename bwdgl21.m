function dy = bwdgl1(t, y)

%*******************************************************************
% Aufruf durch ode-Loesungsprogramm
%
% Definition des DGS der Bewegungsgleichungen des Satelliten im qiS
%
%  y= (    x,     y,     z,  dx/dt,  dy/dt,  dz/dt): Ergebnisvektor
% dy=  (dx/dt, dy/dt, dz/dt, dx/dtt, dy/dtt, dz/dtt)
%*******************************************************************


global K
K= K + 1;


dy= zeros(6,1);

dy(1:3)= y(4:6);
dy(4:6)= evkft21(y(1:6), t);			% grad(V) im qiS
