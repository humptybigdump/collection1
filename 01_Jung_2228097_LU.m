%PLU-Zerlegung
%Valentin Jung
%2228097

close all;
clear all;

Matrix_gr = 20;

P = 0;
A = randi([1 10], Matrix_gr, Matrix_gr);
b = randi([1 10], Matrix_gr, 1);
[L, U] = lu(A);

y = linsolve(L,b);
x = linsolve(U,y);