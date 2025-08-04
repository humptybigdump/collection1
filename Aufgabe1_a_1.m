% read grayscale image file into 2D array containing gray value of each pixel
img = imread('line.tif');            

% compute 2D discrete Fourier transform of image using FFT-algorithm
img_fft = fft2(img);

% swap quadrants (1-3, 2-4) of FFT transform, so that zero-frequency component of spectrum is in the center
img_fft_shifted = fftshift(img_fft);      

% calculate absolute values of complex transform to get amplitude spectrum of image
img_fft_amplitude = abs(img_fft_shifted);

% display results
figure('name','Original Image'); % create new figure window
imshow(img)                      % display grayscale image
figure('name','Amplitude Spectrum of Image');
imshow(img_fft_amplitude,[])     % [] defines max and min of data as limits 
                                 % to be displayed as white and black