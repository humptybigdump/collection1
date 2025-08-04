%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aufgabe 2 Least Square Schätzer
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Plot der Datenpunkte und des Berechneten Approximationspolynoms
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Gegeben Datenwerte aus Tabelle
data_s = [0, 10, 20];
data_h = [10, 50, 10];

%% Berechnetes Polynom
s = linspace(0,25,100);
h = 10 + 8*s - 0.4*s.^2;

%% Plot der Daten und des Polynoms
figure();
plot(s, h);
xlim([0, 22])
ylim([-0.1, 55])
hold on;
plot(data_s, data_h, 'o');
hold off;

