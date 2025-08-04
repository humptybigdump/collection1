function DHv=calc_hvap(spname,T)
% molar enthalpy of vaporization (J/(mol.K)) of substance SPNAME 
% at temperature T 
% SPNAME is a character string specifiying the name of a substance. 
% function will try to find this name in its internal database. 

switch upper(spname)
	case {'H2O','WATER'}
		Tb=373.12;    % boiling point at standard pressure / K
		Tc=647.096;   % critical point / K
		pc=22.064e6;  % critical pressure / Pa
	otherwise
		error('Unknown species: "%s"!',spname);
end

R=8.3145; % J/(mol.K)
Trb=Tb/Tc;
Tr=T/Tc;
DHVb=1.093 .* R .* Tc .* Trb .* (log(pc*1e-5)-1.013)./(0.93-Trb);
n = (0.00264*DHVb/(R*Tb)+0.8794).^10;
DHv = DHVb .* ((1-Tr)./(1-Trb)).^n;
