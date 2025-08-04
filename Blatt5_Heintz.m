%% Matlab script zu Geometrische Modelle Übungsblatt 4 Matlab-Aufgabe

clear variables;
close all;
clc;

%% Original
% Bild einladen und kennzeichnende Größen feststellen
%width
n = 227;
%height 
m = 303;

A = imread('RangRApprox.jpg');
A = rgb2gray(A);
rk = gfrank(A, 227);
imshow(A)
title(['Original (',sprintf('Rank %d)',rank(double(A)))])

%% Rang 60
[U1,S1,V1] = svdsketch(double(A),1e-1,'MaxSubspaceDimension',60);
Alower1 = uint8(U1*S1*V1');
imshow(uint8(Alower1))
title(sprintf('Rank %d approximation',size(S1,1)))


%% Rang 40
[U2,S2,V2] = svdsketch(double(A),1e-1, 'MaxSubspaceDimension',40);
Alower2 = uint8(U2*S2*V2');
imshow(Alower2)
title(sprintf('Rank %d approximation',size(S2,1)))

%% Rang 25
[U3,S3,V3,apxErr] = svdsketch(double(A),1e-1,'MaxSubspaceDimension',25);
Alower3 = uint8(U3*S3*V3');
imshow(Alower3)
title(sprintf('Rank %d approximation',size(S3,1)))


%% Rang 10
[U4,S4,V4,apxErr2] = svdsketch(double(A),1e-1,'MaxSubspaceDimension',10);
Alower4 = uint8(U4*S4*V4');
imshow(Alower4)
title(sprintf('Rank %d approximation',size(S4,1)))

%% Rang 5
[U5,S5,V5,apxErr3] = svdsketch(double(A),1e-1,'MaxSubspaceDimension',5);
Alower5 = uint8(U5*S5*V5');
imshow(Alower5)
title(sprintf('Rank %d approximation',size(S5,1)))

%%
%Vergleich

tiledlayout(3,3,'TileSpacing','Compact')
nexttile
imshow(A)
title('Original Rank 227')
nexttile
imshow(Alower1)
title(sprintf('Rank %d approximation',size(S1,1)))
nexttile
imshow(Alower2)
title(sprintf('Rank %d approximation',size(S2,1)))
nexttile
imshow(Alower3)
title(sprintf('Rank %d approximation',size(S3,1)))
nexttile
imshow(Alower4)
title(sprintf('Rank %d approximation',size(S4,1)))
nexttile
imshow(Alower5)
title(sprintf('Rank %d approximation',size(S5,1)))