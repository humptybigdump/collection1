%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2D thermal plume computation                                            %
% Nelson Molina-Giraldo                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ---------------DEFINE ANALYTICAL SOLUTION------------------------------%
% Transient conditions:                                    
% T_ILS.m    : Infinite Line Source                                     (1)
% T_ICS.m    : Infinite Cylindrical Source                              (2)
% T_FLS.m    : Finite Line Source                                       (3)
% T_MILS.m   : Moving Infinite Line Source                              (4)
% T_MILSd.m  : Moving Infinite Line Source. Considering dispersion      (5)
% T_MILSc.m  : Moving Infinite Line Source. Mean temp around a circle   (6)
% T_MFLS.m   : Moving Finite Line Source                                (7)
% T_MFLSc.m  : Moving Finite Line Source. Mean temp around a circle     (8)

clear;clc
%% ------------------------ INPUT PARAMETERS -----------------------------% 
% Input the number of the analytical solution you want to evaluate
test = 1;
while any(test) % Test input
   prompt = {'ILS = 1, ICS = 2, FLS = 3, MILS = 4, MILSd = 5, MILSc = 6, MFLS = 7, MFLSc = 8; Analytical solution you want to evaluate:  '};
   dlg_title = 'Analytical solutions:';
   num_lines= 1;
   def     = {'9'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   fAS = str2num(geometrie{1}); fASTrue = isempty(fAS);
   test = fASTrue;
end

% Input Space discretization
test = 1;
while any(test) % Test input
   prompt = {'borehole length [m]','borehole radius (ICS,FCS) [m]'};
   dlg_title = 'Space discretization';
   num_lines= 1;
   def     = {'10','0.05'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   H   = str2num(geometrie{1}); HTrue = isempty(H);
   ro   = str2num(geometrie{2}); roTrue = isempty(ro);
   test = [roTrue; HTrue];
end

% Input Time discretization
test = 1;
while any(test) % Test input
   prompt = {'simulation time [days]:','number of timesteps]'};
   dlg_title = 'Time discretization';
   num_lines= 1;
   def     = {'100','100'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   tf = str2num(geometrie{1}); tfTrue = isempty(tf);
   Mt = str2num(geometrie{2}); MtTrue = isempty(Mt);
   test = [tfTrue; MtTrue];
end

% Input flow and heat tranpost parameters
test = 1;
while any(test) % Test numerical input
    prompt = {'Heat flux [W]','Vol. heat capacity of aquifer [J kg-3 K-1]','Vol. heat capacity of water [J m-3 K-1]',...
        'thermal conductivity of aquifer [W m-1 K-1]','longitudinal dispersivity [m]:','transversal dispersivity [m]:',...
        'Specific flux (Darcy flux) [m s-1]:'};
    dlg_title = 'Transportparameter';
    num_lines = 1;
    def     = {'500.0','2.8E6','4.2E6','2.5','0.0','0.0','1E-5'};
    transportparameter  = inputdlg(prompt,dlg_title,num_lines,def);
    fe = str2num(transportparameter{1}); feTrue = isempty(fe); 
    Cm = str2num(transportparameter{2}); CmTrue = isempty(Cm);
    Cw = str2num(transportparameter{3}); CwTrue = isempty(Cw);
    lm = str2num(transportparameter{4}); lmTrue = isempty(lm);
    ax = str2num(transportparameter{5}); axTrue = isempty(ax);
    ay = str2num(transportparameter{6}); ayTrue = isempty(ay);
    q = str2num(transportparameter{7}); qTrue = isempty(q);
    test = [feTrue; CmTrue; CwTrue; lmTrue; axTrue; ayTrue; qTrue];
end 

%% ------------------------CALCULATED PARAMETERS--------------------------%
% Heat flow rate per unit length of borehole 
QL  = fe/H;             % [W/m]

% Time discretization
ts = [0.1 tf];       % minimum and maximum simulation time [days]
t = logspace(log10(ts(1)*86400),log10(ts(2)*86400),Mt);   % [s]
% Space discretization
z = H/2;                % vertical coordinate [m]
x = ro; y = 0;          % borehole wall

% Heat transport velocity [m/s]
vT = q*Cw/Cm;
% Thermal diffusivity
Dt = lm/Cm;

%% --------------------------EXECUTION------------------------------------%
% Assign the analitical solution to the variable AS
AS = {'T_ILS';'T_ICS';'T_FLS';'T_FCS';'T_MILS';'T_MILSd';'T_MILSc';'T_MFLS';'T_MFLSc'};

for i = 1:length(t)        % Loop over vector of coordinates
    T(i) = eval([ AS{fAS} '(x,y,ro,z,H,lm,Cm,vT,t(i),QL,ax,ay)']);
end

%% -----------------------GRAPHICAL OUTPUT--------------------------------%
figure;
%plot(t/86400,T,'k');
semilogx(t/86400,T,'k');
xlabel('time (days)','FontSize',12);
ylabel('Temperature change (K)','FontSize',12);
set(gca,'LineWidth',1.0,'FontSize',12,'FontName','Arial')