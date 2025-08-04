% read grayscale image
img = imread('Sineplus.tif');

% convert unsigned integer into double-precision floating-point because filter kernel contains negative values and imfilter() uses doubles internally
img_double = double(img);

% define filter kernels
L1 = [1 1 1;1 -8 1;1 1 1];
L2 = [0 1 0;1 -4 1;0 1 0];
Sx = [1 0 -1;2 0 -2;1 0 -1]/8;
Sy = Sx';

% apply L1                                (3a)
img2 = imfilter(img_double,L1,'conv','replicate');

% apply L2                                (3b)
% img2 = imfilter(img_double,L2,'conv','replicate');

% apply Sobel in both directions: Sx, Sy  (3c)
% to find all edges
% img2x = imfilter(img_double,Sx,'conv','replicate');
% img2y = imfilter(img_double,Sy,'conv','replicate');
% img2 = sqrt(img2x.^2+img2y.^2);

% alternative (sobel followed by tresholding):
% img2 = edge(img_double,'sobel',3.5);

% display original image
figure
imshow(img)

% display filtered image
% whole range of values is displayed using []
figure
imshow(img2,[])