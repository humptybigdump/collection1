function [SOL,xsol]=bisection(f,xa,xb,mniter)
% function [SOL,xsol]=bisection(f,xa,xb,mniter)
% bisection method for the solution of an equation f(x)=0
% f must be a function handle 
% xa,xb initial guesses that bracket the solution (xa<x<xb)
% mniter: max. number of iteration steps

if nargin < 4, 
  maxiter=50;
else
  maxiter=mniter;
end

q=f(xa)*f(xb);
%tolx=1e-18;

for iter=1:maxiter   % do no more than maxiter steps 
	if q>=0, error('initial guess not sensible (f(xa)*f(xb)>0)!'); end
	xm=.5*(xa+xb);
	fm=f(xm);
  SOL(iter,:)=[xa xm xb fm abs(xb-xa)];
	if fm*f(xb) < 0,
		xa=xm;
	else
		xb=xm;
	end
	%if abs(fm) < tolx, break; end
	%if abs(xb-xa) < tolx, break;end
end

if iter<maxiter,
	disp(sprintf('bisection: Solution bracketed within interval of width %e after %d steps!',...
		xb-xa,iter));
	xsol=.5*(xa+xb);
	fprintf(1,'Solution: %f\n',xsol);
else
	disp(sprintf('Solution could not be bracketed within the requested tolerance (%e) after %d steps!',...
		iter));
	xsol=[]
end

return

% simple example
f= @(x) cos(x)-x;
tolx=1e-4; maxiter=1000;

% thermodynamical example
% cp of air (J/(kg*K)) 
ustar = 1000;
f=@(x) calc_u_cv(x)-ustar;
xa=1; xb=5000;
tolx=1e-3; maxiter=100;

