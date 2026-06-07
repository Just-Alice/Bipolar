#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 30 22:13:08 2025

@author: marinaivanova
"""

import os,sys
import os.path as op
import matplotlib.pyplot as plt
import matplotlib.patheffects as path_effects
import mne
mne.viz.set_3d_backend("pyvista")
#from mne.datasets import sample, fetch_fsaverage
from mne.datasets import fetch_fsaverage
from mne.beamformer import make_lcmv, apply_lcmv, apply_lcmv_epochs
import numpy as np
from numpy import savetxt
from scipy.io import savemat
import csv
import pandas as pd

#%% 

subject = 'zhanx_68'
print(subject)


block = 'b1'
sample_dir = op.join('/Volumes/T7/MEG_Data_PhD/',subject)
raw_fname = op.join(sample_dir, subject + '_' + block + '_preprocessed_HER.fif')
raw            =  mne.io.read_raw_fif(raw_fname, preload=True)
reject            = dict(mag=5e-12, grad=4000e-13)

subjects_dir = '/Volumes/T7/subjects/'


events = mne.find_events(raw, stim_channel='STI104')
event_dict      = {'tpeak': 1}

x = np.unique(events[:, 2])

raw.pick(['mag', 'grad']) 

tmin, tmax = -0.2, 0.6
proj = False 

event_id=event_dict

epochs_1 = mne.Epochs(raw, events, event_id, tmin, tmax,
                baseline=(-0.2, 0), preload=False, proj=proj,
                reject=dict(grad=4000e-13, mag=5e-12))

block = 'b2'

raw_fname = op.join(sample_dir, subject + '_' + block + '_preprocessed_HER.fif')
raw            =  mne.io.read_raw_fif(raw_fname, preload=True)
reject            = dict(mag=5e-12, grad=4000e-13)


events = mne.find_events(raw, stim_channel='STI104')
event_dict      = {'tpeak': 1}

x = np.unique(events[:, 2])

raw.pick(['mag', 'grad']) 

tmin, tmax = -0.2, 0.6
proj = False 

event_id=event_dict

epochs_2 = mne.Epochs(raw, events, event_id, tmin, tmax,
                baseline=(-0.2, 0), preload=False, proj=proj,
                reject=dict(grad=4000e-13, mag=5e-12))

epochs = mne.concatenate_epochs([epochs_1, epochs_2])


# --- Усреднение ---
evoked = epochs.average()

# Разделяем по типу сенсоров
picks_mag = mne.pick_types(evoked.info, meg='mag')
picks_grad = mne.pick_types(evoked.info, meg='grad')

# Усредняем сигнал по каналам отдельно
evoked_mag_mean = evoked.copy().pick(picks_mag).data.mean(axis=0)  # shape (n_times,)
evoked_grad_mean = evoked.copy().pick(picks_grad).data.mean(axis=0)

# Теперь можно, например, построить графики
import matplotlib.pyplot as plt

times = evoked.times * 1000  # в миллисекундах

# --- Magnetometers ---
plt.figure(figsize=(8, 4))
plt.plot(times, evoked_mag_mean * 1e15, color='b')  # convert to fT
plt.title('Average evoked response (magnetometers)')
plt.xlabel('Time (ms)')
plt.ylabel('Amplitude (fT)')
plt.grid(True)
plt.tight_layout()
plt.show()

# --- Gradiometers ---
plt.figure(figsize=(8, 4))
plt.plot(times, evoked_grad_mean * 1e13, color='r')  # convert to fT/m
plt.title('Average evoked response (gradiometers)')
plt.xlabel('Time (ms)')
plt.ylabel('Amplitude (fT/m)')
plt.grid(True)
plt.tight_layout()
plt.show()





