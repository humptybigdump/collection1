clc
clear
close all
addpath("Solvers\","Testproblems\");


%% Settings
tspan = [0; 20];
IC    = [1.01; 3];
sol = struct();
%solver =  {@ode45 @RungeKuttaRichardson};
solver =  {@ode45 @DormandPrinceStepWidthControl};
problem = @brusselator;
options = odeset('refine',1);
options.h    = 0.05; 
options.p    = 4;
options.fmin = 0.2;
options.fmax = 5;
options.Sh   = 0.8;
options.tol  = 1e-3;


%% Solving
nsim = 1000;
times = zeros(length(solver),nsim);
for i0 = 1:nsim
 sol   = {};

 for i1=1:length(solver)
     tic;
     sol{i1} = solver{i1}(@(t,y) problem(t,y),tspan,IC,options);
     times(i1,i0) = toc;
 end
end

mean(times(1,:))
mean(times(2,:))

std(times(1,:))
std(times(2,:))

clear i1 problem solver tmpsolver tspan IC