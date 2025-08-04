function dirichlet_bvp(h)
%
% function sceleton for the implementation of Assignment 17.
%
% There are functions for the evalutation of u, du/dnu and Ku included
% below.
%
% The comments guide you through the necessary steps
%

% Some points, on which you can evaluate u in D
X = [0.45, 0.55; 0.3, 0.7; 0.6, 0.25];

% create geometry and mesh (use the parameter h)


% use the functions from Assignment 14 to obtain the right hand side of
% both the linear systems


% assemble the single layer operator and solve the linear systems


% assemble the single- and double layer potentials using the functions from
% Assignment 15 and evaluate in the domain.


% print the error between your numerical solution and the exact solution
% (given by the function u_func()).

end


function u = u_func(X, ~)

u = (X(:,1) - 0.4).^2 - (X(:, 2) + 0.3).^2;

end


function du_dn = du_dn_func(X, N)

du_dn = 2 * N(1) * (X(:, 1) - 0.4) - 2 * N(2) * (X(:, 2) + 0.3);

end


function Ku = Ku_func(X, ~)

% a quadrature for integrands with end point singularities from Kress' book
% 'Numerical Analysis'
n_quad = 12;
t1 = linspace(0, 2*pi, 2*n_quad+1);
t1 = t1(2:end-1);
p = 5;
t = t1.^p ./ (t1.^p + (2*pi - t1).^p);
w = pi/n_quad * 2*pi*p * t.^2 .* (2*pi - t1).^(p-1) ./ t1.^(p+1);

% helper vectors
ones_h = ones(size(t));
X1 = X(:, 1);
X2 = X(:, 2);
ones_v = ones(size(X1));

% line y_2 = 0
diff = X1 * ones_h - ones_v * t;
K1 = 1/(2*pi) * (-X2 * ones_h) ./ (diff.^2 + X2.^2 * ones_h);
phi1 = u_func([t.', zeros(size(t.'))]);
d1 = K1 * (w.' .* phi1);

% line y_1 = 1
diff1 = X1 * ones_h - 1;
diff2 = X2 * ones_h - ones_v * t;
K2 = 1/(2*pi) * diff1 ./ (diff1.^2 + diff2.^2);
phi2 = u_func([ones(size(t.')), t.']);
d2 = K2 * (w.' .* phi2);

% line y_2 = 1
diff1 = X1 * ones_h - ones_v * t;
diff2 = X2 * ones_h - 1;
K3 = 1/(2*pi) * diff2 ./ (diff1.^2 + diff2.^2);
phi3 = u_func([t.', ones(size(t.'))]);
d3 = K3 * (w.' .* phi3);

% line y_1 = 0
diff = X2 * ones_h - ones_v * t;
K4 = 1/(2*pi) * (-X1 * ones_h) ./ (X1.^2 * ones_h + diff.^2);
phi4 = u_func([zeros(size(t.')), t.']);
d4 = K4 * (w.' .* phi4);

Ku = d1 + d2 + d3 + d4;

end
