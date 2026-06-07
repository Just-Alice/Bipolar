
clear all

cd 'C:\Users\MSI\Documents\Our_project\Heart\all_HER\'

load dataHERnorm_bipolar_avg.mat
load dataHERnorm_healthy_avg.mat

fpath = ['D:/MEG_Data_PhD/zhanx_10/HER/'];

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


    % Step 1: Identify empty cells
    emptyCells = cellfun(@isempty, dataHERnorm_healthy);

    % Step 2: Filter out empty cells
    dataHERnorm_healthy = dataHERnorm_healthy(~emptyCells);


    alltogether_h = cat(2, dataHERnorm_healthy{:});
    sizealltogther_h = size(alltogether_h)

    % Calculate group average and SEM for specific labels
    avrgmatrix_h = mean(alltogether_h(idx, :, :), 2, 'omitnan');
    avrgmatrix_h = squeeze(mean(avrgmatrix_h, 1, 'omitnan'));
    sem_matrix_h = std(alltogether_h(idx, :, :), 0, 2, 'omitnan');
    sem_matrix_h = squeeze(mean(sem_matrix_h, 1, 'omitnan')) / sqrt(size(alltogether_h, 2)); % sem matrix - sem for each number in the vector

    time = time';

    % Step 1: Identify empty cells
    emptyCells = cellfun(@isempty, dataHERnorm_bipolar);

    % Step 2: Filter out empty cells
    dataHERnorm_bipolar = dataHERnorm_bipolar(~emptyCells);


    alltogether_b = cat(2, dataHERnorm_bipolar{:});
    sizealltogther_b = size(alltogether_b);

    % Calculate group average and SEM for specific labels
    avrgmatrix_b = mean(alltogether_b(idx, :, :), 2, 'omitnan');
    avrgmatrix_b = squeeze(mean(avrgmatrix_b, 1, 'omitnan'));
    sem_matrix_b = std(alltogether_b(idx, :, :), 0, 2, 'omitnan');
    sem_matrix_b = squeeze(mean(sem_matrix_b, 1, 'omitnan')) / sqrt(size(alltogether_b, 2)); % sem matrix - sem for each number in the vector

    % Plot and save the group average HER with SEM
    cd(save2path);
    figure;
    plot(time, avrgmatrix_h, 'r');
    xlim([-0.2, 0.6])
    hold on;
    %errorbar(time, avrgmatrix, sem_matrix)
    fill([time; flipud(time)], [avrgmatrix_h + sem_matrix_h; flipud(avrgmatrix_h - sem_matrix_h)], 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    hold on
    plot(time, avrgmatrix_b, 'b');
    hold on;
    %errorbar(time, avrgmatrix, sem_matrix)
    fill([time; flipud(time)], [avrgmatrix_b + sem_matrix_b; flipud(avrgmatrix_b - sem_matrix_b)], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    legend('healthy', 'healthy', 'bipolar', 'bipolar')
    title(sprintf('HER healthy and bipolar LCMV %d - %d', idx(1), idx(2)));
    xlabel('Time');
    ylabel('Amplitude');

    cd C:\Users\MSI/Documents/Our_project/Heart/all_HER/LCMV_ROIs/
    fname = ['LCMV_', num2str(idx(1)), '_', num2str(idx(2)), '.png'];
    saveas(gcf, fname, 'png');
end
