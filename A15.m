function varargout = DisparityDemo(varargin)

%%Figure erzeugen und u.a. festlegen, dass bei Knopfdruck die Funktion
%%DisparityDemo_KeyPressFcn aufgerufen wird
f = figure('Visible','off', 'Units', 'characters', 'Position',[1, 1, 100, 60], 'NumberTitle', 'off',...
           'KeyPressFcn', {@DisparityDemo_KeyPressFcn},...
           'Resize', 'on',...
           'Name', 'DisparityDemo');
       
%%Systemfarben als Hintergrundfarben setzen       
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(f,'Color',defaultBackground);

handles.DisparityDemo = f;
%Zeichenachse hinzuf�gen
handles.Axes = axes('Parent', handles.DisparityDemo);

xmax = 50; %"Tiefe" des Anzeigebereiches in m
alpha = 36; %�ffnungswinkel der beiden Kameras in Grad
ymax = xmax*tan(alpha*pi/180/2); %Breite des Sichtbereiches einer Kamera 
                                 %bei x=xmax

b=0.4; %Basisbreite der Stereoanordnung = Abstand der Kameras zueinander
PixPerLine = 640; %Pixelzahl der Kameras pro Zeile
CamRes = (PixPerLine-1)/(2*tan(alpha*pi/180/2)); %f/Delta p, legt die 
                                          %Aufl�sung fest.
                                          %Kann auch, wie hier, abh�ngig
                                          %vom �ffnungswinkel alpha und der
                                          %Anzahl an Pixeln pro Zeile
                                          %PixPerLine angegeben werden

%Umrechnungsfunktion von x,y nach
%horizontaler Pixelkoordinate k
handles.fk = @(x,y)CamRes*y./x-0.5;  

%Umrechnungsfunktionen von zwei Pixelkoordinaten im linken und rechten Bild
%nach x,y
handles.fx1 = @(l,r)CamRes*b./(r-l);
handles.fy1 = @(l,r)b/2*(l+r+1)./(r-l);

%Umrechnungsfunktionen von Mittelwert und Disparit�t nach x,y
handles.fx2 = @(m,d)CamRes*b./d;
handles.fy2 = @(m,d)b/2*(2*m+1)./d;

%Anzahl an Punkten die erzeugt werden wenn man einen neuen "wahren" Punkt
%vorgibt
handles.N=1e3;

%%Standardabweichung des Fehlers f�r linke und rechte Pixelkoordinate
handles.sr = 1;
handles.sl = 1;
%%Standardabweichung des Fehlers f�r Disparit�t und Mittelwert. Ergibt sich
%%aus d=r-l und m=0.5*(r+l)
handles.sd = sqrt(handles.sr^2+handles.sl^2);
handles.sm = 0.5*sqrt(handles.sr^2+handles.sl^2);

%Sichtfelder der Kameras zeichnen
hold(handles.Axes, 'on');
%linke Kamera
plot(handles.Axes, [-b/2, -b/2-ymax], [0, xmax], 'k:', 'LineWidth', 2);
plot(handles.Axes, [-b/2, -b/2+ymax], [0, xmax], 'k:', 'LineWidth', 2);
%rechte Kamera
plot(handles.Axes, [ b/2,  b/2-ymax], [0, xmax], 'k:', 'LineWidth', 2);
plot(handles.Axes, [ b/2,  b/2+ymax], [0, xmax], 'k:', 'LineWidth', 2);

xlim(handles.Axes, [-25,25]);
ylim(handles.Axes, [0,50]);
daspect(handles.Axes, [1,1,1]);
xlabel('-y');
ylabel('x');
grid(handles.Axes, 'on');

%Figure auf dem Bildschirm zentrieren und sichtbar machen
movegui(f, 'center');
set(f, 'Visible', 'on');
%Handles Datenstruktur in figure speichern
guidata(f, handles);

%falls gew�nscht, Zeiger auf die figure zur�ckgeben
if nargout
    varargout = {f};
end

    %%Diese Funktion wird immer aufgerufen, wenn DisparityDemo den Focus
    %%hat und eine Taste gedr�ckt wird. (Hierzu darf z.B. das Zoom-Werkzeug
    %%NICHT ausgew�hlt sein)
    function DisparityDemo_KeyPressFcn(DispDemoHandle, eventdata)
        %wenn "p" gedr�ckt wurde, einen neuen Punkt einzeichnen, sonst
        %nicht reagieren
        if eventdata.Key == 'p'
            %%Daten der figure holen, da hier die Funktionen zur Umrechnung
            %%usw. gespeichert sind
            handles = guidata(DispDemoHandle);

            %%Berechne 40 Punkte auf dem Einheitskreis, diese werden sp�ter
            %%zur Visualisierung der Kovarianzen ben�tigt
            phi=cat(2, linspace(0,2*pi,40), 0);
            x_uc = cos(phi);
            y_uc = sin(phi);            
            
            %%Warten bis der Benutzer irgendwo in die Zeichenachse geklickt
            %%hat, und die Koordinaten der angeklickten Punktes holen
            [y0, x0] = ginput(1); %Achtung: x,y Achse sind hier per 
                                  %Definition um 90� Gedreht im Vergleich
                                  %zu Matlabs Standardkoordinatensystem
            y0=-y0;               %--> Reihenfolge von x/y umdrehen und y
                                  %negieren
            cla(handles.Axes); %Zeichenfl�che l�schen/leeren
            
            %Sichtfelder der Kameras zeichnen
            plot(handles.Axes, [-b/2, -b/2-ymax], [0, xmax], 'k:', 'LineWidth', 2);
            plot(handles.Axes, [-b/2, -b/2+ymax], [0, xmax], 'k:', 'LineWidth', 2);
            plot(handles.Axes, [ b/2,  b/2-ymax], [0, xmax], 'k:', 'LineWidth', 2);
            plot(handles.Axes, [ b/2,  b/2+ymax], [0, xmax], 'k:', 'LineWidth', 2);

            %Die Koordinatensysteme der einzelnen Kameras sind jeweils um
            %b/2 in y-Richtung verschoben
            yl0 = y0-b/2;
            yr0 = y0+b/2;

            
            %N Punkte um den gerade ausgew�hlten Punkte streuen, wobei die
            %Streuung gem�ss Aufgabe 15 a) unabh�ngig in linkem und rechtem
            %Bild erfolgt
            ml=handles.fk(x0,yl0);  %wahre linke  Pixelkoordinate k_l,0
            mr=handles.fk(x0,yr0);  %wahre rechte Pixelkoordinate k_r,0
            sr = handles.sr;        %Standardabweichung des Fehlers im 
                                    %rechten Bild
            sl = handles.sl;        %Standardabweichung des Fehlers im 
                                    %linken Bild
            %N Punkte zuf�llig ziehen, die normalverteilt um die wahren
            %Werte liegen. Dabei werden die Werte f�r links und rechts
            %unabh�ngig voneinander erzeugt
            l=normrnd(ml,sl,[handles.N,1]);
            r=normrnd(mr,sr,[handles.N,1]);
            %Zu den erzeugten Punkten geh�rige x/y Werte berechnen und
            %deren Kovarianzmatrix berechnen
            x1 = handles.fx1(l,r);
            y1 = handles.fy1(l,r);
            
            M1 = mean([x1, y1]); %Stichprobenmittelwert
            C1 = cov(x1,y1); %Stichprobenvarianz
            %%Bestimme die  Cholesky-Zerlegung der Kovarianzmatrix und
            %%Transformiere damit die Punkte auf dem Einheitskreis:
            %%  Die transformierten Punkte liegen dann auf der l-sigma
            %%  Ellipse, wobei wir l=3 setzten
            EA = 3*chol(C1)'*[x_uc; y_uc];
            %Zeichnen der einzelnen Punkte
            plot(handles.Axes, -y1, x1, '.b');
            %Zeichnen der Ellipse
            plot(handles.Axes, -EA(2,:)-M1(2), EA(1,:)+M1(1), 'c', 'LineWidth', 2);
            
            
            %N Punkte um den gerade ausgew�hlten Punkte streuen, wobei die
            %Streuung gem�ss Aufgabe 15 b) unabh�ngig f�r Mittenwert und
            %Disparit�t erfolgt
            md=mr-ml;           %wahre Disparit�t
            mm=0.5*(mr+ml);     %wahrer Mittenwert
            sd = handles.sd;    %Standardabweichung der Disaprit�t
            sm = handles.sm;    %Standardabweichung des Mittenwertes
            %N Punkte zuf�llig ziehen, die normalverteilt um die wahren
            %Werte liegen. Dabei werden die Werte f�r Disparit�t und
            %Mittenwert unabh�ngig voneinander erzeugt
            d=normrnd(md,sd,[handles.N,1]);
            m=normrnd(mm,sm,[handles.N,1]);
            %Zu den erzeugten Punkten geh�rige x/y Werte berechnen und
            %deren Kovarianzmatrix berechnen
            x2 = handles.fx2(m,d);
            y2 = handles.fy2(m,d);
            
            M2 = mean([x2, y2]); %Stichprobenmittelwert
            C2 = cov(x2,y2); %Stichprobenvarianz
            %%Bestimme die  Cholesky-Zerlegung der Kovarianzmatrix und
            %%Transformiere damit die Punkte auf dem Einheitskreis:
            %%  Die transformierten Punkte liegen dann auf der l-sigma
            %%  Ellipse, wobei wir l=3 setzten
            EB = 3*chol(C2)'*[x_uc; y_uc];
            %Zeichnen der einzelnen Punkte
            plot(handles.Axes, -y2, x2, '.r');
            %Zeichnen der Ellipse
            plot(handles.Axes, -EB(2,:)-M2(2), EB(1,:)+M2(1), 'm', 'LineWidth', 2);
        end
    end

end