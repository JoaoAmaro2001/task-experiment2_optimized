%% =======================================================================
%  TIMING BATTERY FOR PSYCHTOOLBOX EXPERIMENTS
%  -----------------------------------------------------------------------
%  Author: (you)
%  Purpose: Quantitatively benchmark timing performance on this machine
%           for Psychtoolbox EEG/eyetracking tasks.
%  -----------------------------------------------------------------------
%  Includes tests for:
%    1. Visual onset consistency (photodiode-ready)
%    2. Movie frame-drop and drift
%    3. Flip scheduling accuracy
%    4. Keyboard input (KbCheck vs KbQueue)
%    5. WaitSecs precision under CPU load
%    6. File I/O cost (TSV vs XLSX)
%    7. Preallocation vs dynamic growth
%    8. Parallel-port pulse width timing
%    9. Long-run flip stability
%   10. Mouse polling rate
%  -----------------------------------------------------------------------
%  Dependencies: Psychtoolbox, io64 (for parallel port), Excel support
% =======================================================================

clear; close all; clc;
fprintf('\n==============================\n');
fprintf(' TIMING BATTERY FOR PTB TASKS \n');
fprintf('==============================\n\n');

rng('shuffle');

%% -----------------------------------------------------------------------
% Helper function
function safeClose()
    try sca; catch, end
    Priority(0);
end

cleanupObj = onCleanup(@() safeClose());

%% -----------------------------------------------------------------------
% 1. VISUAL ONSET TEST (PHOTODIODE)
% ------------------------------------------------------------------------
fprintf('\n[1] VISUAL ONSET TEST\n');
try
    Screen('Preference','SkipSyncTests',0);
    [win,rect]=Screen('OpenWindow',max(Screen('Screens')),0);
    Priority(MaxPriority(win));

    fps=Screen('NominalFrameRate',win); if fps<=0, fps=60; end
    ifi=Screen('GetFlipInterval',win);
    nFlips=round(fps*10); % ~10 seconds
    rectSmall=[0 0 100 100];
    vbls=nan(nFlips,1);

    for i=1:nFlips
        if mod(i,2), col=255; else, col=0; end
        Screen('FillRect',win,col,rectSmall);
        vbls(i)=Screen('Flip',win);
    end
    safeClose();
    dvbl=diff(vbls);
    fprintf('Mean IFI = %.4f ms | SD = %.4f ms\n',mean(dvbl)*1000,std(dvbl)*1000);
catch ME
    fprintf('Skipped test 1: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 2. MOVIE FRAME DROP & DRIFT TEST
% ------------------------------------------------------------------------
fprintf('\n[2] MOVIE FRAME DROP TEST\n');
try
    [win,~]=Screen('OpenWindow',max(Screen('Screens')),128);
    [fname, path] = uigetfile({'*.mp4;*.avi'},'Select test video');
    if isequal(fname,0)
        error('No video selected');
    end
    [movie,~,fps]=Screen('OpenMovie',win,fullfile(path,fname));
    Screen('PlayMovie',movie,1);
    vbls=[]; texTimes=[];
    while true
        [tex,pts]=Screen('GetMovieImage',win,movie,1);
        if tex<=0, break; end
        Screen('DrawTexture',win,tex,[],[]);
        vbl=Screen('Flip',win);
        vbls(end+1,1)=vbl; %#ok<SAGROW>
        texTimes(end+1,1)=pts; %#ok<SAGROW>
        Screen('Close',tex);
    end
    Screen('PlayMovie',movie,0); Screen('CloseMovie',movie); safeClose();
    fprintf('Flip jitter mean=%.3fms | SD=%.3fms\n',mean(diff(vbls))*1000,std(diff(vbls))*1000);
    fprintf('Movie pts step mean=%.3fms (target=%.3fms)\n',mean(diff(texTimes))*1000,1000/fps);
catch ME
    fprintf('Skipped test 2: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 3. FLIP SCHEDULING TEST
% ------------------------------------------------------------------------
fprintf('\n[3] FLIP SCHEDULING TEST\n');
try
    [win,~]=Screen('OpenWindow',max(Screen('Screens')),0);
    ifi=Screen('GetFlipInterval',win);
    vbl=Screen('Flip',win);
    n=300; stamps=zeros(n,1);
    for k=1:n
        Screen('FillRect',win,255*mod(k,2));
        when=vbl+0.5*ifi;
        vbl=Screen('Flip',win,when);
        stamps(k)=vbl;
    end
    safeClose();
    d=diff(stamps);
    fprintf('Scheduled flips mean=%.6fs | SD=%.6fs\n',mean(d),std(d));
catch ME
    fprintf('Skipped test 3: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 4. KEYBOARD INPUT (KbCheck vs KbQueue)
% ------------------------------------------------------------------------
fprintf('\n[4] KEYBOARD INPUT TEST\n');
try
    ListenChar(2); KbName('UnifyKeyNames'); key=KbName('SPACE');
    fprintf('Press SPACE 10x (KbCheck)...\n');
    t=[]; 
    while numel(t)<10
        [down,secs,kc]=KbCheck;
        if down && kc(key), t(end+1)=secs; WaitSecs(0.2); end
    end
    latCheck=diff(t); fprintf('KbCheck mean ISI=%.3fs | SD=%.3f\n',mean(latCheck),std(latCheck));

    KbQueueCreate; KbQueueStart;
    fprintf('Press SPACE 10x (KbQueue)...\n');
    t2=[];
    while numel(t2)<10
        [pressed,fp]=KbQueueCheck;
        if pressed && fp(key)>0
            t2(end+1)=fp(key); KbQueueFlush; WaitSecs(0.2);
        end
    end
    KbQueueStop; KbQueueRelease; ListenChar(0);
    latQueue=diff(t2);
    fprintf('KbQueue mean ISI=%.3fs | SD=%.3f\n',mean(latQueue),std(latQueue));
catch ME
    fprintf('Skipped test 4: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 5. WAITSSECS PRECISION UNDER LOAD
% ------------------------------------------------------------------------
fprintf('\n[5] WAITSSECS PRECISION UNDER LOAD\n');
try
    n=1000; target=0.002; err=zeros(n,1);
    parfor (i=1:n, max(1,feature('numcores')-1))
        t0=GetSecs; WaitSecs(target); err(i)=(GetSecs - t0) - target;
    end
    fprintf('WaitSecs mean offset=%.3fms | SD=%.3fms\n',mean(err)*1000,std(err)*1000);
catch ME
    fprintf('Skipped test 5: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 6. FILE I/O COST
% ------------------------------------------------------------------------
fprintf('\n[6] FILE I/O COST (TSV vs XLSX)\n');
try
    N=5e5; T=table((1:N)',rand(N,1),'VariableNames',{'idx','val'});
    t=tic; writetable(T, fullfile(tempdir,'test.tsv'),'FileType','text','Delimiter','\t'); tsv=toc(t);
    t=tic; writetable(T, fullfile(tempdir,'test.xlsx')); xlsx=toc(t);
    fprintf('Write TSV=%.2fs | XLSX=%.2fs (%.1fx slower)\n',tsv,xlsx,xlsx/tsv);
catch ME
    fprintf('Skipped test 6: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 7. PREALLOCATION VS DYNAMIC GROWTH
% ------------------------------------------------------------------------
fprintf('\n[7] PREALLOCATION BENEFIT\n');
try
    N=1e6;
    t=tic; a=[]; for i=1:N, a(end+1)=i; end, dyn=toc(t);
    t=tic; b=zeros(1,N); for i=1:N, b(i)=i; end, pre=toc(t);
    fprintf('Dynamic=%.2fs | Preallocated=%.2fs (%.1fx faster)\n',dyn,pre,dyn/pre);
catch ME
    fprintf('Skipped test 7: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 8. PARALLEL PORT PULSE WIDTH SWEEP
% ------------------------------------------------------------------------
fprintf('\n[8] PARALLEL PORT PULSE WIDTH SWEEP (software timing)\n');
try
    ioObj=io64; io64(ioObj); address=hex2dec('BFF8');
    widths=[0.0005 0.001 0.002 0.005 0.010]; reps=200; actual=zeros(numel(widths),1);
    for w=1:numel(widths)
        t0=GetSecs;
        for r=1:reps
            io64(ioObj,address,7); WaitSecs(widths(w)); io64(ioObj,address,0);
        end
        actual(w)=(GetSecs - t0)/reps;
    end
    disp(table(widths',actual','VariableNames',{'Requested','AvgLoopTime'}));
catch ME
    fprintf('Skipped test 8: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 9. LONG-RUN FLIP STABILITY
% ------------------------------------------------------------------------
fprintf('\n[9] LONG-RUN FLIP STABILITY (~2 min)\n');
try
    [win,~]=Screen('OpenWindow',max(Screen('Screens')),0);
    ifi=Screen('GetFlipInterval',win);
    n=2*60/ifi; stamps=zeros(n,1); vbl=Screen('Flip',win);
    for i=1:n
        Screen('FillRect',win,255*mod(i,2));
        vbl=Screen('Flip',win,vbl+0.5*ifi);
        stamps(i)=vbl;
    end
    safeClose(); d=diff(stamps);
    fprintf('Mean=%.6fs | SD=%.6fs\n',mean(d),std(d));
catch ME
    fprintf('Skipped test 9: %s',ME.message);
end

%% -----------------------------------------------------------------------
% 10. MOUSE POLLING RATE
% ------------------------------------------------------------------------
fprintf('\n[10] MOUSE POLLING RATE (move mouse 5s)\n');
try
    dur=5; t0=GetSecs; ts=[]; pos=[];
    while GetSecs - t0 < dur
        [x,y,~]=GetMouse; ts(end+1)=GetSecs; pos(end+1,:)=[x y]; %#ok<SAGROW>
    end
    dt=diff(ts);
    fprintf('Mouse poll dt mean=%.3fms | SD=%.3fms\n',mean(dt)*1000,std(dt)*1000);
catch ME
    fprintf('Skipped test 10: %s',ME.message);
end

%% -----------------------------------------------------------------------
fprintf('\n=============================================\n');
fprintf(' TIMING BATTERY COMPLETE\n');
fprintf('=============================================\n');
