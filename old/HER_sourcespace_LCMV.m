%%

clear 
%% Load files for subject number ID ss
subjects = [2 4 6 8 10 12 14 16 17 18 19 20 22 23 24 27 28 29 31 32 35 36 38 40 42 44 45 46 47 51 52 53 54 55 56 57 58 59 61 63 64 65 67 68 69 70];

% n = 2;

for n = 17

    subj = ['zhanx_', num2str(n)];
    % path to EKG latency peaks
    fpath0 =  ['/Volumes/KINGSTON/MEG_Data_PhD/', subj, '/'];

    % path to ITI bemlabels


    % path to total_ordered_matched_events_stim.mat
    fpath2 = ['/Users/marinaivanova/Documents/Our_project/Heart/total_ordered_stim/', subj '/Processing/python/'];

    %fpath2 = ['/Volumes/T7/MEG_Data_PhD/zhanx_48/'];

    cd(fpath0)
    mkdir HER
    % path to save dataHER after preprocessing
    fpathsave = ['/Volumes/KINGSTON/MEG_Data_PhD/', subj '/HER/'];
    %% Load files for subject number ID ss

    addpath('/Volumes/KINGSTON/MEG_Data_PhD/');
    addpath('/Users/marinaivanova/Documents/MATLAB/fieldtrip-20240603/')
    ft_defaults


    % addpath('/home/mherrojo/packages/fieldtrip-20230118/')
    % ft_defaults

    subj = sprintf('zhanx_%d',n);

    % path to ITI bemlabels
    fpath = ['/Volumes/KINGSTON/subjects/', subj, '/bem/bemlabels_ITI/'];
    f1 = dir(fpath)

    % if length(f1) == 0
    %     fpath = ['/Volumes/T7/bemlabels_ITI/', subj, '/bem/bemlabels/'];
    %     f2 = dir([fpath,'*ITI.*'])
    % end


    %% Check Twave peaks latency values

    load([fpath0,'latency_tpeaks.mat'])


    % These values are all in milliseconds
    thr1 = 400; % we only accept T wave peaks that precede the stimulus onset by more than thr1 milliseconds
    thr2 = 1200; % exclude trials when the T wave peak in latency_tpeaks(:,2) is more than thr farther apart from latency_tpeaks(:,1)

    delta_lat = diff(latency_tpeaks)';
    max(delta_lat)  % check this is not much larger than 1000, as it could mean we skipped an T peak in the detection
    ind_exc = find(delta_lat > thr2); % for instance

    %Twave PEAK at least 400 apart from Stimulus
    latency_tpeaks = latency_tpeaks'; % 320 x 2

    ikeep = (find(latency_tpeaks(:,1)>thr1));
    ikeep2 = (find(latency_tpeaks(:,2)>thr1));
    ikeep2 = setdiff(ikeep2, ind_exc);


    % total indexes of Twave peaks to keep
    ikeep_src = cat(1,ikeep, ikeep2); %
    % latency difference from Stimulus, to keep, in milliseconds
    Latkeep_ms = cat(1, latency_tpeaks(ikeep,1),latency_tpeaks(ikeep2,2));

    % We had a 250 Hz sample in bemlabels:
    % estimate difference between Tpeak and Stimulus in sample points
    Latkeep_sample = round(Latkeep_ms*250/1000);
    latency_tpeaks_sample = round(latency_tpeaks*250/1000);




    % %%
    % load([fpath2, 'total_ordered_matched_events_stim.mat'])%  total_ordered_matched_events  ordered_ind1keep ordered_ind2keep stimpy indexHGF
    % clearvars ordered_ind1keep ordered_ind2keep stimpy
    % keep indexHGF

    cd(['/Volumes/KINGSTON/subjects/', subj,'/bem/bemlabels_ITI/'])

    T = readtable("mapped_remaining_old.csv");
    indexHGF = T.Var1;
    %%  Select trials from newftdata (bemlabels)

    % which trials from newftdata do we keep: which ones do have a matched
    %Twave??

    % indexHGF = indexHGF(161:end);  % for when we are using one block

    IA = find(ismember(indexHGF, ikeep)) ; % IA is the order of events from indexHGF that are valid as they are in ikeep
    % (IA) is valid and equal to intersect(indexHGF,ikeep)

    IA2 = find(ismember(indexHGF, ikeep2)) ;
    % IA2 are the indexes from indexHGF that we keep for Twave HER analysis
    % (IA2)

    %% Load stimulus-locked bemlabels for ITI and choose the selected indexes

    cd(fpath)

    % STC to create time vector

    !rm *rh_*lh*
    !rm *lh_*rh*
    % from /anxiety/results/MRI/RECON/zhanx_19/bem/bemlabels/
    filename=['/Users/marinaivanova/Documents/Our_project/Heart/posteriorcingulate-rh_trial0-rh.stc']
    [stc] = mne_read_stc_file(filename)

    time_sec = -1.5:(1/250):0; % time in seconds
    time_ms = time_sec*1000;

    clear stc


    % Latency of stimulus event:
    % python epochs from -1.5 to 0 seconds, time=0 is 376 sample, the last one
    x = abs(time_sec - 0); xp = find(x==min(x)); %376


    % anatomical labels, rh and lh:
    anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
        'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
        'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'
        'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
        'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
        'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}

    nlabel = length(anat_labels);

    % l = 1;
    %
    % filesrc  = ['pca_',anat_labels{l},'_eLoreta_ITI.mat'];
    % cd(fpath)
    % X = load(filesrc); ntrial = size(X.pca_timecourse,1); nsample = size(X.pca_timecourse,2);
    % nsample = size(X.pca_timecourse,2); % 376 samples for ITI
    % datasrc = nan(nlabel, total_ordered_matched_events, nsample);
    %
    % for l = 1 : length(anat_labels)
    %          filesrc_1  = ['pca_',anat_labels{l},'_ITI.mat'];   % this is for when LCMV was processed separately in each block
    %          %remember: python uses indexes 0 1 2 ...N-1
    %          ordered_1 = load(filesrc_1);
    %          filesrc_2  = ['pca_',anat_labels{l},'_b2_ITI.mat'];
    %          %remember: python uses indexes 0 1 2 ...N-1
    %          ordered_2 = load(filesrc_2);
    %          X = cat(2, ordered_1, ordered_2)
    %
    %          [a, b] = X.pca_timecourse; % Извлекаем значения в две переменные
    %          X = cat(1, a, b);
    %
    %          datasrc(l, :,:) = X;
    %          clear X
    % end

    % for l = 1 : length(anat_labels)
    %          filesrc  = ['pca_',anat_labels{l},'_ITI.mat'];
    %          %remember: python uses indexes 0 1 2 ...N-1
    %          X = load(filesrc);
    %          datasrc(l, :,:) = (X.pca_timecourse);
    %          clear X
    % end
    %
    if n == 22
        for l = 1 : length(anat_labels)
            filesrc  = ['pca_',anat_labels{l},'_ITI.mat'];
            %remember: python uses indexes 0 1 2 ...N-1
            X = load(filesrc);
            % select block2 only
            datasrc(l, :,:) = (X.pca_timecourse(161:end,:));
            clear X
        end
    elseif n == 58
        for l = 1 : length(anat_labels)
            filesrc  = ['pca_',anat_labels{l},'_ITI.mat'];
            %remember: python uses indexes 0 1 2 ...N-1
            X = load(filesrc);
            % select block2 only
            datasrc(l, :,:) = (X.pca_timecourse(161:end,:));
            clear X
        end
    else
        for l = 1 : length(anat_labels)
            filesrc  = ['pca_',anat_labels{l},'_ITI.mat'];
            %remember: python uses indexes 0 1 2 ...N-1
            X = load(filesrc);
            datasrc(l, :,:) = (X.pca_timecourse);
            clear X
        end
    end

    % Note
    % datasrc has dimensions: 26 labels x ntrials x nsamples
    % ntrials are those we kept after preprocessing MEG and running lcmv. Could
    % be 320 or moste likely fewer. The exact index of trials kept is in
    % indexHGF



    % from all valid bemlabels trials, we now select those for which we've
    % identified a valid preceding Tpeak: ikeep and ikeep2
    %
    % Stimulus-locked We Will see if we need this once we have fewer than 320
    % trials

    if ~(length(indexHGF) == size(datasrc,2)), error('mismatch between indexHGF and size of datasrc'), else
        datastimulus = datasrc(:,IA,:);  %ikeep''
        datastimulus2 = datasrc(:,IA2,:); %ikeep2
    end


    %% Data HER

    % Choose HER with latency in ms -300 to 600 ms around the Twave
    % We expect the Twave HER to be around 100-300 ms
    pre = 300*250/1000;
    post = 600*250/1000 ;

    %  time 0 ms is = 376 samples in datasrc (check: time_ms(376)

    %% previous Twave: ikeep1

    % THIS NEEDS TO CHANGE:  IA here, instead of ikeep,
    % we use IA which integrates ikeep and indexHGF


    %     xp0 = 376 - latency_tpeaks_sample(ikeep,1); %centre OLD version
    xp0 = 376 - latency_tpeaks_sample(IA,1); % valid indexes from indexHGF and ikeep
    % dimensions of xp0 are dimensions of datastimulus, e.g. 176 trials
    % from these, we select indfinal below

    xppre = xp0 - pre;
    xppost = xp0 + post;

    % negative xppre are not valid, do not fit into our [-1.5, 0] second
    % interval
    % xppost > 376 are not valid, do not fit into our [-1.5, 0] second
    % interval addpath('/home/mherrojo/eeg/matlab/acquisition/meg/HSE/mnepython/');

    % we keep these trials from all Twave events coming from ikeep and ikeep2
    indfinal = find(xppre >=0 & xppost<=376)';


    len = post+pre+1;
    dataHERsrc = nan(size(datastimulus,1), length(indfinal),len);

    for j = 1: length(indfinal)
        dataHERsrc(:,j,:) = datastimulus(:,indfinal(j),xppre(indfinal(j)):xppost(indfinal(j)));
    end

    clear xp;

    xp = 1:size(dataHERsrc,3);
    time_HER_ms = (xp-pre-1)*1000/250;
    indfinal_1 = indfinal;


    %% 2nd previous Twave: ikeep2

    %     xp0 = 376 - latency_tpeaks_sample(ikeep2,2); %centre
    xp0 = 376 - latency_tpeaks_sample(IA2,2); %centre

    % dimensions of xp0 are dimensions of datastimulus, e.g. 176 trials
    % from these, we select indfinal below

    xppre = xp0 - pre;
    xppost = xp0 + post;

    % negative xppre are not valid, do not fit into our [-1.5, 0] second
    % interval
    % xppost > 376 are not valid, do not fit into our [-1.5, 0] second
    % interval

    % we keep these trials from all Twave events coming from ikeep and ikeep2
    indfinal = find(xppre >= 1 & xppost<=376)';


    len = post+pre+1;
    dataHERsrc2 = nan(size(datastimulus2,1), length(indfinal),len);

    for j = 1: length(indfinal)
        dataHERsrc2(:,j,:) = datastimulus2(:,indfinal(j),xppre(indfinal(j)):xppost(indfinal(j)));
    end

    clear xp;

    indfinal_2 = indfinal;
    indfinal_fin = cat(2, indfinal_1, indfinal_2)';
    %% Concatenate HER epochs

    dataHER_LCMV = cat(2, dataHERsrc, dataHERsrc2);
    %  time_HER_ms  % same for every epoch

    clear *HERsrc* datasti*

    filetag = [fpathsave,subj,'_dataHER_LCMV.mat'];
    save(filetag, 'dataHER_LCMV', 'time_HER_ms', 'Latkeep_sample', 'Latkeep_ms', 'latency_tpeaks', 'latency_tpeaks_sample','indfinal_fin')
    clear
end
% dataHER has dimensions 26 labels x trials x samples
% time_HER_ms has dimensions 1 x samples