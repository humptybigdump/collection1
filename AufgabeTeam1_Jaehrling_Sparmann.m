%% Übungsblatt Kartenprojektionslehre
% Aufgabe Team 1 
% Wintersemester 2023/2024
% Jasmin Jaehrling und Lorriann Sparmann
% Letzte Bearbeitung: 07.02.2024

close all;
clear all;
clc;

%% Aufgabe:
% Das Ziel der Übungsaufgabe besteht darin, unter Einhaltung der
% geometrischen Eigenschaften von Aufgabe 9a) (Orthographische Projektion),
% eine Karte zu erstellen. Hierbei entspricht der Berührungspunkt der 
% Original- und der Bildflaeche dem Hauptpunkt.


%% gegebene Werte
R = 6371000 ;           %Erdradius in m
K = [49 8];             % Hauptpunkt K; Mitte des Kartenblattes
M = 50000000;           % Maßstab 1:50000000
A = [80 20];            % Punkt A
B = [75 30];            % Punkt B

%% 10 ausgewählte Hauptstädte
% Wien, Kopenhagen, Amsterdam, Bern, Lissabon, Nuuk, Kairo, Oslo,
% Ankara, Astana
Staedte = { 'K'; 'W';' Ko';' Am';' B';' L';' N';' Kai';' O';' An';' As';' A';' B'};
num = length(Staedte);
% Koordinaten der Staedte
wien = [48 16];
kopenhagen = [55 12];
amsterdam = [52 5];
bern = [47 7];
lissabon = [38 -9];
nuuk = [64 -51];
kairo = [30 31];
oslo = [60 10];
ankara = [40 33];
astana = [51 71];
figure
%% Parameternetz in blau einzeichnen:

% Parameternetz plotten
d_param=0:10*(pi/180):pi/2;
laenge_d = length(d_param);
a_param=0:10*(pi/180):2*pi;
laenge_a = length(a_param);

for i=1:laenge_d
    x=zeros(laenge_a,1);
    y=zeros(laenge_a,1);
    for j=1:laenge_a

        r_param(j) = R * sin(d_param(i));
        x_param(j) = r_param(j) * cos(a_param(j)) / M;
        y_param(j) = r_param(j) * sin(a_param(j)) / M;
    end
    k0 = plot(y_param,x_param,'Color','b');
    hold on
end

for i=1:laenge_a
    x=zeros(laenge_d,1);
    y=zeros(laenge_d,1);
    for j=1:laenge_d
        r_param2(j) = R * sin(d_param(j));
        x_param2(j) = r_param2(j) * cos(a_param(i)) / M;
        y_param2(j) = r_param2(j) * sin(a_param(i)) / M;
    end
    p1=plot(y_param2,x_param2,'Color','b');
    hold on
end

%% Staedte plotten

% Koordianten 
koords_rad = pi/180*[K; wien; kopenhagen; amsterdam; bern; lissabon; nuuk; kairo; oslo; ankara; astana; A; B];

phi = koords_rad(:,1);     % geographische Breite
lambda = koords_rad(:,2);  % geographische Länge

% Abbildung
for k = 1:1:num

    delta(k) = acos(sin(phi(1)) * sin(phi(k)) + cos(phi(1)) * cos(phi(k)) * cos(lambda(k) - lambda(1)));
    alpha(k) = atan2(cos(phi(k)) .* sin(lambda(k) - lambda(1)), cos(phi(1)) * sin(phi(k)) - sin(phi(1)) * cos(phi(k)) .* cos(lambda(k) - lambda(1)));

    r(k) = R * sin(delta(k));
    x(k) = r(k) * cos(alpha(k)) / M;
    y(k) = r(k) * sin(alpha(k)) / M;
end
pnkt_ab_x = [x(12) x(13)];
pnkt_ab_y = [y(12) y(13)];

% Plot erstellen

k1 = scatter(y, x,25, 'black');
hold on
k2 = scatter (pnkt_ab_y, pnkt_ab_x,25,'filled', 'black');
hold on
text(y,x, Staedte);
hold on

%% Geographisches Netz in gruen einzeichnen

%Breitenkreise
for phi_punkt = -90:10:90 %Breite variieren

    phi_punkt_rad = phi_punkt * (pi/180);

    x_meridiane = [];
    y_breitenkreise = [];

    for lambda_punkt = -180:10:180 %Laenge variieren

        lambda_punkt_rad = lambda_punkt * (pi/180);

        %Berechnung der Schnittpunkte zwischen den dargestellten Breiten-
        %und Laengenkreisen mit Bezug zum Hauptpunkt

        cos_delta = sin(phi(1)) * sin(phi_punkt_rad) + cos(phi(1)) * cos(phi_punkt_rad) * cos(lambda_punkt_rad - lambda(1));
        delt = acos(cos_delta);
        alph = atan2(cos(phi_punkt_rad) .* sin(lambda_punkt_rad - lambda(1)), cos(phi(1)) * sin(phi_punkt_rad) - sin(phi(1)) * cos(phi_punkt_rad) .* cos(lambda_punkt_rad - lambda(1)));
       
        r_netz = R * sin(delt);
        x_netz = r_netz * cos(alph) / M;
        y_netz = r_netz * sin(alph) / M;

        %Nur Punkte auf sichtbarem Teil der Erde darstellen
        if cos_delta > 0
            x_meridiane = [x_meridiane, x_netz];
            y_breitenkreise = [y_breitenkreise, y_netz];
        end
    end

    k3 = plot(y_breitenkreise, x_meridiane, 'g');
end

%Meridiane
for lambda_p = -180:10:180 %Breite variieren

    lambda_p_rad = lambda_p * (pi/180);

    x_meridiane = [];
    y_breitenkreise = [];

    for phi_p = -90:10:90 %Laenge variieren

        phi_p_rad = phi_p * (pi/180);

        %Berechnung der Schnittpunkte zwischen den dargestellten Breiten-
        %und Laengenkreisen mit Bezug zum Hauptpunkt

        cos_delta = sin(phi(1)) * sin(phi_p_rad) + cos(phi(1)) * cos(phi_p_rad) * cos(lambda_p_rad - lambda(1));
        delt = acos(cos_delta);
        alph = atan2(cos(phi_p_rad) .* sin(lambda_p_rad - lambda(1)), cos(phi(1)) * sin(phi_p_rad) - sin(phi(1)) * cos(phi_p_rad) .* cos(lambda_p_rad - lambda(1)));

        r_netz = R * sin(delt);
        x_netz = r_netz * cos(alph) / M;
        y_netz = r_netz * sin(alph) / M;

        %Nur Punkte auf sichtbarem Teil der Erde darstellen
        if cos_delta > 0
            x_meridiane = [x_meridiane, x_netz];
            y_breitenkreise = [y_breitenkreise, y_netz];
        end
    end

   plot(y_breitenkreise, x_meridiane, 'g');
end

%% Orthodrome einzeichnen (zwischen Kairo und Astana):

%Koordinaten von Kairo
phi_1 = phi(8);
lambda_1 = lambda(8);
%Koordinaten von Astana
phi_2 = phi(11);
lambda_2 = lambda(11);

lambda_schritte = lambda_1:pi/180:lambda_2; %1-Grad-Schritte zwischen Kairo und Astana
phi_ortho = atan((tan(phi_1) * sin(lambda_2 - lambda_schritte) + tan(phi_2) * sin(lambda_schritte - lambda_1)) / sin(lambda_2 - lambda_1));

for m = 1:1:41

    delta_ortho(m) = acos(sin(phi(1)) * sin(phi_ortho(m)) + cos(phi(1)) * cos(phi_ortho(m)) * cos(lambda_schritte(m) - lambda(1)));
    alpha_ortho(m) = atan2(cos(phi_ortho(m)) .* sin(lambda_schritte(m) - lambda(1)), cos(phi(1)) * sin(phi_ortho(m)) - sin(phi(1)) * cos(phi_ortho(m)) .* cos(lambda_schritte(m) - lambda(1)));
    
    r_ortho(m) = R * sin(delta_ortho(m));
    x_ortho(m) = r_ortho(m) * cos(alpha_ortho(m)) / M;
    y_ortho(m) = r_ortho(m) * sin(alpha_ortho(m)) / M;
end

k4 = plot(y_ortho, x_ortho, 'm');
hold on

%% Loxodrome einzeichnen (zwischen Kairo und Astana):

phi_loxo = (phi_1 : abs(phi_2-phi_1)/200 : phi_2);
tan_beta = (lambda_2-lambda_1)/(log(tan(pi/4+phi_2/2))- log(tan(pi/4+phi_1/2)));
lambda_loxo = tan_beta * log(tan(pi/4+phi_loxo/2)) - tan_beta * log(tan(pi/4+phi_1/2)) + lambda_1;

delta_loxo = acos(sin(phi(1)) .* sin(phi_loxo) + cos(phi(1)) .* cos(phi_loxo) .* cos(lambda_loxo - lambda(1)));
alpha_loxo = atan2(cos(phi_loxo) .* sin(lambda_loxo - lambda(1)), cos(phi(1)) .* sin(phi_loxo) - sin(phi(1)) .* cos(phi_loxo) .* cos(lambda_loxo - lambda(1)));

r_loxo = R .* sin(delta_loxo);
x_loxo = r_loxo .* cos(alpha_loxo) / M;
y_loxo = r_loxo .* sin(alpha_loxo) / M;

k5 = plot(y_loxo, x_loxo, 'k');
hold on

%% Tissotsche Indikatrix für A und B

beta=0:10*(pi/180):2*pi;
lange_b = length(beta);
% 1. Hauptverzerrung
a_A = cos(delta(12));
a_B = cos(delta(13));
% 2. Hauptverzerrung
b_AB = 1;

theta = 0 : 0.001 : 2*pi;

x_A = x(12);
y_A = y(12);
x_B = x(13);
y_B = y(13);

x_A_HVZ = a_A /100 .* cos(theta) + x_A;
y_A_HVZ = b_AB /100 .* sin(theta) + y_B;
x_B_HVZ = a_B /100 .* cos(theta) + x_B;
y_B_HVZ = b_AB /100 .* sin(theta) + y_B;

% Drehung der Ellipsenkoordinaten
% Berechnung des Drehwinkels
drehen_A = atan(y_A ./ x_A);
drehen_B = atan(y_B ./ x_B);

% Drehmatrizen
R_A = [cos(drehen_A) -sin(drehen_A); sin(drehen_A) cos(drehen_A)];
R_B = [cos(drehen_B) -sin(drehen_B); sin(drehen_B) cos(drehen_B)];

% Abstand radial zu A 
r_A = sqrt(a_A^2 * cos(beta).^2 + b_AB^2 * sin(beta).^2);
e_A = zeros(lange_b,2);

% polares anhängen an A
for i = 1:lange_b
ellipse = [x_A ;y_A] + R_A * 0.01 * [r_A(i) * cos(beta(i)); r_A(i) * sin(beta(i))];
e_A(i,1) = ellipse(1);
e_A(i,2) = ellipse(2);
end
k6 = plot(e_A(:,2),e_A(:,1),'r');
text(-0.02,x_A+0.003,['a_A = ', num2str(a_A)],'Color','r')
text(-0.02,x_A-0.003,['b_A = ', num2str(b_AB)],'Color','r')


% Abstand radial zu B 
r_B = sqrt(a_B^2 * cos(beta).^2 + b_AB^2 * sin(beta).^2);
e_B = zeros(lange_b,2);

% polares anhängen an B
for i = 1:lange_b
ellips = [x_B ;y_B] + R_B * 0.01 * [r_B(i) * cos(beta(i)); r_B(i) * sin(beta(i))];
e_B(i,1) = ellips(1);
e_B(i,2) = ellips(2);
end
plot(e_B(:,2),e_B(:,1),'r');
text(0.025,x_B+0.003,['a_B = ', num2str(a_B)],'Color','r')
text(0.025,x_B-0.003,['b_B = ', num2str(b_AB)],'Color','r')

%% Layoutdesign

axis equal
xlim([-0.1 0.1])
ylim([-0.04 0.1])
title('Karte mit den geometrischen Eigenschaften der orthographischen Projektion')
leg=legend([k1 k2 k0 k3 k4 k5 k6],{'Hauptstadt','Punkte A und B','Parameter Netz', 'Geographisches Netz','Orthodrome','Loxodrome','Ellipse'}, 'Location','northeast');
title(leg,'Karte im Maßstab 1:50 000 000')
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'PaperOrientation','landscape')

set(gcf, 'PaperSize', [29.7, 21]);
set(gcf, 'PaperPosition', [0, 0, 29.7, 21]);

%% Bild speichern
saveas(gcf,'Karte_Team_1_Jaehrling_Sparmann.pdf');


