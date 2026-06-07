
% Step 1: Add FieldTrip to your MATLAB path

addpath('/Users/marinaivanova/Documents/MATLAB/fieldtrip-20240603/')
ft_defaults; % Set FieldTrip defaults

% Step 2: Read the .fif file
% Replace 'your_file.fif' with the actual filename
n = 19;
block = '_b2';
subjname = ['zhanx_', num2str(n)];
    
% fpath=['/Volumes/T7/MEG_Data_PhD/', subjname];
% cd(fpath)

fif_filename = strcat(subjname, block, '_tsss_mc_trans.fif');
cfg = [];
cfg.dataset = fif_filename;


fpath=['/Volumes/T7/MEG_Data_PhD/', subjname];
cd(fpath)
% Read the header to get channel information
hdr = ft_read_header(cfg.dataset);

% Display available channels to identify ECG channels
disp(hdr.label);

% Step 3: Extract ECG data
% Assuming the ECG channel is labeled 'ECG' in the file. Adjust as necessary.
ecg_channel = 'ECG063'; % Replace with the actual label if different

% Define the configuration to read the ECG data
cfg = [];
cfg.dataset = fif_filename;
cfg.channel = {ecg_channel}; % Specify the ECG channel
cfg.continuous = 'yes';

% Read the data
data_ecg = ft_preprocessing(cfg);

% Step 4: Preprocess the ECG data if necessary
% For example, apply a bandpass filter to remove noise
cfg = [];
cfg.demean = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 40]; % Bandpass filter range in Hz
data_ecg_preproc = ft_preprocessing(cfg, data_ecg);


% Step 5: Visualize the ECG data using MATLAB's plot function
figure;
plot(data_ecg_preproc.time{1}, data_ecg_preproc.trial{1});
title('ECG Data');
xlabel('Time (s)');
ylabel('Amplitude (µV)');
grid on;
xlim([500 510]);

% Step 6: Save the preprocessed ECG data (optional)
save('preprocessed_ecg_data.mat', 'data_ecg_preproc');

%%

cfg = [];
cfg.demean = 'yes'; % Remove mean
cfg.bpfilter = 'yes'; % Bandpass filter
cfg.bpfreq = [0.5 40]; % Filter between 0.5 and 40 Hz

% Preprocess the data
%data_ecg_preproc = ft_preprocessing(cfg, ecg_data);

% Extract the ECG signal from the preprocessed data
ecg_signal = data_ecg_preproc.trial{1}(1, :); % Assuming single channel data
fs = data_ecg_preproc.fsample;

% Use MATLAB's findpeaks function for peak detection
[peaks, locs] = findpeaks(ecg_signal, 'MinPeakHeight', 0.5, 'MinPeakDistance', round(0.6*fs));

% Visualize the detected peaks
figure;
plot(ecg_signal);
hold on;
plot(locs, ecg_signal(locs), 'ro'); % Plot R-peaks in red
title('ECG Signal with Detected R-peaks');
xlabel('Samples');
ylabel('Amplitude');
legend('ECG Signal', 'R-peaks');
xlim([50000 60000]);


%% DETECT T-PEAKS

% Detect R-peaks
min_peak_height_R = 0.5 * max(ecg_signal); % 50% of max amplitude as an example
min_peak_distance_R = round(0.6 * fs); % Adjust based on your data
[pks_R, locs_R] = findpeaks(ecg_signal, 'MinPeakHeight', min_peak_height_R, 'MinPeakDistance', min_peak_distance_R);

% Visualize the detected R-peaks
figure;
plot(ecg_signal);
hold on;
plot(locs_R, ecg_signal(locs_R), 'ro'); % Plot R-peaks in red
title('ECG Signal with Detected R-peaks');
xlabel('Samples');
ylabel('Amplitude');
legend('ECG Signal', 'R-peaks');
xlim([50000 60000]);

% Detect T-peaks
% Typically, T-peaks occur after R-peaks and before the next R-peak
% Search within a window after each R-peak

t_peak_indices = [];
for i = 1:length(locs_R)-1
    % Define a search window between the current R-peak and the next R-peak
    search_window_start = locs_R(i) + round(0.2 * fs); % Start the search after the R-peak to avoid overlap
    search_window_end = locs_R(i) + round(0.5 * fs); % End the search before the next R-peak
    if search_window_end > length(ecg_signal)
        break;
    end
    search_window = ecg_signal(search_window_start:search_window_end);
    
    % Detect peaks in the search window
    [pks_T, locs_T] = findpeaks(search_window, 'MinPeakHeight', 0.15 * max(search_window)); % Adjust height threshold as needed
    if ~isempty(pks_T)
        % Assume the first detected peak is the T-peak
        t_peak_indices = [t_peak_indices, search_window_start + locs_T(1) - 1]; % Adjust index to original signal
    end
end

% Ensure there are T-peaks detected
if isempty(t_peak_indices)
    disp('No T-peaks detected. Adjust the MinPeakHeight for T-peaks.');
else
    % Plot the detected T-peaks
    plot(t_peak_indices, ecg_signal(t_peak_indices)); % Plot T-peaks in green
    legend('ECG Signal', 'R-peaks', 'T-peaks');
end

% Zoom in on a specific segment
xlim([50000 60000]);
%%

figure;
plot(ecg_signal);
hold on;
plot(t_peak_indices, ecg_signal(t_peak_indices), 'ro'); % Plot R-peaks in red
title('ECG Signal with Detected T-peaks');
xlabel('Samples');
ylabel('Amplitude');
legend('ECG Signal', 'T-peaks');
xlim([50000 60000]);

tpeaks = t_peak_indices;

save("tpeaks_zhanx_19_b2.mat", "tpeaks")

