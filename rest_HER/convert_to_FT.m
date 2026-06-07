%  prepare_stc_to_ft heartbeats
%% Load MNEpython files

% ss number of participant in subject list: 
%    mysubj = setdiff(1:N, [15, 26, 30]);


subj = 'zhanx_10';

fpath='/Users/marinaivanova/Documents/Our_project/Heart/total_ordered_stim/';
cd([fpath,'' subj '/Processing/python/'])
load total_ordered_matched_events_stim.mat % total_ordered_matched_events  ordered_ind1keep ordered_ind2keep outcomepy

% cd(['/Volumes/T7/bemlabels_ITI/', subj, '/'])
cd(['/Users/marinaivanova/Documents/Our_project/Heart/'])

% Load STC to create a fieldtrip structure template with the correct time vector
% 

 filename='posteriorcingulate-rh_trial0-rh.stc'
 [stc] = mne_read_stc_file(filename);
 time = stc.tmin:stc.tstep:2;    % seconds
 clear stc
% Latency of outcome event:
x = abs(time - 0); xp = find(x==min(x)); %251


% anatomical labels, rh and lh:

anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'  
'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}

cd(['/Volumes/T7/MEG_Data_PhD/', subj, '/HER/'])


nlabel = length(anat_labels);
% datasrc = nan(nlabel, total_ordered_matched_events, 376); 

load ([subj, '_dataHER.mat'])
nsample = length(time_HER_ms);
datasrc = squeeze(dataHER(1, :, :));

warning('Use total_ordered_matched_events works well except in subjects in which we removed manually epochs in Matlab, after MNEpython')




        % 
        % for l = 1 : length(anat_labels)
        %  filesrc  = ['pca_',anat_labels{l},'.mat'];
        %  %remember: python uses indexes 0 1 2 ...N-1
        %  X = load(filesrc);  
        %  datasrc(l, :,:) = (X.pca_timecourse);
        %  clear X
        % end
        % 




s = size(datasrc)
totsample = nsample*s(2)


%% LOAD TEMPLATE FIELDTRIP FILE AND POPPULATE WITH MY STC LABEL TRIALS


% load /home/mherrojo/eeg/matlab/cuttingEEG/conv_thomas_meg/feb22/Ft_pp_TFR/Outcome_locked/zhanx_2/Processed/zhanx_2_data_clean_cont_b1b2.mat

cd(['/Users/marinaivanova/Desktop/code/matlab_code 2/'])

temp = load ('template_preprocessed_python2spm.mat')

ftdata = temp.newftdata; clear temp*


label = struct([]);

for l = 1 : nlabel
    label{l,1} = ftdata.label{l};
end

sampleinfo = [1 totsample]

nlabel = size(datasrc, 1);
epochs = size(datasrc, 2);
samples = size(datasrc, 3);
totsample = epochs * samples;

ytot = zeros(nlabel, totsample);

for l = 1:nlabel
    x = squeeze(datasrc(l,:,:));
    y = reshape(x', [1 totsample]); 
    ytot(l,:) = y;
end

% ytot = nan(nlabel, totsample);
% 
% for l = 1 : nlabel
% 
%     x = squeeze(datasrc(l,:,:));
%     y = reshape(x', [1 376]); 
%     % double-checked this, it is correct: [epoch] [epoch] ...
%     ytot(l,:)  = y;
% 
% end

trial =  struct([]);
trial{1} = dataHER;

time =  struct([]); 
time{1} = time_HER_ms(1:s(1));

newftdata = [];
newftdata.label = label;
newftdata.sampleinfo  = sampleinfo;
newftdata.trial = trial;
newftdata.time = time;
newftdata.cfg = ftdata.cfg;
newftdata.hdr = ftdata.hdr;


Fs = 250 %=round(sampleinfo(end)/((newftdata.time{1}(end) - newftdata.time{1}(1))));

% include latency of outcome event in newftdata.cfg.latevent

% latevent = xp  + nsample*([1:total_ordered_matched_events]-1);
% %checks 
% if unique(diff(latevent))~= nsample | (totsample-latevent(end))~=500
% error('latency vector of outcome event incorrect')
% end

%newftdata.cfg.latevent = latevent;

% 
% cd /home/mherrojo/eeg/matlab/cuttingEEG/conv_bipolar/source/Ft_pp_TFR/Outcome_locked
% mkdir(subj)
% cd(subj)
% !mkdir Processed


fpathsave = ['/Volumes/T7/MEG_Data_PhD/', subj, '/HER/']
filetag = [fpathsave,subj,'_FT.mat'];
save(filetag, 'newftdata')

cfg = [];
avgHER = ft_timelockanalysis(cfg, newftdata);







