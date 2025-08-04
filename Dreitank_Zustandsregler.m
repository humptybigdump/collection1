% Polvorgabe-Entwurf: Dreitank-System mit Zustandsregler
% 1. Vorgegebene Schnelligkeit der Eigenwerte
% 2. Deadbeat
%
% Digitale Regelungen,  Universit�t Karlsruhe (TH), Maschinenbau, MRT
% Dr.-Ing. Michael Knoop
% Wintersemester 2006/07
%
% Erstellt unter MATLAB 7.0 (Release 14, Service Pack 2) mit 
% - Control System Toolbox
% - Simulink

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Strecke
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Zustandsgr��en
% xi: F�llstand Tank Nr. i in m, i=1...3

% Stellgr��e
% u:  Zufluss in Tank Nr. 1 in m�/s

% Ausgangsgr��e
% y:  F�llstand Tank Nr. 3 in m, y = x3


% Parameter
k = 0.01;       % Durchflussparameter in m�/s
F = 1;          % Querschnittsfl�che der Tanks in m�


% Zeitkontinuierliches Zustandsraummodell

A = (k/F) * [-1 1 0; 1 -2 1; 0 1 -2];
B = (1/F)*[1; 0; 0];
C = [0 0 1];
D = 0;

sys = ss ( A, B, C, D );

n = 3;

% Abtastperiode in s
T = 50;

% Transformation in das zeitdiskrete Zustandsraummodell
sysd = c2d ( sys, T, 'zoh' );
Phi = sysd.a;
H   = sysd.b;
disp ('Eigenwerte der zeitdiskreten Systemmatrix Phi');
eig ( Phi )

% Steuerbarkeitsmatrix
QS = H;
for k = 2:n
    QS = [QS, Phi*QS(:,k-1)];
end;

disp ('Rang der Steuerbarkeitsmatrix');
rank ( QS )
disp ('Singul�rwerte der Steuerbarkeitsmatrix');
svd ( QS )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reglerentwurf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Entwurfsziel = 1;       % 1: Vorgegebene Schnelligkeit der Eigenwerte
                        % 2: Deadbeat, alle Eigenwerte in 0

% Vorgabe der n Eigenwerte ew des geregelten Systems
switch Entwurfsziel
    case 1, Tmax = 50;  % Vorgegebene max. Zeitkonstante der Eigenwerte
            z1 = exp ( -T / Tmax );
            ew = [0.20; z1; z1];
    case 2, ew = zeros(n,1);
end;

%R = place ( Phi, H, ew ); % gestattet keine mehrfachen Eigenwerte

disp ('R�ckf�hrverst�rkung')
R = acker ( Phi, H, ew )

disp ('Vorfilterverst�rkung')
V = 1 / (C/(eye(size(Phi))-Phi+H*R)*H)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rechnerische Entwurfskontrolle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Systemmatrix des geregelten Systems
Phir = Phi - H*R;

disp ('Eigenwerte der Systemmatrix des geregelten Systems')
eig ( Phir )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Entwurfskontrolle per Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Erweiterung des zeitkont. Zustandsraummodells um den St�reingang
% u1: Stellgr��e u
% u2: St�rgr��e d, Abfluss aus Tank Nr. 2 in m�/s
B = (1/F)*[1 0; 0 -1; 0 0];

% Zeitintervall f�r Datenabspeicherung bei der Simulation
dT = 5;

% Max. Gradient f�r das Anstiegsbegrenzungsfilter
dw_max = 0.002;

% Start der Simulation
sim ( 'Dreitank_ZR' );

% Ergebnisplots
figure;
plot (t, x );
title ('Zustandsgr��en')
xlabel ('t in s')
ylabel ('xi in m')

figure;
plot (t,w, t,y );
title ('Sollwert und Ausgangsgr��e')
xlabel ('t in s')
ylabel ('m')

figure;
plot (t,u, t,d );
title ('Stellgr��e und St�rgr��e')
xlabel ('t in s')
ylabel ('u in m�/s')