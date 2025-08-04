clear all
clc

%konstante Füllmasse im Kessel [kg]
M = 250;

%zufliessender = abfliessender Massenstrom [kg/h]
M_Punkt = 1800/3600;

%Wärmekapazität des Kesselinhalts und der Massenströme [J/kgK]
cp = 4180;

%Temperatur zufliessender Massenstrom [°C]
T_zu = 25;

%Umgebungstemperatur [°C]
T_u = 20;

%Wärmedurchgangskoeffizient [W/m²K] und Manteloberfläche [m²]
k = 5;
A = 3.5;

%zugeführter Wärmestrom [W]
Qzu = 1000;

%Anfangstemperatur Kesselinhalt [°C]
T_Beginn = 20;

%Integrationsschrittweite [s]
delta_t = 1;

%t_Ende [s]
t_Ende = 3600;

%Speichern der Anfangstemperatur in der Variablen T, die von Zeitschritt zu Zeitschritt
%geändert wird
T = T_Beginn;

%Öffnet Ergebnisdatei "T-t.xls"
fid = fopen('T-t.xls','w');

%Berechnung Enthalpie eintretender Massenstrom [W]
H_zu = M_Punkt*cp*T_zu;

%Schleife der Lösung 
for t=0:delta_t:t_Ende
   
    %Speichern der aktuellen Temperatur in "T-t.xls"
    %Syntax von fprintf: fprintf(FILE, Format, Inhalt)
    %‚FILE‘ ist die skriptinterne Variable, in die geschrieben werden soll (in diesem Fall soll
    %in fid geschrieben werden)
    %‚Format‘ gibt die Formatierung wieder (in diesem Fall Integerzahl mit max. 6 Stellen (6d),
    %Floatzahl mit max. 12 Stellen bei 8 Nachkommastellen (12.8f), \r\n bedeutet Zeilenumbruch)
    %‚Inhalt‘ stellt die zu schreibenden Größen dar (in diesem Fall t (Zeit) und T (Temperatur)
    %für weitere Infos siehe MATLAB-Hilfe zu fprintf
    fprintf(fid,'%6d %12.8f \r\n',t,T);
    
    %Berechnung Enthalpie abfliessender Massenstrom [W]
    H_ab = M_Punkt*cp*T;
    Q_Verlust = k*A*(T-T_u);
   
    %Diskretisierung der Differentialgleichung
    T_t_plus_delta_t = T + delta_t/(M*cp)*(H_zu - H_ab + Qzu - Q_Verlust);
   
    %Überschreibung der aktuell berechneten Temperatur für nächsten Schleifendurchlauf
    T = T_t_plus_delta_t;
      
end

%schließt Ergebnisdatei "T-t.xls"
fclose(fid);