%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Wir führen R-mal jeweils 6 "Messungen" einer normalverteilten Grund-
%% gesamtheit durch, und überprüfen jedesmal ob der Stichprobenmittelwert
%% um mehr als c*S_y^2/sqrt(N) vom wahren Mittelwert abweicht. Wir
%% untersuchen ausserdem, wie groß das Konfidenzintervall für die
%% statistische Sicherheit P ist.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R=1e4;  %Anzahl der Wiederholungen des Versuches
N = 6;  %Anzahl der Mesungen pro Versuch

mu = 4.5;       %Mittelwert der Zufallsvariable, siehe Aufgabe
sig = 20e-3;    %Standardabweichung der Zufallsvariable

c = 2;                      
P_pred = 2*tcdf(c, N-1)-1;    %Zu c gehöriger theoretischer Wert der 
                              %statistischen Sicherheit

P = 0.7;
c_pred = tinv((P+1)/2, N-1);  %Zu P gehörende theoretische Breite des
                              %Konfidenzintervalls

N_true = 0; %Zähler um zu protokollieren wie häufig der 
            %Stichprobenmittelwert im gewünschten Konfidenzintervall lag
P_emp = zeros(1,R); %empirisch ermittelte statistische Sicherheit (nach 
                    %jedem Durchlauf ein neuer Wert)
c_emp = zeros(1,R); %empirisch ermittelte Breite des Konfidenzintervalls
                    %(nach jedem Durchlauf ein neuer Wert)
t = zeros(1,R); %Speicher für die Abweichung des 
                %Stichprobenmittelwertes vom wahren Mittelwert,
                %normiert auf die Varianz des
                %Stichprobenmittelwertes (t-verteilt)

for k=1:R
    y = normrnd(mu, sig, [N, 1]); %%N Zufallszahlen aus der 
                                  %%Grundgesamtheit ziehen = N Messungen
                                  %%machen
    y_hat = mean(y); %Stichprobenmittelwert bestimmen
    S_y_2 = var(y);  %Stichprobenvarianz bestimmen
    
    t(k) = abs(y_hat-mu)/sqrt(S_y_2)*sqrt(N); %t bestimmen
    
    N_true = N_true + (t(k) <= c); %überprüfen ob t im Konfidenzintervall 
                                   %liegt
    P_emp(k) = N_true/k; %relative Häufigkeit

    %das P-te Quantil von t bestimmmen
    t_list = sort(t(1:k), 'ascend');
    ind = max( round(P*numel(t_list)), 1); %da Index 0 nicht zulässig
                                           %Maximumsbildung notwendig
    c_emp(k) = t_list(ind);
end

%%Ergebnisse zeichnen
LineWidth = 2;
FontSize = 18;

figure;
plot([1, R], [P_pred, P_pred], 'r:', 'LineWidth', LineWidth);
hold on;
plot(1:R, P_emp, 'b', 'LineWidth', LineWidth);
ylim([-0.1,1.1]);
set(gca, 'FontSize', FontSize);
xlabel('Stichprobenanzahl', 'FontSize', FontSize);
ylabel('P', 'FontSize', FontSize);
legend('theoretische Rate', 'empirische Rate');
title(strcat('c = ', num2str(c)), 'FontSize', FontSize);

figure;
plot([1, R], [c_pred, c_pred], 'r:', 'LineWidth', LineWidth);
hold on;
plot(1:R, c_emp, 'b', 'LineWidth', LineWidth);
ylim([-0.1,2*c_pred]);
set(gca, 'FontSize', FontSize);
xlabel('Stichprobenanzahl', 'FontSize', FontSize);
ylabel('c', 'FontSize', FontSize);
legend('theoretische Schranke', 'empirische Schranke');
title(strcat('P = ', num2str(P)), 'FontSize', FontSize);
