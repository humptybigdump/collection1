function sol = DormandPrinceStepWidthControl(ode,tspan,IC,options)
  % Initialization
  sol = struct();
  h = options.h;
  p = options.p;
  sol.x = tspan(1);
  sol.y = zeros(length(IC),1);
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
   b  = [35/384      0           500/1113    125/192 -2187/6784  11/84 0];
   b2 = [5179/57600  0           7571/16695  393/640 -92097/339200  187/2100 1/40];

  % Time loop
  i1 = 1;
  hnew = h;
  sol.n_rej = 0;
  sol.n_acc = 0;
  while true
      h  = hnew;  


      % Calculating the steps for method A and B
      % Calculating the stages
      k  = zeros(length(b),length(IC));
      for i2=1:length(b)
        k(i2,:)  = ode(sol.x(i1)+c(i2)*h,sol.y(:,i1)+h*(a(i2,:)*k).').';
      end
      yA = sol.y(:,i1) + h*(b*k).';
      yB = sol.y(:,i1) + h*(b2*k).';

      % Calculating the error
      tau = norm(yA-yB)/norm(yA);

      % Calculate the new time step width:
      hnew = h*min(options.fmax,max(options.fmin,options.Sh*(options.tol/tau)^(1/(p+1))));

      if tau<options.tol
        sol.n_acc = sol.n_acc+1;
        sol.x(i1+1) = sol.x(i1)+h;
        sol.y(:,i1+1) = yA;
        i1 = i1+1;
        if sol.x(i1) > tspan(2)
          sol.y(:,i1) = interp1(sol.x,sol.y.',tspan(2)).';
          sol.x(i1) = tspan(2);
          break
        end
      else
        sol.n_rej = sol.n_rej+1;
      end
      


      
  end
end