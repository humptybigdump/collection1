%AUSFUEHRBARES SKRIPT
clear all
clc

%Festlegung des Feeds
%M_Punkt_0 [kg/s], Modellgleichung 13, VORG_M_0
M0 = 1000/3600;
%Massenanteile Salz und Wasser 
%Modellgleichung 14, VORG_x_0,S
x0s = 0.5;
%Modellgleichung 15, VORG_x_0,W
x0w = 0.49;

%Feste Massenanteile der austretenden Massenströme
%Modellgleichung 16, VORG_x_5,S
x5s = 0;
%Modellgleichung 17, VORG_x_5,W
x5w = 1;
%Modellgleichung 25, VORG_x_3,S
x3s = 1;
%Modellgleichung 26, VORG_x_3,W
x3w = 0;

%Vorgabe des Splitfaktors
%Modellgleichung 19, VORG_alpha
alpha = 0.1;

%Modellgleichung 27, VORG_M_5 [kg/s]
M5 = 465.11/3600;
%Modellgleichung 21, VORG_M_K [kg]
MK = 2000;
%Modellgleichung 28b), VORG_x_6,S
x2s_sat = 0.5;

%Angangswerte für Salz- und Wassermasse im Kristallisator
MS_t = 0;
MW_t = MK;
%Salzmassenanteil zu Beginn
x2s = MS_t/MK;

%Zusammenfasung aller konstanten Prozessgrößen zu X_Para
X_Para = [M0, x0s, x0w, M5, x5s, x5w, x3s, x3w, alpha, MK, x2s_sat];

%erstellt Ergebnisdateien
fid = fopen('Ergebnisse_ohne_Filterausschleusung.xls','w');
fid2 = fopen('Ergebnisse_mit_Filterausschleusung.xls','w');

%Integrationsschrittweite [s]
delta_t = 10;
%Ende der Simulation [s]
t_ende= 100000;

%Schleifenbeginn
for t=0:delta_t:t_ende
    
    %falls Salzmassenanteil in Strom 2 kleiner als Löslichkeit x2s_sat
    if x2s <= x2s_sat
        
    %Reihenfolge der zu bestimmenden Prozessgrößen X_Var    
    %X_Var0 = [M1, x1s, x1w, M2, x2s, x2w, M4, x4s, x4w, M6, x6s, x6w, M7, x7s, x7w]
    X_Var0 = [0.416, 0.33, 0.33, 0.277, 0.33, 0.33, 0.0277, 0.33, 0.33, 0.277, 0.33, 0.33, 0.138, 0.33, 0.33];
    [X_Var,res] = fsolve(@(X_Var) Modellgleichungen_ohne_Filterausschleusung(X_Var, X_Para, MS_t, MW_t), X_Var0);
    
    %Rückbenennung der Prozessgrößen
    M1 = X_Var(1);
    x1s = X_Var(2);
    x1w = X_Var(3);
    M2 = X_Var(4);
    x2s = X_Var(5);
    x2w = X_Var(6);
    M4 = X_Var(7);
    M6 = X_Var(10);
    M7 = X_Var(13);
    
    %aktualisieren der differentiellen Prozessgrößen
    MS_t_plus_delta_t = MS_t + delta_t*(M1*x1s - M2*x2s); 
    MW_t_plus_delta_t = MW_t + delta_t*(M1*x1w - M2*x2w - M5);

    %Überschreibung der aktuell berechneten Massen für nächsten Schleifendurchlauf
    MS_t = MS_t_plus_delta_t;
    MW_t = MW_t_plus_delta_t;
    
    %Ergebnisse in Ergebnisdatei schreiben
    fprintf(fid,'%8d %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f \r\n',t, M1, M2, M4, M6, M7, MS_t, MW_t);
    
    %Ende if-Bedingung
    end
    
    %falls Salzmassenanteil in Strom 2 größer als Löslichkeit x2s_sat
    if x2s > x2s_sat
        
    %Reihenfolge der zu bestimmenden Prozessgrößen X_Var    
    %X_Var0 = [M1, x1s, x1w, M2, x2s, x2w, M3, M4, x4s, x4w, M6, x6w, M7, x7s, x7w]
    X_Var0 = [0.416, 0.33, 0.33, 0.277, 0.33, 0.33, 0.0277, 0.0277, 0.33, 0.33, 0.277, 0.33, 0.138, 0.33, 0.33];
    [X_Var,res] = fsolve(@(X_Var) Modellgleichungen_mit_Filterausschleusung(X_Var, X_Para, MS_t, MW_t), X_Var0);    
    
    %Rückbenennung der Prozessgrößen
    M1 = X_Var(1);
    x1s = X_Var(2);
    x1w = X_Var(3);
    M2 = X_Var(4);
    x2s = X_Var(5);
    x2w = X_Var(6);
    M3 = X_Var(7);
    M4 = X_Var(8);
    M6 = X_Var(11);
    M7 = X_Var(13);
    
    %aktualisieren der differentiellen Prozessgrößen
    MS_t_plus_delta_t = MS_t + delta_t*(M1*x1s - M2*x2s); 
    MW_t_plus_delta_t = MW_t + delta_t*(M1*x1w - M2*x2w - M5);
    
    %Überschreibung der aktuell berechneten Massen für nächsten Schleifendurchlauf    
    MS_t = MS_t_plus_delta_t;
    MW_t = MW_t_plus_delta_t;
    
    %Ergebnisse in Ergebnisdatei schreiben    
    fprintf(fid2,'%8d %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\r\n',t, M1, M2, M3, M4, M6, M7, MS_t, MW_t); 
       
    %Ende if-Bedingung    
    end
   
%Schleifenende    
end

%schließt die Ergebnisdateien
fclose(fid);
fclose(fid2);