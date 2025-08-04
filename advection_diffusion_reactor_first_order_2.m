% Routine to simulate mass balance of a diffusion reactor
% for a chemical/ contaminant which gets transformed by a first order
% reaction
%dD/dt= d/dx(D*dC/dx) -lambda *C

% Initialisation
% Griding of the reactor domain
dx=0.2; %grid size
x=[0:dx:10]; % reactor domain and grid meters
dx_vec=diff(x);% vector containing grid spacing dx

% Define variables & parameters, 
D=1e-6; % diffusion coefficient of substance in sqm per second
v=1e-4;
lambda=0/86400; % reaction time scale of first order reaction
tau=3600; % period of osscillation in case of a periodical input concentration
C_in=0.008% input concentratin in kg/m^3 into the reactor
C_lim=0.001; % tolerance limit for the outflow

% Define initial state based on analytical solution of the linear diffusion
% problem

c=zeros(length(x)); % concentration vectors 
c_old=c; % concentration at old time stept

% Process loop
tmax=100*86400; % maximum computation time
time=0; % start time for simulation
itime=1; % time step counter

% solve equation with explicite centreded euler forward finite difference
figure;
while time <tmax 
    %assure stability, i.e. von Neumann condition is fullfilled
    dt=0.01*1/2*dx^2/D; 
    % boundary conditions
    c(length(x))=c_old(length(x)-1); %right boundary free outflow
    c(1)=C_in; % left boundary constant concentration 
    if time < tau
    c(1)=C_in+0.5*C_in*sin(time/tau)% left boundary periodic input concentration
    else
        c(1)=0;
    end 
    % solve working equation 
    for k=2:length(x)-1
        % calculate new c at time i+1 from c_old at time i 
        c(k)=c_old(k)+2*D*dt*(c(k+1)-c(k))/((x(k+1)-x(k-1))*(x(k+1)-x(k)))...
        -2*D*dt*(c(k)-c(k-1))/((x(k+1)-x(k-1))*(x(k)-x(k-1)))-dt*lambda*c_old(k)...
        -dt*v/(x(k)-x(k-1))*(c_old(k)-c_old(k-1));    
        % Assure that solution is realistic i.e. avoid negative
        % concentration
        if c(k) < 0
            c(k) =0;
        end
    end
    time=time+dt; %update time 
    % Update old concentration
    c_old=c;
    % start plotting sequence
    h1=plot(x,c,'linewidth',2); 
    hold on;
    h2=plot(x,C_lim*ones(1,length(x)),'r-','linewidth',2);
   hold off;
    %Compute RMSE and Mean error
    xlabel('x [m]','fontsize',14);
    ylabel('Concentration  [kg/m^3]', 'fontsize',14);
       axis([x(1) x(length(x)) 0 2*C_in]);
    set(gca,'fontsize',14,'linewidth',2);
   title(['time ' num2str(time/3600) ' h']);
   legend('concentration profile','tolerance'); 
   M(itime)=getframe;
   itime=itime+1;
    % end plotting sequence
end
    
