%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% 2D Thermal Plume Computation                                            %
%                                                                         %
% Version July 2013           Nelson Molina-Giraldo. Matrix Solutions Inc.%
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ---------------DEFINE ANALYTICAL SOLUTION------------------------------%
% Transient conditions:                                    
% T_ILS.m    : Infinite Line Source                                     (1)
% T_ICS.m    : Infinite Cylindrical Source                              (2)
% T_FLS.m    : Finite Line Source                                       (3)
% T_FLSs.m   : Finite Line Source. Steady state                         (4)
% T_FCS.m    : Finite Cylindrical Source                                (5)
% T_FCSs.m   : Finite Cylindrical Source. Steady state                  (6)
% T_MILS.m   : Moving Infinite Line Source                              (7)
% T_MILSs.m  : Moving Infinite Line Source. Steady state                (8)
% T_MILSd.m  : Moving Infinite Line Source. Considering dispersion      (9)
% T_MILSsd.m : Moving Infinite Line Source. Considering dispersion     (10)
% T_MFLS.m   : Moving Finite Line Source                               (11)
% T_MFLSs.m  : Moving Finite Line Source. Steady state                 (12)

clear;clc
%% ------------------------ INPUT PARAMETERS -----------------------------% 
% Input the number of the analytical solution you want to evaluate
test = 1;
while any(test) % Test input
   prompt = {'ILS = 1, ICS = 2, FLS = 3, FLSs = 4, FCS = 5, FCSs = 6, MILS = 7, MILSs = 8, MILSd = 9, , MILSsd = 10, MFLS = 11, MFLSs = 12 ; Analytical solution to evaluate:  '};
   dlg_title = 'Analytical solutions:';
   num_lines= 1;
   def     = {'7'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   fAS = str2num(geometrie{1}); fASTrue = isempty(fAS);
   test = fASTrue;
end

% Input Space discretization
test = 1;
while any(test) % Test input
   prompt = {'minimum x-coordinate xmin [m]:','maximum x-coordinate xmax>xmin: [m]','minimum y-coordinate ymin [m]:',...
       'maximum y-coordinate ymax>ymin [m]:','number of space steps', 'borehole length [m]','borehole radius (ICS,FCS) [m]'};
   dlg_title = 'Space discretization';
   num_lines= 1;
   def     = {'-2','15','-5','5','50','10','0.05'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   xmin = str2num(geometrie{1}); xminTrue = isempty(xmin);
   xmax = str2num(geometrie{2}); xmaxTrue = isempty(xmax); xmaxTrue2=(xmax<=xmin);
   ymin = str2num(geometrie{3}); yminTrue = isempty(ymin);
   ymax = str2num(geometrie{4}); ymaxTrue = isempty(ymax); ymaxTrue2=(ymax<=ymin);
   Mx   = str2num(geometrie{5}); MxTrue = isempty(Mx);
   H   = str2num(geometrie{6}); HTrue = isempty(H);
   ro   = str2num(geometrie{7}); roTrue = isempty(ro);
   test = [xminTrue; xmaxTrue; yminTrue; ymaxTrue; MxTrue; roTrue; xmaxTrue2; ymaxTrue2];
end

% Input Time discretization
test = 1;
while any(test) % Test input
   prompt = {'simulation time [days]:'};
   dlg_title = 'Simulation time';
   num_lines= 1;
   def     = {'100'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   tf = str2num(geometrie{1}); tfTrue = isempty(tf);
   test = [tfTrue];
end

% Input flow and heat tranpost parameters
test = 1;
while any(test) % Test numerical input
    prompt = {'Heat flux [W]','Vol. heat capacity of aquifer [J kg-3 K-1]','Vol. heat capacity of water [J m-3 K-1]',...
        'thermal conductivity of aquifer [W m-1 K-1]','longitudinal dispersivity [m]:','transversal dispersivity [m]:',...
        'Specific flux (Darcy flux) [m s-1]:'};
    dlg_title = 'Transport Parameters';
    num_lines = 1;
    def     = {'500.0','2.8E6','4.2E6','2.5','0.0','0.0','1.0E-6'};
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

% Simulation time
t = tf*86400;  % [s]

% Space discretization
z = H/2;                % vertical coordinate [m]
xs = [xmin xmax];       % minimum and maximum x coordinate [m]
ys = [ymin ymax];       % minimum and maximum y coordinate [m]

% Heat transport velocity [m/s]
vT = q*Cw/Cm;
% Thermal diffusivity
Dt = lm/Cm;

%% --------------------------EXECUTION------------------------------------%
% Assign the analitical solution to the variable AS
AS = {'T_ILS';'T_ICS';'T_FLS';'T_FLSs';'T_FCS';'T_FCSs';'T_MILS';'T_MILSs';'T_MILSd';'T_MILSsd';'T_MFLS';'T_MFLSs'};

% Meshgrid
x = linspace(xs(1),xs(2),Mx);    % x coordinate [m]
y = linspace(ys(1),ys(2),Mx);    % y coordinate [m]
[X Y] = meshgrid(x,y);
fprintf('Start simulation \n');
if  fAS == 2 || fAS == 3 || fAS == 5 || fAS == 6 || fAS == 7 || fAS == 9 || fAS == 11
    Xv = X(:); Yv = Y(:);       % Vector of coordinates   
    T = zeros(1,length(Xv));    % Initializing vector
    for i = 1:length(Xv)        % Loop over vector of coordinates
    T(i) = eval([ AS{fAS} '(Xv(i),Yv(i),ro,z,H,lm,Cm,vT,t,QL,ax,ay)']);
    end
    T = reshape(T,length(X),length(Y));  
else
    T = eval([ AS{fAS} '(X,Y,ro,z,H,lm,Cm,vT,t,QL,ax,ay)']);
end
fprintf('End simulation \n');

%% -----------------------GRAPHICAL OUTPUT--------------------------------%
figure(1);
tmin = min(min(T));
tmin = floor(tmin);
tmax = max(max(T));
dt=floor(tmax)/10;
line = tmin:dt:tmax;
[C,d] = contourf(X,Y,T,line,'k');
colormap (jet);
strlabel = 'yes';
sc = strcmp(strlabel,'yes');
if sc==1; clabel(C,d,'LabelSpacing',200,'FontSize',10); end;
axis equal xy;
axis auto;
axis([xs(1) xs(2) ys(1) ys(2)]);
xlabel ('x [m]','FontSize',12); ylabel ('y [m]','FontSize',12);
set(gca,'LineWidth',1.0,'FontSize',12,'FontName','Arial')
colorbar
daspect([1 1 1])
grid on;

figure(2)
pcolor(X,Y,T); colorbar
xlabel ('x [m]','FontSize',12); ylabel ('y [m]','FontSize',12); shading interp;
set(gca,'LineWidth',1.0,'FontSize',12,'FontName','Arial')
daspect([1 1 1])