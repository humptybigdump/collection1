clear;
%  Routine to simulate mass balance of a reactor reactor
% for a chemical/ contaminant which gets transformed by a first order
% reaction
%dC1/dt= v*dC1/dx -lambda *C1
%dC2/dt= v*dC2/dx +lambda *C1 - lambda2 *C2

% Initialisation
% Griding of the reactor domain
dx=0.05; % %grid size
x=[0:dx:2.];% reactor domain and grid meters
deltax=diff(x); % vector containing grid spacing dx


% Define variables & parameters
v=1e-05;% flow velocity in m per second
lambda= 1/(86400);%1/(0.5*86400); % reaction time scale of first order reaction
lambda2=1/(2*86400); % reaction time scale of first order reaction
tau=3600; % period of osscillation in case of a periodical input concentration
C_in=0.5% input concentratin in kg/m^3 into the reactor
C_lim=0.05;% tolerance limit for the outflow
%scaling factor for initial state


% Define initial state
C=zeros(1, length(x));% concentration vectors
C2=zeros(1, length(x));% metabholite concentration vectors
C_alt=C; % concentration at old time stept
C2_alt=C2; % concentration at old time stept


% Process loop
tmax=10*86400; % maximum simulation time
time=0.; % start time
itime=1; % time step counter

% solve equation with explicite upstream euler forward finite difference
figure;
while time < tmax
   % Define time step with (Courant), maxium computation time and start time 
    dt=1*dx/abs(v);
    % Define boundary conditions (Dirichlet)    
    C(1)=C_in;% left boundary constant concentration
    C2(1)=0;
    %C(1)=C_in+C_in*sin(time/tau); % % left boundary periodic input concentration
   C(length(x))=C_alt(length(x)-1); %right boundary free outflow
   C2(length(x))=C2_alt(length(x)-1); %right boundary free outflow
   % solve working equation 
    for j=2:length(x)-1
        % numerical solution
        C(j)=C_alt(j)-dt*v/(x(j)-x(j-1))*(C_alt(j)-C_alt(j-1))-dt*C_alt(j-1)*lambda;
        C2(j)=C2_alt(j)-dt*v/(x(j)-x(j-1))*(C2_alt(j)-C2_alt(j-1))+dt*C_alt(j-1)*lambda -lambda2*dt*C2_alt(j-1);
        % Assure that solution is realistic i.e. avoid negative
        
        % concentration
        if C(j) < 0
            C(j)=0;
        end
         if C2(j) < 0
            C2(j)=0;
        end
    end
    C_alt=C; % set old Concentration to actual concentration
    C2_alt=C2; % set old Concentration to actual concentration
    % start plotting sequence
    plot(x,C,'b-','linewidth',2);
    hold on;
    plot(x,C2,'g-','linewidth',2);
    plot(x,C_lim*ones(1,length(x)),'r-','linewidth',2);
    hold off;
    xlabel('x [m]','fontsize',14);
    ylabel('C [kg/m^3]','fontsize',14);
    set(gca,'fontsize',14,'linewidth',2);
    axis([x(1) x(length(x)) 0 2*C_in]);
    title(['time ' num2str(time/3600) ' h']);
    legend('concentration mother substance','concentration methabolite','tolerance'); 
    M(itime)=getframe;
    time=time+dt;% new time
    itime=itime+1;
     % end plotting sequence
   end

