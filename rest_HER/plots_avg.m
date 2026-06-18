
clear all

cd 'C:\Users\MSI\Documents\Our_project\Heart\all_HER\'

load dataHERnorm_bipolar_avg.mat
load dataHERnorm_healthy_avg.mat

fpath = ['E:\MEG_Data_PhD\zhanx_10\HER/'];

save2path = ['C:\Users\MSI/Documents/Our_project/Heart/all_HER/timeanalysis/'];

anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'
    'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
    'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
    'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}

for n = 1:2:26

    idx = n:(n+1);
    fname = ['LCMV_', num2str(idx(1)), '_', num2str(idx(2)), '.png'];
    cd(fpath)
    load zhanx_10_dataHER_LCMV.mat
    clear dataHER_LCMV latency_tpeaks latency_tpeaks_sample Latkeep_sample Latkeep_ms    % saving time_HER_ms

    time = time_HER_ms/1000; % seconds
    clear time_H*


    emptyCells_h = cellfun(@isempty, dataHERnorm_healthy);
    emptyCells_b = cellfun(@isempty, dataHERnorm_bipolar);

    dataHERnorm_healthy = dataHERnorm_healthy(~emptyCells_h);
    dataHERnorm_bipolar = dataHERnorm_bipolar(~emptyCells_b);


    %% HEALTHY

    alltogether_h = cat(3, dataHERnorm_healthy{:});
    % size = labels x time x subjects

    % Average LH/RH
    roi_h = squeeze(mean(alltogether_h(idx,:,:),1,'omitnan'));
    % size = time x subjects

    % Mean across subjects
    avrgmatrix_h = mean(roi_h,2,'omitnan');
    % size = time x 1

    % SEM across subjects
    sem_matrix_h = std(roi_h,0,2,'omitnan') ./ sqrt(size(roi_h,2));
    % size = time x 1


    %% BIPOLAR

    alltogether_b = cat(3, dataHERnorm_bipolar{:});
    % size = labels x time x subjects

    % Average LH/RH
    roi_b = squeeze(mean(alltogether_b(idx,:,:),1,'omitnan'));
    % size = time x subjects

    % Mean across subjects
    avrgmatrix_b = mean(roi_b,2,'omitnan');
    % size = time x 1

    % SEM across subjects
    sem_matrix_b = std(roi_b,0,2,'omitnan') ./ sqrt(size(roi_b,2));
    % size = time x 1

    time = time';


    %% PLOT

    cd(save2path);

    figure;

    plot(time, avrgmatrix_h, 'r', 'LineWidth', 2);
    hold on;

    fill([time; flipud(time)], ...
        [avrgmatrix_h + sem_matrix_h; flipud(avrgmatrix_h - sem_matrix_h)], ...
        'r', ...
        'FaceAlpha', 0.2, ...
        'EdgeColor', 'none');

    plot(time, avrgmatrix_b, 'b', 'LineWidth', 2);

    fill([time; flipud(time)], ...
        [avrgmatrix_b + sem_matrix_b; flipud(avrgmatrix_b - sem_matrix_b)], ...
        'b', ...
        'FaceAlpha', 0.2, ...
        'EdgeColor', 'none');

    xlim([-0.2 0.6])
    ylim([-2 2])

    legend('healthy', '', 'bipolar', '')

    title(sprintf('HER healthy and bipolar LCMV %d - %d', idx(1), idx(2)));

    xlabel('Time');
    ylabel('Amplitude (SD)');
    % size = time x 1
    % Plot and save the group average HER with SEM

    cd(save2path);
    figure;
    figure;
    hold on;

    % SEM first
    fill([time; flipud(time)], ...
        [avrgmatrix_h + sem_matrix_h; flipud(avrgmatrix_h - sem_matrix_h)], ...
        'r', ...
        'FaceAlpha', 0.2, ...
        'EdgeColor', 'none');

    fill([time; flipud(time)], ...
        [avrgmatrix_b + sem_matrix_b; flipud(avrgmatrix_b - sem_matrix_b)], ...
        'b', ...
        'FaceAlpha', 0.2, ...
        'EdgeColor', 'none');

    % Then lines on top
    plot(time, avrgmatrix_h, 'r', 'LineWidth', 2);

    plot(time, avrgmatrix_b, 'b', 'LineWidth', 2);

    xlim([-0.2 0.6])
    ylim([-2 2])

    legend('healthy SEM', 'bipolar SEM', 'healthy', 'bipolar')

    title(sprintf('HER healthy and bipolar LCMV %d - %d', idx(1), idx(2)));

    xlabel('Time');
    ylabel('Amplitude (SD)');
    
    saveas(gcf, fullfile(save2path, ...
       sprintf('HER_healthy_vs_bipolar_LCMV_%d_%d.png', ...
       idx(1), idx(2))));
end
