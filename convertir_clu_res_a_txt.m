%% convertir_clu_res_a_txt.m
%--------------------------------------------------------------------------
% convertir_clu_res_a_txt - Conversor de archivos .res y .clu (Neurosuite)
% a archivos de texto plano .txt con tiempos en segundos y etiquetas de cluster.
%
% FUNCIONALIDAD:
%   - Lee archivos `.res.X` y `.clu.X` generados por Neurosuite.
%   - Convierte las marcas temporales (`.res`) a segundos.
%   - Une las etiquetas de cluster (`.clu`) con los timestamps.
%   - Genera archivos `.txt` con dos columnas: 
%       [cluster_id  timestamp_segundos]
%
% FORMATO DE ENTRADA:
%   - `.res.X`: Timestamps de spikes (en muestras).
%   - `.clu.X`: Etiquetas de cluster (la primera línea = número total de clústers).
%   - Los archivos deben estar en el *Current Folder* de MATLAB.
%
% FORMATO DE SALIDA:
%   - Archivos `.txt` con nombre: `aammdd_clusters_X.txt` (uno por tetrodo).
%   - Cada archivo contiene: [cluster_id  timestamp_segundos]
%
% PARÁMETROS:
%   - `fs = 30000` (Hz): Frecuencia de muestreo del archivo `.res`.
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD  
%   javiergs89@gmail.com  
%   Marzo 2022
%--------------------------------------------------------------------------

clear; clc;

%% Parámetros
fs = 30000;  % Frecuencia de muestreo en Hz (ajustar si es necesario)
fm = 1 / fs; % Duración de una muestra en segundos

%% Ingresar nombre base de la sesión
fecha = input('>> Ingresar sesión (formato "aammdd"): ', 's');

%% Loop sobre los tetrodos (hasta 4)
for i = 1:4
    % Construcción de nombres de archivo
    archivo_res = [fecha, '.res.', num2str(i)];
    archivo_clu = [fecha, '.clu.', num2str(i)];

    % Abrir archivos
    file_t = fopen(archivo_res);
    file_c = fopen(archivo_clu);

    % Validación de existencia
    if file_t == -1 || file_c == -1
        warning(['No se encontraron archivos para tetrodo ', num2str(i)]);
        continue;
    end

    % Lectura de datos
    timestamps = fscanf(file_t, '%i');
    clust = fscanf(file_c, '%i'); % Primer línea es total de clusters

    fclose(file_t);
    fclose(file_c);

    % Conversión de tiempo a segundos
    timestamps = timestamps * fm;

    % Combinar etiquetas (ignorando primera línea de .clu)
    data = [clust(2:end), timestamps];

    % Guardar en archivo .txt
    output_filename = [fecha, '_clusters_', num2str(i), '.txt'];
    save(output_filename, 'data', '-ascii');

    fprintf('>>> Tetodo %d convertido y guardado como %s\n', i, output_filename);
end