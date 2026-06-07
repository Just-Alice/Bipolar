#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  5 21:04:25 2024

@author: marinaivanova
"""

import os
import os.path as op
import pyvista
from matplotlib import pyplot as plt
import numpy as np
import mne
mne.viz.set_3d_backend("pyvista")
from mne.io import Raw
import plotly.io as pio
import neurokit2 as nk
import csv
from scipy.io import savemat
import pandas as pd
#%%

all = [2, 4, 6, 8, 10, 12, 14, 16, 17, 18, 19, 20, 22, 23, 24, 27, 28, 29, 31, 32, 35, 36, 38, 40, 42, 44, 45, 46, 47, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 63, 64, 65, 67, 68, 69, 70]
# bipolar = [17 18 19 20 27 35 36 40 42 44 46 51 52 56 57 59 64 69 70];

all_rest = [2]
blocks = ['b0', 'b1', 'b2']

interval = pd.DataFrame()

for n in all:
    for block in blocks:
    
        subject = op.join('zhanx_' + str(n))
        sample_dir = op.join('D:\\MEG_Data_PhD\\', subject)
        
        raw_fname = op.join(sample_dir, subject + '_' + block + '_tsss_mc_trans.fif')
        
        raw            =  mne.io.read_raw_fif(raw_fname, preload=True)
        raw.info['dev_head_t']
        
        
        
        #%%
        
        # take one ECG channel
        
        ECG = raw.copy().pick(picks=["ecg"])
        ecg_signal = raw['ECG063'][0]
        ecg = np.reshape(ecg_signal, np.size(ecg_signal))
        
        del raw
        
        #%%
        
        # Retrieve ECG data from data folder
        
        # Extract R-peaks locations
        
        signals, info = nk.ecg_process(ecg, sampling_rate=1000, method = 'neurokit')
        
        
        # # if ECG is inverted
        
        short_ecg = ecg[:20 * 1000]

        _, is_inverted = nk.ecg_invert(
            short_ecg,
            sampling_rate=1000,
            show=False
        )

        if is_inverted:
            ecg, _ = nk.ecg_invert(
            ecg,
            sampling_rate=1000,
            show=False
        )

        # try cleaning ecg
        
        ecg = nk.ecg_clean(ecg, sampling_rate=1000)
        
        ecg = nk.signal_filter(ecg, sampling_rate=1000, lowcut = 0.5, highcut = 40)
        
        _, rpeaks = nk.ecg_peaks(ecg, sampling_rate=1000, method = 'neurokit')
        
        
        # # Delineate the ECG signal
        
        # _, waves_peak = nk.ecg_delineate(ecg, rpeaks, sampling_rate=1000, method='peak')
        # # Visualize R-peaks in ECG signal
        # plot = nk.events_plot(rpeaks['ECG_R_Peaks'], ecg)
        
        # # Plot the ECG with T-wave detections
        # plot_1 = nk.ecg_plot(signals)
        
        
        # # Save the figure
        path2save = op.join('D:/MEG_Data_PhD/' + subject + '/HER/')
        
        os.makedirs(path2save, exist_ok=True)
        os.chdir(path2save)
        
        #plot_1.savefig('t_wave_detection.png')
        
        #plot = nk.events_plot([waves_peak['ECG_T_Peaks'][:3]])
        
        epochs = nk.ecg_segment(ecg, rpeaks=None, sampling_rate=1000, show=True)
        
        # #%%
        
        # # Zooming into the first 5 R-peaks
        # plot = nk.events_plot(rpeaks['ECG_R_Peaks'][:10], ecg[0:10000])
        
        #%%
        
        # Delineate the ECG signal
        
        # Zooming into the first 3 R-peaks, with focus on T_peaks, P-peaks, Q-peaks and S-peaks
        # plot = nk.events_plot(waves_peak['ECG_T_Peaks'][:7], ecg[0:5000])
        
        #%%
        
        timings = ECG.times
        
        
        #%%
        
        if n == 2 and block == 'b0':
            interval = nk.ecg_intervalrelated(signals)
            interval['block'] = block
            interval['subject'] = subject
        else:
            
            subject = 'zhanx_' + str(n)

            interval1 = nk.ecg_intervalrelated(signals)
            
            # добавляем нужные колонки
            interval1['block'] = block
            interval1['subject'] = subject
            
            # накапливаем
            interval = pd.concat([interval, interval1], ignore_index=True)
        
        
        
        
        
        #%%
        
        # tpeaks = waves_peak['ECG_T_Peaks']
        
        # rpeaks = rpeaks['ECG_R_Peaks']
        
        os.chdir('D:/MEG_Data_PhD/' + subject + '/')
        
            
        #%%
        
        
        # fname = op.join('tpeaks_' + subject + '_' + block + '.mat')
        
        # mydict = {'tpeaks' : tpeaks}
                  
        # savemat(fname, mydict)
        
        #%%
        
        # fname = op.join('rpeaks_' + subject + '_' + block + '.mat')
        
        # mydict = {'rpeaks' : rpeaks}
                  
        # savemat(fname, mydict)

os.chdir('C:/Users/MSI/Documents/Our_project/Heart/Checks/')

interval = interval[['subject', 'block', 'ECG_Rate_Mean']]
interval.to_csv('heart_rate.csv', index=False)


