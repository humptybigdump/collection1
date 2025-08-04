function y = bdf2(odeFun, t, y0, varargin)
%
%  out = bdf2(odeFun,t,y0,varargin)
%    
%  Computes BDF2 approximations using Newton iteration
%
% Input arguments:
%
%   odeFun       - handle for y' = f(t,y)
%   t            - time array
%   y0           - initial value
%
% Extra input arguments: 
%
%   varargin{1}  - function handle to Jacobian of odeFun
%   varargin{2}  - relative error for Newton
%
% Output:
%
%   y             - vector with approximations
%
%

nsteps  = length(t);
hc = t(2) - t(1);
y1 = y0 + hc * odeFun(t(1),y0 + (hc/2)*odeFun(t(2),y0)); % find first value using Runge's method

y = zeros(2,nsteps);
y(:,1) = y0;
y(:,2) = y1;

I = eye(length(y0));

% get optional parameters
Jacobian = varargin{1};
tol = varargin{2};

for n = 2:nsteps-1
    hc = t(n+1)-t(n);
    
    K1 = y(:,n);
    K1old = Inf;

    while abs(K1-K1old)>tol
        K1old = K1;
        F  = K1 - (4/3)*y(:,n) + (1/3)*y(:,n-1) - (2*hc/3)*odeFun(1,K1);
        DF = I - (2*hc/3) * Jacobian(1,K1);        
        K1 = K1 - DF\F;
    end
    
    y(:,n+1) = K1;
end
