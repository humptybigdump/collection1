%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Eingangsdaten laut Aufgabenstellung erstellen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%St�tzstellen aus der Aufgabe
u = [1 2 3 4 ];
z = [1 2 3 4 ];
[U, Z] = meshgrid(u, z); %%meshgrid erstellt aus den Vektoren u und z 
                         %%Matrizen, die f�r die weitere Verarbeitung
                         %%mit MATLAB internen Funktionen erorderlich sind

%Y = [3 4 7 8 7; 5 5 7 4 1; 4 2 1 0.5 0.1; 7 5 2 2 1; 4 5 6 7 8];
Y=[3,4,7,8;5,5,7,4;4,2,1,0;7,5,2,2]
%%Stellen an denen interpoliert werden soll
u_int = 1:0.01:4;
z_int = 1:0.01:4;
[U_int, Z_int] = meshgrid(u_int, z_int);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Interpolation mit verschiedenen Verfahren
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%interp2: MATLAB interne Funktion, "help interp2"

%%Nearest Neighbour Interpolation
Y_int_NN     = interp2(U, Z, Y, U_int, Z_int, 'nearest');
%%bilineare Interpolation
Y_int_linear = interp2(U, Z, Y, U_int, Z_int, 'linear');
%%kubische Splines
Y_int_cubic  = interp2(U, Z, Y, U_int, Z_int, 'spline');

%%globaler Polynom-Ansatz:
%%
%% F�r die Vandermonde-Matrix V_u
%%
%%    /                                       \
%%    | 1 u_0     u_0^2     ...  u_0^(N-1)    |
%%    | 1 u_1     u_1^2     ...  u_1^(N-1)    |
%%    |    :        :               :         |
%%    | 1 u_(N-1) u_(N-1)^2 ...  u_(N-1)^(N-1)|
%%    \                                       /,
%%
%% die Vandermonde-Matrix V_z
%%
%%    /                                       \
%%    | 1 z_0     z_0^2     ...  z_0^(N-1)    |
%%    | 1 z_1     z_1^2     ...  z_1^(N-1)    |
%%    |    :        :               :         |
%%    | 1 z_(N-1) z_(N-1)^2 ...  z_(N-1)^(N-1)|
%%    \                                       /,
%%
%% die Koeffizienten-Matrix A
%%
%%    /                                   \
%%    | a_(0,0)   a_(0,1) ... a_(0,N-1)   |
%%    | a_(1,0)   a_(1,1) ... a_(1,N-1)   |
%%    |    :         :           :        |
%%    | a_(N-1,0) a_(0,1) ... a_(N-1,N-1) |
%%    \                                   /
%%
%% und die Mess-Matrix Y
%%    /                                   \
%%    | Y_(0,0)   Y_(0,1) ... Y_(0,N-1)   |
%%    | Y_(1,0)   Y_(1,1) ... Y_(1,N-1)   |
%%    |    :         :           :        |
%%    | Y_(N-1,0) Y_(0,1) ... Y_(N-1,N-1) |
%%    \                                   /
%%
%% gilt der Zusammenhang:
%%
%% Y = V_u * A * V_z'
%%
%% => A = V_u^(-1) * Y * V_z^(-1)'

N = numel(u);
M = numel(z);
%Vandermonde-Matrizen erstellen
V_u = fliplr(vander(u));
V_z = fliplr(vander(z));
%Polynomkoeffizienten bestimmen
A = (V_u\Y)/(V_z');

%Interpolierte Werte bestimmen
N_int = numel(u_int);
M_int = numel(z_int);
Z_u_int = zeros(N_int, N-1);
for k=0:N-1
   Z_u_int(:,k+1) = ( u_int.^k )';
end
Z_v_int = zeros(M_int, M-1);
for k=0:M-1
   Z_v_int(:,k+1) = ( z_int.^k )';
end
Y_int_global = Z_u_int*A*Z_v_int';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Ausgabeplots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
scatter3(U(:), Z(:), Y(:)); %%surf: 3D Zeichenfunktion
xlabel('u');
ylabel('z');
daspect([1 1 4]);
title('Eingangsdaten');

figure
surf(u_int, z_int, Y_int_NN');
shading flat;
xlabel('u');
ylabel('z');
caxis([min(min(Y)), max(max(Y)) ]);
view(0, 90);
daspect([1 1 4]);
title('MATLAB nearest Neighbour Interpolation');

figure
surf(u_int, z_int, Y_int_linear');
shading flat;
xlabel('u');
ylabel('z');
caxis([min(min(Y)), max(max(Y)) ]);
view(0, 90);
daspect([1 1 4]);
title('MATLAB bilineare Interpolation');
% 
% figure
% surf(u_int, z_int, Y_int_cubic');
% shading flat;
% xlabel('u');
% ylabel('z');
% caxis([min(min(Y)), max(max(Y)) ]);
% view(0, 90);
% daspect([1 1 4]);
% title('MATLAB kubische Spline Interpolation');

figure
surf(u_int, z_int, Y_int_global');
shading flat;
xlabel('u');
ylabel('z');
caxis([min(min(Y)), max(max(Y)) ]);
view(0, 90);
daspect([1 1 4]);
title('Globale Polynom Interpolation');