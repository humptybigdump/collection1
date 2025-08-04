clear variables;
close all;
clc;

A=imread("Berg.jpg");
figure
subplot(2,3,1)
imshow(A);
title('Originalbild');
for j =1:5
    F = zeros(size(A));
    for i=1:3
        [U, S, V] = svd(double(A(:,:,i)));
        rk = rank(double(A(:,:,i)));
        for t = (j^3+3):rk
            S(t,t) = 0;
        end
        F(:,:,i) = U*S*V';
    end
    subplot(2,3,j+1)
    imshow(uint8(F));
    title(sprintf('Beste-Rang-%i-Approximation',j^3+2))
end

