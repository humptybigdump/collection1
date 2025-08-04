    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Vergleich der verschiedenen Interpolations/Approximations-Verfahren
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Es werden 3 Testfunktionen verwendet:
%    - Ein Polynom niedrigen Grades
%    - Ein Polynom hohen Grades
%    - Eine schlecht durch Polynome anzunähernde Funktion
%
% Diese werden jeweils durch die Verfahren
%   -Lagrange-Interpolation
%   -Spline-Interpolation
%   -Least-Squares Schätzer (mit passendem Signalmodell)
%
% interpoliert / approximiert.
%
% Hierzu werden die Eingangswerte einmal unverfälscht, und einmal mit einem
% additiven zufälligen Fehler versehen herangezogen.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Testfunktionen definieren
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_f = 3; %%Anzahl der Testfunktionen
N_V = 3; %%Anzahl der Interpolations-/Approximations-Verfahren


%%Polynom vom Grad 2
f1 = @(u)u.^2+3*u-0.3*ones(size(u));

%%Polynom vom Grad 8
f2 = @(u)1e-8*u.^8-1e-7*u.^7+1e-6*u.^6-1e-5*u.^5+1e-4*u.^4+1e-3*u.^3-1e-2*u.^2+1e-1*u+ones(size(u));

%%1/(1+u^2)
f3 = @(u)1./(1+u.^2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Eingangswerte erzeugen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Stützstellen für Anzeige
u = (-10:0.01:10)';
N = numel(u);

%Stützstellen für Interpolation/Approximation
Schrittweite = 100;
u_in = u(1:Schrittweite:end);
N_in = numel(u_in);

%Stützstellenwerte
y = zeros(N, N_f);
y(:,1) = f1(u);
y(:,2) = f2(u);
y(:,3) = f3(u);

y_in = zeros(N_in, N_f);
y_in(:,1) = f1(u_in);
y_in(:,2) = f2(u_in);
y_in(:,3) = f3(u_in);

%Fehler / Störung / Rauschen
y_in_f = zeros(N_in, N_f);
for k=1:N_f
    %%Rauschleistung an Signalstärke anpassen
    sigma = 0.04*( max(y_in(:,k))-min(y_in(:,k)) );
    n = normrnd(0,sigma,size(y_in(:,k)));
    
    y_in_f(:,k) = y_in(:,k) + n;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Interpolation / Approximation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y_out   = zeros(N, N_f, N_V);
y_out_f = zeros(N, N_f, N_V);

%%Globales Polynomverfahren (Lagrange-Verfahren könnte auch problemlos 
%%durch Newton-Verfahren ersetzt werden)
for k=1:N_f
    %%ungestörte Eingangswerte
    a = LagrangeInterp(u_in, y_in(:,k));
    y_out(:,k,1) = EvaluatePolynom(u, a);
    
    %%gestörte Eingangswerte
    a = LagrangeInterp(u_in, y_in_f(:,k));
    y_out_f(:,k,1) = EvaluatePolynom(u, a);
end

%%Lokales Polynomverfahren (Spline-Interpolation)
for k=1:N_f
    %%ungestörte Eingangswerte
    A = SplineInterp(u_in, y_in(:,k));
    for l=1:N_in-1
        %alle Stützstellen die zum Definitionsbereich des aktuellen Splines
        %gehören finden
        Indices = find(u >= u_in(l) & u <= u_in(l+1));
        %Für diese Stützstellen den aktuellen Spline auswerten
        y_out(Indices,k,2) = EvaluatePolynom(u(Indices), A(l,:)');
    end
    
    %%gestörte Eingangswerte
    A = SplineInterp(u_in, y_in_f(:,k));
    for l=1:N_in-1
        %alle Stützstellen die zum Definitionsbereich des aktuellen Splines
        %gehören finden        
        Indices = find(u >= u_in(l) & u <= u_in(l+1));
        %Für diese Stützstellen den aktuellen Spline auswerten        
        y_out_f(Indices,k,2) = EvaluatePolynom(u(Indices), A(l,:)');
    end
end

%%Least-Squares Schätzer
for k=1:N_f
    %%Polynomordnung auswählen
    switch (k)
        case 1
            M = 2;
        case 2
            M = 8;
        case 3
            M = 8;
        otherwise
            M = N_in-1;
    end
    
    %%ungestörte Eingangswerte
    a = LeastSquaresPolynom(u_in, y_in(:,k), M);
    y_out(:,k,3) = EvaluatePolynom(u, a);
    
    %%gestörte Eingangswerte
    a = LeastSquaresPolynom(u_in, y_in_f(:,k), M);
    y_out_f(:,k,3) = EvaluatePolynom(u, a);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Anzeige
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LineWidth = 2;
MarkerSize = 10;
FontSize = 20;

for k=1:N_f
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%ungestörte Eingangswerte
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure;
    hold all;
    plot(u, y(:,k), 'LineWidth', LineWidth); %%Anzunähernde Funktion
    plot(u_in, y_in(:,k), 'o', 'LineWidth', LineWidth, 'MarkerSize', 10); %%Stützstellen hervorheben    
    for l=1:N_V
        plot(u, y_out(:,k,l), 'LineWidth', LineWidth, 'LineStyle', ':'); %%Ergebnisse des l-ten Verfahrens
    end
    
    %Anzeigebereich anpassen (in vertikaler Richtung)
    miny = min(y(:,k));
    maxy = max(y(:,k));
    d = 0.2; %%Der Anzeigebereich soll "oben" und "unten" jeweils 10% mehr
             %%zeigen
    miny_neu = 0.5 * (  -d  * maxy + (2-d) * miny);
    maxy_neu = 0.5 * ((2+d) * maxy +    d  * miny);
    ylim([miny_neu, maxy_neu]);
    
    %Achsenbeschriftung, etc.
    xlabel('u', 'FontSize', FontSize);
    ylabel('y', 'FontSize', FontSize);
    legend('Zu interpolierende Funktion', 'Eingangswerte', 'Lagrange', 'Splines', 'Polynom-LS');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%gestörte Eingangswerte
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure;
    hold all;
    plot(u, y(:,k), 'LineWidth', LineWidth); %%Anzunähernde Funktion
    plot(u_in, y_in_f(:,k), 'o', 'LineWidth', LineWidth, 'MarkerSize', 10); %%gestörte Werte
    for l=1:N_V
        plot(u, y_out_f(:,k,l), 'LineWidth', LineWidth, 'LineStyle', ':'); %%Ergebnisse des l-ten Verfahrens
    end
    
    %Anzeigebereich anpassen (in vertikaler Richtung)
    miny = min(y(:,k));
    maxy = max(y(:,k));
    d = 0.2; %%Der Anzeigebereich soll "oben" und "unten" jeweils 10% mehr
             %%zeigen
    miny_neu = 0.5 * (  -d  * maxy + (2-d) * miny);
    maxy_neu = 0.5 * ((2+d) * maxy +    d  * miny);
    ylim([miny_neu, maxy_neu]);
    
    %Achsenbeschriftung, etc.
    xlabel('u', 'FontSize', FontSize);
    ylabel('y', 'FontSize', FontSize);
    legend('Zu interpolierende Funktion', 'Eingangswerte', 'Lagrange', 'Splines', 'Polynom-LS');
    
end