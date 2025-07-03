% Ajustar tiempos a cero
Pos_LT(:,2) = Pos_LT(:,2) - Pos_LT(1,2);
Pos_S1(:,2) = Pos_S1(:,2) - Pos_S1(1,2);

% Parámetros comunes
fontsize = 14;
y_max = 780;
y_line = 86.6667;
gap = 20;  % espacio para que entren los textos fuera del rango útil
colors = {'b', 'r'}; % Azul para LT, Rojo para S1
ylim_range = [-gap, y_max + gap];  % nuevo límite Y con gap

figure;

% Subplot 1: Linear Track sin estímulos
subplot(1,2,1)
plot(Pos_LT(:,2), Pos_LT(:,1), 'Color', colors{1}, 'LineWidth', 1.5)
set(gca, 'FontSize', fontsize)
xlabel('Time (s)', 'FontSize', fontsize)
ylabel('LT Position (mm)', 'FontSize', fontsize)
axis([min(Pos_LT(:,2)) max(Pos_LT(:,2)) ylim_range])
hold on

% Líneas horizontales
plot([min(Pos_LT(:,2)) max(Pos_LT(:,2))], [y_line y_line], 'k--')
plot([min(Pos_LT(:,2)) max(Pos_LT(:,2))], [y_max - y_line y_max - y_line], 'k--')

% Textos fuera del rango de trayecto
text(mean([min(Pos_LT(:,2)) max(Pos_LT(:,2))]), -5, 'Social side', ...
    'HorizontalAlignment', 'center', 'FontSize', fontsize)
text(mean([min(Pos_LT(:,2)) max(Pos_LT(:,2))]), 785, 'Object side', ...
    'HorizontalAlignment', 'center', 'FontSize', fontsize)

title('Linear Track (No Stimulus)', 'FontSize', fontsize)

% Subplot 2: Linear Track con estímulos
subplot(1,2,2)
plot(Pos_S1(:,2), Pos_S1(:,1), 'Color', colors{2}, 'LineWidth', 1.5)
set(gca, 'FontSize', fontsize)
xlabel('Time (s)', 'FontSize', fontsize)
ylabel('LT Position (mm)', 'FontSize', fontsize)
axis([min(Pos_S1(:,2)) max(Pos_S1(:,2)) ylim_range])
hold on

% Líneas horizontales
plot([min(Pos_S1(:,2)) max(Pos_S1(:,2))], [y_line y_line], 'k--')
plot([min(Pos_S1(:,2)) max(Pos_S1(:,2))], [y_max - y_line y_max - y_line], 'k--')

% Textos fuera del rango de trayecto
text(mean([min(Pos_S1(:,2)) max(Pos_S1(:,2))]), -5, 'Social side', ...
    'HorizontalAlignment', 'center', 'FontSize', fontsize)
text(mean([min(Pos_S1(:,2)) max(Pos_S1(:,2))]), 785, 'Object side', ...
    'HorizontalAlignment', 'center', 'FontSize', fontsize)

title('Linear Track (Social vs Object)', 'FontSize', fontsize)