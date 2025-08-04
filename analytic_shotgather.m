% Create analytic shotgathers in 2D and 3D

close all; clear all;
addpath SegyMAT -begin

dt=0.0001;
t=(1:3000)*dt;    

fc=40.0;
c=1000.0;
tshift=0.0;
offsets=5:5:250; 

%Type='FM';
Type='Ricker';
dim='2D';
%dim='3D';

sufile="su/2Dricker.su";
%sufile="su/2Dfm.su";
% ------------------------

s=sourcesignal(t,fc,tshift,Type);
%plot(s);

Seis=ana(s,t,c,offsets,dim);

%imagesc(Seis);

wrtsu(sufile,Seis,dt,offsets);






