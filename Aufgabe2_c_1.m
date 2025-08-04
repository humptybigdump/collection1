% read grayscale image 
% img = imread('noise0.tif');     % 4b
img = imread('ctlunge.jpg');    % 4d

% display original image 
imshow(img)

% display histogram
figure
imhist(img)
% limit histogram
counts = imhist(img);
ylim([0 mean(counts)+std(counts)/3])

% threshold image interactively using own function bwtresh()
figure
bwthresh(img);