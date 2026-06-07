% plotting HER

subj = 'zhanx_10';

fpath0 =  ['/Volumes/T7/MEG_Data_PhD/', subj, '/HER/']; 
cd(fpath0)

load([subj,'_dataHER_LCMV.mat'])
% 
mOFC_LCMV = squeeze(mean(mean(dataHER_LCMV(9:10,:,:), 1, 'omitnan'), 2, 'omitnan'));

plot(time,mOFC_LCMV)

title('zhanx 10: medial OFC LCMV');        % Add a title
xlabel('Times'); % Label the x-axis
ylabel('Amplitude'); % Label the y-axis
saveas(gcf, 'zhanx_10_mOFC_LCMV.jpeg');

%%
time = time_HER_ms/1000; % seconds
clear time_H*

% Baseline interval:
t1 = -0.250;
t2 = -0.050;
[~,xp1] = min(abs(time-t1));
[~,xp2] = min(abs(time-t2));

%   dataHER has dims:  26 labels x trials x samples
mbas = mean(dataHER_eLoreta(:,:,xp1:xp2),3,'omitnan');  % -400, 0
mbas = repmat(mbas, [1, 1, size(dataHER_eLoreta,3)]);
sdbas = std(dataHER_eLoreta(:,:,xp1:xp2),0,3,'omitnan');
sdbas = repmat(sdbas,[1, 1, size(dataHER_eLoreta,3)]);

dataHERnorm = (dataHER_eLoreta - mbas)./sdbas; % (X - mean_bas) / std_bas

% Individual plots of HER, after averaging across trials, and selecting
% labels cACC, rACC
x = squeeze(mean(mean(dataHERnorm(1:2,:,:),1,'omitnan'),2,'omitnan'));
figure;plot(time,x)
title(['Heartbeat evoked response cACC zhanx 10'])
xlabel('Time')
ylabel('Amplitude')
% Ensure no variable named 'xlim' is in the workspace
if exist('xlim', 'var')
    clear xlim;
end
% Set x-axis limits
%xlim([0 0.2])
saveas(gcf, ['Panel_HER_cACC_eLoreta_', subj,'.png'], 'png')
    





