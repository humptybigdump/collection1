clear all; close all; clc;

% img = imread('prothese.bmp');
img = imread('ctlunge.jpg');

imshow(img);
title('Select Contour')
h = imfreehand;
pos = getPosition(h);
snakePoints = pos(1:2:end,:);
close
snake_demo(img,snakePoints)