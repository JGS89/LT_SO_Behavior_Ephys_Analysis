close all
clear all
clc
%% Este codigo se utiliza para generar los datos de Zscore
% 9 bines sobre LT, >15 minutos de tarea
% Los datos se pegan en base de datos "Data_Zscore..."
% -JGS 250219
%% Setear prueba a analizar (LT, S1, S2)
prueba = Pos_S2;
%%
folder=('');
[nombre,path] = uigetfile('/*.mat','Session .mat', folder);
nomarch=[path,nombre];
load(nomarch);

%%
x_rescalado = prueba(:,1); % Posicion
Pos_x_time = prueba(:,2); % Tiempo

% Dimension Linear Track
largo_LT_mm = 780;
cant_bines = 9;
Long_bin = largo_LT_mm/cant_bines;
Limites_bines = [0:Long_bin:780];

% Prueba sobre LT como maximo de 15 minutos!
Time_filter = Pos_x_time - min(Pos_x_time);
idx_time_filter = find(Time_filter<=900,1,'last');
X_t_rescal = [ x_rescalado(1:idx_time_filter) Pos_x_time(1:idx_time_filter) ];

% ARMA CELDA [x,t,idx] per BIN
Pos_time_idx_bins = cell(length(Limites_bines)-1,3); % [ Pos Tiempo Idx ] por Bin
for i = 1:length(Pos_time_idx_bins) %% loop checked
    for w = 1:length(X_t_rescal)
        if Limites_bines(i)<X_t_rescal(w,1) && X_t_rescal(w,1)<Limites_bines(i+1)
            Pos_time_idx_bins{i,3}=[Pos_time_idx_bins{i,3} w];% Indices
            Pos_time_idx_bins{i,1}=[Pos_time_idx_bins{i,1} X_t_rescal(w,1)];% Posiciones
            Pos_time_idx_bins{i,2}=[Pos_time_idx_bins{i,2} X_t_rescal(w,2)];% Tiempo
        else
        end
    end
end

datos=who;
idx_neuronas = find(strncmp(datos, 'nr_',3));
neuron_all = cell(length(idx_neuronas),1); %Celda q contiene las neuronas
neuron_all_spikes_LT = cell(length(idx_neuronas),1); %neuronas con spikes sobre LT
for i = 1:length(neuron_all) %% loop checked
    neuron_all{i,1} = eval(datos{idx_neuronas(i)});
end
% RASTER PLOTS %%
% Sako X(t) de los Spk para Raster
for i = 1:length(neuron_all_spikes_LT)
    neuron_all_spikes_LT{i,1} = neuron_all{i,1}(neuron_all{i,1}>=min(Pos_x_time));
    for j = 1:length(neuron_all_spikes_LT{i,1})
        n = neuron_all_spikes_LT{i,1}(j);
        a = X_t_rescal(:,2);
        diff_spk_time = abs(a-n);
        min_diff_spk_time = min(diff_spk_time);
        idx = find(diff_spk_time==min_diff_spk_time);
        idx = round(mean(idx));
        neuron_all_spikes_LT{i,1}(j,2)=(X_t_rescal(idx,1)*n)/X_t_rescal(idx,2);
        clear a, clear n, clear idx, clear diff_spk_time, clear min_diff_spk_time
    end
end

% Calculo los intervalos por bin
Inter_cell_all = cell(length(Pos_time_idx_bins),1);
for w = 1:length(Inter_cell_all) %% loop checked
    if length(Pos_time_idx_bins{w,2}) == 1
        Pos_time_idx_bins{w,2}(1,2) = Pos_time_idx_bins{w,2}(1,1)+0.0001;
    end
    diff_intervalos = diff(Pos_time_idx_bins{w,2});
    idx_diff_inter = find(diff_intervalos>min(diff_intervalos)+0.1); % CRITERIO
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
clear row, clear colum
%
dist_t_bines = [];
for n = 1:9
    diff_bin = diff(Inter_cell_all{n,1},[],2);
    dist_t_bines(1,n) = sum(diff_bin);
    clear diff_bin
end
    %
fr_per_bin = cell(length(Inter_cell_all),length(neuron_all)); %celda para mfr en cada bin (Bins x Neuronas)
[n_bines,n_neuronas] = size(fr_per_bin); %necesario tener # bines y # neuronas
for z = 1:n_bines %recorre cada bin
    intervalos_elegido = Inter_cell_all{z,1}; %selecciona los intervalos del bin
    spk_per_intervalo = cell(length(intervalos_elegido),length(neuron_all)); % (spikes per bins x neuronas)
    vector_diff_inter = [];
    for w = 1:length(intervalos_elegido) %% loop Checked
        for n = 1:length(neuron_all) %% loop Checked
            neurona_elegida = neuron_all{n,1};
            ts_step = neurona_elegida(neurona_elegida>=intervalos_elegido(w,1) & neurona_elegida<=intervalos_elegido(w,2));
            spk_per_intervalo{w,n} = length(ts_step);
            clear neurona_elegida
            clear ts_step
        end
        diff_intervalo = intervalos_elegido(w,2)-intervalos_elegido(w,1);
        vector_diff_inter = [ vector_diff_inter diff_intervalo ];
        clear diff_intervalo
    end
    [row,~] = size(spk_per_intervalo);
    for m = 1:n_neuronas
        vector_spk_inter = [];
        for s = 1:row
            vector_spk_inter = [ vector_spk_inter spk_per_intervalo{s,m} ];
        end
        fr_per_bin{z,m}(1,2) = sum(vector_spk_inter); %Se agrega spk total a bin para cada neurona
        fr_per_bin{z,m}(1,3) = sum(vector_diff_inter); %Se agrega tiempo total a bin para cada neurona
        fr_per_bin{z,m}(1,1) = fr_per_bin{z,m}(1,2)/fr_per_bin{z,m}(1,3); %Se agrega FR total en el bin
        clear vector_spk_inter
    end
    clear vector_diff_inter
    clear row, clear colum
end
neu_firings_all = cell(length(neuron_all),1);

for n = 1:n_neuronas
     for m = 1:n_bines
         neu_firings (1,m) = fr_per_bin{m,n}(1,1); %FR
         neu_firings (2,m) = fr_per_bin{m,n}(1,2); %Spikes
         neu_firings (3,m) = fr_per_bin{m,n}(1,3); %Tiempo
     end
     neu_firings_all{n,1} = neu_firings;
     neu_firings_all{n,2} = [ neu_firings(1,:) neu_firings(2,:) neu_firings(3,:) ]; % FR Spikes Tiempo
     clear neu_firings
end
For_paste = [];
% Se apila Zscore 9 bines para cada neurona
% Pegar en base de datos .xlsx
for i=1:length(neu_firings_all)
  For_paste = [ For_paste;neu_firings_all{i,2} ]; 
end