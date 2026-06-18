

mOFC_lh_Marina = load('E:\subjects\zhanx_14\bem\bemlabels_HER\pca_medialorbitofrontal-lh_HER.mat');

mOFC_rh_Marina = load('E:\subjects\zhanx_14\bem\bemlabels_HER\pca_medialorbitofrontal-rh_HER.mat');

mOFC_lh_Maria = load('C:\Users\MSI\Downloads\mOFC_zhanx_14_pipeline2\pca_medialorbitofrontal-lh_HER.mat');

mOFC_rh_Maria = load('C:\Users\MSI\Downloads\mOFC_zhanx_14_pipeline2\pca_medialorbitofrontal-rh_HER.mat');


time = -1:(1/250):1;  % in seconds
figure;
plot(time,mean(mOFC_rh_Marina.pca_timecourse, 1))

hold on

plot(time,mean(mOFC_rh_Maria.pca_timecourse, 1))
title('mOFC rh')

figure;
plot(time,mean(mOFC_lh_Marina.pca_timecourse, 1))

hold on

plot(time,mean(mOFC_lh_Maria.pca_timecourse, 1))
title('mOFC lh')


