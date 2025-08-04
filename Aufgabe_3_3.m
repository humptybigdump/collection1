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

%% Anmerkung:

% Das hier vorliegende Skript muss lediglich um die entsprechenden Informationen ergaenzt werden, damit es korrekt durchlaeuft.
% Wenn ihr Fragen habt, bitte sofort melden, ich helfe euch dann^^

% Allen Zeilen mit "%xxx" muessen einkommentiert werden, nachdem Sie
% entsprechend um die fehlenden Informationen ergaenztnzt wurden.

%% 2. Verfolgung der Ruhelage und Suchen der Hopf-Bifurkation

%% 2.a. Initialisierung zur EQ Verfolgung
% Startpunkt fuer Verfolgung z=[x,y]=... und beta_1=... (beta_2=-2)
z_init=%xxx;
beta1_init=1;
beta2=-2; %(bleibt unverandert)

% korrekten aktiven Parameter waehlen
ap= %xxx;

% Aufruf der Initialisierung zur Verfolgung von Equilibrium Points
[z0,v0]=%xxx init_EP_EP( ,z_init,[],ap);


%% 2.b. Verfolgung der Ruhelage 

% Festlegen der Optionen zur Verfolgung
opt=contset;
opt=contset(opt,'MaxNumPoints',5);
opt=contset(opt,'MinStepSize',1e-6);
opt=contset(opt,'FunTolerance',1e-6);
opt=contset(opt,'Singularities',1); % detektiert singuläre Punkte
opt=contset(opt,'Eigenvalues',1); % zeichnet Eigenwerte auf
global cds; % Struktur mit allen wichtigen Informationen

% Verfolgung in ERSTE Richtung
    opt=contset(opt,'Backward',0);
    [z1,v1,s1,h1,f1]=cont(@equilibrium,z0,v0,opt);
      
    %Verfolgung bis zu gewuenschtem Parameterwert 
    while z1(end,end)>-2
   [z1,v1,s1,h1,f1]= %xxx;
    end;
    
    %Grafische Darstellung
    %Welche Koordinate x oder y ist hier von Interesse?
    fig_results_EQ=figure;
    cpl(z1,v1,s1,[3,1]);
    xlabel('beta1');
    ylabel('x');
    title('Ruhelagen');
    axis([-2 1.5 -2 3]);
    
% Verfolgung in ZWEITE Richtung
    opt=contset(opt,'Backward',1);
    [z2,v2,s2,h2,f2]= %xxx ;
      
    %Verfolgung bis zu gewuenschtem Parameterwert 
    while z2(end,end)>-2
    [z2,v2,s2,h2,f2]=cont(z2,v2,s2,h2,f2,cds);
    end;
    
    %Grafische Darstellung
    %Welche Koordinate x oder y ist hier von Interesse?
    set(0,'currentfigure',fig_results_EQ);
    cpl(z2,v2,s2,%xxx);
  
%% Hopf-Bifurkation gefunden? Wenn nicht, dann die Einstellungen der Ruhelagenverfolgung entsprechend aendern.


%% 3. Verfolgung des Grenzzyklus ab Hopf-Bifurkation
% Verfolgung des 2. Pfades ab dem BP in positive Richtung

%% 3.a. Initialisierung ab Hopf-Bifurkation aus
s_Hopf = %xxx ;  % Eintrag der Struktur, die die Hopf-Bifurkation enthaelt 
z_Hopf = %xxx    % Wert des Zustandsvektors an der Hopf-Bifurkation 
betaH =  %xxx    % Parameterwert an der Hopf-Bifurkation

[z0LC, v0LC] = init_H_LC(@MatCont_3_3,z_Hopf, [betaH; beta2], ap, 1e-6, 20, 4);
opt=contset(opt,'Multipliers',1);  % Zeichnet Foquet-Multiplikatoren auf

%% 3.b Verfolgung des Grenzzyklus (LC) ab Hopf-Punkt aus
[zLC, vLC, sLC, hLC, fLC] = cont(@limitcycle, z0LC, v0LC, opt);

% bis zu gewuenschtem Parameterwert
while zLC(end,end)>-0.6
[zLC, vLC, sLC, hLC, fLC]=cont(zLC, vLC, sLC, hLC, fLC,cds);   
end;
% Plotten der Ergebnisse in gleiches Diagramm wie Ruhelagen
 set(0,'currentfigure',fig_results_EQ); hold all;
 plotcycle(zLC,vLC, sLC,[size(zLC,1),1,2]);
 zlabel('y');
 axis([-2 1.5 -2 3]);

    



