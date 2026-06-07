

% convert to FT
subj = 'zhanx_10';

fpath = ['/Volumes/T7/MEG_Data_PhD/', subj, '/HER/'];
cd(fpath)
load([subj,'_dataHER.mat'])

anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'  
'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}



ftdata_caudalantcin_lh = struct;
ftdata_caudalantcin_lh.time{1} = time_HER_ms;
ftdata_caudalantcin_lh.trial{1} = squeeze(dataHER(1,:,:));
ftdata_caudalantcin_lh.hdr.Fs = 250;
ftdata_caudalantcin_lh.hdr.nTrials = size(dataHER,2);
ftdata_caudalantcin_lh.label{1} = anat_labels;

cfg = [];
avgHER = ft_timelockanalysis(cfg, ftdata_caudalantcin_lh);
