clear all;
marker_size=12;
linewidth=2;
fontsize=16;
set(0,'DefaultAxesFontName','Helvetica','DefaultAxesFontSize',fontsize);
%------------------------------------------------------------------%
%
% solve a one-dimensional, linear advection equation, using
% the finite volume method.
%
% x=[0,1] with periodic boundary conditions.
%
% \phi_{,t}+u*\phi_x=0
%
% initial condition:
%
%  \phi(x,t=0)=
%
%  4*(x-0.25) if 0.25<=x<0.50
%  4*(0.75-x) if 0.50<=x<0.75
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
%the convection speed "u" is set to unity:
u=1;
%
%value for the parameter sigma=u*dt/dx (CFL number):
sigma=0.5;
%
% the type of numerical flux to be used [central or upwind]:
num_flux='central';
%num_flux='upwind';
%
%number of time steps: 
ntime=100;
%
%number of grid points in x:
nx=50;
%
%length of the domain: x \in [0,Lx]
Lx=1;
%
%
%the nodes of the uniform grid:
x=Lx*((1:nx)-1)/(nx);
dx=x(2)-x(1);
%
% -> from values for sigma, u, dx => get "dt=sigma*dx/u":
dt=sigma*dx/u;
%
disp(sprintf('Solving the 1D advection equation.'))
disp(sprintf('flux: %s',num_flux))
disp(sprintf('running with parameters:'))
disp(sprintf('sigma=%g, nx=%d, ntime=%d',sigma,nx,ntime))
%
%define the variable vector & flux vector:
phi=zeros(nx,1);
flux=zeros(nx+1,1);   %note: we have one more interface than cells;
                      %but because of periodicity, the last will 
                      %be identical to the first!
%
% initialize the solution (external MATLAB function):
[phi]=initial_solution(x);
%
% ------------------------------------------------------
nxplot=500; % for plotting the reference solution
xplot=Lx*((1:nxplot)-1)/(nxplot);
f1=figure;a1=axes;
%
% loop over the number of time steps:
for n=1:ntime
  %
  %compute the fluxes for each cell-face:
  for iface=1:nx+1
    if strcmp(num_flux,'central')
      [flux(iface)]=flux_central(u,phi,iface,nx);
    else
      [flux(iface)]=flux_upwind(u,phi,iface,nx);
    end
  end
  %
  %update the solution explicitly using the formula:
  % phi(xi,(n+1)*dt)=phi(xi,n*dt)-dt/(dx)*
  %                 {flux(xi+1/2,n*dt)-flux(xi-1/2,n*dt)}
  for icell=1:nx
    ileft=icell;
    iright=icell+1;
    phi(icell)=phi(icell)-(dt/dx)*(flux(iright)-flux(ileft));
  end
  if idebug==1
    %compute the reference solution: 
    time=dt*n;
    [phi_ref]=initial_solution(mod(xplot-u*time,1));
    %plotting:
    plot(x,phi,'r-x');hold on;
    plot(xplot,phi_ref,'k-');hold off;
    set(a1,'XLim',[0 1],'YLim',[-.5 1.5]);
    xlabel('x');ylabel('\phi');
    integralPhi=sum(phi)*dx;
    title(sprintf('integral of phi: %15.8e',integralPhi));
    pause(0.2)
  end
end
%
close(f1);
% ------------------------------------------------------
%
%compute the reference solution: 
% (1) assign the initial profile 
% (2) then translate it (taking into account periodicity)
time=dt*ntime;
[phi_ref]=initial_solution(mod(xplot-u*time,1));
%
% ------------------------------------------------------
%plot the result:
f1=figure;a1=axes;hold on;
plot(x,phi,'r-x');
plot(xplot,phi_ref,'k-');
xlabel('x');ylabel('\phi');
legend('numerical','reference');
title(sprintf('flux=%s, sigma=%g, nx=%d, ntime=%d',...
              num_flux,sigma,nx,ntime))
set(a1,'XLim',[0 1],'YLim',[-.5 1.5]);
% ------------------------------------------------------
