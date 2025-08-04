function varargout = A18(varargin)

%%Figure erzeugen
f_width = 200;
f_height = 60;
f = figure('Visible','off', 'Units', 'characters', 'Position',[1, 1, f_width, f_height], 'NumberTitle', 'off',...
           'Resize', 'off',...
           'Name', 'A18 - Fahrzeuglokalisation');
       
%%Systemfarben als Hintergrundfarben setzen       
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(f,'Color',defaultBackground);

handles.FzgLokDemo = f;

M = 50;  %Breite des angezeigten Bereiches (quadratisch) in Meter

%Zeichenachse hinzufügen
handles.Axes = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [5, 2, f_width/2-10, f_height-4], 'XLim', [0, M], 'YLim', [0, M], 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', ':');
daspect(handles.Axes, [1, 1, 1]);
hold(handles.Axes, 'on');
%Signalfenster hinzufügen
handles.S1_Axes    = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [f_width/2+5, f_height-1-  (f_height-8)/7, f_width/2-10, (f_height-8)/7]);
handles.S2_Axes    = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [f_width/2+5, f_height-2-2*(f_height-8)/7, f_width/2-10, (f_height-8)/7]);
handles.S3_Axes    = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [f_width/2+5, f_height-3-3*(f_height-8)/7, f_width/2-10, (f_height-8)/7]);
handles.X_Axes     = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [f_width/2+5, f_height-4-4*(f_height-8)/7, f_width/2-10, (f_height-8)/7]);
handles.R_X1_Axes = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [f_width/2+5, f_height-5-5*(f_height-8)/7, f_width/2-10, (f_height-8)/7]);
hold(handles.R_X1_Axes, 'on');
handles.R_X2_Axes = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [f_width/2+5, f_height-6-6*(f_height-8)/7, f_width/2-10, (f_height-8)/7]);
hold(handles.R_X2_Axes, 'on');
handles.R_X3_Axes = axes('Parent', handles.FzgLokDemo, 'Units', 'characters', 'position', [f_width/2+5, f_height-7-7*(f_height-8)/7, f_width/2-10, (f_height-8)/7]);
hold(handles.R_X3_Axes, 'on');

%Die Sender werden in einem gleichseitigen Dreick positioniert. Hierzu wird
%um das Zentrum des Sichtbereiches ein Kreis mit Radius M/2 gelegt, und
%eine Ecke des Dreiecks auf x=m/2 y=M festgelegt. Die Position der anderen
%Ecken ergibt sich dann aus der Forderung, dass das Dreieck gleichseitig
%ist und die Punkte auf dem Kreis liegen sollen.
x1 = M/2;
x2 = M/2*(1-sqrt(3)/2);
x3 = M/2*(1+sqrt(3)/2);

y1 = M;
y2 = M/4;
y3 = M/4;

%Signalfrequenzen
v_s = 343; %Schallgeschwindigkeit in m/s bei 20°C (ungefähr)
d_max = M/2*sqrt(5); %maximale Entfernung eines Puntkes 
                     %von einem Sender (=sqrt(M^2+(M/2)^2));
f_0 = v_s/3/d_max; %folgt aus lambda_3 >= d_max
f1 =   f_0;
f2 = 2*f_0;
f3 = 3*f_0;

tau_max = 1/f3;

T  = 10; %Beobachtungsdauer in Sekunden
Ta = min(T*2^-13, 1/f3/2); %Abtastintervall in Sekunden

%Figure auf dem Bildschirm zentrieren und sichtbar machen
movegui(f, 'center');
set(f, 'Visible', 'on');
%Handles Datenstruktur in figure speichern
guidata(f, handles);

Y = 8; %Maximaler angezeigter y-wert der Signale im Zeitbereich
sigma_n = 2; %Standardabweichung des Sensorrauschens
    
%Sendesignale sind stets gleich, können also vorab berechnet und gezeichnet
%werden
t = 0:Ta:T;
%Hilfsfunktion
sin_f_t = @(f, t)sin(2*pi*f*t);

s1 = sin_f_t(f1, t);
plot(handles.S1_Axes, t, s1, 'b-');
set(handles.S1_Axes, 'XTick',  [], 'YTick',  []);
ylim(handles.S1_Axes, [-Y, Y]);
    
s2 = sin_f_t(f2, t);
plot(handles.S2_Axes, t, s2, 'b-');
set(handles.S2_Axes, 'XTick',  [], 'YTick',  []);
ylim(handles.S2_Axes, [-Y, Y]);


s3 = sin_f_t(f3, t);
plot(handles.S3_Axes, t, s3, 'b-');
set(handles.S3_Axes, 'XTick',  [], 'YTick',  []);
ylim(handles.S3_Axes, [-Y, Y]);

%Senderpositionen einzeichnen
plot(handles.Axes, x1,   y1, 'xk', 'LineWidth', 2, 'MarkerSize', 10);
text(x1+1, y1-2, 'S1', 'Parent', handles.Axes);
plot(handles.Axes, x2,   y2, 'xk', 'LineWidth', 2, 'MarkerSize', 10);
text(x2+1, y2-2, 'S2', 'Parent', handles.Axes);
plot(handles.Axes, x3,   y3, 'xk', 'LineWidth', 2, 'MarkerSize', 10);
text(x3+1, y3-2, 'S3', 'Parent', handles.Axes);    

%%Berechne 80 Punkte auf dem Einheitskreis, diese werden später
%%zur Visualisierung der Entfernungsschätzung benötigt
phi=cat(2, linspace(0,2*pi,80), 0);
x_uc = cos(phi);
y_uc = sin(phi); 

while (ishandle(f))%Endlosschleife bis Benutzer das Fenster schliesst
    
    %letzte Korrelationen löschen
    cla(handles.R_X1_Axes);
    cla(handles.R_X2_Axes);
    cla(handles.R_X3_Axes);
    
    %letzte Fahrzeugposition löschen
    if exist('FahrzeugMarker', 'var')
        delete(FahrzeugMarker);
        delete(Kreis1);
        delete(Kreis2);
        delete(Kreis3);
        delete(SNR_text);
    end
    
    %Fahrzeugposition auslesen und einzeichnen
    %Fahrzeugposition = letzte angeklickte Position
    Pos = get(handles.Axes, 'CurrentPoint');
    x = Pos(1,1);
    y = Pos(1,2);
    FahrzeugMarker = plot(handles.Axes, x, y, 'xb', 'LineWidth', 2, 'MarkerSize', 10);
    
    %Laufzeiten bestimmen
    tau1 = Laufzeit(x, y, x1, y1, v_s);
    tau2 = Laufzeit(x, y, x2, y2, v_s);
    tau3 = Laufzeit(x, y, x3, y3, v_s);
    
    %Sensorrauschen bestimmen
    n = sigma_n * randn([1, numel(t)]);
    
    %Empfangssignal
    x = sin_f_t(f1, t-tau1) + sin_f_t(f2, t-tau2) + sin_f_t(f3, t-tau3) + n;
    
    %%SNR berechnen
    SNR = 20*log10(((x-n)*(x-n)')/(n*n'));
    SNR_text = text(2,2, strcat('SNR = ', num2str(SNR), ' dB'), 'Parent', handles.Axes);
    
    %Korrelationen schätzen
    R_x1 = xcorr(x, s1, 'unbiased');
    R_x2 = xcorr(x, s2, 'unbiased');
    R_x3 = xcorr(x, s3, 'unbiased');
    
    %Verschiebungen
    tau = cat(2, fliplr(-t(2:end)), t);
    
    %Extrahiere Maxima im Intervall [0, tau_max]
    search_ind = find(tau >=0 & tau <= tau_max);
    tau_search = tau(search_ind);
    [~, tau_1_ind] = max( R_x1(search_ind) );
    tau_1_est = tau_search(tau_1_ind);
    [~, tau_2_ind] = max( R_x2(search_ind) );
    tau_2_est = tau_search(tau_2_ind);
    [~, tau_3_ind] = max( R_x3(search_ind) );
    tau_3_est = tau_search(tau_3_ind);
    
    %Zeichne Empfangssignal und Korrelationsfunktionen
    plot(handles.X_Axes, t, x, 'r-');
    ylim(handles.X_Axes, [-Y, Y]);
    plot(handles.R_X1_Axes, tau, R_x1/max(abs(R_x1)), 'k-');
    plot(handles.R_X2_Axes, tau, R_x2/max(abs(R_x2)), 'k-');
    plot(handles.R_X3_Axes, tau, R_x3/max(abs(R_x3)), 'k-');
    xlim(handles.R_X1_Axes, [0, tau_max]);
    xlim(handles.R_X2_Axes, [0, tau_max]);
    xlim(handles.R_X3_Axes, [0, tau_max]);    
    %Zeichne gefundene Maxima in Korrelationsfunktionen
    plot(handles.R_X1_Axes, [tau_1_est, tau_1_est], [-1, 1], 'r');
    plot(handles.R_X2_Axes, [tau_2_est, tau_2_est], [-1, 1], 'm');
    plot(handles.R_X3_Axes, [tau_3_est, tau_3_est], [-1, 1], 'c');
    %Zeichne gefundene Maxima als Kreise in der 2-D-Ebene
    Kreis1 = plot(handles.Axes, x_uc*v_s*tau_1_est+x1, y_uc*v_s*tau_1_est+y1, 'r');
    Kreis2 = plot(handles.Axes, x_uc*v_s*tau_2_est+x2, y_uc*v_s*tau_2_est+y2, 'm');
    Kreis3 = plot(handles.Axes, x_uc*v_s*tau_3_est+x3, y_uc*v_s*tau_3_est+y3, 'c');
    
    set(handles.X_Axes, 'XTick',  [], 'YTick',  []);
    set(handles.R_X1_Axes, 'XTick',  [], 'YTick',  []);
    set(handles.R_X2_Axes, 'XTick',  [], 'YTick',  []);
    set(handles.R_X3_Axes, 'XTick',  [], 'YTick',  []);
    ylabel(handles.R_X1_Axes, 'R_{x1}(\tau)');
    ylabel(handles.R_X2_Axes, 'R_{x2}(\tau)');
    ylabel(handles.R_X3_Axes, 'R_{x3}(\tau)');
    ylabel(handles.X_Axes, 'x(t)');
    ylabel(handles.S1_Axes, 'S_1(t)');
    ylabel(handles.S2_Axes, 'S_2(t)');
    ylabel(handles.S3_Axes, 'S_3(t)');
    
    %Dieser Befehl sorgt für eine Pause, bis alles gezeichnet und
    %dargestellt ist
    drawnow;
end

%falls gewünscht, Zeiger auf die figure zurückgeben
if nargout
    varargout = {f};
end

    function tau = Laufzeit(x1, y1, x2, y2, v_s)
        tau = 1/v_s * sqrt( (x1-x2)^2 + (y1-y2)^2);
    end
end