%Xwerte erzeugen
l=-0.1:0.01:4.1;

%Ywerte erzeugen
V=-458.5417*l.^3+2166.3750*l.^2-1204.5833.*l;
hold on
plot(l,V,'LineWidth', 2, 'MarkerSize', 10)


%Stützstellen
lStutz=[0 2 3 4];
VStutz=[0 2588 3503 497];
plot(lStutz,VStutz, 'r+','LineWidth', 2, 'MarkerSize', 10)
xlabel( '$l/mm$','interpreter','latex', 'FontSize', 15)
ylabel('$V/mm^3$','interpreter','latex', 'FontSize', 15)