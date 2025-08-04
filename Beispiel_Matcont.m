matlabrc,
clc, clear, close all


%% 1. Initialisierung von MatCont
% Zuerst muss die MAtCont Toolbox initialisiert werden. Hierzu wird der
% relative Pfad zum Matcont Verzeichnis angegeben und die Funktion init
% aufgerufen.

currentdir=cd();
cd('../MatCont_Toolbox/');
init;
cd(currentdir);

%% 2. Initialisierung von MatCont

% initialer Wert des Bifurkationsparameters
mu_init=-1;

% initialer Wert des Zustandsvektors (entspricht dem Wert einer Ruhelage)
x_init = 1; 

% Bei mehrern Parametern in der DGL muss der aktive, zu verwendene
% Parameter festgelegt werden. Hier gibt es nur einen, daher:
ap=1;

% Aufruf der Initialisierung zur Verfolgung von Equilibrium Points
% (=Ruhelagen)
[x0,v0]=init_EP_EP(@MatCont_ODE,x_init,mu_init,ap);


%% 3. Verfolgung 

% Festlegen der Optionen zur Verfolgung
opt=contset;
opt=contset(opt,'MaxNumPoints',5);
opt=contset(opt,'MinStepSize',1e-6);
opt=contset(opt,'FunTolerance',1e-6);
opt=contset(opt,'Singularities',1); % detektiert singul�re Punkte
opt=contset(opt,'Eigenvalues',1); % zeichnet Eigenwerte auf
opt=contset(opt,'Backward',1);
global cds; % Struktur mit allen wichtigen Informationen

% Verfolgung des 1. Pfades von definiertem Startpunkt aus
    
    [x1,v1,s1,h1,f1]=cont(@equilibrium,x0,v0,opt);
      
    %Verfolgung bis zu gewuenschtem Parameterwert 
    while x1(end,end)<2
    [x1,v1,s1,h1,f1]=cont(x1,v1,s1,h1,f1,cds);
    end
    
    %Grafische Darstellung
    fig_results_EQ=figure;
    axis([-1 2 -2 1]);
    cpl(x1,v1,s1,[2,1]);
    xlabel('mu');
    ylabel('x0');
    title('Ruhelagen');

% Verfolgung des 2. Pfades ab dem BP in positive Richtung
s_BP = s1(2); 
x_BP = x1(1,s_BP.index); 
p_BP = x1(2,s_BP.index); 

[x02,v02]=init_BP_EP(@MatCont_ODE,x_BP,p_BP,s_BP,0.01);
opt=contset(opt,'Backward',0);
[x2,v2,s2,h2,f2]=cont(@equilibrium,x02,v02,opt);

    %Verfolgung bis zu gewuenschtem Parameterwert 
    while x2(end,end)<2
    [x2,v2,s2,h2,f2]=cont(x2,v2,s2,h2,f2,cds);
    end
    
    %Grafische Darstellung
    set(0, 'currentfigure', fig_results_EQ); 
    cpl(x2,v2,s2,[2,1]);



% Verfolgung des 3. Pfades ab dem BP in negative Richtung
[x03,v03]=init_BP_EP(@MatCont_ODE,x_BP,p_BP,s_BP,0.01);
opt=contset(opt,'Backward',1);
[x3,v3,s3,h3,f3]=cont(@equilibrium,x03,v03,opt);

    %Verfolgung bis zu gewuenschtem Parameterwert 
    while x3(end,end)>-1
    [x3,v3,s3,h3,f3]=cont(x3,v3,s3,h3,f3,cds);
    end
    
    %Grafische Darstellung
    set(0, 'currentfigure', fig_results_EQ); 
    cpl(x3,v3,s3,[2,1]);

    
%% Gegen�berstellung mit Zeitintegration    
% Zeitintegration 
tspan = [0 10]; 
x0_t = -0.1; 
mu = 1.5; 
MatCont_out=MatCont_ODE();
funeval_handle=MatCont_out{2};
[tout,xout]=ode45(funeval_handle,tspan,x0_t,[],mu); 
fig_transient=figure;
title('Zeitintegration');
xlabel('t');
ylabel('x0');
plot(tout,xout); 

