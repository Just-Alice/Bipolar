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

#%%

subject = 'zhanx_14'
block = 'b1'
sample_dir = op.join('/Volumes/T7/MEG_Data_PhD/', subject)

raw_fname = op.join(sample_dir, subject + '_' + block + '_tsss_mc_trans.fif')

raw            =  mne.io.read_raw_fif(raw_fname, preload=True)
raw.info['dev_head_t']

#%%

# take one ECG channel

ECG = raw.copy().pick(picks=["ecg"])
ecg_signal = raw['ECG063'][0]
ecg = np.reshape(ecg_signal, np.size(ecg_signal))

#%%

# Retrieve ECG data from data folder

# Extract R-peaks locations

signals, info = nk.ecg_process(ecg, sampling_rate=1000)


# if ECG is inverted

ecg = nk.ecg_invert(ecg, sampling_rate=1000, show=True)

_, rpeaks = nk.ecg_peaks(ecg, sampling_rate=1000)
# Delineate the ECG signal

_, waves_peak = nk.ecg_delineate(ecg, rpeaks, sampling_rate=1000, method="peak")
# Visualize R-peaks in ECG signal
plot = nk.events_plot(rpeaks['ECG_R_Peaks'], ecg)

#plot = nk.events_plot([waves_peak['ECG_T_Peaks'][:3]])

#%%

# Zooming into the first 5 R-peaks
plot = nk.events_plot(rpeaks['ECG_R_Peaks'][:5], ecg[:6000])

#%%

# Delineate the ECG signal
#_, waves_peak = nk.ecg_delineate(ecg, rpeaks, sampling_rate=1000, method="peak")

# Zooming into the first 3 R-peaks, with focus on T_peaks, P-peaks, Q-peaks and S-peaks
plot = nk.events_plot(waves_peak['ECG_T_Peaks'][:5], ecg[:5000])

#%%

timings = ECG.times


#%%




#%%

tpeaks = waves_peak['ECG_T_Peaks']

os.chdir('/Volumes/T7/MEG_Data_PhD/' + subject + '/')

    
#%%


fname = op.join('tpeaks_' + subject + '_' + block + '.mat')

mydict = {'tpeaks' : tpeaks}
          
savemat(fname, mydict)


#%%




