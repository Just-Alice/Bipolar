

all_subj = [2 4 6 8 10 12 14 16 17 18 19 20 22 23 24 27 28 29 31 32 35 36 38 40 42 44 45 46 47 51 52 53 54 55 56 57 58 59 61 63 64 65 67 68 69 70];
indsubj_1 = [17 18 19 20 27 35 36 40 42 44 46 51 52 56 57 59 64 69 70]; % bipolar 20
indsubj_2 = [2 4 6 8 10 12 14 16 22 23 24 28 29 31 32 38 45 47 53 54 55 58 61 63 65 67 68];  % healthy 27
nSubj = length(all_subj);
nLabel = 26;
nTime  = 226;

group_data = zeros(nSubj, nLabel, nTime);


for s = all_subj
    
    fpathsave = ['D:/MEG_Data_PhD/zhanx_', num2str(s), '/HER/'];
    fpath = ['D:/MEG_Data_PhD/zhanx_', num2str(s), '/'];
    cd(fpathsave)
    subj = sprintf('zhanx_%d',s);
    filetag = [fpathsave,subj,'_dataHER_rest2.mat'];
    load(filetag) %, 'dataHER_tpeaks', 'time_HER_ms'  % переменная data: 26×456×501

    mean_epochs = squeeze(mean(dataHER_rest,2));   % 26 × 501
    
    if ismember(s, indsubj_1)
    
        group_data_bipolar(s,:,:) = mean_epochs;
    
    elseif ismember(s, indsubj_2)
    
        group_data_healthy(s,:,:) = mean_epochs;

    end
    
end


label_names = {'caudalanteriorcingulate-lh'; 'caudalanteriorcingulate-rh'; 'caudalmiddlefrontal-lh';...
    'caudalmiddlefrontal-rh'; 'isthmuscingulate-lh'; 'isthmuscingulate-rh'; 'lateralorbitofrontal-lh';...
    'lateralorbitofrontal-rh'; 'medialorbitofrontal-lh'; 'medialorbitofrontal-rh'; 'paracentral-lh'  
'paracentral-rh'; 'postcentral-lh'; 'postcentral-rh'; 'posteriorcingulate-lh'; 'posteriorcingulate-rh';...
'precentral-lh'; 'precentral-rh'; 'rostralanteriorcingulate-lh'; 'rostralanteriorcingulate-rh';'rostralmiddlefrontal-lh'; ...
'rostralmiddlefrontal-rh'; 'superiorfrontal-lh'; 'superiorfrontal-rh'; 'superiorparietal-lh'; 'superiorparietal-rh'}; % 26 штук

cd C:\Users\MSI\Documents\Our_project\Heart\all_HER\labels_rest\

for l = 1:nLabel
    
    label_matrix_bipolar = squeeze(group_data_bipolar(:,l,:));
     
    label_matrix_bipolar = label_matrix_bipolar(indsubj_1, :);
    
    save([label_names{l} '_bipolar_rest.mat'],'label_matrix_bipolar')
    
end

for l = 1:nLabel
    
    label_matrix_healthy = squeeze(group_data_healthy(:,l,:));
     
    label_matrix_healthy = label_matrix_healthy(indsubj_2, :);
    
    save([label_names{l} '_healthy_rest.mat'],'label_matrix_healthy')
    
end