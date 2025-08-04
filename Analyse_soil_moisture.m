% Rountine to calculate linear regressions among soil moisture observations 
close all;
% read observations (40 TDR probes on 5 by 5 m extend)
data=dlmread('bodenfeuchte_c1neu.dat',';'); 
bla=1;
[m n]=size(data); 

% plot time series
figure;
plot(data(:,1),data(:,4:20));
xlabel(' Time [h]','fontsize',20);
ylabel('soil water content [-]','fontsize',20);
set(gca,'fontsize',20,'linewidth',2);


%calculate pair wise regressions
% select start and end data set
for i=4:4
    figure;
    ip=find(data(:,i) > 0 & data(:,i+1) > 0);
    subplot(2,1,1);
    h1=plot(data(ip,1),data(ip,i),'r-','linewidth',2);
    hold on;
    h2=plot(data(ip,1),data(ip,i+1),'b-','linewidth',2);
    legend([h1 h2], 'Sonde N', 'Sonde N+1')
    xlabel(' Time [h]','fontsize',20);
    ylabel('soil water content [-]','fontsize',20);
    set(gca,'fontsize',20,'linewidth',2);
    subplot(2,1,2);
    plot(data(ip,i),data(ip,i+1),'+');
    xlabel(['Probe' num2str(i-3) ' [-]'],'fontsize',20);
    ylabel(['Propbe ' num2str(i+1-3) ' [-]'],'fontsize',20);
    set(gca,'fontsize',20,'linewidth',2);
    korrel=corrcoef(data(ip,i),data(ip,i+1)); % correlation matrix using the build in function
    kovar=cov(data(ip,i),data(ip,i+1)); %covariance matrix using the build in function
    m=kovar(2,1)/kovar(1,1); % slope of Regression line
    b=mean(data(ip,i+1))-m*mean(data(ip,i)); % intercept with the ordinate
    y=m*data(ip,i)+b*ones(length(ip),1); % calculate regression/ trend 
    hold on;
    plot(data(ip,i),y,'r--','linewidth',2); % plot regressionsgrade
    para=sprintf('b= %4.3f m= %4.3f R^2 = %4.3f',b,m,korrel(1,2)^2);
    title(para,'fontsize',20');
end

% Calculate histogramm and boxplots
i=10;
figure;
boxplot(data(ip,i:i+4));

figure;
histogram(data(ip,i));

