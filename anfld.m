function [rueck] = anfld(fname)

%*****************************************************
%
% Aufruf durch nuint20.m
%
% Unterprogramm zum Einlesen der Anfangseinstellungen
% fuer das Programm nuint20.m
%
% anfld : "Anfangseinstellungen laden"
%
%*****************************************************

format long g



disp('===== anfld =====')
disp( [ 'Datei mit Anfangseinstellungen :  ', fname ] )


 
%***********************************************************

%-------------------------------------------
datein = fopen(fname, 'r');

nexpl = 1;

%-------------------------------------------
vekein= zeros(1,15);

% Einlesen von aweid, koosys :
[vekein(1:2), anz1] = fscanf(datein, '%*s %i %*s %i', [2]);

% Einlesen der Anfangswerte awor :
[expl, anzex] = fscanf(datein, '%*s', [nexpl]);
[vekein(3:8), anz2] = fscanf(datein, '%g', [6]);

% Einlesen von wieinh :
[expl, anzex] = fscanf(datein, '%*s', [nexpl]);
[vekein(9), anz3] = fscanf(datein, '%i', [1]);



% Einlesen von MAXDEG, intmid :
[vekein(10:11), anz4] = fscanf(datein, '%*s %i %*s %i', [2]);

% Einlesen von t0, tfinal :
[vekein(12:13), anz5] = fscanf(datein, '%*s %g %*s %g', [2]);

% Einlesen von eumrid, anzvu :
[vekein(14:15), anz6] = fscanf(datein, '%*s %i %*s %g', [2]);



% Einlesen von inpaid, reltol, abstol :
[vekein(16:18), anz8] = fscanf(datein, '%*s %i %*s %g %*s %g', [3]);

% Einlesen von stout, maxst, stpfak :
[vekein(19:21), anz8] = fscanf(datein, '%*s %i %*s %g %*s %g', [3]);




% Einlesen von intvid, ivlaus :
[vekein(22:23), anz5] = fscanf(datein, '%*s %i %*s %g', [2]);

% Einlesen von ausid1, ausid2, ausid3 :
[vekein(24:26), anz9] = fscanf(datein, '%*s %i %*s %i %*s %i', [3]);

%-------------------------------------------

zu= fclose(datein);

%***********************************************************


rueck= vekein';

%lr= length(rueck)
