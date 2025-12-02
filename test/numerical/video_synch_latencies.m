%% =======================================================================
%  VIDEO SYNC TEST – Interleaved EEG / Parallel Port / EyeLink triggers
%  -----------------------------------------------------------------------
%  EEG (NetStation): every 1 s
%  Parallel Port: every 1 s, delayed by 1 s from EEG
%  EyeLink: one event per EEG trigger
%  Logs precise datetimes (microsecond resolution)
%  =======================================================================

clear; clc; close all;
settings_main(); HideCursor;

try
    %% --- SETUP ----------------------------------------------------------
    Screen('Preference','SkipSyncTests',1);
    [window, rect] = Screen('OpenWindow', max(Screen('Screens')), [128 128 128]);
    [W,H] = Screen('WindowSize',window);
    center = [W/2, H/2];


    % ===== NetStation =====
    NetStation('Connect', cfg.info.network.ipv4.eeg);
    NetStation('Synchronize');
    disp('NetStation connected & synchronized.');

    % ===== EyeLink =====
    Eyelink('command','set_idle_mode');
    Eyelink('StartRecording');
    WaitSecs(0.1);
    disp('EyeLink recording started.');

    % ===== Logging setup =====
    eventLog = table('Size',[0 5], ...
        'VariableTypes',{'string','double','double','datetime','string'}, ...
        'VariableNames',{'System','Value','tRel','tAbs','Label'});

    %% --- TASK PARAMETERS ------------------------------------------------
    totalDuration = 60;  % seconds
    nextEEG = 0;         % EEG (and EyeLink) triggers start immediately
    nextPAR = 1;         % Parallel port triggers start 1 s later
    evEEG = 1; evPAR = 1;
    fps = 30;
    colorVal = 128;

    % === Start recording moment the clock starts ===
    startExp = GetSecs;
    NetStation('StartRecording');    
    disp('Task started — recording all events.');
    Eyelink('Message','TASK_START');

    %% --- MAIN LOOP ------------------------------------------------------
    while (GetSecs - startExp) < totalDuration
        % Visual flicker (for photodiode validation if needed)
        colorVal = 128 + 127*sin(2*pi*(GetSecs-startExp));
        Screen('FillRect',window,[colorVal colorVal colorVal]);
        Screen('Flip',window);

        tNow = GetSecs(); 
        tRel = tNow - startExp;
        tAbs = datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSSSSS');

        % ---------- EEG + EyeLink every 1 s ----------
        if tRel >= nextEEG
            markerEEG = sprintf('EEG_%02d',evEEG);
            NetStation('Event','EVEN',GetSecs(), 0.001, 'test',2)
            NetStation('FlushReadbuffer');
            parallel_port(8)

            Eyelink('Message',markerEEG);

            eventLog = [eventLog; {"NetStation",evEEG,tRel,tAbs,markerEEG}];
            eventLog = [eventLog; {"EyeLink",evEEG,tRel,tAbs,markerEEG}];

            fprintf('[%.3f s] EEG+EyeLink event %d\n',tRel,evEEG);
            evEEG = evEEG + 1;
            nextEEG = nextEEG + 2;  % every 2 s total cycle (interleaved with PAR)
        end

        % ---------- Parallel port every 1 s (offset 1 s) ----------
        if tRel >= nextPAR

            markerPAR = sprintf('PAR_%02d',evPAR);
            eventLog = [eventLog; {"ParallelPort",evPAR,tRel, ...
                datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSSSSS'), markerPAR}];

            fprintf('[%.3f s] ParallelPort event %d\n',tRel,evPAR);
            evPAR = evPAR + 1;
            nextPAR = nextPAR + 2;  % interleaved pattern (1 s after EEG)
        end

        [keyIsDown,~,keyCode]=KbCheck;
        if keyIsDown && keyCode(KbName('ESCAPE')), break; end
    end

    %% --- CLEANUP --------------------------------------------------------
    NetStation('StopRecording'); NetStation('Disconnect');
    Eyelink('StopRecording'); Eyelink('Message','TASK_END');
    ShowCursor; Screen('CloseAll');

    %% --- SAVE LOG -------------------------------------------------------
    tNow = datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSSSSS');
    saveFile = fullfile(data_path,['syncTest_interleaved_' datestr(tNow,'yyyymmdd_HHMMSS') '.mat']);
    save(saveFile,'eventLog');
    writetable(eventLog,strrep(saveFile,'.mat','.xlsx'));
    disp('Event log saved.');

    %% --- SUMMARY --------------------------------------------------------
    nEEG = sum(eventLog.System=="NetStation");
    nPAR = sum(eventLog.System=="ParallelPort");
    nEYE = sum(eventLog.System=="EyeLink");
    fprintf('Total events -> EEG: %d | PAR: %d | EYE: %d\n', nEEG,nPAR,nEYE);

catch ME
    ShowCursor; Screen('CloseAll');
    Eyelink('StopRecording');
    NetStation('Disconnect');
    rethrow(ME);
end
