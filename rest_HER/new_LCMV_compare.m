% Compare visually one by one the LCMV and eLoreta HEP epochs average


% First plot eLoreta
clear all
close all

ss = 10;

save2path = ['/Users/marinaivanova/Documents/Our_project/Heart/all_HER/'];

% anatomical labels, rh and lh:
anat_labels = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'  
'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}


fpathsave = ['/Volumes/T7/MEG_Data_PhD/zhanx_', num2str(ss), '/HER/']
cd(fpathsave)
subj = sprintf('zhanx_%d',ss);
filetag = [fpathsave,subj,'_dataHER_eloreta.mat'];
load(filetag) %, 'dataHER', 'time_HER_ms', 'Latkeep_sample', 'Latkeep_ms', 'latency_tpeaks', 'latency_tpeaks_sample')

time = time_HER_ms/1000; % seconds
clear time_H*

%% mOFC

% % Baseline interval:
t1 = -0.250;
t2 = -0.050;

[~,xp1] = min(abs(time-t1));
[~,xp2] = min(abs(time-t2));

%   dataHER has dims:  26 labels x trials x samples
mbas = mean(dataHER_eLoreta(:,:,xp1:xp2),3,'omitnan');  % -400, 0
mbas = repmat(mbas, [1, 1, size(dataHER_eLoreta,3)]);
sdbas = std(dataHER_eLoreta(:,:,xp1:xp2),0,3,'omitnan');
sdbas = repmat(sdbas,[1, 1, size(dataHER_eLoreta,3)]);

dataHERnorm_eLoreta = (dataHER_eLoreta - mbas)./sdbas; % (X - mean_bas) / std_bas

x = squeeze(mean(mean(dataHERnorm_eLoreta(9:10,:,:),1,'omitnan'),2,'omitnan'));    % LABEL which label to plot
figure;plot(time,x)
title(['Heartbeat evoked response mOFC eLoreta zhanx ',num2str(ss)])              % change the name
xlabel('Time')
ylabel('Amplitude')

% Ensure no variable named 'xlim' is in the workspace
if exist('xlim', 'var')
    clear xlim;
end

% % Set x-axis limits
% %xlim([0 0.2])
% saveas(gcf, ['Panel_HER_cACC_eLoreta', subj,'.png'], 'png')

hold on


% Then plot LCMV

filetag = [fpathsave, subj, '_dataHER_new_LCMV.mat'];
load(filetag)

 %   dataHER has dims:  26 labels x trials x samples
 mbas = mean(dataHER_LCMV(:,:,xp1:xp2),3,'omitnan');  % -400, 0
 mbas = repmat(mbas, [1, 1, size(dataHER_LCMV,3)]);
 sdbas = std(dataHER_LCMV(:,:,xp1:xp2),0,3,'omitnan');
 sdbas = repmat(sdbas,[1, 1, size(dataHER_LCMV,3)]);

 dataHERnorm_LCMV = (dataHER_LCMV - mbas)./sdbas; 

 x = squeeze(mean(mean(dataHERnorm_LCMV(9:10,:,:),1,'omitnan'),2,'omitnan')); %choose the labels to plot
 
 plot(time,x)
 title(['Heartbeat evoked response new mOFC LCMV and eLoreta zhanx ',num2str(ss)]) % final plot
 xlabel('Time')
 ylabel('Amplitude')
 % Ensure no variable named 'xlim' is in the workspace
 if exist('xlim', 'var')
     clear xlim;
 end
 legend('eLoreta', 'new LCMV')
 % Set x-axis limits
 %xlim([0 0.2])
 saveas(gcf, ['Panel_HER_mOFC_compare_', subj,'.png'], 'png')


%% cACC



% % Baseline interval:
t1 = -0.250;
t2 = -0.050;

[~,xp1] = min(abs(time-t1));
[~,xp2] = min(abs(time-t2));

%   dataHER has dims:  26 labels x trials x samples
mbas = mean(dataHER_eLoreta(:,:,xp1:xp2),3,'omitnan');  % -400, 0
mbas = repmat(mbas, [1, 1, size(dataHER_eLoreta,3)]);
sdbas = std(dataHER_eLoreta(:,:,xp1:xp2),0,3,'omitnan');
sdbas = repmat(sdbas,[1, 1, size(dataHER_eLoreta,3)]);

dataHERnorm_eLoreta = (dataHER_eLoreta - mbas)./sdbas; % (X - mean_bas) / std_bas

x = squeeze(mean(mean(dataHERnorm_eLoreta(1:2,:,:),1,'omitnan'),2,'omitnan'));    % LABEL which label to plot
figure;plot(time,x)
title(['Heartbeat evoked response cACC eLoreta zhanx ',num2str(ss)])              % change the name
xlabel('Time')
ylabel('Amplitude')

% Ensure no variable named 'xlim' is in the workspace
if exist('xlim', 'var')
    clear xlim;
end

% % Set x-axis limits
% %xlim([0 0.2])
% saveas(gcf, ['Panel_HER_cACC_eLoreta', subj,'.png'], 'png')

hold on


% Then plot LCMV

filetag = [fpathsave, subj, '_dataHER_new_LCMV.mat'];
load(filetag)

 %   dataHER has dims:  26 labels x trials x samples
 mbas = mean(dataHER_LCMV(:,:,xp1:xp2),3,'omitnan');  % -400, 0
 mbas = repmat(mbas, [1, 1, size(dataHER_LCMV,3)]);
 sdbas = std(dataHER_LCMV(:,:,xp1:xp2),0,3,'omitnan');
 sdbas = repmat(sdbas,[1, 1, size(dataHER_LCMV,3)]);

 dataHERnorm_LCMV = (dataHER_LCMV - mbas)./sdbas; 

 x = squeeze(mean(mean(dataHERnorm_LCMV(1:2,:,:),1,'omitnan'),2,'omitnan')); %choose the labels to plot
 
 plot(time,x)
 title(['Heartbeat evoked response new cACC LCMV and eLoreta zhanx ',num2str(ss)]) % final plot
 xlabel('Time')
 ylabel('Amplitude')
 % Ensure no variable named 'xlim' is in the workspace
 if exist('xlim', 'var')
     clear xlim;
 end
 legend('eLoreta', 'new LCMV')
 % Set x-axis limits
 %xlim([0 0.2])
 saveas(gcf, ['Panel_HER_cACC_compare_', subj,'.png'], 'png')


%% rACC

% % Baseline interval:
t1 = -0.250;
t2 = -0.050;

[~,xp1] = min(abs(time-t1));
[~,xp2] = min(abs(time-t2));

%   dataHER has dims:  26 labels x trials x samples
mbas = mean(dataHER_eLoreta(:,:,xp1:xp2),3,'omitnan');  % -400, 0
mbas = repmat(mbas, [1, 1, size(dataHER_eLoreta,3)]);
sdbas = std(dataHER_eLoreta(:,:,xp1:xp2),0,3,'omitnan');
sdbas = repmat(sdbas,[1, 1, size(dataHER_eLoreta,3)]);

dataHERnorm_eLoreta = (dataHER_eLoreta - mbas)./sdbas; % (X - mean_bas) / std_bas

x = squeeze(mean(mean(dataHERnorm_eLoreta(19:20,:,:),1,'omitnan'),2,'omitnan'));    % LABEL which label to plot
figure;plot(time,x)
title(['Heartbeat evoked response rACC eLoreta zhanx ',num2str(ss)])              % change the name
xlabel('Time')
ylabel('Amplitude')

% Ensure no variable named 'xlim' is in the workspace
if exist('xlim', 'var')
    clear xlim;
end

hold on


% Then plot LCMV

filetag = [fpathsave, subj, '_dataHER_new_LCMV.mat'];
load(filetag)

 %   dataHER has dims:  26 labels x trials x samples
 mbas = mean(dataHER_LCMV(:,:,xp1:xp2),3,'omitnan');  % -400, 0
 mbas = repmat(mbas, [1, 1, size(dataHER_LCMV,3)]);
 sdbas = std(dataHER_LCMV(:,:,xp1:xp2),0,3,'omitnan');
 sdbas = repmat(sdbas,[1, 1, size(dataHER_LCMV,3)]);

 dataHERnorm_LCMV = (dataHER_LCMV - mbas)./sdbas; 

 x = squeeze(mean(mean(dataHERnorm_LCMV(19:20,:,:),1,'omitnan'),2,'omitnan')); %choose the labels to plot
 
 plot(time,x)
 title(['Heartbeat evoked response new rACC LCMV and eLoreta zhanx ',num2str(ss)]) % final plot
 xlabel('Time')
 ylabel('Amplitude')
 % Ensure no variable named 'xlim' is in the workspace
 if exist('xlim', 'var')
     clear xlim;
 end
 legend('eLoreta', 'new LCMV')
 % Set x-axis limits
 %xlim([0 0.2])
 saveas(gcf, ['Panel_HER_rACC_compare_', subj,'.png'], 'png')







