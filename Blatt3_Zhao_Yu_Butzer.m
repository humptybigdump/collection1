%% Geometrische Modelle der Geodäsie
% Blatt 3 Aufgabe 5 - Ueberbestimmtes LGS loesen
% Ramon Butzer, Kangje Zhao, Chuang Ju

clear variables;
close all;
clc;

%% Matrizen und Vektoren erstellen

% Matrix A 20x10
A = randi([1 10], 20, 10);

% Matrix B 20x20 = A'A
B = A'*A;

% Vektor b 20x1
b = randi([1 10],20,1);

%% Vergewisserung des Rangs und der Symmetrie

% Abfrage des Rangs von A
if(rank(A) == 10)
    disp('Matrix A hat den Rang 10');
else
    disp('Matrix A hat nicht Rang 10, sondern Rang ' + rank(A));
end

% Abfrage der Symmetrie von B = A'A
if(B == B')
    disp('Matrix B = A''A ist symmetrisch');
else
    disp('Matrix B = A''A ist nicht symmetrisch');
end

%% Darstellung der Eigenwerte
figure
scatter(1:10,eig(B), 'b', 'filled');
title('Eigenwerte der Matrix A^T A');
xlabel('Nummer des Eigenwerts');
ylabel('Wert des Eigenwerts');

%% Choleskyzerlegung
eps = 0.001;
R = chol(B);        % WICHTIG: R ist hier die OBERE Dreiecksmatrix!!
%RtransR = R'*R;
G = R';
GGtrans = G*G';

% pruefe, ob GG' tatsaechlich gleich B ist
boolwert = 0;
for i = 1:B(:,1)
    for j = 1:B(1,:)
      if(B > GGtrans-eps | B < GGtrans+eps)
          boolwert = 1;
      end
    end
end

if boolwert==1
    disp('Es ist B == G*G''. Die Choleskyzerlegung hat funktioniert!');
else
    disp('B nicht gleich G*G''. Die Choleskyzerlegung hat nicht funktioniert');
end

% Einfache Abfrage der Gleichheit funktioniert aufgrund von Rundungen
% nicht!
% B==G*G'
% B
% G*G'

%% Loesen der beiden LGS mithilfe Choleskyzerlegung
y_cholesky = linsolve(G,A'*b);
x_cholesky = linsolve(G',y_cholesky)

% Ueberpruefungen
x_normal = linsolve(A,b);
x_probe = linsolve(A'*A, A'*b);

if(x_cholesky > x_probe-eps | x_cholesky < x_probe+eps)
    disp(sprintf('Die Choleskyzerlegung liefert das korrekte Ergebnis!\nUeberprueft: GG''x = A''b   <=>  A''*A*x = A''b'));
else
    disp('Choleskyzerlegung liefert anderes Ergebnis als A''*A*x = A''b');
end


