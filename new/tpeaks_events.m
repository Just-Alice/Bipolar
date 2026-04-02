
clear all
%% This code is for generating an array of latency tpeaks for events channel

%% Load files for subject number ID ss

all = [2 4 6 8 10 12 14	16 17 18 19 20 22 23 24	27 28 29 31 32 35 36 38 40 42 44 45 46 47 51 52 53 54 55 56 57 58 59 61 63 64 65 67 68 69 70];
bipolar = [17 18 19 20 27 35 36 40 42 44 46 51 52 56 57 59 64 69 70];


addpath('/Volumes/KINGSTON/MEG_Data_PhD/');
addpath('/Users/marinaivanova/Documents/MATLAB/fieldtrip-20240603/')
ft_defaults


n = 38;
subj = ['zhanx_', num2str(n)];

fpath0 =  ['/Volumes/KINGSTON/MEG_Data_PhD/', subj, '/'];

block = '_b1';
subjname = ['zhanx_', num2str(n)];

fpath=['/Volumes/KINGSTON/MEG_Data_PhD/', subjname];
cd(fpath)
fif_filename = strcat(subjname, block, '_tsss_mc_trans.fif');


load(['tpeaks_', subjname, '_b1.mat'])
tpeaks_1 = tpeaks;
load(['tpeaks_', subjname, '_b2.mat'])
tpeaks_2 = tpeaks;


header = ft_read_header(fif_filename);

event = ft_read_event(fif_filename, 'chanindx', 311);   % stimulus channel has to be entered for each participant specifically
events_stimulus_1 = [event.sample; event.value];

% Collect indices of elements to remove
indices_to_remove = [];

for i = 1:length(events_stimulus_1)
    if events_stimulus_1(2, i) ~= 110
        indices_to_remove(end+1) = i;
    end
end

% Remove collected indices
events_stimulus_1(:, indices_to_remove) = [];

events_stimulus_1 = events_stimulus_1(1, :);

vector1 = events_stimulus_1;
vector2 = tpeaks_1;

nearest_previous_values_1 = find_nearest_previous_values(vector1, vector2);
%% for the second block

block = '_b2';

fif_filename2 = strcat(subjname, block, '_tsss_mc_trans.fif');

event = ft_read_event(fif_filename2, 'chanindx', 311);    % change stimulus channel

events_stimulus_2 = [event.sample; event.value];

% Collect indices of elements to remove
indices_to_remove = [];


if n == 22
    for i = 1:length(events_stimulus_2)
        if events_stimulus_2(2, i) ~= 110    % special case where block 1 was recorded twice
            indices_to_remove(end+1) = i;
        end
    end
else
    for i = 1:length(events_stimulus_2)
        if events_stimulus_2(2, i) ~= 40
            indices_to_remove(end+1) = i;
        end
    end
end

% Remove collected indices
events_stimulus_2(:, indices_to_remove) = [];

events_stimulus_2 = events_stimulus_2(1, :);

vector1 = events_stimulus_2;
vector2 = tpeaks_2;

nearest_previous_values_2 = find_nearest_previous_values(vector1, vector2);
%%
save_path = [ '/Volumes/KINGSTON/MEG_Data_PhD/', subjname, '/' ];
cd(save_path)

tpeaks_tokeep = cat(2, nearest_previous_values_1, nearest_previous_values_2);

%% Check Twave peaks latency values

load([fpath0,'latency_tpeaks.mat'])


% These values are all in milliseconds
thr1 = 400; % we only accept T wave peaks that precede the stimulus onset by more than thr1 milliseconds
thr2 = 1200; % exclude trials when the T wave peak in latency_tpeaks(:,2) is more than thr farther apart from latency_tpeaks(:,1)

delta_lat = diff(latency_tpeaks)';
max(delta_lat)  % check this is not much larger than 1000, as it could mean we skipped an T peak in the detection
ind_exc = find(delta_lat > thr2); % for instance
%Twave PEAK at least 400 apart from Stimulus

latency_tpeaks = latency_tpeaks'; %

ikeep = (find(latency_tpeaks(:,1)>thr1)); % first previous value
ikeep2 = (find(latency_tpeaks(:,2)>thr1)); % second previous value
ikeep2 = setdiff(ikeep2, ind_exc); % second previous value

% total indexes of Twave peaks to keep
ikeep_src = cat(1,ikeep, ikeep2); %

ikeep_src_b1 = ikeep_src(ikeep_src<=160)';
ikeep_src_b2 = ikeep_src(ikeep_src>160)';

% tpeaks for first and second previous values
tpeaks1_b1 = tpeaks_tokeep(1, ikeep(ikeep<=160));  % first prev values 1 block
tpeaks1_b2 = tpeaks_tokeep(1, ikeep(ikeep>160));  % first prev values 2 block
tpeaks2_b1 = tpeaks_tokeep(2, ikeep2(ikeep2<=160));    % second prev values 320 1 block
tpeaks2_b2 = tpeaks_tokeep(2, ikeep2(ikeep2>160));    % second prev values 320 2 block

tpeaks_final_b1 = [tpeaks1_b1, tpeaks2_b1]; % 
tpeaks_final_b2 = [tpeaks1_b2, tpeaks2_b2];


alignment_b1 = cat(1, tpeaks_final_b1, ikeep_src_b1); % saving the alignment of tpeaks and stimuli for later 
alignment_b2 = cat(1, tpeaks_final_b2, ikeep_src_b2);

save('tpeaks_final_b1.mat', 'tpeaks_final_b1')
save('tpeaks_final_b2.mat', "tpeaks_final_b2")

save('alignment_b1.mat', "alignment_b1");
save('alignment_b2.mat', "alignment_b2");

function [nearest_prev] = find_nearest_previous_values(vec1, vec2)

    % This function helps find the nearest previous T-peaks for stimuli
    sorted_vec2 = sort(vec2);
    len_vec1 = length(vec1);
    
    nearest_prev1 = NaN(1, len_vec1);
    nearest_prev2 = NaN(1, len_vec1);
    
    for i = 1:len_vec1
        value1 = vec1(i); % event stimulus ms
        
        idx_all = find(sorted_vec2 < value1); % which tpeaks go before stimulus event
        
        if ~isempty(idx_all) 
            nearest_prev1(i) = sorted_vec2(idx_all(end)); % first previous value before stimulus
            
            if length(idx_all) > 1
                nearest_prev2(i) = sorted_vec2(idx_all(end-1)); % second previous value before stimulus
            end
        end
    end

    nearest_prev = cat(1, nearest_prev1, nearest_prev2);
end


