function Tn = calcTu(sp,ufix,xw,xorw,Tg,p)

if nargin < 4 | isempty(xorw), xorw = 'w'; end
if nargin < 5 | isempty(Tg), Tg = 800.0; end
if nargin < 6 | isempty(p), p = 1.013e5; end

if strcmpi(xorw,'x'),error('xorw=''x'' not yet supported');end
%.... code for xorw=='w' 
niter=1;
while niter<60
  [u,cv]=calc_u_cv(Tg,sp.thcf,p);
  u=u./sp.MM; cv=cv./sp.MM;
  U = xw(:)'*u;
  CV= xw(:)'*cv;
  corr =  (U-ufix)/CV;
  Tn = Tg - corr;
  if (abs(corr)<1e-6);break;end
  Tg = Tn;
  niter = niter+1;
end

%Tout = Tg;
