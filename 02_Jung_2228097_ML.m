%Ueb02 - Matlab
%Valentin Jung
%2228097

close all;
clear all;

f = @computeSquare;
g = @computePowerThree;

num = (1:1:20)';
fValues = f(num);
gValues = g(num);
sumValues = sum(fValues, gValues);

figure;
scatter(num, fValues)
hold on
scatter(num, gValues)
hold on
scatter(num, sumValues)
title('Ueb02');
hold off;

function x = computeSquare(x)
x = x.^2;
end

function y = computePowerThree(x)
y = x.^3;
end

function z = sum(x, y)
z = x+y;
end