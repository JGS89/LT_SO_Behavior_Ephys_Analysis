%% resample_tracking_anymaze.m
%--------------------------------------------------------------------------
% resample_tracking_anymaze - Reprocesa y resamplea los datos de tracking 
% obtenidos con ANYMAZE a partir de videos grabados con la cámara OpenMV M7.
%
% Esta rutina permite convertir archivos de tracking exportados en formato 
% Excel (.xlsx) desde ANYMAZE en un formato compatible para ser utilizado 
% en NeuroExplorer (.txt) o para generar nuevos archivos .m con estructura 
% organizada y resampleada.
%
% FUNCIONALIDAD:
%   - Carga archivos .xlsx generados por ANYMAZE con los datos de tracking.
%   - Permite realizar un resample temporal (ajustar frecuencia de muestreo).
%   - Exporta los resultados a formato .txt (para NeuroExplorer) o a nuevos 
%     archivos .mat/.m para análisis posterior en MATLAB.
%
% INPUT:
%   - Archivos .xlsx con tracking exportado desde ANYMAZE.
%
% OUTPUT:
%   - Archivo de texto (.txt) para importar en NeuroExplorer.
%   - Opcional: planillas .mat o scripts .m con las variables de tracking resampleadas.
%
% NOTAS:
%   - Asegurarse de que el archivo .xlsx tenga el formato estándar exportado por ANYMAZE.
%   - La tasa de resampleo puede ajustarse manualmente dentro del código según necesidad.
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD  
%   javiergs89@gmail.com  
%   Marzo 2022
%--------------------------------------------------------------------------
clc
clear all
close all

% Ubicar el directorio de la sesion donde se encuentran los .XLSX

[file, myPath] = uigetfile('','Seleccione archivos *.xlsx', '*.xlsx');

length_protocol = input('LT (2) o SO (3)? ');

fecha = num2str(file(7:12));
protocol = num2str(file(14:13+length_protocol));
file_xls = xlsread(file);
pos_x = file_xls([3:end],1);
pos_y = file_xls([3:end],2);
file_xls2 = xlsread(file,2);
% 9 = I
tiempo = file_xls2(1:end,8);
for i = 1:(length(tiempo)-1)
    diff_tiempo(i,1) = tiempo(i+1,1)-tiempo(i,1);
end
diff_mean = mean(diff_tiempo');
%creo un vector "auxiliar" de tiempo de intervalos diff_mean
vect_tiempo_aux = [0:diff_mean:3300];
vect_tiempo_aux = vect_tiempo_aux';
[n,m]=size(vect_tiempo_aux);
vect_onesX = ones(n,1);
vect_onesY = ones(n,1);
%Te busca en el vect tiempo auxiliar el valor mas cerca al t0 del tiempo
[diff_value,closest_value] = min(abs(vect_tiempo_aux-tiempo(1,1))); 
%coloco el closest_value del vector aux en el 1,1 del tiempo resample
tiempo_resample = vect_tiempo_aux(closest_value,1);
for i = 2:(length(tiempo))
    tiempo_resample(i,1) = tiempo_resample(i-1,1)+diff_mean;
end
x_ori = timeseries(pos_x,tiempo);
y_ori = timeseries(pos_y,tiempo);
x_resample = resample(x_ori,tiempo_resample);
y_resample = resample(y_ori,tiempo_resample);
x_new = x_resample.data;
y_new = y_resample.data;
x_new(end,1)=x_new(end-1,1);
y_new(end,1)=y_new(end-1,1);
[o,p]=size(x_new);
vect_onesX(closest_value:(closest_value+o-1))=x_new(:);
vect_onesY(closest_value:(closest_value+o-1))=y_new(:);
vect_onesX(closest_value,1)=vect_onesX(closest_value+1,1);
vect_onesY(closest_value,1)=vect_onesX(closest_value+1,1);

Pos_X = [ vect_onesX vect_tiempo_aux ];
Pos_Y = [ vect_onesY vect_tiempo_aux ];

save([fecha,'_posX_',protocol,'.txt'],'Pos_X','-ascii');
save([fecha,'_posY_',protocol,'.txt'],'Pos_Y','-ascii');
save([fecha,'_diff_mean_',protocol,'.txt'],'diff_mean','-ascii');
