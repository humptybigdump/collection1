function s = create_specieslist(str,elestr,thfil)
% function s = create_specieslist(str,elestr,thfil)
% create a specieslist object s, with thermodynamical data 
% calls import_thermo(thfil,s)
%  
% str   : a string that contains a whitespace-separated list of the names
%         of all considered species. 
% elestr: a string that contains a whitespace-separated list of the
%         names of all considered elements. Optional  
% thfil : name of a file of thermodynamical data (optional, default is
%         defined  in import_thermo). 
%         Use elestr='' as a placeholder if no elestr is specified.
% s     : a specieslist object  
% SAMPLE CALL: 
% function s = create_specieslist('CO2 O2 CO N2 CH4 H2O H2 CH2O','H C O N')
% 
% 
% R. Schie?l, ITT, Uni Karlsruhe 
% schiessl@itt.uni-karlsruhe.de 
% Last revision: 
% 19Dec07

str=upper(str);

% allow default elementlist 
if nargin < 2, elestr='H C O N'; end
if (nargin>=2 & isempty(elestr)),  elestr='H C O N'; end
elestr=upper(elestr);

% If no filename for Thermo-file is given, assume a default 
if nargin < 3,  
  thfil='THERMO.tot';
end

% a little list of atomic molar masses (g/mol)
[ael,am] = strread('H 1.00794 C 12.0107 O 15.9994 N 14.00674 AR 39.948 S 32.066 F 18.9984 Cl 35.453 HE 4.0026','%s %f');
am=am*1e-3; % now in kg/mol

s.names = strread(str,'%s');
s.nspe  = length(s.names);

if nargin < 2 | isempty(elestr), elestr='H C O N'; end
s.ele  = strread(elestr,'%s');
s.nele = length(s.ele);
s.eMM  = zeros(s.nele,1);

% try to find elements of elementlist in ael, assign molar mass 
for i=1:s.nele
  idx=strmatch(s.ele{i},ael,'exact');
	if(isempty(idx)),
		error(['UNKNOWN element "',s.ele{i},'" (this is not present in the ' ...
			'list of unknown elements!)']);
	end
	s.eMM(i)=am(idx);  % molar mass of i-th element from list
end

% import thermodynamical data from file 
s = import_thermo(thfil,s);
% element composition matrix 
s.mu = s.elenum.*repmat(s.eMM',s.nspe,1);
s.mu = s.mu; 
iii=find(s.MM==0);
if ~isempty(iii),
	for kkk=1:length(iii)
		warning(['Species "' s.names{iii(kkk)} '" has molar mass zero. This can cause problems! Check elementlist!']);
	end
end
s.mu = s.mu ./ repmat(s.MM,1,s.nele);  
