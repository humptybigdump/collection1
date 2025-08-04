
%Konstanten aus Aufgabenstellung
a = 1/2/pi * 1e-3;
b = 1/2/pi * 1e-5;
c = 2;
d = 1;

fs = 1e7;
f_0 = 1e5;


%G(s)
G_Za= [a, 1];
G_Ne = [b, 1];

G = tf(G_Za, G_Ne);
G_m1 = tf(G_Ne, G_Za);

G_sq = @(f)(1+a^2*(2*pi*f).^2)./(1+b^2*(2*pi*f).^2);
S_xx = @(f)d^2*ones(size(f)).*(f<=f_0);
S_nn = @(f)c^2*ones(size(f));

%H(f) = 1/G(f) * D(f)
f=logspace(log10(0.1), log10(fs), 1e3);

D_f = max(G_sq(f).*S_xx(f)./(S_xx(f).*G_sq(f)+S_nn(f)), 1e-4); %%max 1e-4 da sonst numerische Probleme auftreten
D = frd(D_f, f, 'FrequencyUnit','Hz');

H = series(G_m1, D);
Tot = series(G, H);

F_G = squeeze(bode(G, 2*pi*f)); %squeeze da Bode sonst ein [1x1xnumel(f)] array ausgibt
F_H = squeeze(bode(H, 2*pi*f));
F_Tot = squeeze(bode(Tot, 2*pi*f));

%%Exakte Bodeplots
LW = 3;
FS = 20;
%%Alternativ: Funktion bode() benutzen, LineWidth etc. aber nicht einfach
%%vorgebbar
fig = figure;
set(fig, 'Position', [1000, 400, 1000, 400]);
ax = gca;
plot(f, 20*log10(F_G),   'LineWidth', LW, 'Color', 'k', 'LineStyle', '-');
hold on;
plot(f, 20*log10(F_H),   'LineWidth', LW, 'Color', 'b', 'LineStyle', '--');
plot(f, 20*log10(F_Tot), 'LineWidth', LW, 'Color', 'r', 'LineStyle', '--');
set(ax, 'XScale', 'log');
ylim([-45, 45]);
xlim([1, fs]);
grid on;
xlabel('f / Hz', 'FontSize', FS);
ylabel('mag / dB', 'FontSize', FS);
leg = legend('|G(f)|', '|H(f)|', '|G(f)H(f)|', 'Location', 'Best');
set(leg, 'FontSize', 0.75*FS);
set(gca, 'FontSize', 0.66*FS);
set(fig,'PaperPositionMode','auto');
currentpath = pwd();
print(strcat(currentpath, '/wiener'), '-depsc', '-r300');
close(fig);


%%Geraden Approximation
fig = figure;
set(fig, 'Position', [1000, 400, 1000, 400]);
ax = gca;
plot([1, 1e3, 1e5, fs], [0, 0, 40, 40],   'LineWidth', LW, 'Color', 'k', 'LineStyle', '-');
hold on;
f_k = 1/0.4437*1e3;
A1 = -20*log10(5);
A2 = A1+20*log10(f_k)-20*log10(1e3);
A3 = A2+20*log10(f_k)-20*log10(1e5);
plot([1, 1e3, f_k, 1e5, 1e5, fs], [A1, A1, A2, A3, -100, -100],   'LineWidth', LW, 'Color', 'b', 'LineStyle', '--');
set(ax, 'XScale', 'log');
ylim([-45, 45]);
xlim([1, fs]);
grid on;
xlabel('f / Hz', 'FontSize', FS);
ylabel('mag / dB', 'FontSize', FS);
leg = legend('|G(f)|', '|H(f)|', 'Location', 'Best');
set(leg, 'FontSize', 0.75*FS);
set(gca, 'FontSize', 0.66*FS);
set(fig,'PaperPositionMode','auto');
print(strcat(currentpath, '/wienerApprox'), '-depsc', '-r300');
close(fig);