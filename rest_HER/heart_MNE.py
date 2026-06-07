#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun  7 15:51:30 2024

@author: marinaivanova
"""

import mne
import numpy as np
import matplotlib.pyplot as plt
import os
import os.path as op


subject = 'zhanx_34'
block = 'b1'
sample_dir = op.join('/Volumes/T7/MEG_Data_PhD/', subject)

raw_fname = op.join(sample_dir, subject + '_' + block + '_tsss_mc_trans.fif')

raw = mne.io.read_raw_fif(raw_fname, preload=True)

# List all available channels to verify the ECG channel name
print("Available channels:", raw.ch_names)

# Pick the ECG channel
ecg_channel = 'ECG063'  # Adjust this based on the actual channel name
if ecg_channel not in raw.ch_names:
    raise ValueError(f"ECG channel '{ecg_channel}' not found in data. Available channels: {raw.ch_names}")

# Filter the ECG signal to remove noise
#raw.filter(1., 40., fir_design='firwin')

# Detect R-peaks using the correct channel name
picks = mne.pick_channels(raw.info['ch_names'], include=[ecg_channel])
ecg_events = mne.preprocessing.find_ecg_events(raw, ch_name=ecg_channel)

# Extract ECG signal
ecg_signal = raw.get_data(picks=picks)[0]

# Detect R-peaks using the correct channel name
picks = mne.pick_channels(raw.info['ch_names'], include=[ecg_channel])
ecg_events = mne.preprocessing.find_ecg_events(raw, ch_name=ecg_channel)[0]

# Extract ECG signal
ecg_signal = raw.get_data(picks=picks)[0]

# Get the times of the R-peaks
r_peaks_indices = ecg_events[:, 0]
r_peaks_times = r_peaks_indices / raw.info['sfreq']

# Ensure the indices are within the bounds of the ECG signal array
valid_peaks = r_peaks_indices < len(ecg_signal)
valid_r_peaks_indices = r_peaks_indices[valid_peaks]
valid_r_peaks_times = r_peaks_times[valid_peaks]

# Plot the ECG signal with R-peaks
plt.figure(figsize=(12, 6))
plt.plot(raw.times, ecg_signal, label='ECG signal')
plt.plot(valid_r_peaks_times, ecg_signal[valid_r_peaks_indices], 'ro', label='R-peaks')
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('ECG signal with detected R-peaks')
plt.legend()

# Set x-axis limits (e.g., 0 to 10 seconds)
plt.xlim(0, 10)

plt.show()