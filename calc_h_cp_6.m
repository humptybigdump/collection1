function [h,cp,s] = calc_h_cp(T,th,pi)
%********************************************************************************
% function [h,cp]=getcpH(T,th)
% Compute molar heat capacity at constant pressure cp [J/(mol*K)] 
% and molar enthalpy h [J/mol] of a specieslist at temperature T 
% NASA polynomial coefficients of thermodynamic data must be given as input 
% (stored in matrix th of size (nspe x 14)) 
%********************************************************************************
Rgas = 8.31447;  % molar gas constant [J/(mol*K)]
patm = 1.013e5; % need pressure for calculation of entropy
if nargin <3, pi=patm*ones(size(th,1),1); end
%********************************************************************************
% Compute molar values of cp [J/(mol*K)] and H [J/mol]
% from NASA polynomial coefficients th
%********************************************************************************
% R. Schießl, ITT, Uni Karlsruhe 
% schiessl@itt.uni-karlsruhe.de 
% Last revision: 
% 19Dec07


%if isnan(T),
%	error('T is NaN!');
%end

% allow continuation for out-of-range values of T  
if T<200
	[h,cp,s]=calc_h_cp(200,th,pi);
	h = h + (T-200)*cp;
	s = s + cp/200 * (T-200);
	return
end

if T>5000
	[h,cp,s]=calc_h_cp(5000,th,pi);
	h = h + (T-5000)*cp;
	s = s + cp/5000 * (T-5000);
	return
end


if T>1000 
  %%% h
  tcf=[th(:,1) th(:,2)/2 th(:,3)/3 th(:,4)/4 th(:,5)/5]; 
  h=T*tcf(:,5);h=T*(h+tcf(:,4));h=T*(h+tcf(:,3));h=T*(h+tcf(:,2));
  h=T*(h+tcf(:,1));h=h+th(:,6);
  %%% cp
  if nargout>1,
    tcf=th(:,1:5);
    cp=T*tcf(:,5);cp=T*(cp+tcf(:,4));cp=T*(cp+tcf(:,3));
    cp=T*(cp+tcf(:,2));cp=cp+tcf(:,1);
  end
  %%% s
  if  nargout>2,
    tcf=[th(:,2) th(:,3)/2 th(:,4)/3 th(:,5)/4]; 
    s=T*tcf(:,4);s=T*(s+tcf(:,3));s=T*(s+tcf(:,2));s=T*(s+tcf(:,1));
    s=s+log(T)*th(:,1)+th(:,7);
  end
else
  %%% h
  tcf=[th(:,8) th(:,9)/2 th(:,10)/3 th(:,11)/4 th(:,12)/5]; 
  h=T*tcf(:,5);h=T*(h+tcf(:,4));h=T*(h+tcf(:,3));h=T*(h+tcf(:,2));
  h=T*(h+tcf(:,1));h=h+th(:,13);
  %%% cp
  if nargout>1,
    tcf=th(:,8:12);
    cp=T*tcf(:,5);cp=T*(cp+tcf(:,4));cp=T*(cp+tcf(:,3));
    cp=T*(cp+tcf(:,2));cp=cp+tcf(:,1);
  end
  %%% s
  if  nargout>2
    tcf=[th(:,9) th(:,10)/2 th(:,11)/3 th(:,12)/4]; 
    s=T*tcf(:,4);s=T*(s+tcf(:,3));s=T*(s+tcf(:,2));s=T*(s+tcf(:,1));
    s=s+log(T)*th(:,8)+th(:,14);
  end
end
h=h*Rgas;
if nargout>1,cp=cp*Rgas;end
if nargout>2,
	s=s*Rgas; % "temperature part" of entropy.
	%s=(s-log(max(pi/patm,1e-99)))*Rgas;
end

return

%old version
T1 = [1;T;T^2;T^3;T^4];
T2 = [1;T;T^2/2;T^3/3;T^4/4;T^5/5];
T3 = [1;log(T);T;T^2/2;T^3/3;T^4/4];
if T>1000
  cp = th(:,1:5)*T1*Rgas;
  h  = th(:,[6 1:5])*T2*Rgas;
  s  = th(:,[7 1:5])*T3*Rgas - Rgas*log(max(pi/patm,1e-12));  
else
  cp = th(:,8:12)*T1*Rgas;
  h  = th(:,[13 8:12])*T2*Rgas;
  s  = th(:,[14 8:12])*T3*Rgas - Rgas*log(max(pi/patm,1e-12));  
end
