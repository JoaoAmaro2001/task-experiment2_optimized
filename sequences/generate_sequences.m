% Transform this script into a function!

% Run setpath
setpath;

% Directories
allstim_path   = fullfile(sourcedata, 'supp', 'allStimuli');
stim_path      = fullfile(sourcedata, 'supp', 'stimuli');

% Settings
moveAvi        = false;
createSequence = true;
method         = 'pre-built'; % {'real-time', 'pre-built'};

% ------------------------------------------------------------------
if moveAvi

stimFolders   = dir(allstim_path); % Get only folders
stimFolders   = stimFolders([stimFolders.isdir]); % Remove non-folders

% Move all .avi files
for i = 1:length(stimFolders)
    stimFiles = dir(fullfile(allstim_path, stimFolders(i).name, '*.avi'));
    for j = 1:length(stimFiles)
        copyfile(fullfile(allstim_path, stimFolders(i).name, stimFiles(j).name), fullfile(stim_path, stimFiles(j).name));
    end
end

end
% ------------------------------------------------------------------

if createSequence
    
    % Task vars
    filesForEachRun = 30;
    numOfRuns       = 2; 

    if strcmpi(method,'real-time')

    % Assign numbers to each file
    stimFilesCurated = dir(fullfile(stim_path, '*.avi'));
    numFiles = length(stimFilesCurated);
    fileNumbers = 1:numFiles;
    fileNames = {stimFilesCurated.name}';
    
    % Create a table with numbers and filenames
    fileTable = table(fileNumbers', fileNames, 'VariableNames', {'Number', 'FileName'});
    
    % Randomize numbers
    randomOrder = randperm(numFiles);
    
    % Select 30 numbers for the first sequence
    sequenceFilesComplete = fileTable.FileName;
    sequenceFilesComplete(randomOrder) = fileTable.FileName;
    
    % Save
    cd(fullfile(scripts,'sequences'))
    save('sequence1.mat', 'sequenceFiles', 'sequenceNumbers')
    
    % % Perform second randomization for sequence2 (Ensure no overlap with sequence1)
    remainingNumbers = setdiff(randomOrder, sequenceNumbers);
    sequenceNumbers = remainingNumbers(randperm(filesForEachRun)); % Re-shuffle!!!
    sequenceFiles = fileTable.FileName(sequenceNumbers);
    
    % Save
    save('sequence2.mat', 'sequenceFiles', 'sequenceNumbers');

    elseif strcmpi(method,'pre-built')

    % Files for each run (half)
    filesForEachRun = 30;

    % Assign numbers to each file
    stimFilesCurated = dir(fullfile(stim_path, '*.avi'));
    numFiles = length(stimFilesCurated);
    fileNumbers = 1:numFiles;
    fileNames = {stimFilesCurated.name}';
    
    % Create a table with numbers and filenames
    fileTable = table(fileNumbers', fileNames, 'VariableNames', {'Number', 'FileName'});
    
    % Randomize numbers
    randomOrder = randperm(numFiles);
    sequenceFilesComplete = fileTable.FileName;
    sequenceFilesComplete(randomOrder) = fileTable.FileName;
    % Save run 1 sequence
    sequenceFiles1 = sequenceFilesComplete(1:filesForEachRun);   
    cd(fullfile(scripts,'sequences'))
    save('sequence1.mat', 'sequenceFiles1', 'randomOrder')
    % Save run 2 sequence
    sequenceFiles2 = sequenceFilesComplete(filesForEachRun+1:end);       
    cd(fullfile(scripts,'sequences'))
    save('sequence2.mat', 'sequenceFiles2', 'randomOrder')
    % Output sequence side by side
    out_sequence = {sequenceFiles1{:}; sequenceFiles2{:}};
    disp(out_sequence');
    if length(unique(out_sequence))~=filesForEachRun*numOfRuns
        error('Stimulus randomization went wrong...')
    end
    end
end

cd(scripts)

