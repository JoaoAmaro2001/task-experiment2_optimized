function elCleanup()
    % Cleanup function used throughout the eyelink script
    try
        Screen('CloseAll'); % Close window if it is open
    catch ME
        fprintf('Screen close error: %s\n', ME.message);
    end
    Eyelink('Shutdown'); % Close EyeLink connection
    ListenChar(0); % Restore keyboard output to Matlab
    ShowCursor(); % Restore mouse cursor
    if ~IsOctave; commandwindow; end % Bring Command Window to front
end