%%

clear all
all_subj = [2 4 6 8 10 12 14 16 17 18 19 20 22 23 24 27 28 29 31 32 35 36 38 40 42 44 45 46 47 51 52 53 54 55 56 57 58 59 61 63 64 65 67 68 69 70];
bipolar = [17 18 19 20 27 35 36 40 42 44 46 49 51 52 56 57 59 64 69 70];
rest = [14];

for n = rest
    clear datasrc dataHER_tpeaks X f1 filename filesrc filetag fpath fpath0 fpathsave post pre T1 T2 trial_num trial_num1 trial_num2 x xp
    %% Load files for subject number ID ss

    subj = ['zhanx_', num2str(n)];
    % path to EKG latency peaks
    fpath0 =  ['E:/MEG_Data_PhD/', subj, '/'];

    cd(fpath0)
    mkdir HER
    % path to save dataHER after preprocessing
    fpathsave = ['E:/MEG_Data_PhD/', subj '/HER/'];
    %% Load files for subject number ID ss

    addpath('E:/MEG_Data_PhD/');
    addpath('/C:\Users\MSI\Documents/MATLAB/fieldtrip-20240603/')
    ft_defaults


    subj = sprintf('zhanx_%d',n);

    % path to ITI bemlabels
    fpath = ['E:/subjects/', subj, '/bem/bemlabels_HER/'];
    f1 = dir(fpath)


    %% Load stimulus-locked bemlabels for ITI and choose the selected indexes

    cd(fpath)

    % STC to create time vector

    !rm *rh_*lh*
    !rm *lh_*rh*
    % from /anxiety/results/MRI/RECON/zhanx_19/bem/bemlabels/
    filename=['C:\Users\MSI\Documents\Our_project\Heart/posteriorcingulate-rh_trial0-rh.stc']
    [stc] = mne_read_stc_file(filename)
    %


    % anatomical labels, rh and lh:
    anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
        'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
        'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'
        'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
        'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
        'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}

    nlabel = length(anat_labels);


    for l = 1 : length(anat_labels)
        filesrc  = ['pca_',anat_labels{l},'_HER.mat'];
        %remember: python uses indexes 0 1 2 ...N-1
        X = load(filesrc);
        datasrc(l, :,:) = (X.pca_timecourse);
        clear X
    end

   

    cd(fpath0)
    T1 = readtable("align_result.csv");
    trial_num1 = T1.Var1;
    T2 = readtable("align_result2.csv");
    trial_num2 = T2.Var1;
    trial_num = [trial_num1', trial_num2'];
    %% Data HER

    
    time_sec = -1:(1/250):1;
    time_ms = time_sec * 1000;

    tmin = -0.3;
    tmax = 0.6;

    [~, idx_start] = min(abs(time_sec - tmin));
    [~, idx_end]   = min(abs(time_sec - tmax));

    dataHER_tpeaks = datasrc(:, :, idx_start:idx_end);

    size(dataHER_tpeaks,3)
    time_HER_ms = time_sec(idx_start:idx_end) * 1000;

    clear stc
    % I do not exclude any trials as t-peaks were selected in the 'tpeaks_events' code, and MNE-Python rejected some trials due to the previous LCMV analysis


    %% Concatenate HER epochs

    % dataHER_LCMV = cat(2, dataHERsrc, dataHERsrc2);
    %  time_HER_ms  % same for every epoch

    clear *HERsrc* datasti*

    filetag = [fpathsave,subj,'_dataHER_tpeaks.mat'];
    save(filetag, 'dataHER_tpeaks', 'time_HER_ms', 'trial_num')

    % dataHER has dimensions 26 labels x trials x samples
    % time_HER_ms has dimensions 1 x samples

end