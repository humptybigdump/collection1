function sol = AdamsBashforthMoulton(ode,tspan,IC,options)
  % Initialization
  sol = struct();
  h = options.h;
  sol.x = tspan(1):h:tspan(2);
  sol.x(end) = tspan(2);
  sol.y = zeros(length(IC),length(sol.x));
  sol.y(:,1) = IC;

  % Adams Bashforth Coefficients up to order 8: 
  gamma  = [1 1/2 5/12 3/8 251/720 95/288 19087/60480 5257/17280 1070017/3628800];
  
  % Adams Moulton Coefficients up to order 8: 
  gammaT = [1 -1/2 -1/12 -1/24 -19/720 -3/160 -863/60480 -257/24192 -33953/3628800];

  % First Step: Euler Explicit
  sol.y(:,2) = sol.y(:,1) + h*ode(sol.x(1),sol.y(:,1));

  % Time loop
  dFim1         = zeros(length(sol.y(:,1)),options.p);
  dFim1(:,1)    = ode(sol.x(1),sol.y(:,1));
  for i1=2:(length(sol.x)-1)
      h=sol.x(i1+1)-sol.x(i1);

      % Calculate the Adams Bashforth differences:
        q = min(i1,options.p);
        dFi           = zeros(length(sol.y(:,1)),options.p);
        dFi(:,1)      = ode(sol.x(i1),sol.y(:,i1));
      for i2=2:q
          dFi(:,i2) = dFi(:,i2-1)-dFim1(:,i2-1);
      end
      % Calculate the predictor step with Adams Bashforth
      yp = sol.y(:,i1) + h*dFi(:,1:q)*gamma(1:q).';
      
      % Calculate the Adams Moulton differences:
      dFip1         = zeros(length(sol.y(:,1)),options.p);
      dFip1(:,1)    = ode(sol.x(i1+1),yp);
      for i2=2:q
          dFip1(:,i2) = dFip1(:,i2-1)-dFi(:,i2-1);
      end
      % Calculate the corrected step with Adams Moulton
      sol.y(:,i1+1) = sol.y(:,i1) + h*dFip1(:,1:q)*gammaT(1:q).';

      % Actualize the differences
      dFim1 = dFi;     
  end
end