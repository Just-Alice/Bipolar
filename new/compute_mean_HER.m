clear all

all = [2 4 6 8 10 12 14	16 17 18 19 20 22 23 24	27 28 29 31 32 35 36 38 40 42 44 45 46 47 49 51 52 53 54 55 56 57 58 59 61 63 64 65 67 68 69 70];
bipolar = [17 18 19 20 27 35 36 40 42 44 46 49 51 52 56 57 59 64 69 70];
test = 10;

for ss = test
    % table for R
    clear subject group
    % anatomical labels, rh and lh:
    anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
        'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
        'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'
        'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
        'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
        'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}


    fpathsave = ['/Volumes/KINGSTON/MEG_Data_PhD/zhanx_', num2str(ss), '/HER/'];
    fpath = ['/Volumes/KINGSTON/MEG_Data_PhD/zhanx_', num2str(ss), '/'];
    cd(fpathsave)
    subj = sprintf('zhanx_%d',ss);
    filetag = [fpathsave,subj,'_dataHER_tpeaks.mat'];
    load(filetag) %, 'dataHER_LCMV', 'time_HER_ms'


    time = time_HER_ms/1000; % seconds
    clear time_H*

    % Define time range of interest and baseline period
    time_range = [-0.5, 1]; % from -500 ms to 1000 ms
    baseline_range = [-0.25, -0.05]; % baseline period
    analysis_window = [0.1, 0.4]; % period of interest: 0.1 to 0.4 seconds

    % Ensure `time` variable matches the epoch length
    epoch_length = size(dataHER_tpeaks, 3); % Assuming datasrc contains data in [label, trial, time] format
    if length(time) ~= epoch_length
        error('Mismatch between time vector and data dimensions. Check the epoch length!');
    end

    % Find indices for baseline and analysis windows
    baseline_idx = find(time >= baseline_range(1) & time <= baseline_range(2));
    analysis_idx = find(time >= analysis_window(1) & time <= analysis_window(2));

    % Preallocate for normalized HEP
    HEPnorm = nan(size(dataHER_tpeaks)); % Same size as datasrc

    % Loop through each label and trial
    for l = 1:size(dataHER_tpeaks, 1) % For each anatomical label
        for t = 1:size(dataHER_tpeaks, 2) % For each trial
            % Extract single trial HEP
            HEP = squeeze(dataHER_tpeaks(l, t, :));

            % Compute baseline mean and standard deviation
            meanHEPbas = mean(HEP(baseline_idx));
            stdHEPbas = std(HEP(baseline_idx));

            % Normalize HEP with baseline
            HEPnorm(l, t, :) = (HEP - meanHEPbas) / stdHEPbas;
        end
    end

    % Compute mean normalized HEP in the analysis window (0.1-0.4 s)
    mean_HEPnorm = nan(size(dataHER_tpeaks, 1), size(dataHER_tpeaks, 2)); % Preallocate for mean HEPnorm
    for l = 1:size(HEPnorm, 1) % For each anatomical label
        for t = 1:size(HEPnorm, 2) % For each trial
            % Extract normalized HEP for the trial in the analysis window
            HEPnorm_trial = squeeze(HEPnorm(l, t, analysis_idx));
            % Compute mean normalized HEP
            mean_HEPnorm(l, t) = mean(HEPnorm_trial, 'omitnan');
        end
    end

    mOFC = mean(mean_HEPnorm(9:10, :))';  % mean of the trial
    cACC = mean(mean_HEPnorm(1:2, :))';
    rACC = mean(mean_HEPnorm(19:20, :))';

    % Save results
    save([fpathsave, 'HEPnorm_results.mat'], 'HEPnorm', 'mean_HEPnorm', 'time', 'baseline_range', 'analysis_window');
    disp('Normalization and analysis completed. Results saved.');


    for i = 1:length(trial_num)
        subject(i) = ss;
        if ismember(ss, bipolar)
            group(i) = 1;
        else
            group(i) = 0;
        end
    end
    group = group';

    %
    % for i = 1:length(indfinal_fin)
    %     subject(i) = ss;
    % end

    subject = subject';
    %% load hgf file
    hgf_folder = ['/Volumes/KINGSTON/HGF_bipolar/zhanx_', num2str(ss), '/'];
    filename = ['zhanx_', num2str(ss), '.mat'];
    cd(hgf_folder)
    load(filename)

    est = player_struct.hgf71.est23.traj;
    
    % 
    % if ss == 31
    %     index_cut = find(indfinal_fin >= 160);
    %     indfinal_fin = indfinal_fin(1:index_cut-1);
    % end
    
    cd(fpath)
    T1 = readtable("align_result.csv");
    trial_ind = T1.Var4;
    T2 = readtable("align_result2.csv");
    trial_ind2 = T2.Var4;

    trial_index = cat(1, trial_ind, trial_ind2);  % initial trial index from tpeaks_events code

    alltrials = abs(est.muhat(:,2));
    HGF = alltrials(trial_index);
    alltrials1 = est.sahat(:,1);
    HGF1 = alltrials1(trial_index);

    trial = trial_index;

    data = table(subject,group,trial,mOFC,cACC,rACC,HGF,HGF1);

    if ss == 2
        data2 = data;
    else
        data2 = vertcat(data2, data);
    end

end


cd /Users/marinaivanova/Documents/Our_project/Heart/
filename2 = ['dataHEP4brms_tpeaks.csv'];

writetable(data2, filename2)

 % data2 = vertcat(dataHEP4brms2,dataHEP4brms4, dataHEP4brms6, dataHEP4brms8, dataHEP4brms10, dataHEP4brms12, dataHEP4brms14, dataHEP4brms16, dataHEP4brms17, dataHEP4brms18, dataHEP4brms19, dataHEP4brms20, dataHEP4brms22, dataHEP4brms23, dataHEP4brms24, dataHEP4brms27, dataHEP4brms28, dataHEP4brms29, dataHEP4brms32);
 %    data2 = vertcat(data, dataHEP4brms35, dataHEP4brms36, dataHEP4brms38, dataHEP4brms40, dataHEP4brms42, dataHEP4brms44, dataHEP4brms45, dataHEP4brms46, dataHEP4brms47, dataHEP4brms49, dataHEP4brms51,dataHEP4brms52,dataHEP4brms53,dataHEP4brms54,dataHEP4brms55,dataHEP4brms56 );


