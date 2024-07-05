% Step 1: Read the CSV file
randomizedTrials_all = readtable('randomizedTrials_all.csv');  % Adjust the path to your CSV file

% Step 2: Process the data (optional)
% Example: Convert dates if necessary
% data.Date = datetime(data.Date, 'InputFormat', 'yyyy-MM-dd');

% Step 3: Save the processed data to a MAT-file
save('randomizedTrials_all.mat', 'randomizedTrials_all');

% Step 4: Optionally, verify the saved data
load('randomizedTrials_all.mat')
loadedData = load('randomizedTrials_all.mat');
disp(loadedData.randomizedTrials_all);