function dy = brusselator(t,y)
  dy = [1+y(1)^2*y(2)-4*y(1);
        3*y(1)-y(1)^2*y(2)];
end