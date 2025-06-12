%% convertir_rhd_a_dat.m
%--------------------------------------------------------------------------
% convertir_rhd_a_dat - Conversor de archivos .rhd (Intan RHD2132) a .dat
% para uso con Neurosuite (NDManager, Neuroscope, Klusters).
%
% FUNCIONALIDAD:
%   - Lee todos los archivos .rhd de una carpeta (1 minuto cada uno).
%   - Extrae los datos del registro analógico.
%   - Convierte los datos a formato binario .dat (int16).
%   - Incluye canal TTL si está presente en el archivo original.
%
% FORMATO DE SALIDA:
%   - Archivos .dat con nombre modificado automáticamente
%     (usa sufijo numérico: 101.dat, 102.dat, etc.).
%
% REQUISITOS:
%   - Función `read_Intan_RHD2000_file.m` disponible en el path.
%   - Archivos .rhd deben estar en la misma carpeta.
%
% USO:
%   Ejecutar el script y seleccionar la carpeta que contiene los .rhd
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD  
%   javiergs89@gmail.com  
%   Marzo 2022
%--------------------------------------------------------------------------

clear; clc; close all;

%% Seleccionar carpeta con archivos .rhd
myPath = uigetdir('', 'Seleccionar carpeta con archivos .rhd a convertir');
if myPath == 0
    return; % Salir si se cancela
end
myPath = [myPath, filesep];

% Listar todos los archivos .rhd en la carpeta seleccionada
fileList = dir(fullfile(myPath, '*.rhd'));

%% Procesar cada archivo .rhd
for indA = 1:length(fileList)

    % Nombre del archivo actual
    filename = fileList(indA).name;

    % Crear nombre único para archivo .dat de salida (101.dat, 102.dat, ...)
    index_offset = 100 + indA;
    output_suffix = int2str(index_offset);
    datFileName = [filename(1:end-10), output_suffix, '.dat'];
    outputPath = fullfile(myPath, datFileName);

    % Leer datos del archivo .rhd
    read_Intan_RHD2000_file(filename, myPath);

    % Convertir datos a formato int16
    IData = int16(amplifier_data);

    % Reestructurar en una sola línea para guardar
    IDataReshaped = reshape(IData, 1, []);

    % Guardar archivo .dat
    fp = fopen(outputPath, 'w');
    fwrite(fp, IDataReshaped, 'int16');
    fclose(fp);

    % Limpiar variables temporales
    clear IData IDataReshaped amplifier_data;
end

disp('>>> Archivos .dat guardados correctamente en la carpeta seleccionada.');