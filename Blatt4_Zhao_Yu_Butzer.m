%% Geometrische Modelle der Geodäsie
% Blatt 4 Aufgabe 5 - QE-Zerlegung
% Ramon Butzer, Kangje Zhao, Chuang Ju

clear variables;
close all;
clc;

%% Matrizen und Vektoren erstellen

% Matrix A 20x10
A = randi([1 10], 20, 20);
disp("Matrix A hat Rang " + rank(A));

% Vektor b 20x1
b = randi([1 10],20,1);

%% QR-Zerlegung
eps = 0.001;
[Q,R] = qr(A);   % Q ist ONB von Bild(A), R ist obere DreiecksMatrix

% pruefe, ob Q*R gleich A ist
boolwert = 1;
for i = 1:A(:,1)
    for j = 1:A(1,:)
      if(A < Q*R-eps | A > Q*R +eps)
          boolwert = 0;
      end
    end
end

if boolwert==1
    disp('Es ist A == Q*R. Die QR-Zerlegung hat funktioniert!');
else
    disp('B nicht gleich Q*R. Die QR-Zerlegung hat nicht funktioniert');
end

% Einfache Abfrage der Gleichheit funktioniert aufgrund von Rundungen
% nicht!
% A == Q*R


%% Loesen des LGS mithilfe QR-Zerlegung


y_qr = linsolve(Q,b);
x_qr = linsolve(R,y_qr);
% x_qr = linsolve(R,Q'*b);  % Alternativ

% Ueberpruefungen
x_normal = linsolve(A,b);

if(x_qr > x_normal-eps | x_qr < x_normal+eps)
    fprintf('Die QR-Zerlegung liefert das korrekte Ergebnis!\nUeberprueft: Q R x = A b   <=>  A x = b\n');
else
    disp('QR-Zerlegung liefert anderes Ergebnis als A x= b');
end

%% Ausgabe eines Beispiels mit kleinerer Matrix
% A = randi([1 10], 5, 5)
% [Q1,R1] = qr(A)
% Q1*R1


