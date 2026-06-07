% INPUT
% indsubj: index of subjects for which dataHER is available
% 



%indsubj = [17 18 19 20 27 35 36 40 41 42 44 46 49 51 52]; % Bipolar
indsubj = [2 4 6 8 10 12 14 16 22 23 24 28 29 31 32 38 45 47];  % healthy

save2path = ['/Users/marinaivanova/Documents/Our_project/Heart/all_HER/'];

% anatomical labels, rh and lh:
anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'  
'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}

%indlab = [1,2,19,20];


%% Do baseline correction (Data - MeanBas) / StdBas

dataHERnorm_healthy = {};

for ss = indsubj
    

    fpathsave = ['/Volumes/T7/MEG_Data_PhD/zhanx_', num2str(ss), '/HER/']
    cd(fpathsave)
    subj = sprintf('zhanx_%d',ss); 
    filetag = [fpathsave,subj,'_dataHER.mat'];
    load(filetag) %, 'dataHER', 'time_HER_ms', 'Latkeep_sample', 'Latkeep_ms', 'latency_tpeaks', 'latency_tpeaks_sample')
    

    time = time_HER_ms/1000; % seconds
    clear time_H*
    
    % Baseline interval:
    % t1 = -0.250;
    % t2 = -0.050;
    t1 = -0.2;
    t2 = -0.1;
    [~,xp1] = min(abs(time-t1));
    [~,xp2] = min(abs(time-t2));
    
    %   dataHER has dims:  26 labels x trials x samples
    mbas = mean(dataHER(:,:,xp1:xp2),3,'omitnan');  % -400, 0
    mbas = repmat(mbas, [1, 1, size(dataHER,3)]);
    sdbas = std(dataHER(:,:,xp1:xp2),0,3,'omitnan');
    sdbas = repmat(sdbas,[1, 1, size(dataHER,3)]);

    dataHERnorm = (dataHER - mbas)./sdbas; % (X - mean_bas) / std_bas

    % Stats interval:
    % t1 = 0.1;
    % t2 = 0.5;
    % [~,xp1] = min(abs(time-t1));
    % [~,xp2] = min(abs(time-t2));
    % 
    % dataHERnorm = dataHERnorm(:,:,xp1:xp2);
    % 
    % time2plot = time(xp1 : xp2)

    dataHERnorm_healthy{ss} = dataHERnorm; % cell structure, 26 labels x trials x samples

  

    % Individual plots of HER, after averaging across trials, and selecting
    % labels cACC, rACC
    x = squeeze(mean(mean(dataHERnorm(1:2,:,:),1,'omitnan'),2,'omitnan'));
    figure;plot(time,x)
    title(['Heartbeat evoked response cACC zhanx ',num2str(ss)])
    xlabel('Time') 
    ylabel('Amplitude')
    % Ensure no variable named 'xlim' is in the workspace
    if exist('xlim', 'var')
        clear xlim;
    end
% Set x-axis limits
    %xlim([0 0.2])
    saveas(gcf, ['Panel_HER_cACC_', subj,'.png'], 'png')
    
    x = squeeze(mean(mean(dataHERnorm(1:2,:,:),1,'omitnan'),2,'omitnan'));
    figure;plot(time,x)
    title(['Heartbeat evoked response rACC zhanx ', num2str(ss)])
    xlabel('Time') 
    ylabel('Amplitude') 
    %xlim([0 0.2])
    saveas(gcf, ['Panel_HER_rACC_', subj,'.png'], 'png')


    filetag = ['dataHERnorm.mat'];
    save(filetag, 'dataHERnorm')
    
end

% save dataHERnorm_allsubj to later do group stats

close all
cd(save2path)

filetag_1 = ['dataHERnorm_healthy.mat'];
save(filetag_1, 'dataHERnorm_healthy')

%%


% Step 1: Identify empty cells
emptyCells = cellfun(@isempty, dataHERnorm_healthy);

% Step 2: Filter out empty cells
dataHERnorm_healthy = dataHERnorm_healthy(~emptyCells);


alltogether = cat(2, dataHERnorm_healthy{:});
sizealltogther = size(alltogether)

% Calculate group average and SEM for specific labels (cACC)
avrgmatrix = mean(alltogether(1:2, :, :), 2, 'omitnan');
avrgmatrix = squeeze(mean(avrgmatrix, 1, 'omitnan'));
sem_matrix = std(alltogether(1:2, :, :), 0, 2, 'omitnan');
sem_matrix = squeeze(mean(sem_matrix, 1, 'omitnan')) / sqrt(size(alltogether, 2)); % sem matrix - sem for each number in the vector

% time2plot = time2plot';

% Plot and save the group average HER with SEM
cd(save2path);
figure;
plot(time, avrgmatrix, 'b');
hold on;
%errorbar(time, avrgmatrix, sem_matrix)
fill([time; flipud(time)], [avrgmatrix + sem_matrix; flipud(avrgmatrix - sem_matrix)], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
title('HER healthy');
xlabel('Time');
ylabel('Amplitude');
saveas(gcf, 'HER_healthy_cACC_LCMV.png', 'png');