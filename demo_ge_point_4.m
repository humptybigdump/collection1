%% Demo ge_point
% Example usage of the ge_point function.
%   X, Y, Z should be the same constructs as used by the ge_point function.  
% 'help ge_point' for more info.

t = 0:pi/50:10*pi;

output = ge_point(sin(t), cos(t), (t*1000000), ...
                    'LineWidth', 1.2, ...
                    'LineColor','ffffa432', ...
                    'Icon', 'http://maps.google.com/mapfiles/kml/pal4/icon25.png');

ge_output('demo_ge_point.kml', output );
