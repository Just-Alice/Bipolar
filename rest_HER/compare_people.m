


all_subj = [2 4 6 8 10 12 14 16 17 18 19 20 22 23 24 27 28 29 31 32 35 36 38 40 42 44 45 46 47 51 52 53 54 55 56 57 58 59 61 63 64 65 67 68 69 70];
bipolar = [17 18 19 20 27 35 36 40 42 44 46 49 51 52 56 57 59 64 69 70];
healthy = [2 4 6 8 10 12 14 16 22 23 24 28 29 31 32 38 45 47 53 54 55 58 61 63 65 67 68];  % healthy


HER_for_perm_pip2 = [];
HER_for_perm_pip1 = [];

for ss = all_subj

    fpath = ['/Volumes/KINGSTON/MEG_Data_PhD/zhanx_', num2str(ss), '/'];
    fpathsave = ['/Volumes/KINGSTON/MEG_Data_PhD/zhanx_', num2str(ss), '/HER/'];
    subj = sprintf('zhanx_%d',ss);
    filetag_1 = [fpathsave,subj,'_dataHER_tpeaks.mat'];
    load(filetag_1) %, 'dataHER_tpeaks', 'time_HER_ms'

    time_2 = time_HER_ms/1000; % seconds
    clear time_H*

    filetag_2 = [fpathsave,subj,'_dataHER_LCMV.mat'];
    load(filetag_2)

    time_1 = time_HER_ms/1000; % seconds
    clear time_H*
    
    % % Baseline interval:
    t1 = -0.250;
    t2 = -0.050;
    % t1 = -0.2;
    % t2 = -0.1;
    [~,xp1] = min(abs(time-t1));
    [~,xp2] = min(abs(time-t2));

%% Pipeline 2 for permutation testing

    newdataHER_tpeaks = mean(dataHER_tpeaks, 2, 'omitnan');
    newdataHER_tpeaks = squeeze(mean(newdataHER_tpeaks(9:10, :, :), 1))';
    HER_for_perm_pip2(end+1, :) = newdataHER_tpeaks;
    
%% Pipeline 2 plot

    % average data_HER_tpeaks across trials, 2nd dimension, then squeeze,
    % therefore dataGER_tpeaks will be 2D
    %   dataHER has dims:  26 labels x trials x samples
    mbas_tpeaks = mean(dataHER_tpeaks(:,:,xp1:xp2),3,'omitnan');  % -400, 0
    mbas_tpeaks = repmat(mbas_tpeaks, [1, 1, size(dataHER_tpeaks,3)]);
    sdbas_tpeaks = std(dataHER_tpeaks(:,:,xp1:xp2),0,3,'omitnan');
    sdbas_tpeaks = repmat(sdbas_tpeaks,[1, 1, size(dataHER_tpeaks,3)]);

    dataHERnorm_tpeaks = (dataHER_tpeaks - mbas_tpeaks)./sdbas_tpeaks; % (X - mean_bas) / std_bas   % 1) average across trials 2) baseline correction 3) stats
  
    % Individual plots of HER, after averaging across trials, and selecting
    % labels cACC, rACC
    x = squeeze(mean(mean(dataHERnorm_tpeaks(9:10,:,:),1,'omitnan'),2,'omitnan'));
    figure;plot(time_2,x)
    title(['Pipeline 2 mOFC zhanx ',num2str(ss)])
    xlabel('Time') 
    ylabel('Amplitude')
    % Ensure no variable named 'xlim' is in the workspace
    if exist('xlim', 'var')
        clear xlim;
    end
    hold on

%% Pipeline 1 for permutation testing
     
    
    newdataHER_LCMV = mean(dataHER_LCMV, 2, 'omitnan');
    newdataHER_LCMV = squeeze(mean(newdataHER_LCMV(9:10, :, :), 1))';
    HER_for_perm_pip1(end+1, :) = newdataHER_LCMV;

%% Pipeline 1 plot

    mbas_LCMV = mean(dataHER_LCMV(:,:,xp1:xp2),3,'omitnan');  % -400, 0
    mbas_LCMV = repmat(mbas_LCMV, [1, 1, size(dataHER_LCMV,3)]);
    sdbas_LCMV = std(dataHER_LCMV(:,:,xp1:xp2),0,3,'omitnan');
    sdbas_LCMV = repmat(sdbas_LCMV,[1, 1, size(dataHER_LCMV,3)]);

    dataHERnorm_LCMV = (dataHER_LCMV - mbas_LCMV)./sdbas_LCMV; % (X - mean_bas) / std_bas   % 1) average across trials 2) baseline correction 3) stats
  
    % Individual plots of HER, after averaging across trials, and selecting
    % labels cACC, rACC
    x = squeeze(mean(mean(dataHERnorm_LCMV(9:10,:,:),1,'omitnan'),2,'omitnan'));
    
    plot(time_1,x)
    title(['Pipeline 1 mOFC zhanx ',num2str(ss)])
    xlabel('Time') 
    ylabel('Amplitude')
    % Ensure no variable named 'xlim' is in the workspace
    if exist('xlim', 'var')
        clear xlim;
    end
% Set x-axis limits
    xlim([-0.5 0.7])
    cd /Users/marinaivanova/Documents/Our_project/Heart/all_HER/compare_HER_plots/
    saveas(gcf, ['Pipeline Comparison mOFC_', subj,'.png'], 'png')

    
%% Permutation test
% 
%     p_value = zeros(1, length(time));
% 
%     for np = 1:226
% 
%         p_value(np) = permutationTest(dataHER_tpeaks(:, np), dataHER_LCMV(:,np), 5000);
% 
%     end
% 
%     figure;
%     plot(time, p_value, 'LineWidth', 2, 'Color', [0 0.447 0.741]);
%     hold on;
% 
%     yline(0.05, '--r', 'LineWidth', 1.5, 'Label', 'p = 0.05', 'LabelHorizontalAlignment', 'left');
% 
%     xlabel('Time (s)', 'FontSize', 12);
%     ylabel('p-value', 'FontSize', 12);
%     title(['Permutation test - p-value - mOFC_ zhanx_', num2str(ss)], 'FontSize', 14, 'FontWeight', 'bold');
%     grid on;
%     set(gca, 'FontSize', 12, 'LineWidth', 1.2, 'Box', 'off');
% 
%     xlim([min(time) max(time)]);
%     ylim([0 1]);
% 
%     set(gcf, 'Color', 'w');
% 
% 
%     saveas(gcf, ['p_value_mOFC_fake_zhanx', num2str(ss)], 'png');
% 
%     filetag = ['p_value_mOFC_fake', num2str(ss), '.mat'];
%     save(filetag, 'p_value')
% 
% end
% 
% cd '/Users/marinaivanova/Documents/Our_project/Heart/'
% 
% time = time_2;
% % Stats interval:
% t1 = -0.3;
% t2 = 0.6;
% [~,xp1] = min(abs(time-t1));
% [~,xp2] = min(abs(time-t2));
% 
% time2plot = time(xp1 : xp2);
% 
% 
% % Preallocate p_value array
% p_value = zeros(1, length(time));
% 
% for np = 1:length(time)
% 
%     p_value(np) = permutationTest(dataHER_tpeaks(:, np), dataHER_LCMV(:,np), 5000);
 end
% 
% 
% figure;
% plot(time, p_value, 'LineWidth', 2, 'Color', [0 0.447 0.741]); 
% hold on;
% 
% yline(0.05, '--r', 'LineWidth', 1.5, 'Label', 'p = 0.05', 'LabelHorizontalAlignment', 'left');
% 
% xlabel('Time (s)', 'FontSize', 12);
% ylabel('p-value', 'FontSize', 12);
% title('Permutation test - p-value - mOFC - compare pipelines 1 & 2', 'FontSize', 14, 'FontWeight', 'bold');
% grid on;
% set(gca, 'FontSize', 12, 'LineWidth', 1.2, 'Box', 'off'); 
% xlim([min(time) max(time)]);
% ylim([0 1]);
% 
% set(gcf, 'Color', 'w'); 
% 
% 
% saveas(gcf, ['p_value_mOFC', num2str(ss)], 'png');
