% read grayscale image
img = imread('Sineplus.tif');

% convert unsigned integer into double-precision floating-point because filter kernel contains negative values and imfilter() uses doubles internally
img_double = double(img);

% define filter kernels
Dx = [1 0 -1]/2;
Dy = Dx';
Sx = [1 0 -1;2 0 -2;1 0 -1]/8;
Sy = Sx';

% set kernel to be used (Dx, -Dx, ...)
kernel = Dx;

% apply convolution filter to image
img2 = imfilter(img_double,kernel,'conv','replicate');

% display original image
figure
imshow(img)

% display filtered image
% whole range of values is displayed using []
figure
imshow(img2,[])