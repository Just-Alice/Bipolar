%%

clear all
%% Load files for subject number ID ss


n = 10;
subj = ['zhanx_', num2str(n)];
% path to EKG latency peaks
fpath0 =  ['/Volumes/KINGSTON/MEG_Data_PhD/', subj, '/']; 

cd(fpath0)
mkdir HER
% path to save dataHER after preprocessing
fpathsave = ['/Volumes/KINGSTON/MEG_Data_PhD/', subj '/HER/'];
%% Load files for subject number ID ss

addpath('/Volumes/KINGSTON/MEG_Data_PhD/');
addpath('/Users/marinaivanova/Documents/MATLAB/fieldtrip-20240603/')
ft_defaults


subj = sprintf('zhanx_%d',n); 

% path to ITI bemlabels
fpath = ['/Volumes/KINGSTON/subjects/', subj, '/bem/bemlabels_HER/'];   
f1 = dir(fpath)

% if length(f1) == 0
%     fpath = ['/Volumes/T7/bemlabels_ITI/', subj, '/bem/bemlabels/'];  
%     f2 = dir([fpath,'*ITI.*'])
% end


%% Check Twave peaks latency values 

cd(['/Volumes/KINGSTON/subjects/', subj,'/bem/bemlabels_ITI/'])

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


if n == 22
     for l = 1 : length(anat_labels)
             filesrc  = ['pca_',anat_labels{l},'_HER.mat'];
             %remember: python uses indexes 0 1 2 ...N-1
             X = load(filesrc);  
             % select block2 only
             datasrc(l, :,:) = (X.pca_timecourse(161:end,:));
             clear X
     end   
elseif n == 58
     for l = 1 : length(anat_labels)
             filesrc  = ['pca_',anat_labels{l},'_HER.mat'];
             %remember: python uses indexes 0 1 2 ...N-1
             X = load(filesrc);  
             % select block2 only
             datasrc(l, :,:) = (X.pca_timecourse(161:end,:));
             clear X
     end   
else
    for l = 1 : length(anat_labels)
             filesrc  = ['pca_',anat_labels{l},'_HER.mat'];
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

pre = 300*250/1000; 
post = 600*250/1000;
xp = 1:size(datasrc,3);
time_HER_ms = (xp-pre-1)*1000/250;

cd(fpath0)
T1 = readtable("align_result.csv");
trial_num1 = T1.Var1;
T2 = readtable("align_result2.csv");
trial_num2 = T2.Var1;
trial_num = [trial_num1', trial_num2'];
%% Data HER

dataHER_tpeaks = datasrc; % I do not exclude any trials as t-peaks were selected in the 'tpeaks_events' code, and MNE-Python rejected some trials due to the previous LCMV analysis


 %% Concatenate HER epochs
 
% dataHER_LCMV = cat(2, dataHERsrc, dataHERsrc2);
%  time_HER_ms  % same for every epoch

clear *HERsrc* datasti*

filetag = [fpathsave,subj,'_dataHER_tpeaks.mat'];
save(filetag, 'dataHER_tpeaks', 'time_HER_ms', 'trial_num')

% dataHER has dimensions 26 labels x trials x samples
% time_HER_ms has dimensions 1 x samples