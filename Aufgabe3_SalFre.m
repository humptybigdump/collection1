%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Kartenprojektionen         %
%   Bogdan Sala und Marie Freund   %
%          14.02.2023              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Konstanten
rad = pi/180;       %Umformung Winkel zu Radian

%% Staedte mit Name = [Breite Laenge]
London = [51 0]*rad;
Dublin = [53 -6]*rad;
Copenhagen = [55 12]*rad;
Berlin = [52 13]*rad;
Warsaw = [52 21]*rad;
Vienna = [48 16]*rad;
Bologna = [44 11]*rad;
Marseille = [43 5]*rad;
Madrid = [40 -3]*rad;
Santiago_de_Compostela = [42 -8]*rad;
Karlsruhe = [49 8]*rad;
staedte = [London; Dublin; Copenhagen; Berlin; Warsaw; Vienna;...
    Bologna; Marseille; Madrid; Santiago_de_Compostela];

phiP = staedte(:,1);
lambdaP = staedte(:,2);
phiH = Karlsruhe(1,1);
lambdaH = Karlsruhe(1,2);

%% Berechnung von u und v 
u = asin( sin(phiH) .* sin(phiP) + cos(phiH) .*...
    cos(phiP) .* cos(lambdaP - lambdaH));

% Mehrdeutigkeit von Sinus
v = asin( (sin(lambdaP - lambdaH)./cos(u)) .* cos(phiP)); 
for i = 1 : length(v)
    if phiP(i) < phiH
        v(i) = pi() - v(i);
    end
end
% Staedte und Hauptpunkt Karlsruhe
u = [u;0];
v = [v;0];

% Berechnung der Bildkoordinaten fuer die Staedte
[xstr,ystr] = Lambert(u,v);

%% Berechnung der Loxodrome
deltaKa = u(11);
deltaCo = u(3);
alphaKa = v(11);
alphaCo = v(3);

deltaLoxo = deltaKa:0.001:deltaCo;

tanBeta = (alphaCo - alphaKa) / log(tan(pi/4 + deltaCo/2) - log(tan(pi/4 + deltaKa/2)));
alphaLoxo = tanBeta .* log(tan(pi/4 + deltaLoxo/2)) - log(tan(pi/4 + deltaKa/2)) + alphaKa;

%Berechnung der Bildkoordinaten der Loxodrome
[xLoxostr,yLoxostr] = Lambert(deltaLoxo,alphaLoxo);

%% Berechnung der Orthodromen

alphaOrtho = alphaKa:0.001:alphaCo;

deltaOrtho = atan( (tan(deltaKa) .* sin(alphaCo - alphaOrtho) + ...
   tan(deltaCo) .* sin(alphaOrtho - alphaKa)) / sin(alphaCo - alphaKa));

% %Berechnung der Bildkoordinaten der Orthodrome
[xOrthostr,yOrthostr] = Lambert(deltaOrtho,alphaOrtho);

%% Elemente der Verzerrungsellipsen 

%Herleitung der Hauptverzerrungen

% x' = 2*R*sin(delta/2).*cos(alpha);
% y' = 2*R*sin(delta/2).*sin(alpha);

% x'_delta {
% x'_delta = R*cos(alpha)*cos(delta/2)
% y'_delta = R*sin(alpha)*cos(delta/2)

% x'_alpha {
% x'_alpha = -2*R * sin(delta/2)*sin(alpha)
% y'_alpha = 2*R * sin(delta/2)*cos (alpha)

% E'= <x'_delta, x'_delta> = (R*cos(alpha)*cos(delta/2))^2 +
% (R*sin(alpha)*cos(delta/2))^2
%   = R^2*cos^2(delta/2)

% F'= x'_delta x x'_lambda = 0

% G' = <x'_alpha,x'_alpha> = (-2*R * sin(delta/2)*sin(alpha))^2 + (2*R *
% sin(delta/2)*cos (alpha))^2
%    = 4 * R^2 * sin^2(delta/2) 

% E = R^2;
% F = 0;
% G = R^2 * cos^2(delta)

%   a = sqrt(E'/E) = R/R*cos(delta/2) = cos(delta/2)
%   b = sqrt(G'/G) = 1 / cos(delta/2)

%Hauptverzerrungen Berlin
a_Berlin = cos(u(4)/2);
b_Berlin = 1/cos(u(4)/2);

%Hauptverzerrungen_Warsaw
a_Warsaw = cos(u(5)/2);
b_Warsaw = 1 /cos(u(5)/2);

HauptVerz_berlin = [a_Berlin,b_Berlin];
HauptVerz_warsaw = [a_Warsaw,b_Warsaw];

%% Plots
figure ('Name','Lambert Projektion');
scatter(ystr,xstr,'o');
c = {'London'; 'Dublin'; 'Copenhagen'; 'Berlin a:0,7336 b:1,3632';'Warsaw a:0,7592 b:1,3172';'Vienna';...
    'Bologna'; 'Marseille'; 'Madrid'; 'Santiago de Compostela';'Karlsruhe'};
text(ystr,xstr,c,'VerticalAlignment','bottom','HorizontalAlignment','center');

hold on 

plot(yLoxostr,xLoxostr,'r');

plot(yOrthostr,xOrthostr,'b');

legend('Staedte','Loxodrome','Orthodrome','Location','northwest');
grid on 
hold off

% Plot to PDF
set(gcf, 'PaperUnits', 'normalized');
set(gcf, 'PaperOrientation', 'landscape');
set(gcf, 'PaperPosition', [0 0 1 1]);

print(gcf, 'Aufgabe3_SalFre', '-dpdf')


%% Funktionen
function [x, y] = Lambert(delta, alpha)
    R = 637100000;  %Erdradius in cm
    M = 10000000;   %Massstab
    x = 2*R/M*sin(delta/2).*cos(alpha);
    y = 2*R/M*sin(delta/2).*sin(alpha);
end