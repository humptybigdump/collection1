% read grayscale image
img = imread('ctselects&pnoise.tif');


% apply convolution filters

% 3x3 mean        (2b)
% kernel = ones(3)/3^2;
% img2 = imfilter(img,kernel,'conv','replicate');

% 5x5 Gauss       (2c)
% kernel = [1 1 2 1 1;1 2 4 2 1;2 4 8 4 2;1 2 4 2 1;1 1 2 1 1]/52;
% img2 = imfilter(img,kernel,'conv','replicate');


% apply order statistic filters
% ordfilt2(img,order,domain) replaces each pixel by the order'th element of it's neighbourhood defined by domain (here: 5x5 square)

% minimum filter  (2d)
% img2 = ordfilt2(img,1,true(5));

% maximum filter  (2e)
% img2 = ordfilt2(img,5^2,true(5));

% median filter   (2f)
% img2 = ordfilt2(img,round((5^2+1)/2),true(5));
img2 = medfilt2(img,[5 5]);


% display original image
figure
imshow(img)

% display filtered image
figure
imshow(img2)