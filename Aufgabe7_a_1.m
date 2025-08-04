% R = imread('ctlungeproj.tif');
R = imread('ctlungeprojnoise.tif');
theta = 0:0.5:179.5;
Rr = iradon(R,theta,'linear','Ram-Lak');
Rr1 = iradon(R,theta,'linear','Shepp-Logan');
Rr2 = iradon(R,theta,'linear','Hamming');
imshow(Rr,[])
figure
imshow(Rr1,[])
figure
imshow(Rr2,[])