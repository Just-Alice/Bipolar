nTrials = size(pca_timecourse_lh,1);


for i = 1:nTrials

    figure;
    plot(pca_timecourse_lh(i, :))
    title(['Trial ' num2str(i)])
    xlabel('Time');
    ylabel('Amplitude');

    % drawnow;
    cd C:\Users\MSI\Documents\Our_project\Heart\Cleaning\new_tpeaks\zhanx_54/lh/
    fname = [num2str(i), '.png'];
    saveas(gcf, fname, 'png');
    close all

end

%%
% 
% pca_timecourse = pca_timecourse_lh;
% pca_timecourse([214 215 226 227], :) = [];

% cd /Volumes/KINGSTON/subjects/zhanx_67/bem/bemlabels_HER/
% save('pca_medialorbitofrontal-lh_HER.mat', 'pca_timecourse');