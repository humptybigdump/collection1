% read grayscale image
img = imread('ctselectwgnoise.tif');

% create kernel for mean filter
kernel = ones(3)/3^2;   % 3x3      (1b)
% kernel = ones(5)/5^2;   % 5x5      (1c)
% kernel = ones(9)/9^2;   % 9x9      (1d)

% create kernel for gaussian filter  (1e)
% kernel = [1 1 2 1 1;1 2 4 2 1;2 4 8 4 2;1 2 4 2 1;1 1 2 1 1]/52;
% kernel = fspecial('gaussian', 5, 1.03);

% apply filter kernel using convolution
% border pixels are replicated to extend image
img2 = imfilter(img,kernel,'conv','replicate');

% display original image
figure
imshow(img)

% display filtered image
figure
imshow(img2)