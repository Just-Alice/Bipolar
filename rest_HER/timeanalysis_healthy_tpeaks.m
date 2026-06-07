

% INPUT
% indsubj: index of subjects for which dataHER is available
% 

indsubj_1 = [17 18 19 20 27 35 36 40 42 44 46 51 52 56 57 59 64 69 70]; % bipolar 20
indsubj_2 = [2 4 6 8 10 12 14 16 22 23 24 28 29 31 32 38 45 47 53 54 55 67 58 61 63 65 68];  % healthy 27
%indsubj = [2 4 6 8 10 12 14 16 17 18 19 20 22 23 24 27 28 29 31 32 36 38 40 42 44 46 47 49 51 52]; % all

save2path = ['/Users/marinaivanova/Documents/Our_project/Heart/all_HER/'];

% anatomical labels, rh and lh:
anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'  
'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}



%% Do baseline correction (Data - MeanBas) / StdBas

dataHERnorm_healthy_tpeaks = {}; % without 10 31 54 55 67

for ss = indsubj_2

    fpathsave = ['/Volumes/KINGSTON/MEG_Data_PhD/zhanx_', num2str(ss), '/HER/'];
    cd(fpathsave)
    subj = sprintf('zhanx_%d',ss); 
    filetag = [fpathsave,subj,'_dataHER_tpeaks.mat'];
    load(filetag) %, 'dataHER', 'time_HER_ms', 'Latkeep_sample', 'Latkeep_ms', 'latency_tpeaks', 'latency_tpeaks_sample')
    

    time = time_HER_ms/1000; % seconds
    clear time_H*
    
    % % Baseline interval:
    t1 = -0.250;
    t2 = -0.050;
    % t1 = -0.2;
    % t2 = -0.1;
    [~,xp1] = min(abs(time-t1));
    [~,xp2] = min(abs(time-t2));
    

    % average data_HER_tpeaks across trials, 2nd dimension, then squeeze,
    % therefore dataGER_tpeaks will be 2D
    %   dataHER has dims:  26 labels x trials x samples
    mbas = mean(dataHER_tpeaks(:,:,xp1:xp2),3,'omitnan');  % -400, 0
    mbas = repmat(mbas, [1, 1, size(dataHER_tpeaks,3)]);
    sdbas = std(dataHER_tpeaks(:,:,xp1:xp2),0,3,'omitnan');
    sdbas = repmat(sdbas,[1, 1, size(dataHER_tpeaks,3)]);

    dataHERnorm = (dataHER_tpeaks - mbas)./sdbas; % (X - mean_bas) / std_bas   % 1) average across trials 2) baseline correction 3) stats

    % Stats interval:
    % t1 = 0.1;
    % t2 = 0.5;
    % [~,xp1] = min(abs(time-t1));
    % [~,xp2] = min(abs(time-t2));
    % 
    % dataHERnorm = dataHERnorm(:,:,xp1:xp2);
    % 
    % time2plot = time(xp1 : xp2)

    dataHERnorm_healthy_tpeaks{ss} = dataHERnorm; % cell structure, 26 labels x trials x samples
  

    % Individual plots of HER, after averaging across trials, and selecting
    % labels cACC, rACC
    x = squeeze(mean(mean(dataHERnorm(9:10,:,:),1,'omitnan'),2,'omitnan'));
    figure;plot(time,x)
    title(['Heartbeat evoked response mOFC zhanx ',num2str(ss)])
    xlabel('Time') 
    ylabel('Amplitude')
    % Ensure no variable named 'xlim' is in the workspace
    if exist('xlim', 'var')
        clear xlim;
    end
% Set x-axis limits
    %xlim([0 0.2])
    saveas(gcf, ['Panel_HER_mOFC_', subj,'.png'], 'png')
    
    x = squeeze(mean(mean(dataHERnorm(1:2,:,:),1,'omitnan'),2,'omitnan'));
    figure;plot(time,x)
    title(['Heartbeat evoked response cACC zhanx ', num2str(ss)])
    xlabel('Time') 
    ylabel('Amplitude') 
    %xlim([0 0.2])
    saveas(gcf, ['Panel_HER_mOFC_', subj,'.png'], 'png')


    filetag = ['dataHERnorm.mat'];
    save(filetag, 'dataHERnorm')
    
end

% save dataHERnorm_allsubj to later do group stats

close all
cd(save2path)

filetag_1 = ['dataHERnorm_healthy_tpeaks.mat'];
save(filetag_1, 'dataHERnorm_healthy_tpeaks')

%%


% Step 1: Identify empty cells
emptyCells = cellfun(@isempty, dataHERnorm_healthy_tpeaks);

% Step 2: Filter out empty cells
dataHERnorm_healthy_tpeaks = dataHERnorm_healthy_tpeaks(~emptyCells);


alltogether = cat(2, dataHERnorm_healthy_tpeaks{:});
sizealltogther = size(alltogether)

% Calculate group average and SEM for specific labels (mOFC)
avrgmatrix = mean(alltogether(9:10, :, :), 2, 'omitnan');
avrgmatrix = squeeze(mean(avrgmatrix, 1, 'omitnan'));
sem_matrix = std(alltogether(9:10, :, :), 0, 2, 'omitnan');
sem_matrix = squeeze(mean(sem_matrix, 1, 'omitnan')) / sqrt(size(alltogether, 2)); % sem matrix - sem for each number in the vector

time = time';

% Plot and save the group average HER with SEM
cd(save2path);
figure;
plot(time, avrgmatrix, 'b');
hold on;
%errorbar(time, avrgmatrix, sem_matrix)
fill([time; flipud(time)], [avrgmatrix + sem_matrix; flipud(avrgmatrix - sem_matrix)], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
title('HER healthy mOFC tpeaks');
xlim([-0.2 0.6])
xlabel('Time');
ylabel('Amplitude');
saveas(gcf, 'HER_healthy_mOFC_tpeaks.png', 'png');


%  close all