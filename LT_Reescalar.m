function pos_time_R = LT_Reescalar(pos_x,pos_y,invertir)
%% LT_Reescalar.m
%--------------------------------------------------------------------------
% LT_Reescalar - Reescala posiciones bidimensionales obtenidas de
% Anymaze (en unidades arbitrarias, como píxeles) a milímetros para trayectorias 
% lineales (Linear Track).
%
% Esta función toma como entrada las coordenadas X y Y de la posición 
% animal a lo largo del tiempo, obtenidas del software Anymaze. Calcula 
% la proyección de la posición sobre el eje longitudinal del Linear Track 
% y reescala esta distancia al rango real (en mm), considerando un largo 
% total de 780 mm del entorno experimental.
%
% INPUTS:
%   posX     - Matriz Nx2 con las coordenadas X y el tiempo correspondiente: [X  tiempo]
%   posY     - Matriz Nx2 con las coordenadas Y y el tiempo correspondiente: [Y  tiempo]
%   invertir - Valor lógico (0 o 1). Si es 1, invierte la dirección del eje longitudinal.
%
% OUTPUT:
%   salida   - Matriz Nx2 con la posición reescalada en mm y el tiempo correspondiente: [posición_mm  tiempo]
%
% NOTAS:
%   - Asegúrese de que `posX` y `posY` tengan el mismo número de filas y estén sincronizados temporalmente.
%   - El reescalado se hace en base a la proyección sobre la trayectoria lineal más larga.
%   - Invertir = 1 se usa para cambiar la dirección del recorrido (útil para comparar sesiones).
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD
%   javiergs89@gmail.com
%   Marzo 2022
%--------------------------------------------------------------------------

largo_LT_mm = 780;
x = pos_x(find((pos_x(:,1)>1)));
x(1,:) = []; % Se elimina el primer punto por artefacto de tracking
Pos_x_time = pos_x(find((pos_x(:,1)>1)),2);
Pos_x_time(1,:) = [];
y = pos_y(find((pos_y(:,1)>1)));
y(1,:) = []; 
trsh_min = min(x)+30;
trsh_max = max(x)-30;
pos_bi = [ x , y ];
y_sup = [];
y_inf = [];
for i = 1:length(x)
    if pos_bi(i,1) < trsh_min
        y_inf = [ y_inf pos_bi(i,2)];
    elseif pos_bi(i,1) > trsh_max
        y_sup = [ y_sup pos_bi(i,2)];
    else
    end
end
y_means_ext = [ mean(y_inf) mean(y_sup) ];
x_means_ext = [ mean(x(find(x<trsh_min))) mean(x(find(x>trsh_max))) ];
recta = [ transpose(x_means_ext) transpose(y_means_ext) ];
m = ((recta(2,2)-recta(1,2))/(recta(2,1)-recta(1,1)));
b0 = -m*recta(2,1)+recta(2,2);
ang = atand((recta(2,2)-recta(1,2))/(recta(2,1)-recta(1,1))); %angulo
x_proy = x./cosd(ang);
x_modif = x_proy-min(x_proy);
radio_raton_mm = 20;
posR = radio_raton_mm+(x_modif.*(largo_LT_mm-(radio_raton_mm*2)))./max(x_modif);
posR = smooth(posR, 15); % AGREGADO para smoothear error de ANYMAZE
if invertir == 1 % invierte eje X en tareas sociales
    posR = abs(posR - 780);
end
timeR = Pos_x_time;
pos_time_R = [ posR timeR ];

end