% read grayscale image file into 2D array containing gray value of each pixel
img = imread('bar.tif');        % 2a
% img = imread('bar2.tif');       % 2b
% img = imread('bar45.tif');      % 2c
% img = imread('barsmooth.tif');  % 2d
% img = imread('circle.tif');     % 3a
% img = imread('circle2.tif');    % 3b
% img = imread('Sine8.tif');      % 4a
% img = imread('Sine10.tif');     % 4b
% img = imread('Sine20.tif');     % 4c
% img = imread('sampler.tif');    % 5a

% compute 2D discrete Fourier transform of image using FFT-algorithm
img_fft = fft2(img);

% swap quadrants (1-3, 2-4) of FFT transform, so that zero-frequency component of spectrum is in the center
img_fft_shifted = fftshift(img_fft);

% calculate absolute values of complex transform to get amplitude spectrum of image
img_fft_amplitude = abs(img_fft_shifted);

% take logarithm of amplitude spectrum for visualization
img_fft_amplitude_log = log(img_fft_amplitude+1);

% get sizes of image
sizeX = size(img,2);
sizeY = size(img,1);

% extract values of Amplitude Spectrum to plot Profile
% along horizontal line through origin
img_fft_profile = img_fft_amplitude_log(round(sizeY/2)+1,:);

% along line under +45 degree through origin
% img_fft_profile = img_fft_amplitude_log(1:sizeX+1:sizeX*sizeY);

% along line under -45 degree through origin
% img_fft_profile = img_fft_amplitude_log(sizeY:sizeY-1:(sizeX-1)*sizeY+1);

% display results
figure('name','Original Image'); % create new figure window
imshow(img)                      % display grayscale image
figure('name','Amplitude Spectrum of Image');
imshow(img_fft_amplitude_log,[]) % [] defines max and min of data as limits 
                                 % to be displayed as white and black
figure('name','Profile of Amplitude Spectrum');
plot(img_fft_profile)
xlim([0 numel(img_fft_profile)])