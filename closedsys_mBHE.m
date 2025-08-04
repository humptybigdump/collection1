function closedsys_mBHE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% 2D Thermal Plume Computation                                            %
% Multiple BHE and variable load                                          %
% Version July 2013           Nelson Molina-Giraldo Matrix Solutions Inc. %
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
   prompt = {'constant load (1) or variable load (2)'};
   dlg_title = 'Define Load:';
   num_lines= 1;
   def     = {'1'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   g1 = str2num(geometrie{1}); g1True = isempty(g1);
   test = [g1True];
end

if g1 == 1
    % Input the number of the analytical solution you want to evaluate
    test = 1;
    while any(test) % Test input
    prompt = {'ILS = 1, ICS = 2, FLS = 3, FLSs = 4, FCS = 5, FCSs = 6, MILS = 7, MILSs = 8, MILSd = 9, , MILSsd = 10, MFLS = 11, MFLSs = 12 ; Analytical solution to evaluate:  '};
    dlg_title = 'Analytical solutions:';
    num_lines= 1;
    def     = {'1'};
    geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
    fAS = str2num(geometrie{1}); fASTrue = isempty(fAS);
    test = [fASTrue];
    end
else
    test = 1;
    while any(test) % Test input
    prompt = {'Heat flux amplitud of each BHE [W/m]:','Period [days]'};
    dlg_title = 'Synthetic load profile for ILS';
    num_lines= 1;
    def     = {'[60 60 60 60 60 60 60 60 60]','365'};
    geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
    Jamp = str2num(geometrie{1}); JampTrue = isempty(Jamp);
    Pp = str2num(geometrie{2}); PpTrue = isempty(Pp);
    test = [JampTrue; PpTrue];
    fAS = 1;
    end
end 
% Input Space discretization
test = 1;
while any(test) % Test input
   prompt = {'minimum x-coordinate xmin [m]:','maximum x-coordinate xmax>xmin: [m]','minimum y-coordinate ymin [m]:',...
       'maximum y-coordinate ymax>ymin [m]:','number of space steps'};
   dlg_title = 'Space discretization';
   num_lines= 1;
   def     = {'-5','15','-5','15','50','10','0.05'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   xmin = str2num(geometrie{1}); xminTrue = isempty(xmin);
   xmax = str2num(geometrie{2}); xmaxTrue = isempty(xmax); xmaxTrue2=(xmax<=xmin);
   ymin = str2num(geometrie{3}); yminTrue = isempty(ymin);
   ymax = str2num(geometrie{4}); ymaxTrue = isempty(ymax); ymaxTrue2=(ymax<=ymin);
   Mx   = str2num(geometrie{5}); MxTrue = isempty(Mx);
   test = [xminTrue; xmaxTrue; yminTrue; ymaxTrue; MxTrue; xmaxTrue2; ymaxTrue2];
end

% Input BHE
test = 1;
while any(test) % Test input
   prompt = {'x-coordinate position of neighboring BHE [m]:','y-coordinate position of neighboring BHE [m]',...
             'borehole length [m]','borehole radius (ICS,FCS) [m]'};
   dlg_title = 'BHEs';
   num_lines= 1;
   def     = {'[0 0 0 5 5 5 10 10 10]','[0 5 10 0 5 10 0 5 10]','10','0.05'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   xbhe = str2num(geometrie{1}); xbheTrue = isempty(xmin);
   ybhe = str2num(geometrie{2}); ybheTrue = isempty(xmax); xmaxTrue2=(xmax<=xmin);
   H   = str2num(geometrie{3}); HTrue = isempty(H);
   ro   = str2num(geometrie{4}); roTrue = isempty(ro);
   test = [xbheTrue; ybheTrue; roTrue; HTrue];
end

% Input Time discretization
test = 1;
while any(test) % Test input
   prompt = {'simulation time [days]:','number of timesteps]'};
   dlg_title = 'Time discretization';
   num_lines= 1;
   def     = {'365*10.50','40'};
   geometrie  = inputdlg(prompt,dlg_title,num_lines,def);
   tf = str2num(geometrie{1}); tfTrue = isempty(tf);
   Mt = str2num(geometrie{2}); MtTrue = isempty(Mt);
   test = [tfTrue; MtTrue];
end

% Input flow and heat transport parameters
test = 1;
while any(test) % Test numerical input
    prompt = {'Heat flux [W]','Vol. heat capacity of aquifer [J kg-3 K-1]','Vol. heat capacity of water [J m-3 K-1]',...
        'thermal conductivity of aquifer [W m-1 K-1]','longitudinal dispersivity [m]:','transversal dispersivity [m]:',...
        'Specific flux (Darcy flux) [m s-1]:'};
    dlg_title = 'Transportparameter';
    num_lines = 1;
    def     = {'500.0','2.8E6','4.2E6','2.5','0.0','0.0','2.25E-6'};
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
t = linspace(ts(1)*86400,ts(2)*86400,Mt);   % [s]

% Space discretization
z = H/2;                % vertical coordinate [m]
xs = [xmin xmax];       % minimum and maximum x coordinate [m]
ys = [ymin ymax];       % minimum and maximum y coordinate [m]

% Heat transport velocity [m/s]
vT = q*Cw/Cm;

%% --------------------------EXECUTION------------------------------------%
% Assign the analitical solution to the variable AS
AS = {'T_ILS';'T_ICS';'T_FLS';'T_FLSs';'T_FCS';'T_FCSs';'T_MILS';'T_MILSs';'T_MILSd';'T_MILSsd';'T_MFLS';'T_MFLSs'};

%% ------------------------CALL SUBROUTINES-------------------------------%
Cal = {'Tf_mBHE_Qconst';'Tf_mBHE_Qvar'};

if g1 == 2      % Synthetic load profile
P = Pp*86400;              % Period
QL = seasonalinput(Jamp,P,ts,Mt,xbhe);
end

% Calling subroutines
eval([ Cal{g1} '(AS{fAS},fAS,ro,z,H,lm,Cm,vT,t,QL,ax,ay,xbhe,ybhe,xs,ys,Mx)']);


function Tf_mBHE_Qconst(Sol,fAS,ro,z,H,lm,Cm,vT,t,QL,ax,ay,xbhe,ybhe,xs,ys,Mx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature field                                                       %
% Multiple borehole                                                       %
% Constant load                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------EXCECUTION------------------------------------%
% Number of neighboring BHE  
nbhe = length(xbhe);

% Prellocationg cell array
x = zeros(nbhe,Mx); y = zeros(nbhe,Mx);
X = zeros(Mx,Mx,nbhe); Y = zeros(Mx,Mx,nbhe);
X_v = zeros(Mx*Mx,nbhe); Y_v = zeros(Mx*Mx,nbhe);
T = zeros(Mx*Mx,nbhe); Tr = zeros(Mx,Mx,nbhe); Tfinal = zeros(Mx,Mx);

% loop over BHE
for i = 1:nbhe 
fprintf('nbhe = %1.0f \n',i);  
% Create grid with coordinates system with respect to each BHE location
x(i,:) = linspace(xs(1)-xbhe(i),xs(2)-xbhe(i),Mx); 
y(i,:) = linspace(ys(1)-ybhe(i),ys(2)-ybhe(i),Mx); 
[X(:,:,i),Y(:,:,i)] = meshgrid(x(i,:),y(i,:));
% Vector of coordinates
X_v(:,i) = reshape(X(:,:,i),1,Mx*Mx);
Y_v(:,i) = reshape(Y(:,:,i),1,Mx*Mx);

% EVALUATE ANALYTICAL SOLUTION

if  fAS == 2 || fAS == 3 || fAS == 5 || fAS == 6 || fAS == 7 || fAS == 9 || fAS == 11
    for j = 1:length(X_v)        % Loop over vector of coordinates
    T(j,i) = eval([ Sol '(X_v(j,i),Y_v(j,i),ro,z,H,lm,Cm,vT,t(end),QL,ax,ay)']);
    end
else
T(:,i) = eval([ Sol '(X_v(:,i),Y_v(:,i),ro,z,H,lm,Cm,vT,t(end),QL,ax,ay)']);
end

% Reshape X,Y,Mt*nbhe
Tr(:,:,i) = reshape(T(:,i),Mx,Mx);

end

Tfinal(:,:) = sum(Tr(:,:,:),3)+10;

%Coordinate in x direction for the final figure [m]
x_fig = linspace(xs(1),xs(2),Mx);
y_fig = linspace(ys(1),ys(2),Mx);
[X_fig,Y_fig] = meshgrid(x_fig,y_fig);

% -----------------------GRAPHICAL OUTPUT--------------------------------%
figure

pcolor(x_fig,flipud(y_fig),Tfinal(:,:));
set(gca,'YDir','normal')
colorbar('FontSize',6);
xlabel ('x [m]','FontSize',16); ylabel ('y [m]','FontSize',16); shading interp;
set(gca,'LineWidth',1.5,'FontSize',16,'FontName','Arial')
daspect([1 1 1])

function Tf_mBHE_Qvar(Sol,fAS,ro,z,H,lm,Cm,vT,t,QL,ax,ay,xbhe,ybhe,xs,ys,Mx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature field                                                       %
% Multiple borehole                                                       %
% Variable load                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------EXCECUTION------------------------------------%

% Number of neighboring BHE  
nbhe = length(xbhe);

% Prellocationg cell array
x = zeros(nbhe,Mx); y = zeros(nbhe,Mx);
X = zeros(Mx,Mx,nbhe); Y = zeros(Mx,Mx,nbhe);
X_v = zeros(Mx*Mx,nbhe); Y_v = zeros(Mx*Mx,nbhe);
Tsum = zeros(Mx*Mx,length(t),nbhe);
T = zeros(Mx*Mx,length(t),nbhe);
Tini = zeros(Mx*Mx,nbhe);
Tfinal1 = zeros(Mx*Mx,length(t));

for i = 1:nbhe
fprintf('nbhe = %1.0f \n',i);  
% Create grid with coordinates system with respect to each BHE location
x(i,:) = linspace(xs(1)-xbhe(i),xs(2)-xbhe(i),Mx); 
y(i,:) = linspace(ys(1)-ybhe(i),ys(2)-ybhe(i),Mx); 
[X(:,:,i),Y(:,:,i)] = meshgrid(x(i,:),y(i,:));
% Vector of coordinates
X_v(:,i) = reshape(X(:,:,i),1,Mx*Mx);
Y_v(:,i) = reshape(Y(:,:,i),1,Mx*Mx);

%%%%%%CALL FUNCTION OF ANALYTICAL SOLUTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if  fAS == 2 || fAS == 3 || fAS == 5 || fAS == 6 || fAS == 7 || fAS == 9 || fAS == 11
    for l = 1:length(X_v)        % Loop over vector of coordinates
    Tini(l,i) = eval([ Sol '(X_v(l,i),Y_v(l,i),ro,z,H,lm,Cm,vT,t(end),QL(1,1),ax,ay)']);    
    end
else
Tini(:,i) = eval([ Sol '(X_v(:,i),Y_v(:,i),ro,z,H,lm,Cm,vT,t(end),QL(1,1),ax,ay)']);
end

T(:,1,i) = Tini(:,i);
Tsum(:,1,i) = Tini(:,i);

for j = 2:length(QL)
%fprintf('qL = %1.0f \n',j);
%%%%%%CALL FUNCTION OF ANALYTICAL SOLUTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if  fAS == 2 || fAS == 3 || fAS == 5 || fAS == 6 || fAS == 7 || fAS == 9 || fAS == 11
    for l = 1:length(X_v)        % Loop over vector of coordinates
    T(l,j,i) = eval([ Sol '(X_v(l,i),Y_v(l,i),ro,z,H,lm,Cm,vT,(t(end)-t(j-1)),QL(i,j)-QL(i,j-1),ax,ay)']);    
    end
else
T(:,j,i) = eval([ Sol '(X_v(:,i),Y_v(:,i),ro,z,H,lm,Cm,vT,(t(end)-t(j-1)),QL(i,j)-QL(i,j-1),ax,ay)']);
end

Tsum(:,j,i) = sum(T(:,:,i),2);
end
end

Tr = reshape(Tsum,Mx,Mx,length(t),nbhe);
Tfinal = sum(Tr,4)+10;

%Coordinate in x direction for the final figure [m]
x_fig = linspace(xs(1),xs(2),Mx);
y_fig = linspace(ys(1),ys(2),Mx);
%% -----------------------GRAPHICAL OUTPUT--------------------------------%
figure
pcolor(x_fig,flipud(y_fig),Tfinal(:,:,end))
caxis([0 20])
colorbar('ylim',[0 20],'FontSize',16);
xlabel ('x [m]','FontSize',16); ylabel ('y [m]','FontSize',16); shading interp;
set(gca,'LineWidth',1.5,'FontSize',16,'FontName','Arial')
daspect([1 1 1])

function Q = seasonalinput(Jamp,P,ts,Mt,xbhe)
% Number of neighboring BHE  
nbhe = length(xbhe);

% time discretization [hours]
t_h = linspace(ts(1)*86400,ts(end)*86400,Mt);
f=1/P;                  % Period and frequency
w = 2*pi*f;             % Angular frequency

% heat flow rate [W]
Q = zeros(nbhe,Mt);   % Initializing vector

for i = 1:nbhe
    for j = 1:length(t_h)
    Q(i,j) = Jamp(i)*cos(pi+w*t_h(j));
    end
end
