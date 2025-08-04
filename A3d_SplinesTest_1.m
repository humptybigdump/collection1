%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Eingangsdaten erstellen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% identische Eingangsdaten und Funktionen wie in A3.m aus Übung 1
%%
%% Änderungen:
%%    -es wird nur ein Satz an Stützstellen berücksichtigt
%%    -die Werte zu den verschiedenen Funktionen werden nicht in mehreren
%%     einzelnen Vektoren gespeichert, sondern in einer Matrix, wobei eine
%%     Spalte zu einer Funktion gehört
%%

%%Stützstellen für Ausgabeplots
u = (-3 : 3e-2 : 3)';

N = numel(u); %%Anzahl der Stützstellen für Ausgabeplots

%%Stützstellen für Interpolation
Schrittweite = 40; %%Zum Vergleich mit A3.m entweder Schrittweite = 5 oder
                   %%Schrittweite = 40 setzen
u_wenig  = u(1:Schrittweite:end); %%Nur jeden Schrittweite-ten Wert 
                                  %%verwenden

N_wenig = numel(u_wenig); %%Anzahl der Stützstellen für Interpolation

%%Zu interpolierende Funktionen definieren
f1 = @(u)exp(u);
f2 = @(u)sin(2*pi*1/4*u);
f3 = @(u)1./(u+3.1);
f4 = @(u)1./(1+u.^2);

%%Namen der Funktionen in einem CellArray speichern, wird später beim
%%Anzeigen der Ergebnisse benötigt
FunctionName = {'Exponentialfunktion'; 'Sinus'; '1/u, verschoben'; '1/(1+u^2)'};

%%Werte dieser Funktionen in den Stützstellen berechnen
y = zeros(N, 4);

y(:,1) = f1(u);
y(:,2) = f2(u);
y(:,3) = f3(u);
y(:,4) = f4(u);

y_wenig = zeros(N_wenig, 4);

y_wenig(:,1) = f1(u_wenig);
y_wenig(:,2) = f2(u_wenig);
y_wenig(:,3) = f3(u_wenig);
y_wenig(:,4) = f4(u_wenig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Die Ergebnisse der verschiedenen Funktionen werden in einem 3D-Array
%%gespeichert, so dass die zu einer Testfunktion zugehörigen Werte auf
%%einer "Seite" stehen
%%
%% N_wenig-1 : Anzahl der Splines = Anzahl Stützstellen - 1
%% 4         : Anzahl der Parameter pro Spline (Polynomkoeffizienten)
%  4         : Anzahl Testfunktionen
A_tilde = zeros([N_wenig-1, 4, 4]);
A       = zeros([N_wenig-1, 4, 4]);

%%loop über alle Testfunktionen
for i=1:4
    [A_tilde(:,:,i), A(:,:,i)] = SplineInterp(u_wenig, y_wenig(:,i));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ausgabe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LineWidth = 3;
MarkerSize = 10;
FontSize = 20;

%%loop über alle Testfunktionen
for i=1:4
    
    figure;    % Neues Fenster erzeugen für Vergleich:
    h1 = gca;  % Interpolationsfunktion / zu interpolierende Funktion
    hold on; %%Dafür sorgen, dass alte plots nicht von neuen gelöscht werden
    
    figure;    % Neues Fenster erzeugen für Vergleich:
    h2 = gca;  % Interpolationsfunktion / Teilfunktionen (einzelne Splines)           
    hold on; %%Dafür sorgen, dass alte plots nicht von neuen gelöscht werden
    
    %Zu interpolierende Funktion (nur in Fenster 1 plotten)
    plot(h1, u, y(:,i), 'b:', 'LineWidth', LineWidth);
    
    %Stützstellen plotten (in beiden Fenstern)
    plot(h1, u_wenig, y_wenig(:,i), 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);
    plot(h2, u_wenig, y_wenig(:,i), 'bx', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);
    
    %Einzelne Splines zusammengesetzt plotten
    for k=1:N_wenig-1
        %%Wertebereich zwischen den Stützstellen "herausschneiden"
        u_i = u( u>=u_wenig(k) & u<=u_wenig(k+1));
        %%Werte des Splines an diesen Werten berechnen
        y_i = EvaluatePolynom(u_i, A_tilde(k,:,i)');
        %%in beiden Fenstern plotten
        plot(h1, u_i, y_i, 'r-', 'LineWidth', LineWidth);
        plot(h2, u_i, y_i, 'r-', 'LineWidth', LineWidth);
    end
    
    %Einzelne Splines über dem gesamten Eingabebereich plotten
    for k=1:N_wenig-1
        %%Spline über dem gesamten Eingabebereich berechnen
        y_i = EvaluatePolynom(u, A_tilde(k,:,i)');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Farbe festlegen.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Die Farben der Splines sollen abwechselnd Cyan und Blau sein
        color1 = [0 1 1]; %%Cyan in [R G B] Darstellung
        color2 = [0 0 1]; %%Blau in [R G B] Darstellung 
        color =  mod(k,2) * color1 + (1-mod(k,2)) * color2;
        
        %%plotten (nur in Fenster 2)
        plot(h2, u, y_i, 'LineStyle', ':', 'LineWidth', LineWidth, 'Color', color);
    end
    
    %Anzeigebereich anpassen (in vertikaler Richtung)
    miny = min(y(:,i));
    maxy = max(y(:,i));
    k = 0.2; %%Der Anzeigebereich soll "oben" und "unten" jeweils 10% mehr
             %%zeigen
    miny_neu = 0.5 * (  -k  * maxy + (2-k) * miny);
    maxy_neu = 0.5 * ((2+k) * maxy +    k  * miny);
    ylim(h1, [miny_neu, maxy_neu]);
    ylim(h2, [miny_neu, maxy_neu]);
    
    %Achsenbeschriftung, etc.
    xlabel(h1, 'u', 'FontSize', FontSize);
    ylabel(h1, 'y', 'FontSize', FontSize);
    legend(h1, 'Zu interpolierende Funktion', 'Stützstellen', 'Interpolationsfunktion');
    title(h1, FunctionName{i}, 'FontSize', FontSize);
    set(h1, 'FontSize', 0.75*FontSize);
    
    xlabel(h2, 'u', 'FontSize', FontSize);
    ylabel(h2, 'y', 'FontSize', FontSize);
    title(h2, FunctionName{i}, 'FontSize', FontSize);
    set(h2, 'FontSize', 0.75*FontSize);
end