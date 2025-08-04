%Ueb04 - Matlab
%Valentin Jung
%2228097

close all;
clear all;

A = randi([1,20],20,20);
b = randi([1,20],20,1);

[Q,R] = qr(A);

L1 = linsolve (R, Q'*b);
L2 = linsolve (A, b);

L = L2 -L1;