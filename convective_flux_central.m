function [f]=convective_flux_central(a,phi,iface,nx);
%
%Use: [f]=convective_flux_central(a,phi,iface,nx);
%
% computes a central two-point approximation to the 
% flux "f=a*\phi" of a linear 1D advection problem,
% evaluated at a cell-face.
%
% input:
%
% a         - advection speed 
% phi(1:nx) - cell-averaged values of "phi" 
% iface     - index of the current cell-face
% nx        - dimension of the vector "phi"
%
% output:
%
% f         - the computed flux value 
%
ileft=iface-1;
iright=iface;
%"wrap-around" correction for periodicity:
if ileft<1
 ileft=nx; 
end
if iright>nx
 iright=1; 
end
%
f=a*(phi(ileft)+phi(iright))/2;
