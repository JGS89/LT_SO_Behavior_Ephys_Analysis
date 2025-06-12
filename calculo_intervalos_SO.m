%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULO DE INTERVALOS POR TAREA PARA SESIONES TIPO "SOCIAL-OBJETO" (SO)
% Autor: Javier Gonzalez Sanabria (JGS) � 2024
%
% Este script calcula intervalos de inter�s usando la funci�n externa 
% "funcion_intervalos.m" para las tareas:
%   (1) LT � Linear Track sin est�mulos
%   (2) S1 � Primera exposici�n a social y objeto
%   (3) S2 � Reexposici�n a social y objeto (invertido)
%
% Requiere:
% - Archivo de sesi�n *.mat con variables Pos_X_<tarea>, Pos_Y_<tarea>
% - Variable combinada Pos_<tarea> = [X Y]
% - Funci�n auxiliar: "funcion_intervalos.m"
%
% Salida:
% - Celda por tarea con 6 tipos de intervalos (ver "tags")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% === INICIALIZACI�N ===
clear; close all; clc;

% Selecci�n del archivo de sesi�n (.mat)
[file, folder] = uigetfile('C:\Users\JGS\Desktop\JGS', 'Seleccionar sesi�n *.mat', '*.mat');
load([folder, file]);

% Extrae fecha desde nombre del archivo
fecha = file(4:end);  % Ej: 010324_S1.mat ? fecha = 010324_S1.mat

% Etiquetas de intervalos que devuelve la funci�n "funcion_intervalos"
tags = {
    'AllRuns';   % 1. Todos los intervalos de corrida
    'toSoc';     % 2. Corridas hacia el compartimiento social
    'toObj';     % 3. Corridas hacia el compartimiento objeto
    'inSoc';     % 4. Permanencia en zona social
    'inObj';     % 5. Permanencia en zona objeto
    'inCenter'   % 6. Permanencia en zona central
};

% Verifica si ya existen variables Pos_<tarea> en el archivo cargado
datos = who;

%% === LOOP DE TAREAS (LT - S1 - S2) ===
for task = 1:3
    switch task
        case 1  % Linear Track (LT)
            idx_task = find(strncmp(datos, 'Pos_LT', 6));
            if ~isempty(idx_task)
                % Si a�n no est� creada Pos_LT, crearla con: 
                % Pos_LT = LT_Reescalar(Pos_X_LT, Pos_Y_LT, 0);
                ints_LT = funcion_intervalos(Pos_LT);
                close all;
                for m = 1:6
                    ints_LT{m, 2} = tags{m};  % Agrega etiqueta
                end
            end

        case 2  % Primera exposici�n (S1)
            idx_task = find(strncmp(datos, 'Pos_S1', 6));
            if ~isempty(idx_task)
                ints_S1 = funcion_intervalos(Pos_S1);
                close all;
                for m = 1:6
                    ints_S1{m, 2} = tags{m};
                end
            end

        case 3  % Reexposici�n (S2)
            idx_task = find(strncmp(datos, 'Pos_S2', 6));
            if ~isempty(idx_task)
                ints_S2 = funcion_intervalos(Pos_S2);
                close all;
                for m = 1:6
                    ints_S2{m, 2} = tags{m};
                end
            end
    end
end

%% === FINALIZACI�N ===

% Limpieza del espacio de trabajo (opcional)
clear task idx_task datos tags m;

% Guardado manual opcional:
% save(fecha)
disp('%%%%% < F I N A L I Z A D O > %%%%%')