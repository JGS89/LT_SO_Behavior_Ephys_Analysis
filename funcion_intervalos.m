function Celda_Intervalos = funcion_intervalos(pos_time_R)
%% funcion_intervalos.m
%--------------------------------------------------------------------------
% funcion_intervalos - Extrae intervalos de comportamiento del animal a lo 
% largo del Linear Track reescalado, a partir de datos previamente 
% procesados con la función 'LT_Reescalar.m'.
%
% Esta función recibe una matriz con las posiciones longitudinales (en mm)
% y los tiempos correspondientes, y devuelve una celda con distintos tipos 
% de intervalos relevantes para el análisis de comportamiento en prueba de
% exploración sobre LINEAR TRACK (780 mm), discriminación SOCIAL-OBJETO.
% El LT se encuentra segmentado en 9 bines de 87 mm cada uno. Los extremos
% El bin 1 conecta con el demostrador SOCIAL y el bin 9 con el OBJETO.
%
% INPUT:
%   pos_time_R = [ pos, time ]  - Matriz Nx2 con la posición reescalada
%   (mm) y el tiempo (seg) desde comienzo de tarea (registro)
%
% OUTPUT:
%   intervalos - Celda 6x1 con los siguientes elementos:
%       {1} Intervalos de corrida (todos los trayectos entre extremos)
%       {2} Intervalos de corrida hacia el bin 1 (lado social)
%       {3} Intervalos de corrida hacia el bin 9 (lado objeto)
%       {4} Intervalos de permanencia en bin 1 (zona social)
%       {5} Intervalos de permanencia en bin 9 (zona objeto)
%       {6} Intervalos de permanencia en la zona central (bines 4, 5 y 6)
%
% NOTAS:
%   - Requiere que la trayectoria haya sido previamente reescalada con 
%     'LT_Reescalar.m'.
%   - El Linear Track se asume dividido en 9 bines iguales a lo largo de 
%     sus 780 mm de longitud.
%   - Los intervalos se calculan según cambios de posición y umbrales de permanencia.
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD  
%   javiergs89@gmail.com  
%   Marzo 2022
%--------------------------------------------------------------------------
    
    largo_LT_mm = 780; % Largo del Linear Track en mm
    pos = pos_time_R(:,1); time = pos_time_R(:,2);
    Long_bin = largo_LT_mm/9; Limites_bines = [0:Long_bin:780];
    
    numero_desv = 1; %CRITERIO nro de desv que consideramos
    
    delta_x = diff(pos);
    delta_t = diff(time);
    vel = delta_x./delta_t;
    vel_abs = vel;
    vel_alisada = smooth(vel_abs, 20);
    media_vel = mean(vel_alisada);
    desvio_vel = std(vel_alisada);
    
    umbral = media_vel + numero_desv * desvio_vel;
    vel_supra_2right = find(vel_alisada > umbral);
    vel_supra_2left = find(vel_alisada < -umbral);
    vel_supra = {vel_supra_2left ; vel_supra_2right};
    
    trans_2right = find(diff(vel_supra_2right) > 1);
    trans_2left = find(diff(vel_supra_2left) > 1);
    transicion = {trans_2left ; trans_2right};
    
    int_2right = zeros(length(trans_2right), 2);
    int_2left = zeros(length(trans_2left), 2);
    Celda_Intervalos = cell(5,1);
    Celda_Intervalos{2,1} = int_2left; Celda_Intervalos{3,1} = int_2right;
    
    %% INTERVARLOS DE CORRIDA - Total / a Izq / a Der
    % NO SE CUENTA EL ULTIMO INTERVALO YA QUE EL ANIMAL CORRE PORQUE YO
    % APAGO LA CAMARA
    for n = 2:3
        int_vel_supra = Celda_Intervalos{n,1};
        vel_s = vel_supra{n-1,1};
        for i = 1:length(transicion{n-1})
            if i == 1
                int_vel_supra(i,1) = time(vel_s(1));
                int_vel_supra(i,2) = time(vel_s(transicion{n-1}(i)));
            else
                int_vel_supra(i,1) = time(vel_s(transicion{n-1}(i-1)+1));
                int_vel_supra(i,2) = time(vel_s(transicion{n-1}(i)));
            end
        end
       Celda_Intervalos{n,1} = int_vel_supra;
    end
    
    % Coloco los intervalos totales de corrida en la posicion 1 de la celda
    Celda_Intervalos{1,1} = sort([ Celda_Intervalos{2,1}; Celda_Intervalos{3,1} ]);
   
    %plot
    figure;
    plot(time,pos)
    hold on
    grid on
    axis tight
    plot(time(1:end-1,1),vel_abs)
    plot(time(1:end-1,1),vel_alisada)
    plot([min(time) max(time)],[umbral umbral])
    plot([min(time) max(time)],[-umbral -umbral])
    ylim([-250 800])
    plot([min(time) max(time)],[760 760]) %Limites en base al centro del animal
    plot([min(time) max(time)],[20 20])
    plot([min(time) max(time)],[(780-87) (780-87)]) % zona derecha
    plot([min(time) max(time)],[87 87]) % zona izquierda
    
    %% ARMA CELDA [x,t,idx] per BIN
    Pos_time_idx_bins = cell(length(Limites_bines) - 1, 3); % [ Pos Tiempo Idx ] por Bin
    X_t_rescal = pos_time_R;

    for i = 1:length(Pos_time_idx_bins) %% loop checked
        for w = 1:length(X_t_rescal)
            if Limites_bines(i) < X_t_rescal(w,1) && X_t_rescal(w,1) < Limites_bines(i+1)
                    Pos_time_idx_bins{i,3}=[Pos_time_idx_bins{i,3} w];% Indices
                    Pos_time_idx_bins{i,1}=[Pos_time_idx_bins{i,1} X_t_rescal(w,1)];% Posiciones
                    Pos_time_idx_bins{i,2}=[Pos_time_idx_bins{i,2} X_t_rescal(w,2)];% Tiempo
            end
        end
    end

    %% Calculo los intervalos por bin
    Inter_cell_all = cell(length(Pos_time_idx_bins),1);

    for w = 1:length(Inter_cell_all)
        diff_intervalos = diff(Pos_time_idx_bins{w,2});
        idx_diff_inter = find(diff_intervalos > min(diff_intervalos) + 0.1); % CRITERIO
        if isempty(idx_diff_inter)
            idx_diff_inter = 1;
        end
        zero_inter = zeros(length(idx_diff_inter)+1,2); % tiene q haber diff+1 intervalos
        for i = 1:length(zero_inter)%% resto min diff para incluir pixel de transicion entre bines
            if isempty(Pos_time_idx_bins{w,2})
                zero_inter(i,1) = 0; % Si no visita el bin es 0-0
                zero_inter(i,2) = 0;
            else
                if i==1
                    zero_inter(i,1)=Pos_time_idx_bins{w,2}(1,1)-min(diff_intervalos);
                    zero_inter(i,2)=Pos_time_idx_bins{w,2}(1,idx_diff_inter(i));
                elseif i==length(zero_inter)
                    zero_inter(i,1)=Pos_time_idx_bins{w,2}(1,idx_diff_inter(i-1)+1)-min(diff_intervalos);
                    zero_inter(i,2)=Pos_time_idx_bins{w,2}(1,end);
                else
                    zero_inter(i,1)=Pos_time_idx_bins{w,2}(1,idx_diff_inter(i-1)+1)-min(diff_intervalos);
                    zero_inter(i,2)=Pos_time_idx_bins{w,2}(1,idx_diff_inter(i));
                end

            end
        end
        Inter_cell_all{w,1} = zero_inter; % Contiene los intervalos por cada bin
        clear diff_intervalos
        clear idx_diff_inter
        clear zero_inter
    end
    % Intervalos en bin 1 (Social) >> en fila 4
    Celda_Intervalos{4,1} = Inter_cell_all{1,1};
    % Intervalos en bin 9 (Objeto) >> en fila 5
    Celda_Intervalos{5,1} = Inter_cell_all{9,1};
    % Intervalos en Centro - bin 4 al 6 >> en fila 6
    len4 = length(Inter_cell_all{4,1});
    len5 = length(Inter_cell_all{5,1});
    len6 = length(Inter_cell_all{6,1});
    lens = [ len4 len5 len6 ];
    idxdiff = find(lens~=max(lens));
    for n = 1:length(idxdiff)
        difflen = max(lens)-length(Inter_cell_all{3+idxdiff(n),1});
        for m = 1:difflen
            Inter_cell_all{3+idxdiff(n),1}(end+m,1:2) = [ 0 0 ];
        end
    end
    center_inter = [ Inter_cell_all{4,1}; Inter_cell_all{5,1}; Inter_cell_all{6,1} ];
    [~,idx] = sort(center_inter(:,1));
    sortcenter = center_inter(idx,:);
    Celda_Intervalos{6,1} = sortcenter(find(sortcenter(:,1) > 0),:);

end