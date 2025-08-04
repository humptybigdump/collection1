% PI-Regler mit Anti-Windup Ma�nahme f�r das Dreitank-System
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

% Transformation der Strecke in das zeitdiskrete Zustandsraummodell
sysG = c2d ( sys, T, 'zoh' );

disp ( 'z-�bertragungsfunktion der Strecke' )
tf ( sysG )

disp ( 'Pole der Strecke' )
pole ( sysG )

disp ( 'Nullstellen der Strecke' )
zero ( sysG )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reglerentwurf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% z-�bertragungsfunktion des Reglers
z = tf ( 'z', T );
K = 0.0142;
sysR = K*(z-0.9)/(z-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rechnerische Entwurfskontrolle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sysFO = sysG * sysR;        % Offene Kette
sys1 = tf ( 1 );            % "Unity" in der R�ckf�hrung

% z-F�hrungs�bertragungsfunktion
sysFW = feedback ( sysFO, sys1 );

disp ( 'Pole der z-F�hrungs�bertragungsfunktion' )
pole ( sysFW )

disp ( 'Nullstellen der z-F�hrungs�bertragungsfunktion' )
zero ( sysFW )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Entwurfskontrolle per Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Erweiterung des zeitkont. Zustandsraummodells um den St�reingang
% u1: Stellgr��e u
% u2: St�rgr��e d, Abfluss aus Tank Nr. 2 in m�/s
B = (1/F)*[1 0; 0 -1; 0 0];

% Regler
numR = K * [1 -0.9];
denR = [1 -1];
KP = K;
KI = KP - 0.9*K;

% Begrenzung der Stellgr��e in m�/s
umax = 0.0125;
umin = 0;

% Zeitintervall f�r Datenabspeicherung
dT = 5;

% Start der Simulation
sim ( 'Dreitank_PI_AntiWindup' );

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
plot (t,u );
title ('Stellgr��e und St�rgr��e')
xlabel ('t in s')
ylabel ('u in m�/s')
