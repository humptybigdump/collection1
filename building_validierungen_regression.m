% Zeitreihen-Segment von
set(gaitfindobj('CE_Zeitreihen_Segment_Start'),'string','1');eval(gaitfindobj_callback('CE_Zeitreihen_Segment_Start'));

% bis
set(gaitfindobj('CE_Zeitreihen_Segment_Ende'),'string','2104');eval(gaitfindobj_callback('CE_Zeitreihen_Segment_Ende'));

%% Regression,  Data-Mining,  Entwurf 
eval(gaitfindobj_callback('MI_Regression_Entwurf'));

%% Regression,  Data-Mining,  Anwendung 
eval(gaitfindobj_callback('MI_Regression_Anwendung'));

% bis
set(gaitfindobj('CE_Zeitreihen_Segment_Ende'),'string','4208');eval(gaitfindobj_callback('CE_Zeitreihen_Segment_Ende'));

% Zeitreihen-Segment von
set(gaitfindobj('CE_Zeitreihen_Segment_Start'),'string','2105');eval(gaitfindobj_callback('CE_Zeitreihen_Segment_Start'));

%% Regression,  Data-Mining,  Anwendung 
eval(gaitfindobj_callback('MI_Regression_Anwendung'));

