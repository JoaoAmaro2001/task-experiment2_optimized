function [subjectinfo] = sub_1

% This function returns the subject-specific details
%
% the first few lines with comments are displayed as help

% define the filenames, parameters and other information that is subject specific
subjectinfo.subjectid   = 'Subject01';
subjectinfo.eegfilename = 'myProject/rawdata/EEG/subject01.eeg';
subjectinfo.mrifilename = 'myProject/rawdata/MRI/01_mri.nii';
subjectinfo.badtrials   = [1 3]; % subject made a mistake on the first and third trial

% more information can be added to this script when needed
...