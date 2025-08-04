%%Kennlinie definieren
y = @(u)2*u-1/10*u.^2+1/48*u.^3;

%%Möglicher Messbereich
u_a_g = 0;
u_e_g = 4;
N=1000;
u = linspace(u_a_g, u_e_g, N);
uextended= linspace(-10, +20, 10*N);

%%Ausgewählter Messbereich
u_a = 3/5;
u_e = u_a+2;
N=1000;

%%ideale Kennlinie bei FPJ über den möglichen Bereich
y_i_g = @(u)( y(u_e_g)-y(u_a_g) )/( u_e_g-u_a_g )*(u-u_a_g) + y(u_a_g);
S_i_g = ( y(u_e_g)-y(u_a_g) )/( u_e_g-u_a_g );

%%ideale Kennlinie bei FPJ für ausgewählten Bereich
y_i = @(u)( y(u_e)-y(u_a) )/( u_e-u_a )*(u-u_a) + y(u_a);
S_i = ( y(u_e)-y(u_a) )/( u_e-u_a );

%%relative Anzeigefehler
F_r_g = @(u) (y(u)-y_i_g(u))./(y_i_g(u)-y(u_a_g));
F_r   = @(u) (y(u)-y_i(u)  )./(y_i(u)  -y(u_a  ));

%%Zeichnen
LineWidth = 2;
FontSize = 16;


plot(uextended, y(uextended), 'r', 'LineWidth', LineWidth);
hold on;
plot(uextended, y_i_g(uextended), 'k:', 'LineWidth', LineWidth);
xlabel('u', 'FontSize', FontSize);
ylabel('y', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
legend('Kennlinie', 'Fixpunktjustierung für u_a=0, u_e=4', 'Location', 'Best');
 
figure
plot(u, y(u), 'r', 'LineWidth', LineWidth);
hold on;
plot(u, y_i_g(u), 'k:', 'LineWidth', LineWidth);
xlabel('u', 'FontSize', FontSize);
ylabel('y', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
legend('Kennlinie', 'Fixpunktjustierung für u_a=0, u_e=4', 'Location', 'Best');

figure;
plot(u, y(u), 'r', 'LineWidth', LineWidth);
hold on;
plot(u, y_i(u), 'b:', 'LineWidth', LineWidth);
xlabel('u', 'FontSize', FontSize);
ylabel('y', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
xlim([u_a, u_e]);
legend('Kennlinie', 'Fixpunktjustierung für u_a=3/5, u_e=13/5', 'Location', 'NorthWest');

figure;
plot(u, abs(F_r_g(u)), 'k', 'LineWidth', LineWidth);
xlabel('u', 'FontSize', FontSize);
ylabel('F_{r}', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
ylim([0, 0.04]);
title('Betrag des relativen Kennlinienfehlers bezogen auf ideale Anzeigespanne');

figure;
plot(u, abs(F_r(u)), 'b', 'LineWidth', LineWidth);
xlabel('u', 'FontSize', FontSize);
ylabel('F_{r}', 'FontSize', FontSize);
set(gca, 'FontSize', FontSize);
grid on;
xlim([u_a, u_e]);
ylim([0, 0.04]);
title('Betrag des relativen Kennlinienfehlers bezogen auf ideale Anzeigespanne');