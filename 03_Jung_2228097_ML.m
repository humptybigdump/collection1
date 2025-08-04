%Ueb03 - Matlab
%Valentin Jung
%2228097

close all;
clear all;

z = 20; %Zeilen
s = 10; %Spalten

r = 10; %Zufallsbereich

A = zeros(z, s);

for i = 1 : z
    for j = 1 : s
        if i == j
            A(i,j) = 100 * randi(r);
        else A(i,j) = randi(r);
        end
    end
end

B = A' * A;
b = randi([1, s], z, 1);

T_1 = (rank(A) == 10);  %Test Rang = 10
T_2 = (B == B');        %Test Symmetrie

R = chol(B);
y = linsolve(R, A' * b);
x = linsolve(R' ,y);

E = eig(B);

figure;
plot(E)

x_2 = linsolve(B, A' * b);

figure;
plot(x_2 - x)
