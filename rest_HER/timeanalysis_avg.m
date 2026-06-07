
% INPUT
% indsubj: index of subjects for which dataHER is available
% 

indsubj_1 = [17 18 19 20 27 35 36 40 42 44 46 51 52 56 57 59 64 69 70]; % bipolar 20
indsubj_2 = [2 4 6 8 10 12 14 16 22 23 24 28 29 31 32 38 45 47 53 54 55 67 58 61 63 65 68];  % bipolar 27
%indsubj = [2 4 6 8 10 12 14 16 17 18 19 20 22 23 24 27 28 29 31 32 36 38 40 42 44 46 47 49 51 52]; % all

save2path = ['C:\Users\MSI/Documents/Our_project/Heart/all_HER/'];

% anatomical labels, rh and lh:
anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'  
'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}



%% Do baseline correction (Data - MeanBas) / StdBas

dataHERnorm_bipolar = {}; % without 10 31 54 55 67

for ss = 14

    fpathsave = ['E:/MEG_Data_PhD/zhanx_', num2str(ss), '/HER/'];
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

   dataHER_avg = squeeze(mean(dataHER_tpeaks,2,'omitnan'));
   % size = labels x time

   mbas = mean(dataHER_avg(:,xp1:xp2),2,'omitnan');
   mbas = repmat(mbas,[1 size(dataHER_avg,2)]);

   sdbas = std(dataHER_avg(:,xp1:xp2),0,2,'omitnan');
   sdbas = repmat(sdbas,[1 size(dataHER_avg,2)]);

   dataHERnorm = (dataHER_avg - mbas)./sdbas;

    % Individual plots of HER, after averaging across trials, and selecting
    % labels cACC, rACC
    % x = squeeze(mean(mean(dataHERnorm(9:10,:,:),1,'omitnan'),2,'omitnan'));

    x = mean(dataHERnorm(9:10,:),1);
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
    % saveas(gcf, ['Panel_HER_mOFC_', subj,'.png'], 'png')
    
    x = mean(dataHERnorm(1:2,:),1);
    figure;plot(time,x)
    title(['Heartbeat evoked response cACC zhanx ', num2str(ss)])
    xlabel('Time') 
    ylabel('Amplitude') 
    %xlim([0 0.2])
    % saveas(gcf, ['Panel_HER_сACC_', subj,'.png'], 'png')

    % Stats interval:
    % t1 = 0.1;
    % t2 = 0.5;
    % [~,xp1] = min(abs(time-t1));
    % [~,xp2] = min(abs(time-t2));
    % 
    % dataHERnorm = dataHERnorm(:,:,xp1:xp2);
    % 
    % time2plot = time(xp1 : xp2)

    dataHERnorm_bipolar{ss} = dataHERnorm; % cell structure, 26 labels x trials x samples
  
end
% save dataHERnorm_allsubj to later do group stats

% close all
% cd(save2path)
% 
% filetag_1 = ['dataHERnorm_bipolar_avg.mat'];
% save(filetag_1, 'dataHERnorm_bipolar')


