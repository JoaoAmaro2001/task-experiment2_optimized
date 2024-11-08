setpath;

% Directories
allstim_path   = fullfile(sourcedata, 'supp', 'allStimuli');
stim_path      = fullfile(sourcedata, 'supp', 'stimuli');

% Settings
moveAvi        = false;
createSequence = true;

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

filesForEachSession = 30;
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
sequenceNumbers = randomOrder(1:filesForEachSession);
sequenceFiles = fileTable.FileName(sequenceNumbers);

% Save
cd(fullfile(scripts,'sequences'))
save('sequence1.mat', 'sequenceFiles', 'sequenceNumbers')

% % Perform second randomization for sequence2 (Ensure no overlap with sequence1)
remainingNumbers = setdiff(randomOrder, sequenceNumbers);
sequenceNumbers = remainingNumbers(randperm(filesForEachSession)); % Re-shuffle!!!
sequenceFiles = fileTable.FileName(sequenceNumbers);

% Save
save('sequence2.mat', 'sequenceFiles', 'sequenceNumbers');
cd(scripts)

end


