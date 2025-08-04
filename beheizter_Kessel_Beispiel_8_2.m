clear all
clc

%konstante F�llmasse im Kessel [kg]
M = 250;

%zufliessender = abfliessender Massenstrom [kg/h]
M_Punkt = 1800/3600;

%W�rmekapazit�t des Kesselinhalts und der Massenstr�me [J/kgK]
cp = 4180;

%Temperatur zufliessender Massenstrom [�C]
T_zu = 25;

%Umgebungstemperatur [�C]
T_u = 20;

%W�rmedurchgangskoeffizient [W/m�K] und Manteloberfl�che [m�]
k = 5;
A = 3.5;

%zugef�hrter W�rmestrom [W]
Qzu = 1000;

%Anfangstemperatur Kesselinhalt [�C]
T_Beginn = 20;

%Integrationsschrittweite [s]
delta_t = 1;

%t_Ende [s]
t_Ende = 3600;

%Speichern der Anfangstemperatur in der Variablen T, die von Zeitschritt zu Zeitschritt
%ge�ndert wird
T = T_Beginn;

%�ffnet Ergebnisdatei "T-t.xls"
fid = fopen('T-t.xls','w');

%Berechnung Enthalpie eintretender Massenstrom [W]
H_zu = M_Punkt*cp*T_zu;

%Schleife der L�sung 
for t=0:delta_t:t_Ende
   
    %Speichern der aktuellen Temperatur in "T-t.xls"
    %Syntax von fprintf: fprintf(FILE, Format, Inhalt)
    %�FILE� ist die skriptinterne Variable, in die geschrieben werden soll (in diesem Fall soll
    %in fid geschrieben werden)
    %�Format� gibt die Formatierung wieder (in diesem Fall Integerzahl mit max. 6 Stellen (6d),
    %Floatzahl mit max. 12 Stellen bei 8 Nachkommastellen (12.8f), \r\n bedeutet Zeilenumbruch)
    %�Inhalt� stellt die zu schreibenden Gr��en dar (in diesem Fall t (Zeit) und T (Temperatur)
    %f�r weitere Infos siehe MATLAB-Hilfe zu fprintf
    fprintf(fid,'%6d %12.8f \r\n',t,T);
    
    %Berechnung Enthalpie abfliessender Massenstrom [W]
    H_ab = M_Punkt*cp*T;
    Q_Verlust = k*A*(T-T_u);
   
    %Diskretisierung der Differentialgleichung
    T_t_plus_delta_t = T + delta_t/(M*cp)*(H_zu - H_ab + Qzu - Q_Verlust);
   
    %�berschreibung der aktuell berechneten Temperatur f�r n�chsten Schleifendurchlauf
    T = T_t_plus_delta_t;
      
end

%schlie�t Ergebnisdatei "T-t.xls"
fclose(fid);