R = double(imread('ctlungeproj.tif'));

% Rr = iradon(R(:,[1 2]),[0 0.5],'linear','Ram-Lak');
% for i=3:2:359
%     Rr = Rr + iradon(R(:,[i i+1]),[i/2-0.5 i/2],'linear','Ram-Lak');
%     imshow(Rr,[-80 220])
%     % imshow(Rr,[-8 179])
%     % imshow(Rr,[])
%     pause(0.02)
% end

% Rr = iradon(R(:,[1 2]),[0 0.5],'linear','None');
% for i=3:2:359
%     Rr = Rr + iradon(R(:,[i i+1]),[i/2-0.5 i/2],'linear','None');
%     imshow(Rr,[25 48936])
%     % imshow(Rr,[11634 48936])
%     % imshow(Rr,[])
%     pause(0.02)
% end

Rr = iradon([R(:,1) R(:,1)],[0 0],'linear','Ram-Lak')/2;
for i=2:10:360
    Rr = Rr + iradon([R(:,i) R(:,i)],[i i]/2-0.5,'linear','Ram-Lak')/2;
    % imshow(Rr,[-80 220])
    % imshow(Rr,[-8 179])
    imshow(Rr,[])
    pause(0.005)
end