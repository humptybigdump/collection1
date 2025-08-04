function geo = create_geometry(geometry_name, options)
%
% This function creates the geometric descriptions of domains that can be used in the Galerkin
% solver. Each domain has got a boundary that is the union of a finite number of closed polygonal
% chains. In the direction the polygonal chain is traversed, the outside of the domain lies to the
% right (mathematically positive orientation). The end points of each of the straight lines in the
% polygonal chains are referred to as corner points.
%
% The following geometries are supported:
%  'square':       [0, 1] x [0, 1]
%  'rectangle':    the rectangle [0, 2] x [0, 1]
%  'L_shape':      the polygon with the corners (0, 0), (-1, -1), (0, -2),  (2, 0), (0, 2), (-1, 1)
%  'figure_eight_: rectangle [0, 5] x [0, 3] without the squares [1, 2] x [1, 2] and [3, 4] x [1, 2]
%  'circle':       n-point point polygon inscribed in the circle of radius
%                  0.75 centred at the origin. The default value of  n is 50, but a
%                  different value may be specified in the field 'n' of the struct
%                  'options'.
%
% The function returns a struct "geo". This has got the following fields:
%
% geo.num_conrner_points  total number of corner points in all the polygonal chains.
%
%      geo.corner_points  array of dimension num_corner_points x 2 containing the X and Y
%                         coordinate of each corener point.
%
%         geo.num_chains  number of closed polygonal chains that form the boundary.
%
%             geo.chains  cell array of length geo.num_chains. Each entry is itself a vector
%                         containing the indeces of the corner points that are traversed. Each chain
%                         is closed. It is formed of straight line segments connecting the
%                         consecutive listed corner points plus one line connection the last point
%                         to the first.
%

% check that options is defined as a struct with the field 'n' (default
% value 50).
if (nargin < 2)
    options = struct('n', 50);
end
if (~ isfield(options, 'n'))
    options.n = 50;
end

% intialize geo
geo = struct('num_corner_points', 1, 'corner_points', 0, 'num_chains', 0, 'chains', 0);

switch geometry_name

    case 'square'
        geo.num_corner_points = 4;
        geo.corner_points = [0, 0; 1, 0; 1, 1; 0, 1];
        geo.num_chains = 1;
        geo.chains = {[1, 2, 3, 4]};

    case 'rectangle'
        geo.num_corner_points = 4;
        geo.corner_points = [0, 0; 2, 0; 2, 1; 0, 1];
        geo.num_chains = 1;
        geo.chains = {[1, 2, 3, 4]};

    case 'L_shape'
        geo.num_corner_points = 6;
        geo.corner_points = [0, 0; -1, -1; 0, -2; 2, 0; 0, 2; -1, 1];
        geo.num_chains = 1;
        geo.chains = {[1, 2, 3, 4, 5, 6]};

    case 'figure_eight'
        geo.num_corner_points = 12;
        geo.corner_points = [0, 0; 5, 0; 5, 3; 0, 3; 1, 1; 2, 1; 2, 2; 1, 2; 3, 1; 4, 1; 4, 2; 3, 2];
        geo.num_chains = 3;
        geo.chains = {[1, 2, 3, 4], [5, 8, 7, 6], [9, 12, 11, 10]};

    case 'circle'
        n = options.n;
        geo.num_corner_points = n;
        phi = linspace(-pi, pi, n+1);
        phi = phi(1:end-1);
        geo.corner_points = 0.75 * [cos(phi.'), sin(phi.')];
        geo.num_chains = 1;
        geo.chains = { 1:n };

    otherwise
        error('Unknown geometry type: %s\n', geometry_name);

end