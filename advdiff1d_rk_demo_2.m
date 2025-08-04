clear all;
marker_size=12;
linewidth=2;
fontsize=16;
set(0,'DefaultAxesFontName','Helvetica','DefaultAxesFontSize',fontsize);
%------------------------------------------------------------------%
%
% solve a one-dimensional, linear advection-diffusion equation, using
% the finite volume method.
%
% x=[0,1] with periodic boundary conditions.
%
% \phi_{,t}+u*\phi_x=\nu*\phi_{,xx}
%
% initial condition:
%
%  \phi(x,t=0)=sin(kx*x) with: kx=cst (wavenumber)
%
% the grid is uniform and cell-faces are mid-way between grid centers:
%
%face: 1       2               i      i+1                     n+1
%      |---x---|---x---|---x---|---x---|---x---|---x---|---x---|
%cell:     1              i-1      i      i+1              n
%     x=0                                                     x=1
%------------------------------------------------------------------%
idebug=1; % "1" -> pauses after each time step for plotting
%
% the parameters of the initial solution:
kx=2*pi;
%
%the convection speed "u" is set to unity:
u=1;
%
%value for the parameter sigma=u*dt/dx (CFL number):
sigma=1.5;
%
%value for the parameter beta=dt*nu/dx^2 (CFL / cell-Reynolds-number)
beta=.1;
%
% the type of temporal scheme: 
time_scheme='explicit_euler';
%time_scheme='runge_kutta2';
%time_scheme='runge_kutta3';
%
%define the coefficients of the time integration:
if strcmp(time_scheme,'explicit_euler')
  % explicit euler scheme (1st order accurate in time):
  alpha_k=[1];
elseif strcmp(time_scheme,'runge_kutta2')
  % 2-step runge-kutta method:
  alpha_k=[1/2,1];
elseif strcmp(time_scheme,'runge_kutta3')
  % 3-step runge-kutta method:
  alpha_k=[1/3,1/2,1];
end
%
%number of time steps: 
ntime=200;
%
%number of grid points in x:
nx=20;
%
%length of the domain: x \in [0,Lx]
Lx=1;
%
%the nodes of the uniform grid:
x=Lx*((1:nx)-1)/(nx);
dx=x(2)-x(1);
%
% -> from values for sigma, u, dx 
% => get "dt=sigma*dx/u":
% => get "nu=beta*dx^2/dt":
dt=sigma*dx/u;
nu=beta*dx^2/dt;
%
disp(sprintf('linear advection-diffusion equation.'))
disp(sprintf('temporal scheme: %s',time_scheme))
disp(sprintf('running with parameters:'))
disp(sprintf('sigma=%g, beta=%g, Re_d_x=%g,nx=%d, ntime=%d',...
             sigma,beta,u*dx/nu,nx,ntime))
if strcmp(time_scheme,'explicit_euler')
  if sigma^2>2*beta | 2*beta>1
    disp(sprintf('theoretically unstable!'))
  end
elseif strcmp(time_scheme,'runge_kutta2')
  %graphical evaluation of stability:
  [f1,h1]=plot_rk2_stab(sigma,beta);
  pause 
elseif strcmp(time_scheme,'runge_kutta3')
  %graphical evaluation of stability:
  [f1,h1]=plot_rk3_stab(sigma,beta);
  pause 
end
  
%
%define the variable vector & flux vector:
phi=zeros(nx,1);
flux=zeros(nx+1,1);   %note: we have one more interface than cells;
                      %but because of periodicity, the last will 
                      %be identical to the first!
gflux=zeros(nx+1,1);   %diffucie flux
%
% initialize the solution (external MATLAB function):
[phi]=initial_solution(x,kx);
%
% ------------------------------------------------------
nxplot=500; % for plotting the reference solution
xplot=Lx*((1:nxplot)-1)/(nxplot);
f1=figure;a1=axes;
%
% loop over the number of time steps:
for n=1:ntime
  %
  phi_n=phi; %save the previous time-step solution.
  %
  %loop over runge-kutta sub-steps:
  for krk=1:length(alpha_k)
    %compute the fluxes for each cell-face:
    for iface=1:nx+1
      [flux(iface)] =convective_flux_central(u,phi,iface,nx);
      [gflux(iface)]=viscous_flux_central(nu,phi,iface,dx,nx);
    end
    %
    %update the solution explicitly using the formula:
    % phi(xi,(n+1)*dt)=phi(xi,n*dt)-dt/(dx)*
    %                 {flux(xi+1/2,n*dt)-flux(xi-1/2,n*dt)}
    %                 +dt/(dx)*{gflux(xi+1/2,n*dt)-gflux(xi-1/2,n*dt)}
    for icell=1:nx
      ileft=icell;
      iright=icell+1;
      phi(icell)=phi_n(icell)-...
          (alpha_k(krk)*dt/dx)*(flux(iright)-flux(ileft))+...
          (alpha_k(krk)*dt/dx)*(gflux(iright)-gflux(ileft));
    end
  end
  if idebug==1
    %compute the reference solution: 
    time=dt*n;
    [phi_ref]=final_solution(xplot,kx,u,nu,time);
    %plotting:
    plot(x,phi,'r-x');hold on;
    plot(xplot,phi_ref,'k-');hold off;
    set(a1,'XLim',[0 1],'YLim',[-2 2]);
    xlabel('x');ylabel('\phi');
    pause(0.1)
  end
end
%
% ------------------------------------------------------
%
%compute the reference solution: 
time=dt*ntime;
[phi_ref]=final_solution(xplot,kx,u,nu,time);
%
%plot the result:
f1=figure;a1=axes;hold on;
plot(x,phi,'r-x');
plot(xplot,phi_ref,'k-');
xlabel('x');
ylabel('\phi');
legend('numerical','reference');
title(sprintf('scheme: %s, sigma=%g, beta=%g, Re_d_x=%g,nx=%d, ntime=%d',...
             time_scheme,sigma,beta,u*dx/nu,nx,ntime))
