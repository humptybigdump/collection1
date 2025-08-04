function sol = DormandPrince(ode,tspan,IC,options)
  % Initialization
  sol = struct();
  h = options.h;
  sol.x = tspan(1):h:tspan(2);
  sol.x(end) = tspan(2);
  sol.y = zeros(length(IC),length(sol.x));
  sol.y(:,1) = IC;

  % Butcher Tableau
  c = [0 1/5 3/10 4/5 8/9 1 1];
  a = [ 0           0           0           0        0          0     0;
        1/5         0           0           0        0          0     0;
        3/40        9/40        0           0        0          0     0;
        44/45      -56/15       32/9        0        0          0     0;
        19372/6561 -25360/2187  64448/6561 -212/729  0          0     0;
        9017/3168  -355/33      46732/5247  49/176  -5103/18656 0     0;
        35/384      0           500/1113    125/192 -2187/6784  11/84 0];
   %b = [35/384      0           500/1113    125/192 -2187/6784  11/84 0];
   b = [5179/57600  0           7571/16695  393/640 -92097/339200  187/2100 1/40];
  % Time loop
  for i1=1:(length(sol.x)-1)
      h=sol.x(i1+1)-sol.x(i1);
      % Calculating the stages
      k = zeros(length(b),length(IC));
      for i2=1:length(b)
        k(i2,:) = ode(sol.x(i1)+c(i2)*h,sol.y(:,i1)+h*(a(i2,:)*k).').';
      end
      % Calculating the next step
      sol.y(:,i1+1) = sol.y(:,i1) + h*(b*k).';
  end
end