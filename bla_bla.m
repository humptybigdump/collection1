% comparison of random numbers

N=200000;
data1=1*rand(N,1) + 19.5;
data2=1*randn(N,1)+20;

figure;
subplot(2,1,1);
histogram(data1);
mean(data1)
std(data1)
subplot(2,1,2);
histogram(data2);
mean(data2)
std(data2)
