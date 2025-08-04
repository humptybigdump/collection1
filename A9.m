%%Kennlinie definieren
y = @(u)-1/32*u.^3+1/4*u.^2+5/8*u-2;

%%Messbereich festlegen
u_0 = 4; %Arbeitspunkt
d = 8; %Breite des Messbereiches
N=1000; %Anzahl Zwischenstellen
Deltau = linspace(-d/2, d/2, N); % help linspace
u = u_0 + Deltau;

%%y_1 = y(u0 + Deltau)
y_u0_pDu = @(Du)y(u_0+Du);

%%y_2 = y(u0 - Deltau)
y_u0_mDu = @(Du)y(u_0-Du);

%%Differenzkennlinie
y_D = @(Du)y_u0_pDu(Du) - y_u0_mDu(Du);


%%Zeichnen
LineWidth = 2;
FontSize = 16;
MarkerSize = 12;

plot(u, y_u0_pDu(Deltau), 'b', 'LineWidth', LineWidth);
hold on;
plot(u, -y_u0_mDu(Deltau), 'k', 'LineWidth', LineWidth);
plot(u, y_D(Deltau), 'r:', 'LineWidth', LineWidth);
plot(u_0, y(u_0), 'ob', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);
plot(u_0, y_D(0), 'or', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);
xlabel('u', 'FontSize', FontSize);
ylabel('y', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
legend('y(u_0+\Delta u)', '-y(u_0-\Delta u)', 'Differenzkennlinie y_D(u)', 'Location','northwest');