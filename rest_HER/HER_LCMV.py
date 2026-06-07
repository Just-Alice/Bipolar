#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 28 11:59:45 2024

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

# undone: 20 42
all = [2, 4, 6, 8, 10, 12, 14, 16, 17, 18, 19, 22, 23, 24, 27, 28, 29, 31, 32, 35, 36, 38, 40, 44, 45, 46, 47, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 63, 64, 65, 67, 68, 69, 70]

all_rest = [14]

for n in all_rest:
    
    subject = op.join('zhanx_' + str(n))
    print(subject)
    
    # My bandpass-filter settings for LCMV beamforming
    f1 = 0.5
    f2 = 30
    
    block = 'b1'
    sample_dir = op.join('E:/MEG_Data_PhD/',subject)
    raw_fname = op.join(sample_dir, subject + '_' + block + '_preprocessed_HER.fif') # load the new raw file with T-peaks triggers
    raw            =  mne.io.read_raw_fif(raw_fname, preload=True)
    # reject            = dict(mag=5e-12, grad=4000e-13)
    
    os.chdir(sample_dir)
    alignment = np.load('alignment_b1_python.npy') # three columns: left column is event sample in samples,
    # the middle column is the event latency in ms, the right column is the initial stimulus number
    subjects_dir = 'E:/subjects/'
    subject_fs = 'fsaverage'
    
    # band pass filtering for LCMV
    raw.filter(f1, f2, fir_design='firwin') 
    events = mne.find_events(raw, uint_cast = True, stim_channel='STI104') # the name of the stimuli channel
    # for T-peaks is STI104
    
    
    print("first_samp =", raw.first_samp)  # learn the number of the first sample to check the alignment of 
    # the triggers vs stimuli
    
    
    # block 1
    x = np.unique(events[:, 2])
    print(x)
          
    # pick relevant channels
    raw.pick(['mag', 'grad'])  # pick channels of interest
    
    # create epochs
    proj = False  # already applied
    tmin, tmax = -2, 1
    event_id=1
    
    
    stim_epochs = mne.Epochs(raw, events, event_id, tmin, tmax,
                    baseline=(None), preload=False, proj=proj)
                    # reject=dict(grad=4000e-13, mag=5e-12))
    
    stim_epochs.load_data()       # otherwise selection does not work properly
    valid_epochs = stim_epochs.selection
    valid_stim_samples = alignment[valid_epochs]
    align_result = np.column_stack([valid_epochs, valid_stim_samples]) # includes the epoch number (1 column) ,
    # 2 column is event sample in samples,
    # 3 column is the event latency in ms, 4 column is the initial stimulus number
    
    del raw
    
    event_list = stim_epochs.selection.tolist()
    
    os.chdir(sample_dir)
    os.getcwd()
    np.savetxt("event_list_stim.csv", event_list)
    np.savetxt("align_result.csv", align_result, delimiter=",") # saving the epochs alignment
    
    
    del alignment
    # Block 2
    block = 'b2'
    sample_dir = op.join('E:/MEG_Data_PhD/', subject)
    raw_fname = op.join(sample_dir, subject + '_' + block + '_preprocessed_HER.fif')
    raw            =  mne.io.read_raw_fif(raw_fname, preload=True)
    
    reject            = dict(mag=5e-12, grad=4000e-13)
    
    raw.filter(f1, f2, fir_design='firwin') 
    
    alignment2 = np.load('alignment_b2_python.npy')
    
    events = mne.find_events(raw, uint_cast = True, stim_channel='STI104')
    
    # block 2
    x = np.unique(events[:, 2])
    print(x)
    
    
    # pick relevant channels
    raw.pick(['mag', 'grad'])  
    
    # create epochs
    proj = False  # already applied
    tmin, tmax = -2, 1
    event_id=1
    
    stim2_epochs = mne.Epochs(raw, events, event_id, tmin, tmax,
                            baseline=(None), preload=False, proj=proj)
                           # reject=dict(grad=4000e-13, mag=5e-12))
    
    stim2_epochs.load_data()      # otherwise selection does not work properly
    valid_epochs2 = stim2_epochs.selection
    valid_stim_samples2 = alignment2[valid_epochs2]
    align_result2 = np.column_stack([valid_epochs2, valid_stim_samples2]) # includes the epoch number (1 column) ,
    # 2 column is event sample in samples,
    # 3 column is the event latency in ms, 4 column is the initial stimulus number
    
    del raw
    
    event_list = stim_epochs.selection.tolist()
    
    os.chdir(sample_dir)
    os.getcwd()
    np.savetxt("event_list_stim.csv", event_list)
    np.savetxt("align_result2.csv", align_result2, delimiter=",") # saving the epochs alignment
    
    event_list = stim2_epochs.selection.tolist()
    np.savetxt("event_list_stim2.csv", event_list)
    
    
    # Combine epochs block 1 and 2
    allstim_epochs         = mne.concatenate_epochs([stim_epochs,stim2_epochs])
    # del stim2_epochs, stim_epochs
    print(allstim_epochs)
    
    event_list = allstim_epochs.selection.tolist()
    os.chdir(sample_dir)
    os.getcwd()
    np.savetxt("event_list_allstim.csv", event_list)
    
    def no_rejected_epochs(drop_log):
        indices = []
        for idx, tup in enumerate(drop_log):
            if tup and all(item != 'IGNORED' for item in tup):
                indices.append(idx)
        return indices
    
    
    # DL = allstim_epochs.drop_log
    
    # mid = len(DL) // 2
    # first = DL[:mid]
    # second = DL[mid:]
    
    
    # np.savetxt("rejected_epochs1.csv", no_rejected_epochs(first))
    # np.savetxt("rejected_epochs2.csv", no_rejected_epochs(second))
    # np.savetxt("rejected_allepochs.csv", no_rejected_epochs(DL))
    
    
    # allstim = list()
    # with open('event_list_allstim.csv', newline='') as csvfile:
    #     spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    #     for row in spamreader:
    #         allstim.append(int(float(row[0])))
            
    # allreject = list()
    # with open('rejected_allepochs.csv', newline='') as csvfile:
    #     spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    #     for row in spamreader:
    #         allreject.append(int(float(row[0])))
            
    # stim1 = list()
    # with open('event_list_stim.csv', newline='') as csvfile:
    #     spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    #     for row in spamreader:
    #         stim1.append(int(float(row[0])))
            
    # stim2 = list()
    # with open('event_list_stim2.csv', newline='') as csvfile:
    #      spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    #      for row in spamreader:
    #          stim2.append(int(float(row[0])))
            
    # total_stim = list(set(allreject).union(set(allstim))) # total epochs (before rejection) in vector 0...961
    
    # # # combining two epochs into one vector
    # epoch_mapping = {orig: i+1 for i, orig in enumerate(stim1)}  # поменть на i+1
    # epoch_mapping.update({orig + len(stim1): i + len(stim1) + 1 for i, orig in enumerate(stim2)}) # не i+160, а i+161
    
    # # # mapping epochs to 0...319 vector
    # mapped_allstim = [epoch_mapping[e] for e in total_stim]
    # mapped_rejected = sorted(set(epoch_mapping[e] for e in allreject))
    # mapped_remaining = sorted(set(range(0,len(total_stim))) - set(mapped_rejected))
    
    
    # if not os.path.exists('/Volumes/KINGSTON/subjects/' + subject +'/bem/bemlabels_HER/'):
    #     os.makedirs('/Volumes/KINGSTON/subjects/' + subject +'/bem/bemlabels_HER/')
    # os.chdir('/Volumes/KINGSTON/subjects/' + subject +'/bem/bemlabels_HER/')
    
    # # # saving to .csv
    # pd.DataFrame(mapped_allstim).to_csv("mapped_allstim.csv", index=False, header=False)
    # pd.DataFrame(mapped_rejected).to_csv("mapped_rejected.csv", index=False, header=False)
    # pd.DataFrame(mapped_remaining).to_csv("mapped_remaining.csv", index=False, header=False)
    
    # Computing the covariance matrices
    data_cov = mne.compute_covariance(allstim_epochs, tmin=0, tmax=1,
                                        method='empirical', rank='info')
    noise_cov = mne.compute_covariance(allstim_epochs, tmin=-2, tmax=-1,   # change in accordance with eLoreta
                                        method='empirical', rank='info')
    data_cov.plot(allstim_epochs.info)
    
    # Now crop single epochs for speed purposes, cut to a window of interest: We will use this for TFR and ConvModelling
    myepochs = allstim_epochs.crop(-1, 1)
    
    del allstim_epochs # save memory
    
    # Forward model
    # Read forward model: surf-fwd.fif: surface-based source space
    block = 'b1'
    fname_fwd = op.join(sample_dir, subject + '_' + block + '-surf-fwd.fif') 
    forward = mne.read_forward_solution(fname_fwd)
    # save a bit of memory
    src = forward['src']
    #del forward
    
    # Labels
    mylabel_names = ['caudalanteriorcingulate-lh', 'caudalanteriorcingulate-rh', 'caudalmiddlefrontal-lh', 'caudalmiddlefrontal-rh', 'isthmuscingulate-lh', 'isthmuscingulate-rh', 'lateralorbitofrontal-lh', 'lateralorbitofrontal-rh', 'medialorbitofrontal-lh', 'medialorbitofrontal-rh', 'paracentral-lh','paracentral-rh', 'postcentral-lh', 'postcentral-rh', 'posteriorcingulate-lh', 'posteriorcingulate-rh', 'precentral-lh', 'precentral-rh', 'rostralanteriorcingulate-lh', 'rostralanteriorcingulate-rh', 'rostralmiddlefrontal-lh', 'rostralmiddlefrontal-rh', 'superiorfrontal-lh', 'superiorfrontal-rh', 'superiorparietal-lh', 'superiorparietal-rh' ]
                
    
    # fname_stc = os.path.join(subjects_dir, subject, 'bem')
    # os.chdir(fname_stc)
    # if not os.path.exists('bemlabels_ITI'):
    #     os.mkdir('bemlabels_ITI')
    
    # # fname_stc = os.path.join(subjects_dir, subject, 'bem','bemlabels_HER')
    # # os.chdir(fname_stc)
    # # os.getcwd()
    
    # Apply lcmv to all epochs and vertices
    # Extract all trials and all epochs
    filters = make_lcmv(myepochs.info, forward, data_cov, reg=0.05,
                         noise_cov=noise_cov, pick_ori='max-power',
                         weight_norm='unit-noise-gain', rank=None)
    
    
    stcall = apply_lcmv_epochs(myepochs, filters)
    ntrials = len(stcall)
    del filters, myepochs
    
    
    # Using a predefined set of label names: save pca_flip for each label and trial (64 labels x 300 trials)
    # Loop on labels and trials
    
    # Loop across all labels __names__
    
    # fpath_stc = os.path.join(subjects_dir, subject, 'bem')
    # os.chdir(fpath_stc)
    # if not os.path.exists('bemlabels_HER'):
    #     os.mkdir('bemlabels_HER')
    
    # fname_stc = os.path.join(subjects_dir, subject, 'bem','bemlabels_HER')
    
    
    fpath_stc = os.path.join(subjects_dir, subject, 'bem', 'bemlabels_HER')
    os.makedirs(fpath_stc, exist_ok=True)
    os.chdir(fpath_stc)
    os.getcwd()
    
    # Initialize empty dictionary to store time courses
    time_courses = {}
    
    for ll in mylabel_names:
        aparc_label_name = ll
        label = mne.read_labels_from_annot(subject, parc='aparc.DKTatlas',
                                    subjects_dir=subjects_dir,
                                    regexp=aparc_label_name)[0] 
        # Initialize empty list to store time courses for this label
        time_courses[aparc_label_name] = []
        # Loop on trials ntrials
        for i in range(ntrials):
                # One trial: One trial-source estimate for a label
                pca_anat = stcall[i].extract_label_time_course(label, src, mode='pca_flip')[0]
                # flip the pca so that the max power between tmin and tmax is positive
                pca_anat *= np.sign(pca_anat[np.argmax(np.abs(pca_anat))])
                # Append time course to list for this label
                time_courses[aparc_label_name].append(pca_anat)
        # Save list of time courses for this label to a single file
        fnamemat = 'pca_' + aparc_label_name + '_HER.mat'
        savemat(fnamemat, {'pca_timecourse': time_courses[aparc_label_name]})
    
    
    
    del stcall
