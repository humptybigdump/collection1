%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Vergleich von Interpolationsergebnissen mit vielen und wenigen Stützstellen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Eingangsdaten erstellen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%TIPP: "doc colon" in Kommandozeile eingeben um verschiedene Verwendungen
%%      von ":" zu verstehen

%%Stützstellen für Ausgabeplots
u = (-3 : 3e-2 : 3)';

%%Wenige Stützstellen (6)
u_wenig  = u(1:40:end); %%Nur jeden 40. Werte verwenden
%%Viele Stützstellen (41)
u_viel = u(1:5:end); %%Nur jeden 5. Werte verwenden

%%Zu interpolierende Funktionen definieren
f1 = @(u)exp(u);
f2 = @(u)sin(2*pi*1/4*u);
f3 = @(u)1./(u+3.1);
f4 = @(u)1./(1+u.^2);

%%Werte dieser Funktionen in den Stützstellen berechnen
y_1 = f1(u);
y_2 = f2(u);
y_3 = f3(u);
y_4 = f4(u);

  
y_1_wenig = f1(u_wenig);
y_2_wenig = f2(u_wenig);
y_3_wenig = f3(u_wenig);
y_4_wenig = f4(u_wenig);

y_1_viel = f1(u_viel);
y_2_viel = f2(u_viel);
y_3_viel = f3(u_viel);
y_4_viel = f4(u_viel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[a_1_wenig, L_1_wenig, V_1_wenig] = LagrangeInterp(u_wenig, y_1_wenig);
[a_2_wenig, L_2_wenig, V_2_wenig] = LagrangeInterp(u_wenig, y_2_wenig);
[a_3_wenig, L_3_wenig, V_3_wenig] = LagrangeInterp(u_wenig, y_3_wenig);
[a_4_wenig, L_4_wenig, V_4_wenig] = LagrangeInterp(u_wenig, y_4_wenig);

[a_1_viel, L_1_viel, V_1_viel] = LagrangeInterp(u_viel, y_1_viel);
[a_2_viel, L_2_viel, V_2_viel] = LagrangeInterp(u_viel, y_2_viel);
[a_3_viel, L_3_viel, V_3_viel] = LagrangeInterp(u_viel, y_3_viel);
[a_4_viel, L_4_viel, V_4_viel] = LagrangeInterp(u_viel, y_4_viel);


%% Man bemerke, dass wie erwartet L_i_j und V_i_j bei gleichem j 
%% für alle i identisch sind.
%%
%% Bei der Berechnung ab Zeile 48 werden Warnungen ausgegeben, da die
%% Stützstellen zu dicht beieinander liegen und damit die Vandermonde
%% Matrix schlecht konditioniert ist.

V_wenig = fliplr(vander(u)); %%Siehe Kommentare in "LagrangeInterp.m"
V_wenig = V_wenig(:, 1:numel(a_1_wenig)); %%Verwerfen der Spalten die zu 
                                          %%Polynomkoeffizienten zu hoher
                                          %%Ordnung gehören
y_L_1_wenig = V_wenig * a_1_wenig;
y_L_2_wenig = V_wenig * a_2_wenig;
y_L_3_wenig = V_wenig * a_3_wenig;
y_L_4_wenig = V_wenig * a_4_wenig;

V_viel = fliplr(vander(u)); %%Siehe Kommentare in LagrangeInterp
V_viel = V_viel(:, 1:numel(a_1_viel)); %%Verwerfen der Spalten die zu 
                                       %%Polynomkoeffizienten zu hoher
                                       %%Ordnung gehören

y_L_1_viel = V_viel * a_1_viel;
y_L_2_viel = V_viel * a_2_viel;
y_L_3_viel = V_viel * a_3_viel;
y_L_4_viel = V_viel * a_4_viel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ausgabe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LineWidth = 2;
MarkerSize = 10;

% figure % Neues Fenster erzeugen
% plot(u, y_L_1_wenig, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
% hold on % Dafür sorgen dass alter plot nicht überschrieben wird
% plot(u_wenig, y_1_wenig, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %%Stützstellen
% plot(u, y_1, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
% xlabel('u');
% ylabel('y');
% legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
% title('Exponentialfunktion, wenig Stützstellen');

figure % Neues Fenster erzeugen
plot(u, y_L_2_wenig, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
hold on % Dafür sorgen dass alter plot nicht überschrieben wird
plot(u_wenig, y_2_wenig, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %Stützstellen
plot(u, y_2, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
xlabel('u');
ylabel('y');
legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
title('Sinusfunktion, wenig Stützstellen');

figure % Neues Fenster erzeugen
plot(u, y_L_3_wenig, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
hold on % Dafür sorgen dass alter plot nicht überschrieben wird
plot(u_wenig, y_3_wenig, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %Stützstellen
plot(u, y_3, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
xlabel('u');
ylabel('y');
legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
title('1/u um 3,1 nach rechts verschoben, wenig Stützstellen');

% figure % Neues Fenster erzeugen
% plot(u, y_L_4_wenig, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
% hold on % Dafür sorgen dass alter plot nicht überschrieben wird
% plot(u_wenig, y_4_wenig, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %Stützstellen
% plot(u, y_4, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
% xlabel('u');
% ylabel('y');
% legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
% title('1/(1+u^2), wenig Stützstellen');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure % Neues Fenster erzeugen
% plot(u, y_L_1_viel, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
% hold on % Dafür sorgen dass alter plot nicht überschrieben wird
% plot(u_viel, y_1_viel, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %Stützstellen
% plot(u, y_1, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
% xlabel('u');
% ylabel('y');
% legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
% title('Exponentialfunktion, viele Stützstellen');

figure % Neues Fenster erzeugen
plot(u, y_L_2_viel, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
hold on % Dafür sorgen dass alter plot nicht überschrieben wird
plot(u_viel, y_2_viel, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %Stützstellen
plot(u, y_2, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
xlabel('u');
ylabel('y');
legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
title('Sinusfunktion, viele Stützstellen');
% 
figure % Neues Fenster erzeugen
plot(u, y_L_3_viel, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
hold on % Dafür sorgen dass alter plot nicht überschrieben wird
plot(u_viel, y_3_viel, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %Stützstellen
plot(u, y_3, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
xlabel('u');
ylabel('y');
legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
title('1/u um 3,1 nach rechts verschoben, viele Stützstellen');

% figure % Neues Fenster erzeugen
% plot(u, y_L_4_viel, 'r-', 'LineWidth', LineWidth); %%Interpolationsfunktion
% hold on % Dafür sorgen dass alter plot nicht überschrieben wird
% plot(u_viel, y_4_viel, 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize); %Stützstellen
% plot(u, y_4, 'b:', 'LineWidth', LineWidth); %%Zu Interpolierende Funktion
% xlabel('u');
% ylabel('y');
% legend('Interpolationsfunktion', 'Stützstellen', 'Zu interpolierende Funktion');
% title('1/(1+u^2), viele Stützstellen');