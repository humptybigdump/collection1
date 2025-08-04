%%Kennlinie definieren
y = @(u)0.4*u.^2 + 2;

%%Messbereich festlegen
u_a = 0;
u_e = 4;
N=1000;
u = linspace(u_a, u_e, N);

%%a) ideale Kennlinie berechnen
y_i_Fix = @(u)( y(u_e)-y(u_a) )/( u_e-u_a )*(u-u_a) + y(u_a);

%%d) Toleranzbandjustierung
y_i_Tol = @(u)y(u)+0.8;

%%b) F_r
F_Fix = @(u) (y(u)-y_i_Fix(u));
F_Tol = @(u) (y_i_Tol(u)-y_i_Fix(u));

%%Zeichnen
LineWidth = 2;
FontSize = 16;

plot(u, y(u), 'r', 'LineWidth', LineWidth);
hold on;
plot(u, y_i_Fix(u), 'k:', 'LineWidth', LineWidth);
plot(u, y_i_Tol(u), 'b:', 'LineWidth', LineWidth);
xlabel('u', 'FontSize', FontSize);
ylabel('y', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
legend('Kennlinie', 'Fixpunktjustierung', 'Toleranzbandjustierung', 'Location', 'Best');

figure;
plot(u, abs(F_Fix(u)), 'k', 'LineWidth', LineWidth);
hold on;
plot(u, abs(F_Tol(u)), 'b:', 'LineWidth', LineWidth);
xlabel('u', 'FontSize', FontSize);
ylabel('|F_A|', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
legend('Fixpunktjustierung', 'Toleranzbandjustierung');
title('Betrag des absoluten Kennlinienfehlers');

