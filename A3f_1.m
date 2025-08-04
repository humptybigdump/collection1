%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aufgabe 3 f) Vergleich von Newton- und Spline-Interpolation
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Eingangsdaten
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%aus Aufgabenstellung
u = [1; 2; 3; 4];
y = [12; 10; 15; 12];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[a, a_N, d, d_tilde] = NewtonInterp(u, y); %%siehe NewtonInterp.m
%a : Koeffizienten vor Polynome um 0


[A, A_S, y_tt] = SplineInterp(u, y); %%siehe SplineInterp.m
%A : Koeffizienten vor Polynome um 0

%keyboard; %%Ausgabe anschauen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Anzeige / Vergleich
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
hold on;  % Dafür sorgen dass alte plots nicht gelöscht werden

LineWidth = 3;
MarkerSize = 15;
FontSize = 20;

u_plot = (1:0.01:4)';

%%Stützstellen
plot(u, y, 'xr', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);

%%Newton-Interpolation
plot(u_plot, EvaluatePolynom(u_plot, a), 'b:', 'LineWidth', LineWidth);

%%Splines
for k=1:size(A,1)%jeden Spline einzeln zeichnen
    %%Die Werte von u_plot nehmen, die in den Definitionsbereich des i-ten
    %%Splines fallen
    u_i = u_plot( u_plot >= u(k) & u_plot <= u(k+1) );
    
    %Die Koeffizienten des i-ten Splines nehmen
    a_i = A(k,:)'; %%Die Koeffizienten des k-ten Splines stehen in der 
                   %%k-ten Zeile von A 
    %Zeichnen
    plot(u_i, EvaluatePolynom(u_i, a_i), 'k:', 'LineWidth', LineWidth);
end

xlabel('u', 'FontSize', FontSize);
ylabel('y', 'FontSize', FontSize);
legend('Stützstellen', 'Newton', 'Splines');
title('Vergleich Newton-/Lagrange-Interpolation mit Spline-Interpolation', 'FontSize', FontSize);
set(gca, 'FontSize', 0.75*FontSize);