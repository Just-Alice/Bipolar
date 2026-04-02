
%% PhD data preprocessing Fieldtrip:

% to obtain latency_tpeaks

addpath('/Users/marinaivanova/Documents/MATLAB/fieldtrip-20230428/')

ft_defaults

all = [2 4 6 8 10 12 14	16 17 18 19 20 22 23 24	27 28 29 31 32 35 36 38 40 42 44 45 46 47 51 52 53 54 55 56 57 58 59 61 63 64 65 67 68 69 70];

for n = all %: numsubj

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
    channel = find(strcmp(header.label, 'STI101'));
    

    event = ft_read_event(fif_filename, 'chanindx', channel);   % change the stimulus channel number

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

    latency_large_1 = zeros(2, length(events_stimulus_1));
    latency_large_2 = zeros(2, length(events_stimulus_1));

    for i = 1:length(nearest_previous_values_1)
        latency_tpeaks_1(1, i) = events_stimulus_1(i) - nearest_previous_values_1(i);
        idx = find(tpeaks_1 == nearest_previous_values_1(i));
        if idx == 1
            continue
        else
            latency_tpeaks_1(2, i) = events_stimulus_1(i) - tpeaks_1(idx-1);

        end
    end

%%
    block = '_b2';
    fif_filename = strcat(subjname, block, '_tsss_mc_trans.fif');

    event = ft_read_event(fif_filename, 'chanindx', channel);     % change the stimulus channel number

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
    
    for i = 1:length(nearest_previous_values_2)

        latency_tpeaks_2(1, i) = events_stimulus_2(i) - nearest_previous_values_2(i);
        idx = find(tpeaks_2 == nearest_previous_values_2(i));
        if idx == 1
            continue

        else
            latency_tpeaks_2(2, i) = events_stimulus_2(i) - tpeaks_2(idx-1); 
        end

    end
    %%
    save_path = [ '/Volumes/KINGSTON/MEG_Data_PhD/', subjname, '/' ];
    cd(save_path)

    latency_tpeaks = cat(2, latency_tpeaks_1, latency_tpeaks_2);

    mean_interval = mean(latency_tpeaks(1, :))
    save('latency_tpeaks','latency_tpeaks')
end

function nearest_previous_values = find_nearest_previous_values(vec1, vec2)
    
    sorted_vec2 = sort(vec2);
    len_vec1 = length(vec1);
    nearest_previous_values = NaN(1, len_vec1); 
    
    for i = 1:len_vec1
        value1 = vec1(i);
       
        idx = find(sorted_vec2 < value1, 1, 'last');
        
        if ~isempty(idx)
            nearest_previous_values(i) = sorted_vec2(idx);
        end
    end
end




