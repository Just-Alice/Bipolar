
clear all
subj = 54;
bad_epochs = [189, 190, 191, 192, 193, 194, 195, 196, 197, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499];


fpath = ['E:\subjects\zhanx_', num2str(subj), '/bem/bemlabels_HER/'];
cd(fpath)
files = dir('*_HER.mat');

dir
for i = 1:length(files)
    fprintf(files(i).name)
    load(files(i).name)
    pca_timecourse(bad_epochs, :) = [];
    cd(fpath)
    save(files(i).name, 'pca_timecourse')
end

