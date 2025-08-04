%% ########################################################################
% Decision making in structural engineering problems under polymorphic
% uncertainty - A benchmark proposal
% 
% Deterministic analysis of portal frame
% 
% Authors
%   Univ.-Prof. Dr.-Ing. Y. Petryna (yuriy.petryna@tu-berlin.de)
%   M.Sc. M. Drieschner (martin.drieschner@tu.berlin.de)
%   Technische Universität Berlin
%   Faculty VI Planning Building Environment
%   Department of Civil Engineering
%   Chair of Structural Mechanics
%   www.statik.tu-berlin.de
% 
% Implementation
%   August 2018 in MATLAB R2018b
% ________________________________________________________________________
% Developed within the
% 
%   Subproject 4: MuScaBlaDes
%   Multi-scale failure analysis with polymorphic uncertainties for optimal
%   design of rotor blades (MuScaBlaDes)
%   www.statik.tu-berlin.de/v_menue/forschung/muscablades/
% as part of the
%   DFG Priority Programme SPP 1886
%   Polymorphic uncertainty modelling for the numerical design of
%   structures
% ########################################################################

%% 0. Preparing workspace 
clear
close all
clc

%% 1. Define input parameters

% material properties (S355)
Emodul = 210e9;                     % Young's modulus [N/m^2]
sig_y = 275e6;                      % yield stress [N/m^2]

% geometry
L_frame = 10;                       % frame length [m]
H_frame = 8;                        % frame height [m]

% amount of elements
elem = 5;

% element cross-sections
b = 0.20;                           % width of columns and girder [m]
b = repmat(b,elem,1);

h_cL = 0.14;                        % height of left column [m]
h_g = 0.85;                         % height of girder [m]
h_cR = 0.14;                        % height of right column [m]
h=[repmat(h_cL,2,1);h_g;repmat(h_cR,2,1)];

% load magnitudes
F_V = 2700e3;                       % vertical load [N] (always downwards)
F_B = -0.001*F_V;                   % brake load [N] (to the left or right)
F_H = 10.1e3;                       % horizontal load [N] (always from left to right)

% load positions
L_V = 5;                            % position of L_V [m]
H_H = H_frame/2;                    % position of F_H [m]

%% 2. Solving

comment = 1;                        % comment for maximum stress location
                                    % =0 => no
                                    % ~=0 => yes
[g_mat, g_stab, V_4, V_8] = portalFrame_2018_08(Emodul,sig_y,L_frame,H_frame,elem,b,h,F_V,F_B,F_H,L_V,H_H,comment);
g_sys = min([g_mat,g_stab],[],2);

%% 3. Outputs

% 3.1 Decision making

% Material failure?
if g_mat<=0
    fprintf('%s\t\t\t\t\t\t\t%s%s\n','Material Failure:','g_mat = ',num2str(g_mat));
else
    fprintf('%s\t\t\t\t\t\t%s%s\n','No Material Failure:','g_mat = ',num2str(g_mat));
end

% Stability failure?
if g_stab<=0
    fprintf('%s\t\t\t\t\t\t\t%s%s\n','Stability Failure:','g_stab = ',num2str(g_stab));
else
    fprintf('%s\t\t\t\t\t\t%s%s\n','No Stability Failure:','g_stab = ',num2str(g_stab));
end

% System failure?
if g_sys<=0
    fprintf('%s\t%s\n','=>','System Failure');
    
    if g_mat<g_stab
        fprintf('\t%s\n','Material Failure occurs first');
    else
        fprintf('\t%s\n','Stability Failure occurs first');
    end
else
    fprintf('%s\t%s\n','=>','No System Failure');
end

% 3.2 Decision making by data assimilation
fprintf('\n%s\t\t\t\t\t\t%s%s%s\n','Vertical displacement:','V_4 = ',num2str(V_4),'m')
fprintf('%s\t\t\t\t\t%s%s%s\n','Horizontal displacement:','V_8 = ',num2str(V_8),'m')
fprintf('%s\t%s%s%s\n','Position of the vertical and brake load:','L_V = ',num2str(L_V),'m')
