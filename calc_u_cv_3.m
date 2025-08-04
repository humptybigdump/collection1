function [u,cv,s] = calc_u_cv(T,th,pi)
%********************************************************************************
% function [h,cp]=getcpH(T,th)
% Compute molar heat capacity at constant pressure cp [J/(mol*K)] 
% and molar enthalpy h [J/mol] of a specieslist at temperature T 
% NASA polynomial coefficients of thermodynamic data must be given as input 
% (stored in matrix th of size (nspe x 14)) 
%********************************************************************************
Rgas = 8.31447;  % molar gas constant [J/(mol*K)]
patm = 1.013e5;  % need pressure for calculation of entropy
if nargin <3, pi=patm*ones(size(th,1),1); end
%********************************************************************************
% Compute molar values of cp [J/(mol*K)] and H [J/mol]
% from NASA polynomial coefficients th
%********************************************************************************

[u,cv,s] = calc_h_cp(T,th,pi);
 
u = u - Rgas*T;
cv = cv - Rgas;