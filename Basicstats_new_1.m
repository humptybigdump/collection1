% Creates histogram of articial data sets
%
% ------ 

bla=3; % seed of random number generator to be changed to create difference sequences in random numbers
randn('seed',bla);

N=200; % size of artificial data set N time steps

data1=randn(N,1)+20; % Data set one  
randn('seed',bla);
data2=5*randn(N,1)+20 % Data set two


% create figure with two plots of the histogramm 

figure;
subplot(2,1,1);
[h1 x]=hist((data1));
bar(x,h1/N,1);
xlabel(' Soil moisture VOL%','fontsize',16);
ylabel('h(-)','fontsize',16);
set(gca,'fontsize',16,'linewidth',2);
average=mean(data1);
stabw=std(data1);
title( [num2str(average),', ' num2str(stabw)],'fontsize',16);
%xlim([15 30]); % x-axis limits

 subplot(2,1,2);
[h2 x]=hist(data2);
bar(x,h2/N,1);
xlabel(' Soil moisture VOL%','fontsize',16);
ylabel('h(-)','fontsize',16);
set(gca,'fontsize',16,'linewidth',2);
%xlim([15 30]);
average=mean(data2);
stabw=std(data2);
title( [num2str(average),', ' num2str(stabw)],'fontsize',16);


bla=[data1 data2]; 
figure;
boxplot(bla,'notch','on');
set(gca,'fontsize',16,'linewidth',2);

