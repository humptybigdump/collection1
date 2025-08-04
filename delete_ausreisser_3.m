% Auswahl Einzelmerkmal (EM)
% {'MAX ZR Energy','MIN ZR Energy'}
set_textauswahl_listbox(gaitfindobj('CE_Auswahl_EM'),{'MAX ZR Energy','MIN ZR Energy'});eval(gaitfindobj_callback('CE_Auswahl_EM'));

%% Einzelmerkmale,  Ansicht,  Manuelle Klassenzuweisung Datentupel über Einzelmerkmale 
eval(gaitfindobj_callback('MI_Anzeige_SpecialSelection'));

% Wertebereich für Auswahl
set(gaitfindobj('CE_DatapointValueSelection'),'string','<0');eval(gaitfindobj_callback('CE_DatapointValueSelection'));

%% Auswählen,  Bearbeiten,  Datentupel über Werte der Einzelmerkmale 
eval(gaitfindobj_callback('MI_Datenauswahl_ValueSelection'));

%% Löschen,  Bearbeiten,  Ausgewählte Datentupel 
eval(gaitfindobj_callback('MI_Loeschen_Datentupel'));

