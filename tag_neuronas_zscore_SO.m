%% tag_neuronas_zscore_SO.m
%--------------------------------------------------------------------------
% tag_neuronas_zscore - Clasifica neuronas en función de su actividad 
% (Z-score) en los extremos del Linear Track (bin 1: lado social, 
% bin 9: lado objeto), previamente calculada.
%
% Este script permite al usuario ingresar vectores unidimensionales con 
% los valores Z-score para cada neurona en bin 1 y bin 9. A partir de esta 
% información, se genera una clasificación en 5 grupos según el grado de 
% codificación y discriminación espacial de las neuronas.
%
% INPUTS ESPERADOS:
%   z_bin1 - Vector fila o columna con los valores Z-score de cada neurona en bin 1 (lado social)
%   z_bin9 - Vector fila o columna con los valores Z-score de cada neurona en bin 9 (lado objeto)
%
%   (Ambos vectores deben tener igual longitud y representar las mismas neuronas)
%
% OUTPUT:
%   etiquetas - Vector con etiquetas numéricas (1 a 5) indicando el grupo asignado a cada neurona:
%       1: No codificante         ? Actividad baja en ambos extremos
%       2: No discriminante       ? Actividad similar en ambos extremos
%       3: Codificación OBJETO    ? Preferencia significativa hacia bin 9
%       4: Hyperdiscriminante     ? Diferencia extrema entre bin 1 y bin 9
%       5: Codificación SOCIAL    ? Preferencia significativa hacia bin 1
%
% CRITERIOS DE CLASIFICACIÓN:
%   - Se basan en umbrales de Z-score y diferencia absoluta entre Z_bin1 y Z_bin9.
%   - Los valores umbral específicos deben definirse según el criterio del analista
%     o basados en la distribución de los datos.
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD  
%   javiergs89@gmail.com  
%   Marzo 2022
%--------------------------------------------------------------------------

% Ejemplo de inicialización (el usuario debe pegar sus vectores aquí):
z_bin1 = []; % Z-score de neuronas en bin 1 (SOCIAL)
z_bin9 = []; % Z-score de neuronas en bin 9 (OBJETO)

%% CORRER EL CALCULO DE ETIQUETAS
lim = 1; % Umbral criterio Z score = {-1; +1} 
tags_todos = [];
for idx = 1:length(bin1_todos)
    Xi = z_bin1(idx); % bin 1
    Yi = z_bin9(idx); % bin 9

    if Xi < -lim

        if Yi > lim % cuadrante 1
            tags_todos = [ tags_todos; 4 ];
        elseif Yi < -lim % cuadrante 7
            tags_todos = [ tags_todos; 2 ];
        else % cuadrante 4
            tags_todos = [ tags_todos; 5 ];
        end

    elseif Xi > lim

        if Yi > lim % cuadrante 3
            tags_todos = [ tags_todos; 2 ];
        elseif Yi < -lim % cuadrante 9
            tags_todos = [ tags_todos; 4 ];
        else % cuadrante 6
            tags_todos = [ tags_todos; 5 ];
        end

    else % -lim < X < lim

        if Yi > lim % cuadrante 2
            tags_todos = [ tags_todos; 3 ];
        elseif Yi < -lim % cuadrante 8
            tags_todos = [ tags_todos; 3 ];
        else % cuadrante 5
            tags_todos = [ tags_todos; 1 ];
        end
    end
end