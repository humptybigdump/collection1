%% Geometrische Modelle der Geodäsie
% Blatt 6 Aufgabe 5 - Quaternionen
% Ramon Butzer

clear variables;
close all;
clc;

%%

% Beispielquaternionen
q1 = quat(1,0,1,0);
q2 = quat(1,0,-1,1);
disp("Addition: ")
quatAdd(q1,q2)
disp("Multiplikation: ")
quatProd(q1,q2)
disp("Konjugation")
quatConj(q1)
disp("Inverse")
quatInv(q1)
disp("Norm")
quatNorm(q1)
disp("Quotient")
quatDiv(q1,q2)


%%
% Funktionsdefinitionen
function y = quat(A, B, C, D)       % Quaternion definition
    y = [A B C D];
end

function y = quatAdd(a,b)           % Addition
    y = a+b;
end    
    
function y = quatProd(a,b)          % Multiplikation nicht kommutativ
    y = zeros(1,4);
    y(1) = a(1)*b(1) - a(2)*b(2) - a(3)*b(3) - a(4)*b(4);
    y(2) = a(1)*b(2) + a(2)*b(1) + a(3)*b(4) - a(4)*b(3);
    y(3) = a(1)*b(3) - a(2)*b(4) + a(3)*b(1) + a(4)*b(2);
    y(4) = a(1)*b(4) + a(2)*b(3) - a(3)*b(2) + a(4)*b(1);
end

function y = quatDiv(a,b)           % Division (greift auf Inverse zu)
    y = quatProd(a, quatInv(b));
end

function y = quatInv(a)             % inverse (für Division benötigt
    y = quatConj(a) / quatNorm(a)^2;
end

function y = quatConj(a)            % Konjugation (für Inverse benötigt)
    y = [1 -1 -1 -1].*a;
end

function y = quatNorm(a)            % Norm (für Inverse benötigt)
    y = sqrt(sum(a.^2));
end