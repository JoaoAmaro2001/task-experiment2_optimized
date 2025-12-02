function elFinish(cfg)

    % Put tracker in idle/offline mode before closing file. Eyelink('SetOfflineMode') is recommended.
    % However if Eyelink('Command', 'set_idle_mode') is used, allow 50ms before closing the file as shown in the commented code:
    % Eyelink('Command', 'set_idle_mode'); % Put tracker in idle/offline mode
    
    
    Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
    WaitSecs(0.05); % Allow some time for transition  
    Eyelink('CloseFile');

    edfFile = [cfg.input{1},'.edf'];
    out_path = fullfile(cfg.paths.sourcedata,'supp','eyelinkFiles');
    
    try
        cd(out_path)
        fprintf('Receiving data file ''%s''\n', edfFile);
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status/1024);
        end

        if isfile(edfFile)
            fprintf('Data file ''%s'' can be found in ''%s''\n', out_path);
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile);
    end

end