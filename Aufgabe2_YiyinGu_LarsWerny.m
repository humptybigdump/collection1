clear; clc; close all;

%%
% WS24/25 Team2
% Yiyin Gu und Lars Werny
% Das Skript erstellt ein PDF der stereographischen Projektion im Maßstab
% 1:75000000. Zur besseren Übersicht innerhalb Europas haben wir noch eine
% vergrößerte Karte als PDF gesondert beigefügt. Der Hauptpunkt ist
% Karlsruhe und die Projektion ist konform, also winkeltreu

%% Test mit delta und alpha
fig = figure('Units','centimeters','Position',[0, 0, 29.7, 21]);
% Konstanten
R = 6371000/75000000; % Erdradius in m durch Maßstabszahl
rho = 180/pi; % Umrechnung von Grad in Bogenmaß
phi_KA = deg2rad(49); %Hauptpunkt
lambda_KA = deg2rad(8); %Hauptpunkt

% Städte in Grad
cities = [ 48, 16; % Wien
           55, 12; % Kopenhagen
           52, 5;  % Amsterdam
           46, 7;  % Bern
           40, 116; % Peking
           38, -77; % Washington DC
          -26, 28;  % Johannesburg
           22, 51;  % Dubai
           51, 0;   % London
           55, 37;  % Moskow
           80, -20; % A
           75, 30]; % B
% Städtenamen
city_names = {'Wi', 'Ko', 'Am', 'Be', 'Pe', 'DC', 'Jo', 'Du', 'Lo', 'Mo', 'A', 'B'};


% Nordpol hinzufügen
KA_pole = [49, 8]; % Nordpol Koordinaten
cities = [cities; KA_pole]; % Nordpol zu Städten hinzufügen

% Umrechnung der Städtekoordinaten in Bogenmaß
cities_rad = cities ./ rho;

%% Berechnung der Städte
% Initialisiere Arrays für die Koordinaten
x = zeros(1, length(cities_rad));
y = zeros(1, length(cities_rad));

% Projektion der Städte mit KA als Hauptpunkt
for i = 1:length(cities_rad)
    [x(i), y(i)] = radToKA(cities_rad(i, 1), cities_rad(i, 2));
end
%% Berechnung der Städte
% Initialisiere Arrays für die Koordinaten
x = zeros(1, length(cities_rad));
y = zeros(1, length(cities_rad));

% Projektion der Städte mit KA als Hauptpunkt
for i = 1:length(cities_rad)
    [x(i), y(i)] = radToKA(cities_rad(i, 1), cities_rad(i, 2));
end

hold on;



%% Berechnung der Breitenkreise

% Initialisieren der Arrays
breitenkreise_phi = [];
breitenkreise_lambda = [];
phi_values = -80 : 20 : 80; % In 10 Grad Schritten werden Kreise berechnet
phi_values = phi_values ./ rho;
phi_values = phi_values';
lambda_values = linspace(0, 2*pi, 360)';

for i = 1 : length(phi_values)
for j = 1 : length(lambda_values)
breitenkreise_phi(j + (i-1)*360) = phi_values(i);
breitenkreise_lambda(j + (i-1)*360) = lambda_values(j);
end
end
breitenkreise_phi = breitenkreise_phi';
breitenkreise_lambda = breitenkreise_lambda';

% Umrechnung in stereographische Koordinaten
for i = 1:length(breitenkreise_lambda)
    [x_Br(i), y_Br(i)] = radToKA(breitenkreise_phi(i), breitenkreise_lambda(i));
end

%% Berechnung der Längenkreise

% Initialisieren der Arrays
langenkreise_phi = [];
langenkreise_lambda = [];
lambda_values = 0 : 30 : 360;% In 10 Grad Schritten werden Kreise berechnet
lambda_values = lambda_values ./ rho;
lambda_values = lambda_values';
phi_values = linspace( -pi/2, pi/2, 180)';

for i = 1 : length(lambda_values)
for j = 1 : length(phi_values)
langenkreise_phi(j + (i-1)*180) = phi_values(j);
langenkreise_lambda(j + ((i-1)*180)) = lambda_values(i);
end
end
langenkreise_phi = langenkreise_phi';
langenkreise_lambda = langenkreise_lambda';

% Umrechnung in stereographische Koordinaten
for i = 1:length(langenkreise_lambda)
    [x_La(i), y_La(i)] = radToKA(langenkreise_phi(i), langenkreise_lambda(i));
end


%% Berechnung des Paramaternetzes


% Azimut bleibt fest, delta wird durchiteriert 
% -> Ergebnis sind Geraden

delta_values = -179 : 1 :179; % Es werden viele diskrete Punkte erzeugt bei konstanten Azimut
delta_values = delta_values ./rho';
azimut_values = linspace( -2*pi, 2*pi, 21);
for i = 1 :length(azimut_values)
    for j = 1 :length(delta_values)
    deltas(j + (i-1)*180) = delta_values(j);
    azimuts(j + (i-1)*180)= azimut_values(i);
    end
end

deltas = deltas';

% Berechnen der Koordinaten für das Parameternetz
for i = 1 : length(deltas)
x_d(i) = 2 * R * tan(deltas(i)/2)* cos(azimuts(i));
y_d(i) = 2 * R * tan(deltas(i)/2)* sin(azimuts(i));
end

% Auf Indizes achten. Schleife muss für den Plot richtig initialisiert sein
clear azimuts deltas
azimut_values = 0 : 1 : 360;
azimut_values = azimut_values./rho';
delta_values = linspace(0, pi* 0.9, 10);
for i = 1 : length(delta_values)
    for j = 1: length(azimut_values)
    deltas(j + (i-1)*361) = delta_values(i);
    azimuts(j + (i-1)*361)= azimut_values(j);
    end
end
azimuts  = azimuts';

for i = 1 : length(deltas)
x_a(i) = 2 * R * tan(deltas(i)/2)* cos(azimuts(i));
y_a(i) = 2 * R * tan(deltas(i)/2)* sin(azimuts(i));
end

%% Berechnung der Loxodrome zwischen Wien und Peking

% Wichtig ist, dass jeweils die erste Koordinate westlich der zweiten
% liegt. Bei Wien ist ein besserer Unterschied als bei Kapstadt sichtbar


phi_1 = cities_rad(1,1); % Wien
lambda_1 = cities_rad(1,2);
phi_2 = cities_rad(5,1); % Peking
lambda_2 = cities_rad(5,2);

% Berechnung der Loxodrome nach den Formeln im Skript
beta = atan2(lambda_2-lambda_1, log(tan(pi/4+ phi_2/2))- log(tan(pi/4+ phi_1 /2)));
s = R/cos(beta)*(phi_2-phi_1);
s_lox = 0: s/10000 : s;
phi_lox = s_lox .* cos(beta)/R + phi_1;
lambda_lox = tan(beta)* (log(tan(pi/4 + phi_lox ./ 2))- ...
                    log(tan(pi/4 + phi_1 / 2))) + lambda_1; %Gl. beta nach lambda2 umgestellt

% Umrechnung in stereographische Koordinaten
for i = 1:length(lambda_lox)
    [x_Lo(i), y_Lo(i)] = radToKA(phi_lox(i), lambda_lox(i));
end

%% Berehnung der Orthodrome zwischen Wien und Peking

% Erzeugen vieler diskreter Punkte 

lambda_orth = (lambda_1: (lambda_2-lambda_1)/10000: lambda_2); %invertieren für richtige Dimension
phi_orth = atan2(tan(phi_1)*sin(lambda_2-lambda_orth)+ tan(phi_2)*sin(lambda_orth-lambda_1),sin(lambda_2-lambda_1)); %Formel auf S.39 im Skript

% Umrechnung in stereographische Koordinaten
for i = 1:length(lambda_lox)
    [x_Or(i), y_Or(i)] = radToKA(phi_orth(i), lambda_orth(i));
end

%% Berechnen der Tissotschen Indikatrix
% Da die Abbildung konform ist, muss nur eine Hauptverzerrung berechnet
% werden. Es ist einfacher nur a zu berechnen, da die Fundamentalgröße der
% Kugel nur R^2 ist. Somit vereinfacht sich die Rechnung.
% E' = R^2/cos(delta/2)^4
% E = R^2
% a = Sqrt(E'/E) = 1 / cos(delta/2)^2
% Zudem ist die Verzerrung von A größer, da der Punkt weiter entfernt vom
% Hauptpunkte entfernt ist

% Koordinaten von Punkt A
phi_A = cities_rad(11,1);
lambda_A = cities_rad(11,2);

% Koordinaten in rad von Punkt B
phi_B = cities_rad(12,1);
lambda_B = cities_rad(12,2);

% Berechnung von delta für beide Punkte
cos_delta = sin(phi_KA)* sin(phi_A)+ cos(phi_KA)* cos(phi_A) * cos(lambda_A-lambda_KA);
delta_A = acos(cos_delta); % Herleitung über Poldreieck

cos_delta = sin(phi_KA)* sin(phi_B)+ cos(phi_KA)* cos(phi_B) * cos(lambda_B-lambda_KA);
delta_B = acos(cos_delta);

%Hauptverzerrung der beiden Punkte

h_A = 1/cos(delta_A/2)^2;
h_B = 1/cos(delta_B/2)^2;

fprintf('Die Hauptverzerrungen im Punkt A: \t a=%f \t b=%f \n', h_A, h_A);
fprintf('Die Hauptverzerrungen im Punkt B: \t a=%f \t b=%f', h_B, h_B);

% Tissot-Indikatrix plotten
th = 0 : 0.01 : 2*pi;
x_Kr = x(11) + h_A /100 * cos(th);
y_Kr = y(11) + h_A /100 *sin(th);
plot(x_Kr,y_Kr,'r','LineWidth',0.5,'DisplayName', 'Hauptverzerrung im A')

x_Kr = x(12) + h_B /100 * cos(th);
y_Kr = y(12) + h_B /100 *sin(th);
plot(x_Kr,y_Kr,'r','LineWidth',0.5,'DisplayName', 'Hauptverzerrung im B')

%% Plotten der Karte
all_x = [x(:); x_Br(:); x_La(:); x_d(:); x_a(:); x_Lo(:); x_Or(:)]; 
all_y = [y(:); y_Br(:); y_La(:); y_d(:); y_a(:); y_Lo(:); y_Or(:)]; 
x_min = min(x);
x_max = max(x);
y_min = min(y);
y_max = max(y);
axis([x_min - 0.1, x_max + 0.1, y_min - 0.1, y_max + 0.1]);
axis equal;
xlabel('x');
ylabel('y');
title('Übung Kartenprojektion:Stereographische Projektion der Städte mit Maßstab 1:75000000');

% Städte plotten
plot(x, y, 'rx', 'MarkerSize', 12, 'LineWidth', 2,'DisplayName', 'Städte'); % Städte

% Beschriften der Städte
for i = 1:length(city_names)
    text(x(i), y(i), city_names{i}, 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'b');
end

% Breitenkreise plotten
plot(x_Br , y_Br, 'g-', 'LineWidth', 0.2, 'DisplayName', 'Breitenkreise');

% Längenkreise plotten
plot(x_La, y_La, 'g-', 'LineWidth', 0.2, 'DisplayName', 'Längenkreise');

% Orthodrome plotten
plot(x_Or, y_Or, 'r-', 'LineWidth', 1.0, 'DisplayName', 'Orthodrome');

% Loxodrome plotten
plot(x_Lo, y_Lo, 'k-', 'LineWidth', 1.0, 'DisplayName', 'Loxodrome');

% Paramerternetz plotten
plot(x_d, y_d, 'b-', 'LineWidth',0.2,'DisplayName', 'Parameternetz delta')
plot(x_a, y_a, 'b-', 'LineWidth',0.2,'DisplayName', 'Parameternetz alpha')

% Legende anzeigen
legend('show', 'Location', 'best');

% Format anpassen
set(fig, 'PaperOrientation', 'landscape');
set(fig, 'PaperSize', [29.7, 21]);
set(fig, 'PaperPosition', [0, 0, 29.7, 21]);
print(fig, 'Aufgabe2_YiyinGu_LarsWerny', '-dpdf', '-fillpage');
%% Funktion

function [x, y] = radToKA(phi, lambda)
% Funktion berechnet ausgehend von dem Poldreieck delta und A


phi_KA = deg2rad(49); %Hauptpunkt
lambda_KA = deg2rad(8); %Hauptpunkt
R = 6371000/75000000; % Erdradius in cm

cos_delta = sin(phi_KA)* sin(phi)+ cos(phi_KA)* cos(phi) * cos(lambda-lambda_KA);
delta = acos(cos_delta); % Herleitung über Poldreieck
A = atan2(sin(lambda - lambda_KA) .* cos(phi), ...
              cos(phi) .* sin(phi_KA) .* cos(lambda - lambda_KA) - cos(phi_KA) .* sin(phi)); % Herleitung über Poldreieck
x = 2 * R * tan(delta/2)* cos(A);
y = 2 * R * tan(delta/2)* sin(A);

end
