% Put tracker in idle/offline mode before closing file. Eyelink('SetOfflineMode') is recommended.
% However if Eyelink('Command', 'set_idle_mode') is used, allow 50ms before closing the file as shown in the commented code:
% Eyelink('Command', 'set_idle_mode'); % Put tracker in idle/offline mode

cwd = pwd;

WaitSecs(0.05); % Allow some time for transition  
% Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
WaitSecs(0.5); % Allow some time before closing and transferring file
% Eyelink('CloseFile'); % Close EDF file on Host PC
% Transfer a copy of the EDF file to Display PC
% transferFile; % See transferFile function ----- NOT BEING USED!
Eyelink('command', 'set_idle_mode');
WaitSecs(5);
Eyelink('CloseFile');

try
    cd(fullfile(sourcedata,'supp','eyelinkFiles'))
    fprintf('Receiving data file ''%s''\n',...
        [data.input{1},'.edf'] );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status/1024);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n',...
            [data.input{1},'.edf'], pwd );
    end
    cd(cwd)
catch
    fprintf('Problem receiving data file ''%s''\n',...
        [data.input{1},'.edf'] );
end

% close the eye tracker and window
Eyelink('ShutDown');
Screen('CloseAll');
cleanupEl;    % Clean up the experiment + eye tracker