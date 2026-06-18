#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 30 15:12:03 2025

@author: marinaivanova
"""

"""
Добавление событий из MATLAB в MEG-данные (MNE-Python)
-----------------------------------------------------
Этот скрипт:
1. Загружает времена событий из MATLAB (.mat)
2. Загружает MEG-данные (.fif)
3. Конвертирует времена (мс) в индексы сэмплов
4. Создаёт искусственный стимульный канал (STI101)
5. Добавляет его в объект Raw и сохраняет новый файл
"""

import numpy as np
import mne
import scipy.io as sio
import os.path as op
import os
import csv
from scipy.io import savemat


all = [2, 4, 6, 8, 10, 12, 14, 16, 17, 18, 19, 20, 22, 23, 24, 27, 28, 29, 31, 32, 35, 36, 38, 40, 42, 44, 45, 46, 47, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 63, 64, 65, 67, 68, 69, 70]
# bipolar = [17 18 19 20 27 35 36 40 42 44 46 51 52 56 57 59 64 69 70];

rest = [46, 47, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 63, 64, 65, 67, 68, 69, 70]
test = [14]

for n in test: # in all:  # choose 'all' for final run
    subj = op.join('zhanx_' + str(n))
    blocks = ['_b1', '_b2']
    for block in blocks:
        fpath = op.join('E:/MEG_Data_PhD/' + subj + '/')   

        mat_file = op.join(fpath + 'tpeaks_final' + block + '.mat')
        meg_file = op.join(fpath + subj + block + '_preprocessed.fif')       
        output_file = op.join(subj + block + '_preprocessed_HER.fif')  
        mat_var_name = op.join('tpeaks_final' + block)      
        mat_var_name_2 = op.join('alignment' + block)
        alignment_file = op.join(fpath + 'alignment' + block + '.mat')
        align_name = op.join('alignment' + block +'_python')
    

        mat = sio.loadmat(mat_file)
        event_times_ms = np.squeeze(mat[mat_var_name])
        alignment = sio.loadmat(alignment_file)
        align = alignment[mat_var_name_2]     # the alignment variable
            
        raw = mne.io.read_raw_fif(meg_file, preload=True)
        

        sfreq = raw.info['sfreq']
        event_samples = np.round(event_times_ms / 1000 * sfreq).astype(int) # convert ms to samples 
        # given sfreq = 250 Hz
        
        
        stim_data = np.zeros((1, raw.n_times))
        
        
        try:
            stim_data[0, event_samples] = 1 # impulses at the event times
        except IndexError:
            valid_mask = (event_samples >= 0) & (event_samples < raw.n_times) 
            event_samples = event_samples[valid_mask]
           # align = align.transpose()
           
            if n == 24 or n == 28:
                align = align.T[valid_mask]
                align = align.T
            else:
                align = align[valid_mask]
                
        stim_data[0, event_samples] = 1
            
        stim_info = mne.create_info(['STI104'], sfreq, ['stim'])
        stim_raw = mne.io.RawArray(stim_data, stim_info)
        
        raw_with_stim = raw.add_channels([stim_raw], force_update_info=True)
       
        
        os.chdir(fpath)
        
        align_save = np.column_stack([event_samples, align.T]) # event samples, event ms, stim number
        np.save(align_name, align_save)
        
        raw_with_stim.save(output_file, overwrite=True)
  
