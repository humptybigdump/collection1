function [seis] = ana(s,t,c,offsets,dim)

dt=t(2)-t(1);
ns=length(t);
[S,f]=fast_fourier_transform(s, dt, 2);
w=2.0*pi*f; k=w/c;

seis=zeros(length(t),length(offsets));
switch lower(dim),
    case '2d'
        for n=1:length(offsets),
            R=offsets(n);
            ID=sqrt(2.0*pi./(k*R));
            %ID(ns/2+1)=(ID(ns/2+2)+ID(ns/2))/2.0;
            ID=ID.*exp(-i*k*R).*exp(-i*pi/4);
            %seis(:,n)=real(ifft(ifftshift(S.*ID)));
            seis(:,n)=real(inverse_fast_fourier_transform(S.*ID, dt, 2));

        end
    case '3d'
        for n=1:length(offsets),
            R=offsets(n);
            ID=1.0/R;
            ID=ID.*exp(-i*k*R);
            %seis(:,n)=real(ifft(ifftshift(S.*ID)));
            seis(:,n)=real(inverse_fast_fourier_transform(S.*ID, dt, 2));
        end

    otherwise
        disp('ana: Unknown Dimension.')
end

end