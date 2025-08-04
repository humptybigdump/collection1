%% Use Fourier transforms to find the frequency components of a signal buried in noise

% clear workspace and close figures
clc;
clear;
close all;

% Input data (Noisy signal, WAV-File in CD-quality 44,1 kHz, DVD-quality 48 kHz)  
[xn fs]     = audioread('Herrenhausen29.wav');      % sampled data/sample rate
dt = 1/fs;                                          % determine sample period (time step)

%% FFT
%
t = [1:1:length(xn)].*dt;               % time vector

t_min = 19;                             % min. time of "window"
t_max = 20;                             % max. time of "window"

% Change window-size and position in order to ckeck resonace frequeny!
xn = xn(t>t_min & t<t_max,:);           % apply window on input data

N = length(xn);                         % length of vector
f = [0:floor((N-1)/2)]/(N*dt);          % frequency vector
t = [1:1:N].*dt+t_min;                  % time vector of "window"

x = fft(xn);                            % applying FFt on sampled data
X = x/N;                                % normalization
F = cat(1,2*X(1:floor((N-1)/2)+1));     % limitation to < F_Max (floor = Abrunden)

fig1 = figure;

%% plot signal

ax(1) = subplot(2,1,1);
plot(t,xn);

%limits
ylim([-1 1]);

%title and lables
title({'a) signal'})
xlabel('time [s]')
ylabel('amplitude [-]')

%% plot FFT

ax(2) = subplot (2,1,2);

plot(f,abs(F));

%limits
xlim([0 200]);
ylim([0 .1]);

%ticks
xticks(0:50:200)
yticks(0:.02:.1)

%title and lables
title({'b) frequency spectrum'})
xlabel('f [Hz]')
ylabel('amplitude [-]')

