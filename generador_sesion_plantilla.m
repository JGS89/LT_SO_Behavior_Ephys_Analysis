%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMPLATE – GENERADOR DE PLANILLAS .mat PARA SESIONES EXPERIMENTALES   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Javier Gonzalez Sanabria (JGS) – 2024
% Objetivo: Generar archivos .mat organizados con información clave de 
% cada sesión experimental para análisis neurofisiológico.
%
% La planilla incluye:
% (1) Neuronas (vectores de timestamps)
% (2) Señales LFP del hipocampo ventral (matriz: [Voltaje Tiempo])
% (3) Intervalos de pruebas (matriz: [t_inicio t_final])
% (4) Tracking bidimensional de la sesión (X/Tiempo y Y/Tiempo)
%
% Archivos requeridos:
% - clustersOK.txt
% - TTLS.xlsx
% - Archivos .txt con señales LFP
% - Archivos .xlsx con tracking (obtenidos de ANYMAZE)
% - Script externo: Resample_Tracking_Open_MV.m (para el tracking)
%
% NOTA: Ejecutar por secciones según el tipo de datos disponible.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% === [1] CARGA DE NEURONAS – CLUSTERS BUENOS ===
% Define clusters buenos y su calidad, carga archivo txt y genera vectores de timestamps.

cluster_buenos = [ ];    % IDs de clusters válidos
calidad        = [ ];    % Calidad de cada unidad (1 = alta, 2 = inter, 3 = baja)

folder = uigetdir('', 'Seleccionar carpeta con archivos de clústeres');
[ nombre, ~ ] = uigetfile('*.txt', 'Seleccionar planilla clustersOK', folder);
fecha   = nombre(1:6);       % Extrae fecha del nombre del archivo
tetrodo = nombre(end-4);     % Extrae número de tetrodo

tabla        = readtable(nombre);
tabla_datos  = table2array(tabla);

for n = 1:length(cluster_buenos)
    clu = cluster_buenos(n);
    idx = tabla_datos(:,1) == clu;
    filt = tabla_datos(idx,:);
    
    if length(int2str(clu)) == 2
        name = ['nr_t', tetrodo, '_', int2str(clu), '_', int2str(calidad(n))];
    else
        name = ['nr_t', tetrodo, '_0', int2str(clu), '_', int2str(calidad(n))];
    end

    eval([ name ' = filt(:,2);' ]);
end

%% === [2] CARGA DE LFP – SEÑALES DEL HIPOCAMPO ===
% Lee archivos .txt de señales LFP ya convertidas. Devuelve matrices [Voltaje Tiempo].

path = uigetdir('', 'Seleccionar carpeta con LFP (.txt)');
archivos_txt = dir(fullfile(path, [fecha '_ch*.txt']));
celda_txt    = struct2cell(archivos_txt);

for i = 1:length(archivos_txt)
    file_ID = fopen(celda_txt{1,i}, 'r');
    file    = fscanf(file_ID, '%f');
    fclose(file_ID);
    
    timestamps = (0:0.0008:(length(file)-1)*0.0008)';
    varName    = ['LFP_HP', num2str(i)];
    complete   = [file timestamps];
    
    eval([varName ' = complete;']);
end

%% === [3] INTERVALOS DE PRUEBAS EXPERIMENTALES ===
% Lee TTLS.xlsx y genera variables tipo [inicio final] por prueba

file_var = readtable('TTLS.xlsx','Range','A1:D10');
[r, ~] = size(file_var);

for n = 1:r
    prueba = file_var.TTLS{n};
    if isempty(prueba)
        continue
    end

    if strcmp(prueba, 'HC')
        inicio = 60;
    else
        inicio = file_var.inicio(n);
    end
    final  = file_var.final(n);
    name   = ['Intervalos_', prueba, '_all'];
    eval([name ' = [inicio final];']);
end

%% === [4] TRACKING BIDIMENSIONAL – ANYMAZE (OPENMV) ===
% Procesa archivos .xlsx de tracking y genera matrices Pos_X y Pos_Y

files = dir('*Tracking*.xlsx');
for m = 1:length(files)
    file     = files(m).name;
    fecha    = file(7:12);
    protocolo = file(14:15);
    if protocolo(end) == '_'
        protocolo = protocolo(1:end-1);
    end

    file_xls  = xlsread(file);
    pos_x     = file_xls(2:end, 1);
    pos_y     = file_xls(2:end, 2);
    file_xls2 = xlsread(file, 2);
    tiempo    = file_xls2(3:end, 9);  % Columna I (9) = tiempo

    diff_tiempo = diff(tiempo);
    diff_mean   = mean(diff_tiempo);

    vect_tiempo_aux = (0:diff_mean:3300)';
    [~, closest_value] = min(abs(vect_tiempo_aux - tiempo(1)));

    tiempo_resample = vect_tiempo_aux(closest_value:(closest_value + length(tiempo) - 1));
    x_ori = timeseries(pos_x, tiempo);
    y_ori = timeseries(pos_y, tiempo);
    x_resample = resample(x_ori, tiempo_resample);
    y_resample = resample(y_ori, tiempo_resample);

    x_new = x_resample.data;
    y_new = y_resample.data;

    % Crea vectores completos para toda la duración del experimento
    vect_onesX = nan(size(vect_tiempo_aux));
    vect_onesY = nan(size(vect_tiempo_aux));
    vect_onesX(closest_value:closest_value+length(x_new)-1) = x_new;
    vect_onesY(closest_value:closest_value+length(y_new)-1) = y_new;

    % Llenado de extremos vacíos para evitar NaNs en bordes
    vect_onesX(1:closest_value-1) = x_new(1);
    vect_onesY(1:closest_value-1) = y_new(1);

    Pos_X = [vect_onesX vect_tiempo_aux];
    Pos_Y = [vect_onesY vect_tiempo_aux];

    % Guardado de variables
    name_x = ['Pos_X_', protocolo];
    name_y = ['Pos_Y_', protocolo];
    eval([name_x ' = Pos_X;']);
    eval([name_y ' = Pos_Y;']);

    save([fecha, '_posX_', protocolo, '.txt'], 'Pos_X', '-ascii');
    save([fecha, '_posY_', protocolo, '.txt'], 'Pos_Y', '-ascii');
    save([fecha, '_diff_mean_', protocolo, '.txt'], 'diff_mean', '-ascii');
end
% Finalizado...