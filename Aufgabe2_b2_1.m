% read grayscale image
img = imread('mri.tif');

% display image and get handle h to image object
h = imshow(img);

% open Adjust Contrast tool for this image object
imcontrast(h)