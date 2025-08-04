% read grayscale image
img = imread('mri.tif');

% original image
% img2 = img;

% shift gray values   (1a)
img2 = img+50;

% stretch contrast    (2b)
% img2 = img*1.75;

% take logarithm      (2f)
% conversion to double needed, because log() doesn't allow integers as input
% mat2gray() normalizes the values to range between 0.0 and 1.0, 
% so that im2uint8() can convert them back to uint8 for imhist()
% img2 = im2uint8(mat2gray(log(double(img+1))));

% equalize histogram  (2h)
% img2 = histeq(img);

% invert image        (3b)
% img2 = imcomplement(img);

% display image
figure('name','Image')
imshow(img2)

% display histogram
figure('name','Histogram')
imhist(img2)
% limit histogram to one standard deviation above the mean number of occurrences of each gray value
counts = imhist(img2);
ylim([0 mean(counts)+std(counts)])