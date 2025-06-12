%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULO DE INTERVALOS POR TAREA PARA SESIONES TIPO "SOCIAL-OBJETO" (SO)
% Autor: Javier Gonzalez Sanabria (JGS) – 2024
%
% Este script calcula intervalos de interés usando la función externa 
% "funcion_intervalos.m" para las tareas:
%   (1) LT – Linear Track sin estímulos
%   (2) S1 – Primera exposición a social y objeto
%   (3) S2 – Reexposición a social y objeto (invertido)
%
% Requiere:
% - Archivo de sesión *.mat con variables Pos_X_<tarea>, Pos_Y_<tarea>
% - Variable combinada Pos_<tarea> = [X Y]
% - Función auxiliar: "funcion_intervalos.m"
%
% Salida:
% - Celda por tarea con 6 tipos de intervalos (ver "tags")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% === INICIALIZACIÓN ===
clear; close all; clc;

% Selección del archivo de sesión (.mat)
[file, folder] = uigetfile('', 'Seleccionar sesión *.mat', '*.mat');
load([folder, file]);

% Extrae fecha desde nombre del archivo
fecha = file(4:end);

% Etiquetas de intervalos que devuelve la función "funcion_intervalos"
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
                % Si aún no está creada Pos_LT, crearla con: 
                % Pos_LT = LT_Reescalar(Pos_X_LT, Pos_Y_LT, 0);
                ints_LT = funcion_intervalos(Pos_LT);
                close all;
                for m = 1:6
                    ints_LT{m, 2} = tags{m};  % Agrega etiqueta
                end
            end

        case 2  % Primera exposición (S1)
            idx_task = find(strncmp(datos, 'Pos_S1', 6));
            if ~isempty(idx_task)
                ints_S1 = funcion_intervalos(Pos_S1);
                close all;
                for m = 1:6
                    ints_S1{m, 2} = tags{m};
                end
            end

        case 3  % Reexposición (S2)
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

%% === FINALIZACIÓN ===

% Limpieza del espacio de trabajo (opcional)
clear task idx_task datos tags m;

% Guardado manual opcional:
% save(fecha)
disp('%%%%% < F I N A L I Z A D O > %%%%%')
