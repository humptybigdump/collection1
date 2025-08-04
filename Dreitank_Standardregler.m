% Wurzelortskurve: Dreitank-System mit zeitdiskreten Standardreglern
% 1. P-Regler
% 2. PI-Regler
% 3. PID-Regler
%
% Digitale Regelungen,  Universität Karlsruhe (TH), Maschinenbau, MRT
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

% Zustandsgrößen
% xi: Füllstand Tank Nr. i in m, i=1...3

% Stellgröße
% u:  Zufluss in Tank Nr. 1 in m³/s

% Ausgangsgröße
% y:  Füllstand Tank Nr. 3 in m, y = x3


% Parameter
k = 0.01;       % Durchflussparameter in m²/s
F = 1;          % Querschnittsfläche der Tanks in m²


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

disp ( 'z-Übertragungsfunktion der Strecke' )
tf ( sysG )

disp ( 'Pole der Strecke' )
pole ( sysG )

disp ( 'Nullstellen der Strecke' )
zero ( sysG )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reglerentwurf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Reglertyp = 3;      % 1: P-Regler
                    % 2: PI-Regler
                    % 3: PID-Regler

% z-Übertragungsfunktion des Reglers ("ohne" Verstärkung)
z = tf ( 'z', T );
switch Reglertyp
    case 1, sysR = tf ( 1 );
    case 2, sysR = (z-0.9)/(z-1);
    case 3, sysR = ((z-0.45)*(z-0.9))/(z*(z-1));
end;

% Systemdarstellung der offenen Kette
sysFO = sysG * sysR;

% Wurzelortskurve
rlocus ( sysFO );
pause

% Reglerverstärkung
switch Reglertyp
    case 1, K = 0.00917;
    case 2, K = 0.0142;
    case 3, K = 0.04;
end;

% z-Übertragungsfunktion des Reglers (mit Verstärkung)
sysR = K * sysR;
disp ( 'z-Übertragungsfunktion des Reglers' )
tf ( sysR )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rechnerische Entwurfskontrolle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sysFO = sysG * sysR;        % Offene Kette
sys1 = tf ( 1 );            % "Unity" in der Rückführung

% z-Führungsübertragungsfunktion
sysFW = feedback ( sysFO, sys1 );

disp ( 'Pole der z-Führungsübertragungsfunktion' )
pole ( sysFW )

disp ( 'Nullstellen der z-Führungsübertragungsfunktion' )
zero ( sysFW )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Entwurfskontrolle per Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Erweiterung des zeitkont. Zustandsraummodells um den Störeingang
% u1: Stellgröße u
% u2: Störgröße d, Abfluss aus Tank Nr. 2 in m³/s
B = (1/F)*[1 0; 0 -1; 0 0];

% Reglerdarstellung mit Zähler- und Nennerpolynom
switch Reglertyp
    case 1, numR = K;
            denR = 1;
    case 2, numR = K * [1 -0.9];
            denR = [1 -1];
    case 3, numR = K * [1 -1.35 0.405];
            denR = [1 -1 0];
end;

% Zeitintervall für Datenabspeicherung
dT = 5;

% Start der Simulation
sim ( 'Dreitank_SR' );

% Ergebnisplots
figure;
plot (t, x );
title ('Zustandsgrößen')
xlabel ('t in s')
ylabel ('xi in m')

figure;
plot (t,w, t,y );
title ('Sollwert und Ausgangsgröße')
xlabel ('t in s')
ylabel ('m')

figure;
plot (t,u );
title ('Stellgröße und Störgröße')
xlabel ('t in s')
ylabel ('u in m³/s')
