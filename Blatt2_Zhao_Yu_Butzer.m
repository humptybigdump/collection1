%% Geometrische Modelle der Geodäsie
% Blatt 2 Aufgabe 5
% Ramon Butzer, Kangje Zhao, Chuang Ju

clear variables;
close all;
clc;

% Funktion anwenden
x_vector = linspace(1,20,20);
f = @ComputeSquare;
g = @ComputeMinusTen;
sum = @ComputeSum;

figure
scatter(x_vector,f(x_vector));
hold on
scatter(x_vector, g(x_vector));
scatter(x_vector, sum(f(x_vector),g(x_vector)));
title('Addition zweier Funktionen');
legend('f(x) = x^2 ', 'g(x) = -10x', '(f+g)(x) =x^2-10x', 'location', 'northwest');
xlabel('x-Achse');
ylabel('y-Achse');


% Funktion erstellen (ganz am Ende des Skripts)
function y = ComputeSquare(x)
y = x.^2;
end

function y = ComputeMinusTen(x)
y = -10*x;
end

function y = ComputeSum(f,g)
y = f + g;
end