%% Geometrische Modelle der Geodäsie
% Blatt 5 Aufgabe 5 - Bildkompression
% Ramon Butzer

clear variables;
close all;
clc;

%% Bild einladen
% Ein RGB-Bild besteht aus einer Matrix mit Zeilen und Spaltenanzahl gemäß
% der Bildauflösung für jeden Farbkanal.
% Bsp: Ein full-HD bild besteht aus drei Matrizen der Dimension 1080x1920
% Ein Grauwert-Bild besteht aus nur einer Matrix der geg. Dimension

pic = imread("berg.jpg");
pic_grey = rgb2gray(pic);       % Bild in Grauwerte umwandeln

tiledlayout(2,3);
nexttile;
imshow(pic);                   % Bild anzeigen Lassen
title('Original');

%% Singulärwertzerlegung durchführen
% Für jeden Farbkanal wird nun getrennt eine Singulärwertzerlegung
% durchgeführt. Diese erzeugt die Matrix S mit den größenmäßig geordneten
% Singulärwerten des Farbkanals.
% Dann wird eine Rang-R-Approximation durchgeführt, das heißt es werden 
% sämtliche Werte ab einem bestimmten Rang/Diagonaleintrag auf Null
% gesetzt. Somit enthält die Matrix weniger Daten und das Bild benötigt
% weniger Speicher, ist jedoch auch undeutlicher/unschärfer.
% Die Approximation kann leider nicht rückgängig gemacht werden, da die
% Informationen über die gestrichenen Singulärwerte verloren gehen (im
% approximierten Bild nicht gespeichert sind).


for i = 1:5				% Schleife über Anzahl der Bilder
    compressedPic = zeros(size(pic));	% Leeres Bild erstellen
    for j = 1:3				% Schleife über Farbkanäle
        [U,S,V] = svd(double(pic(:,:,j)));  % Singulärwertzerlegung
        rk = rank(S);			% Rang der Singulärwertmatrix
        for nullzellen = i^3+1:rk	% Schleife über Zellen, die Null werden
            S(nullzellen,nullzellen) = 0;
        end
        compressedPic(:,:,j) = U*S*V';	% Farbkanal mit neuer Singulärwertmatrix wieder erstellen
    end
    nexttile;
    imshow(uint8(compressedPic));	% Bild aus drei Farbkanälen wieder zusammensetzen und anzeigen
    title(sprintf('Beste Rang-%i-Approximation',i^3));
end
