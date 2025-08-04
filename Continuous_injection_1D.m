% Program Continuous_injection.m
%
% Development of continuous injection j at x=0 in 1D flow field.
% Heat flux j leads to temperature change DeltaT = j/(C_w*q)
% where j= Heat flux; C_w= volumetric heat capacity of water; q= specific
% water flux (Darcy flux).
%
% Calculation of 1D temperature time series for given observation location xx.  
% Calculation of 1D temperature profile for given time tt.
%
% Limit: Large values of arg3, e.g., very large values of xx.
%
% Version 12 March 2013                       Fritz Stauffer IfU ETH Zurich
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input of parameters
xx = 100.0;     % Observation location [m]
ut = 4;         % Thermal velocity [m/d]
Dt = 0.08;      % Thermal diffusion coefficient [m^2/d]
alpha = 10.0;   % Longitudinal thermal dispersivity [m]
T0 = 10.0;      % Initial temperature [K]
DeltaT = 3.0;   % Temperature change [K]
tmax = 100.0;   % Maximum time [d]
xmax = 200.0;   % Maximum x-coordinate for temperature profile [m]
tt = 20.0;      % Time for temperature profile T(x,tt) [d]%
DL = Dt + alpha*ut;     % Longitudinal dispersion coefficient
%
% Calculation of time series for given location xx and Figure 1
dt = tmax/500;
t= 1:1:tmax;            % Discrete time vector
T=zeros(1,251);
arg1 = ut*(xx-abs(xx))/(2*DL);
arg2 = (abs(xx)-ut*t)./sqrt(4*DL*t);
arg3 = ut*(xx+abs(xx))/(2*DL);
arg4 = (abs(xx)+ut*t)./sqrt(4*DL*t);
T = T0 + DeltaT/2*(exp(arg1).*erfc(arg2)-exp(arg3)*erfc(arg4));
figure;
    plot(t,T,'r');
    axis ([0 tmax (min((T0),(T0+DeltaT))-2) (max((T0+DeltaT),T0)+2)]);
    xlabel ('Time t [d]');
    ylabel ('Temperature [°C]');
    title (strcat('Temperature time series at location x=',num2str(xx),' m'));
    grid on;
%
% Calculation of temperature profile for time tt and Figure 2
dx = xmax/500;
x= 0:dx:xmax;            % x vector
T=zeros(1,251);
arg1 = ut.*(x-abs(x))/(2*DL);
arg2 = (abs(x)-ut*tt)./sqrt(4*DL*tt);
arg3 = ut.*(x+abs(x))/(2*DL);
arg4 = (abs(x)+ut*tt)./sqrt(4*DL*tt);
T = T0 + DeltaT/2*(exp(arg1).*erfc(arg2)-exp(arg3).*erfc(arg4));
figure;
    plot(x,T,'r');
    axis ([0 xmax (min((T0),(T0+DeltaT))-2) (max((T0+DeltaT),T0)+2)]);
    xlabel ('Location x [m]');
    ylabel ('Temperature [°C]');
    title (strcat('Temperature profile at time t=',num2str(tt),' d'));
    grid on;
% end
