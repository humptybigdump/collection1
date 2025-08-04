% read grayscale image
img = imread('Sineplus.tif');
% img = imread('ctselect.tif');

% compute FFT
img_fft = fftshift(fft2(img));
img2_fft = img_fft;

% create logical matrix containing circle
% create grid to evaluate implicit function of the circle
[gridY,gridX] = meshgrid(1:size(img,1),1:1:size(img,2));
% calculate center coordinates of image
centerY = round((size(img,1)+1)/2);
centerX = round((size(img,2)+1)/2);
% matrix circle contains 1 (true), where inequality is fulfilled, 0 (false) elsewhere
circle = sqrt((gridX-centerX).^2+(gridY-centerY).^2)<=25;

% use logical indexing to set values of FFT inside circle to 0   (Highpass: b)
img2_fft(circle) = 0;

% invert circle matrix to set values of FFT outside circle to 0  (Lowpass: d)
% img2_fft(~circle) = 0;

% compute inverse FFT
img2 = ifft2(ifftshift(img2_fft));

% display original image and FFT (logarithmic amplitude)
figure('name','Original Image')
imshow(img)
figure('name','FFT of Original Image')
imshow(log(abs(img_fft)+1),[])

% display modified FFT and filtered Image
figure('name','Modified FFT')
imshow(log(abs(img2_fft)+1),[])
figure('name','Filtered Image')
% use range of gray values in img to maintain brightness & contrast
imshow(img2,[min(img(:)) max(img(:))])