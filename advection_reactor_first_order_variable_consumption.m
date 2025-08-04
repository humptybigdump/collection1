clear;
%  Routine to simulate mass balance of a reactor reactor
% for a chemical/ contaminant which gets transformed by a first order
% reaction
%dc/dt= v*dC/dx -lambda *C

% Initialisation
% Griding of the reactor domain
dx=0.05; % %grid size
x=[0:dx:2];% reactor domain and grid meters
deltax=diff(x); % vector containing grid spacing dx


% Define variables & parameters
v=1e-05;% flow velocity in m per second
lambda_ave= 1/86400; % reaction time scale of first order reaction
tau=3600; % period of osscillation in case of a periodical input concentration
C_in=0.5% input concentratin in kg/m^3 into the reactor
C_lim=0.05;% tolerance limit for the outflow
%scaling factor for initial state


% Define initial state
C=zeros(1, length(x));% concentration vectors 
C_alt=C; % concentration at old time stept



% Process loop
tmax=10*86400; % maximum simulation time
time=0.; % start time
itime=1; % time step counter
time_vec=[time];
C_leak=[0];

% solve equation with explicite upstream euler forward finite difference
figure;
while time < tmax
   % Define time step with (Courant), maxium computation time and start time 
    dt=1*dx/abs(v);
    % Define boundary conditions (Dirichlet)    
    C(1)=C_in;% left boundary constant concentration 
    %C(1)=C_in+C_in*sin(time/tau); % % left boundary periodic input concentration
    lambda=1*lambda_ave*sin(time/(24*tau)); % % left boundary periodic input concentration

    C(length(x))=C_alt(length(x)-1); %right boundary free outflow
   % solve working equation 
    for j=2:length(x)-1
        % numerical solution
        %C(j)=C_alt(j)-dt*v/(x(j)-x(j-1))*(C_alt(j)-C_alt(j-1))-dt*C_alt(j-1)*lambda;
        C(j)=C_alt(j)-dt*v/(x(j)-x(j-1))*(C_alt(j)-C_alt(j-1))-dt*C_alt(j-1)*lambda;
        % Assure that solution is realistic i.e. avoid negative
        % concentration
        if C(j) < 0
            C(j)=0;
        end
    end
    C_alt=C; % set old Concentration to actual concentration
    % start plotting sequence
    plot(x,C,'b-','linewidth',2);
    hold on;
    plot(x,C_lim*ones(1,length(x)),'r-','linewidth',2);
    hold off;
    xlabel('x [m]','fontsize',14);
    ylabel('C [kg/m^3]','fontsize',14);
    set(gca,'fontsize',14,'linewidth',2);
    axis([x(1) x(length(x)) 0 2*C_in]);
    title(['time ' num2str(time/3600) ' h']);
    legend('concentration profile','tolerance'); 
    M(itime)=getframe;
    time=time+dt;% new time
    itime=itime+1;
     % end plotting sequence
    time_vec=[time_vec time];
    C_leak=[C_leak C(length(x))];

   end

figure;
plot(time_vec/3600,C_leak,'b-','linewidth',2);
xlabel('t [h]','fontsize',14);
ylabel('C [kg/m^3]','fontsize',14);
set(gca,'fontsize',14,'linewidth',2);
