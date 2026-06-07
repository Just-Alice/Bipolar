
bipolar = [17 18 19 20 27 35 36 40 42 44 46 51 52 56 57 59 64 69 70]; % Bipolar
healthy = [2 4 6 8 10 12 14 16 22 23 24 28 29 31 32 38 45 47 53 54 55 58 61 63 65 67 68];  % healthy


%% this is the code for permutation testing of bipolar and healthy variables
% 


%dataHER_healthy = zeros(18, 101);


for i = 1: length(healthy)

    subj = ['zhanx_', num2str(healthy(i))];

    fpath = ['E:/MEG_Data_PhD/', subj, '/HER/'];

    cd(fpath)
    
    load([subj, '_dataHER_LCMV.mat']) % dataHER
    
    time = time_HER_ms/1000; % seconds

    %Stats interval:
    t1 = -0.3;
    t2 = 0.6;
    [~,xp1] = min(abs(time-t1));
    [~,xp2] = min(abs(time-t2));

    time2plot = time(xp1 : xp2)

    dataHER_avg = squeeze(mean(dataHER_LCMV,2,'omitnan'));
    % size = labels x time

    mbas = mean(dataHER_avg(:,xp1:xp2),2,'omitnan');
    mbas = repmat(mbas,[1 size(dataHER_avg,2)]);

    sdbas = std(dataHER_avg(:,xp1:xp2),0,2,'omitnan');
    sdbas = repmat(sdbas,[1 size(dataHER_avg,2)]);

    dataHERnorm = (dataHER_avg - mbas)./sdbas;

    % Stats interval:
    % t1 = 0.1;
    % t2 = 0.5;
    % [~,xp1] = min(abs(time-t1));
    % [~,xp2] = min(abs(time-t2));
    %
    % dataHERnorm = dataHERnorm(:,:,xp1:xp2);
    %
    % time2plot = time(xp1 : xp2)

    newdataHER = squeeze(mean(dataHERnorm(9:10, :, :), 1))';

    dataHER_healthy(i, :) = newdataHER;


end



%dataHER_bipolar = zeros(15, 101);


for i = 1: length(bipolar)

    subj = ['zhanx_', num2str(bipolar(i))];

    fpath = ['E:/MEG_Data_PhD/',subj, '/HER/'];

    cd(fpath)
    
    load([subj, '_dataHER_LCMV.mat']) % dataHER

    time = time_HER_ms/1000;
    % Stats interval:
    t1 = -0.3;
    t2 = 0.6;
    [~,xp1] = min(abs(time-t1));
    [~,xp2] = min(abs(time-t2));

    time2plot = time(xp1 : xp2)

    dataHER_avg = squeeze(mean(dataHER_LCMV,2,'omitnan'));
    % size = labels x time

    mbas = mean(dataHER_avg(:,xp1:xp2),2,'omitnan');
    mbas = repmat(mbas,[1 size(dataHER_avg,2)]);

    sdbas = std(dataHER_avg(:,xp1:xp2),0,2,'omitnan');
    sdbas = repmat(sdbas,[1 size(dataHER_avg,2)]);

    dataHERnorm = (dataHER_avg - mbas)./sdbas;
    % newdataHER = newdataHER(:,:,xp1:xp2);
    newdataHER = squeeze(mean(dataHERnorm(9:10, :, :), 1))';
    
    dataHER_bipolar(i, :) = newdataHER;


end

cd 'C:\Users\MSI\Documents\Our_project\Heart\'

% Preallocate p_value array
p_value = zeros(1, length(time));

for np = 1:226

    p_value(np) = permutationTest(dataHER_bipolar(:, np), dataHER_healthy(:,np), 5000);

end

cd 'C:\Users\MSI\Documents\Our_project\Heart\all_HER\'

figure;
plot(time, p_value, 'LineWidth', 2, 'Color', [0 0.447 0.741]); 
hold on;

yline(0.05, '--r', 'LineWidth', 1.5, 'Label', 'p = 0.05', 'LabelHorizontalAlignment', 'left');

xlabel('Time (s)', 'FontSize', 12);
ylabel('p-value', 'FontSize', 12);
title('Permutation test - p-value - mOFC', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.2, 'Box', 'off'); 
xlim([min(time) max(time)]);
ylim([0 1]);

set(gcf, 'Color', 'w'); 


saveas(gcf, 'p_value_mOFC', 'png');

filetag = ['p_value_mOFC.mat'];
save(filetag, 'p_value')


