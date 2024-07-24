err = Eyelink('CheckRecording');
if(err ~= 0)
    fprintf('EyeLink Recording stopped!\n');
    % Transfer a copy of the EDF file to Display PC
    Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
    Eyelink('CloseFile'); % Close EDF file on Host PC
    Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
    WaitSecs(0.1); % Allow some time for screen drawing
    % Transfer a copy of the EDF file to Display PC
    transferFile; % See transferFile function below)
    error('EyeLink is not in record mode when it should be. Unknown error. EDF transferred from Host PC to Display PC, please check its integrity.');
end