clear; close all; clc;
addpath SegyMAT -begin
%------------------
% Definition of some parameters 
filed="su/2Dfm.su"; % Observed data
fileg="su/2Dricker.su"; % Modelled data

tracenorm=1;  % =1: Apply trace normalization 
SN=0.5;         % Noise added to observed data. 
NFmax=150.0;             % SN=signal to noise ratio
                   % NFMax= Max. frequency of noise
%----------------------------

%---------------------------
% read seismic data
[d,SuTraceHeaders1,SuHeader1]=ReadSu(filed);
[g,SuTraceHeaders2,SuHeader2]=ReadSu(fileg);

ns=SuHeader1.ns;
dt=SuHeader1.dt*10^-6;
t=linspace(dt, ns*dt, ns)';
num_trace=[SuTraceHeaders1.TraceNumber];
offset=[SuTraceHeaders1.offset]*10^-3;
ntr=length(num_trace);

%---------------------------
% trace normalization
if tracenorm
    for trace=1:ntr
        d(:,trace)=d(:,trace)/max(abs(d(:,trace)));
        g(:,trace)=g(:,trace)/max(abs(g(:,trace)));
    end
end

dmax=max(max(abs(d)));

% Add noise to observed data
if SN>0.0
    noise = SN*dmax*rand(ns,ntr);
    [B,A] = butter(4,NFmax/(1/(2*dt)));
    noise_filtered = filter(B,A,noise);
    noise_filtered=noise_filtered-mean(noise_filtered);
    ntap = 150;
    w = hamming(2*ntap)*0.5;
    noise_filtered(1:ntap,:) = noise_filtered(1:ntap,:).*w(1:ntap);
    %plot(noise_filtered);
    d = d+noise_filtered;
end


%---------------------------
% calculate known source signals for comparison
source_d = sourcesignal(t,40.0,0.0,'fm');
source_g = sourcesignal(t,40.0,0.0,'ricker');
[SOURCE_D,f] = fast_fourier_transform(source_d, dt, 1);
[SOURCE_G,f] = fast_fourier_transform(source_g, dt, 1);

%---------------------------
% calculate source wavelet correction filter
c = stfi(d,g);

%---------------------------
% apply source wavelet correction filter
SOURCE_G_NEW = c.*SOURCE_G;
source_g_new = inverse_fast_fourier_transform(SOURCE_G_NEW, dt, 1);

for n=1:ntr
    [G(:,n),f]=fast_fourier_transform(g(:,n), dt, 1);
    G_NEW(:,n)=c.*G(:,n);
    g_new(:,n)=inverse_fast_fourier_transform(G_NEW(:,n), dt, 1);
end

%---------------------------
% Plot results. Inverted source time function.
figure; plot(t,source_g,'k-',...
    t,source_d,'g-',...
    t,source_g_new,'r--',...
    'linewidth',2.0);
title('Source Time Function Inversion');
legend('modelled','observed','corrected','Location','NorthEast')

%legend('g(t)','d(t)','c*g');
TW=0.06;
xlim([0 TW])
xlabel('T(s)'); ylabel('Amplitude')
niceplot;

% %print('STFI-F4','-dpng')

%---------------------------
% Plot results. Seismograms.

figure; hold on
itr = 1:5:50; % plot only these traces, negative if all
% Wind data
if itr>0
    dw=d(:,itr);
    gw=g(:,itr);
    gw_new=g_new(:,itr);
    offsetw=offset(itr);
end

xcur=1.0;
xp=xcur*(offsetw(2)-offsetw(1));
for trace=1:length(offsetw)
    plot(t,dw(:,trace)*xp+offsetw(trace),'g-','linewidth',1.0)
    plot(t,gw(:,trace)*xp+offsetw(trace),'k-','linewidth',1.0)
    plot(t,gw_new(:,trace)*xp+offsetw(trace),'r--','linewidth',1.0)
end
legend('observed','modelled','corrected','Location','NorthWest')
hold off
axis xy
axis([ min(t) max(t) min(offsetw)-xp max(offsetw)+xp])
title('Source Time Function Inversion');
ylabel('offset (m)');
xlabel('time (s)');
niceplot;