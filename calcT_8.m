function [Tn,niter,h,cp,s] = calcT(sp,hfix,xw,xorw,Tg,p)
% [Tn,niter,h,cp,s] = calcT(sp,hfix,xw,xorw,Tg,p)  
% compute temperature of a gas mixture for given enthalpy and 
% chemical composition
% 
% $ mod. 1oct07: handle mole numbers in xw and enthalpy H [in J] in hfix 
% $ mod. 25oct08: additional outputs: molar h,pc,s at last iteration step  
% R. Schieﬂl, ITT, Uni Karlsruhe 
% schiessl@itt.uni-karlsruhe.de 
% Last revision: 
% 19Dec07
if nargin < 4 | isempty(xorw), xorw = 'w'; end
if nargin < 5 | isempty(Tg), Tg = 800.0; end
if nargin < 6 | isempty(p), p = 1.013e5; end

if ~any(strcmpi(xorw,{'x','w','n'}))
	error(['Argument XORW must be one out of "x" "w" or "n", not "',xorw,'"!']);
end

if strcmpi(xorw,'x'),
  xw=x2w(xw,sp.MM);
	xorw='w';
end

if strcmpi(xorw,'n')
	n=xw(:);
	niter=1;
	while 1   % Newton iteration to get T
		[h,cp]=calc_h_cp(Tg,sp.thcf,p);
		H = n(:)'*h;
		CP= n(:)'*cp;
		corr =  (H-hfix)/CP;
		Tn = Tg - corr;
		if (abs(corr) < abs(Tn)*1e-14);
			if nargout>2		
				[h,cp,s]=calc_h_cp(Tg,sp.thcf,p); % for output
			end
			break;
		end
		Tg = Tn;
		niter = niter+1;
		if niter > 50,
			niter=-50;
			break
		%	error('Too many iterations needed!');
		end
	end
elseif strcmp(xorw,'w')
	%.... code for xorw=='w'
	niter=1;
	while 1   % Newton iteration to get T
		[h,cp]=calc_h_cp(Tg,sp.thcf,p);
		h=h./sp.MM;
		cp=cp./sp.MM;
		H = xw(:)'*h;
		CP= xw(:)'*cp;
		corr =  (H-hfix)/CP;
		Tn = Tg - corr;
		if abs(corr)<1e-8;break;end
		Tg = Tn;
		niter = niter+1;
		if niter > 50,
			niter=-50;
			break
			%error('too many iterations needed!');
		end
	end
end

if nargout>2		
	[h,cp,s]=calc_h_cp(Tg,sp.thcf,p); % for output
end



