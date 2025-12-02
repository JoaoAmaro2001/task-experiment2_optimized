function igt
%**************************************************************************
% Implementation of Iowa Gambling Task for ERP with NetStation
%
% Significant chunks downloaded from alishir's github.
%
% Brock Kirwan
% 3/4/2013
%**************************************************************************

%history
%3/4/13 - modified from version found here: https://github.com/alishir/IGT_net/tree/master/igt_psychtoolbox
%3/6/13 - added outcome codes (0001, 0002, etc.) depending on the feedback
%         after IowaBatman subject 1 (i.e., 2-6).
%3/7/13 - added choice codes "SAFE" and "RISK" for safe and risky decks
%         after IowaSubject 6 (i.e., >7).
%3/13/13 - Added 750 ms delay between button press and feedback to try to
%          dissociate the ERPs for the two events.
%3/25/13 - Added flag to run behavioral version without recording to
%          NetStation. Save all data to 'Data' folder.


%---Setup Stuff------------------------------------------------------------
%DATA is a nice structure that holds all the variables and data for one
%subject.  It gets saved at the end of the experiment in the subject's
%folder.  It is declared global so that all the other sub-routines can have
%access to it, but you need to be sure to clear it out or you'll get the
%previous subject's trial setup.
clear global cfg;
global cfg;

%start off by calling the start_gui function.  Wait for user to input
%things like subj name and demographics.
h = startGui;
handles = guidata(h);
delete(h);%kill the figure
rand('state',sum(clock)); % set the random seed to a different state for each subject

%I don't think these values will change that much:
% subwindowsize = [0 0 1340 800]; %use [] for no subwindow.
% subwindowsize = [0 0 600 600];
subwindowsize = [];
cfg.blocks = 4;
cfg.maxItr = 100; % usually 100;
cfg.deckMax = 40; %usually 40
cfg.startRun = 1;
cfg.validResp = {'1!' '2@' '3#' '4$' 'esc' 'ESCAPE'};
cfg.subject = handles.sub;
cfg.age = handles.age;
cfg.sex = handles.sex;
cfg.handedness = handles.handedness;
cfg.matFileName = ['Data/s' cfg.subject '/IGT_cfg.mat'];
cfg.game_seq = zeros(3,cfg.maxItr);	% sequence of card selection
cfg.rt = zeros(cfg.maxItr,6);
cfg.debug = 0;
cfg.RespFdbkDelay = .75;
cfg.recordEeg = 0; %set to 0 if you're not plugged into the netstation.

%placeholder variables to keep track of things in the task
cfg.cardTime     = zeros(cfg.maxItr, cfg.blocks);
cfg.keyTime      = zeros(cfg.maxItr, cfg.blocks);
cfg.fdbkTime     = zeros(cfg.maxItr, cfg.blocks);
cfg.origSel      = zeros(cfg.maxItr, cfg.blocks);
cfg.selectedDeck = zeros(cfg.maxItr, cfg.blocks);
cfg.reward       = zeros(cfg.maxItr, cfg.blocks);
cfg.punish       = zeros(cfg.maxItr, cfg.blocks);


%set escape key name for windows/mac
% if strcmp(computer,'PCWIN')
%     cfg.escape = 'esc';
% else
%     cfg.escape = 'ESCAPE';
% end
cfg.escape = 'ESCAPE';

%check for the Data folder
if ~exist('Data','dir')
    status = mkdir('Data');
    if status == 0; error(['Problem creating the Data directory: ' lasterr]); end
end

%if the subject already has a DATA structure, load it.
if exist(cfg.matFileName,'file') && ~strcmp(cfg.subject,'99');
    load(cfg.matFileName);
end
%if not, create the directory
status = mkdir(['Data/12s' cfg.subject]);
if status == 0; error(['problem creating subject directory: ' lasterr]); end;
%create logfile
cfg.fileName = ['Data/s' cfg.subject '/IGT_' datestr(now,'yyyymmddHHMMSS') '_s' cfg.subject '.txt'];

%open the text log file
if exist(cfg.fileName, 'file') == 0
    fid = fopen(cfg.fileName, 'a');
    fprintf(fid, '%s \n\r', 'Iowa Gambling Task: EEG version');
    fclose(fid);
end

%gets rid of Matlab7 warnings about cogent's mixed case function names.
vertemp = version;
if str2double(vertemp(1))>6
    warning off MATLAB:dispatcher:InexactMatch;
end

%put it all in a try-catch loop so you can get out if it breaks.
try
    %---psychtoolbox configuration stuff---------------------------------------
    %make sure you're using a compatible version of psychtoolbox (PTB)
    AssertOpenGL;
    %be sure you're using the right screen
    screenid = max(Screen('Screens'));
    % Open window, with or without imaging pipeline:
    cfg.win = Screen('OpenWindow', screenid, 255, subwindowsize);
    Screen('TextFont', cfg.win, char('Helvetica'));
    Screen('TextStyle', cfg.win, 1);
    Screen('TextSize', cfg.win, 30);
    %ListenChar(2);

    %put something on the screen
    DrawFormattedText(cfg.win, 'Please wait...', 'center', 'center');
    Screen('Flip', cfg.win);

    %---pre-load the stimuli for speed-----------------------------------------
    [cfg.width, cfg.height] = Screen('WindowSize', cfg.win);
    cardWidth = cfg.width / 5;
    cardHeight = cfg.height / 3;
    posX = cardWidth / 5;		% || s |c| s |c| s |c| s |c| s ||	there are 5 space in horizon
    posY = cardHeight / 6;

    % deck with labels
    imgA = imread('./images/a.jpeg', 'JPG');
    imgB = imread('./images/b.jpeg', 'JPG');
    imgC = imread('./images/c.jpeg', 'JPG');
    imgD = imread('./images/d.jpeg', 'JPG');
    imgASel = imread('./images/a_sel.jpeg', 'JPG');
    imgBSel = imread('./images/b_sel.jpeg', 'JPG');
    imgCSel = imread('./images/c_sel.jpeg', 'JPG');
    imgDSel = imread('./images/d_sel.jpeg', 'JPG');

    imgBlank = imread('./images/blank.jpeg', 'JPG');

    textA = Screen('MakeTexture', cfg.win, double(imgA));
    textB = Screen('MakeTexture', cfg.win, double(imgB));
    textC = Screen('MakeTexture', cfg.win, double(imgC));
    textD = Screen('MakeTexture', cfg.win, double(imgD));
    textASel = Screen('MakeTexture', cfg.win, double(imgASel));
    textBSel = Screen('MakeTexture', cfg.win, double(imgBSel));
    textCSel = Screen('MakeTexture', cfg.win, double(imgCSel));
    textDSel = Screen('MakeTexture', cfg.win, double(imgDSel));
    textBlank = Screen('MakeTexture', cfg.win, double(imgBlank));

    deckA = [posX, posY, posX + cardWidth, posY + cardHeight];
    deckB = deckA + [posX + cardWidth, 0, posX + cardWidth, 0];
    deckC = deckB + [posX + cardWidth, 0, posX + cardWidth, 0];
    deckD = deckC + [posX + cardWidth, 0, posX + cardWidth, 0];



    %---Start up the NetStation session----------------------------------------
    if cfg.recordEeg
        [status, errMsg] = NetStation('Connect', '10.5.72.232');
        if status && ~cfg.debug;
            display(['Problem connecting to NetStation: ' errMsg]);
            quitExp;
        end
        
        %Sync NetStation and PsychToolbox times
        [status, errMsg] = NetStation('Synchronize');
        if status && ~cfg.debug;
            display(['Problem syncing time with NetStation: ' errMsg]);
            quitExp;
        end
        
        %Start recording.
        [status, errMsg] = NetStation('StartRecording');
        if status && ~cfg.debug;
            display(['Problem starting NetStation recording: ' errMsg]);
            quitExp;
        end
    end

    %----Main Block Loop-------------------------------------------------------

    %cumulative reward/punishment tracking variables
    acc_reward = 0;
    acc_punish = 0;

    %loop over the number of blocks
    for block = 1:cfg.blocks
        
        textures = {textA textB textC textD};
        selecteds = {textASel textBSel textCSel textDSel};
        locations = {deckA' deckB' deckC' deckD'};

        %setup decks for this block
        decks = penalty_dist(cfg.deckMax);	% 40 card in each deck

        % shuffle decks
        shuffleDecks = randperm(4);

        %log:
        %deck assignment
        %Columns are: itr, cardTime, keyTime, fdbkTime, origSel, selectedDeck, reward, punish
        fid = fopen(cfg.fileName, 'a');
        fprintf(fid, '%s \n\r', num2str(shuffleDecks));
        fprintf(fid, '%s \n\r', 'itr, cardTime, keyTime, fdbkTime, origSel, selectedDeck, reward, punish');
        fclose(fid);

        %Ready to go!
        DrawFormattedText(cfg.win, 'Press SPACE to begin.', 'center', 'center');
        Screen('Flip', cfg.win);
        while KbCheck; end;
        KbWait;

        %%%Main Trial Loop%%%
        itr = 1;
        while itr <= cfg.maxItr  % iteration of card selection by subject

            %Generate deck stimuli
            %showDecks(cfg.win, decks, shuffleDecks);
            for deck = 1:4
                if decks.index(1,shuffleDecks(deck)) > cfg.deckMax
                    textures{deck} = textBlank;
                end
                Screen('DrawTextures', cfg.win, textures{deck}, [], locations{deck});
            end

            %put a fixation cross on the screen
            DrawFormattedText(cfg.win,'+','center','center');

            %Flip the deck stimuli to the screen
            [cardTime] = Screen(cfg.win, 'Flip');

            %Send an event signal to NetSTation
            %[status, errMsg] = NetStation('Event', 'STIM', cardTime, [], 'tria', itr);
            if cfg.recordEeg
                [status, errMsg] = NetStation('Event', 'STIM', cardTime);
                if status && ~cfg.debug;
                    display(['Problem recording event: ' errMsg]);
                    quitExp;
                    return
                end
            end

            %wait for key press
            while 1
                FlushEvents;
                [keyIsDown, keyTime, keyCode] = KbCheck;
                thisKey = KbName(keyCode);
                if strcmp(thisKey, cfg.escape); quitExp; return; end
                if keyIsDown == 1 %&& any(strcmp(cfg.validResp,thisKey(1)))
                    %wait for them to release the key and move on
                    while KbCheck; end
                    break
                end
            end
            switch thisKey(1)
                case {'1!','1'}; selectedDeck = 1;
                case {'2@','2'}; selectedDeck = 2;
                case {'3#','3'}; selectedDeck = 3;
                case {'4$','4'}; selectedDeck = 4;
                otherwise; selectedDeck = 0;
            end

            % convert user selection to shuffle decks
            origSel = selectedDeck;
            if selectedDeck ~= 0
                selectedDeck = shuffleDecks(selectedDeck);
                
                %put an event selection event in the netstation file. This
                %will be different for "safe" vs. "risky" decks. The code
                %is SAFE for "safe" decks (C and D) and RISK for "risky"
                %decks (A and B).
                if cfg.recordEeg
                    switch selectedDeck
                        case {1,2}; respCode = 'RISK';
                        case {3,4}; respCode = 'SAFE';
                        otherwise; respCode = 'RESP';
                    end
                    [status, errMsg] = NetStation('Event', respCode, keyTime);
                    if status && ~cfg.debug;
                        display(['Problem recording event: ' errMsg]);
                        quitExp;
                        return
                    end
                end

                % draw cards again to indicate selection
                for deck = 1:4
                    if decks.index(1,shuffleDecks(deck)) > cfg.deckMax
                        textures{deck} = textBlank;
                    end
                    Screen('DrawTextures', cfg.win, textures{deck}, [], locations{deck});
                end
                %mark_selectedDeck(cfg.win, orig_sel);
                Screen('DrawTextures', cfg.win, selecteds{origSel}, [], locations{origSel});
                %put a fixation cross on the screen
                DrawFormattedText(cfg.win,'+','center','center');

                %Flip the deck stimuli to the screen
                [selectTime] = Screen(cfg.win, 'Flip');

                %Send an event signal to NetSTation
                if cfg.recordEeg
                    [status, errMsg] = NetStation('Event', 'SELT', selectTime);
                    if status && ~cfg.debug;
                        display(['Problem recording event: ' errMsg]);
                        quitExp;
                        return
                    end
                end

                if (decks.index(1,selectedDeck) <= cfg.deckMax)

                    %calculate feedback
                    reward = decks.reward(selectedDeck ,decks.index(1, selectedDeck));
                    punish = decks.punish(selectedDeck ,decks.index(1, selectedDeck));
                    decks.index(1, selectedDeck) = decks.index(1, selectedDeck) + 1;

                    %display feedback
                    %show_msg(cfg.win, current_reward, punish, orig_sel);
                    if punish == 0
                        msg = ['You won: ' num2str(reward) ];
                    else
                        msg = ['You won: ' num2str(reward) '\n' ...
                            'But lost: ' num2str(punish)];
                    end
                    %draw cards again
                    for deck = 1:4
                        if decks.index(1,shuffleDecks(deck)) > cfg.deckMax
                            textures{deck} = textBlank;
                        end
                        Screen('DrawTextures', cfg.win, textures{deck}, [], locations{deck});
                    end
                    %put the message in
                    DrawFormattedText(cfg.win,msg,'center','center');
                    %mark_selectedDeck(cfg.win, orig_sel);
                    Screen('DrawTextures', cfg.win, selecteds{origSel}, [], locations{origSel});

                    %wait a pre-specified time between button press and
                    %feedback
                    while GetSecs < selectTime + cfg.RespFdbkDelay
                    end
                        
                    %Flip the deck stimuli to the screen
                    [fdbkTime] = Screen(cfg.win, 'Flip');

                    %calculate the outcome code
                    % Each place is a deck (1000 = A, 0100 = B, 0010 = C,
                    % 0001 = D)
                    % Each digit is an outcome (1 = positive, 2 = negative)
                    % codes: 
                    %   1000 = +100
                    %   2000 = -250
                    %   0100 = +100
                    %   0200 = -1250
                    %   0010 = +50
                    %   0020 = -50
                    %   0001 = +50
                    %   0002 = -250
                    
                    feedbackCode = '0000';
                    if punish == 0
                        code = '1'; 
                    else
                        code = '2';
                    end
                    feedbackCode(selectedDeck) = code;
                    
                    %Send an event signal to NetSTation
                    if cfg.recordEeg
                        [status, errMsg] = NetStation('Event', feedbackCode, fdbkTime);
                        if status && ~cfg.debug;
                            display(['Problem recording event: ' errMsg]);
                            quitExp;
                            return
                        end
                    end
                    
                    %log the data for this trial
                    fid = fopen(cfg.fileName, 'a');
                    fprintf(fid, '%d, %f, %f, %f, %d, %d, %d, %d\n\r', itr, cardTime, keyTime, fdbkTime, origSel, selectedDeck, reward, punish);
                    fclose(fid);


                    %leave the feedback up for 1.25 seconds
                    while GetSecs < 1.25 + fdbkTime; end;
                    %Screen(cfg.win, 'Flip');

                    %record responses, sequence
                    cfg.cardTime(itr,block)     = cardTime;
                    cfg.keyTime(itr,block)      = keyTime;
                    cfg.fdbkTime(itr,block)     = fdbkTime;
                    cfg.origSel(itr,block)      = origSel;
                    cfg.selectedDeck(itr,block) = selectedDeck;
                    cfg.reward(itr,block)       = reward;
                    cfg.punish(itr,block)       = punish;

                    %increment the itr counter
                    itr = itr + 1;

                    %accumulate reward, punishment
                    acc_reward = acc_reward + reward;
                    acc_punish = acc_punish + punish;
                end
            end
        end %while itr <= cfg.maxItr

        %reset the decks variable.
        clear decks;
        %clear the display
        %Screen(cfg.win, 'Flip');

        %give some feedback:
        DrawFormattedText(cfg.win, ['End of block. \n\n Total gained: ' ...
            num2str(acc_reward) '\n Total lost: ' num2str(acc_punish)], ...
            'center','center');
        [t] = Screen(cfg.win, 'Flip');
        
        %wait 5 seconds while the totals are on the screen
        while GetSecs < t + 5; end
        %while KbCheck; end;
        %KbWait;


    end %for block = 1:cfg.blocks

    DrawFormattedText(cfg.win, ['Your total score: \n\n' ...
        'Total gained: ' num2str(acc_reward) ...
        '\n Total lost: ' num2str(acc_punish)], ...
        'center','center');
    Screen(cfg.win,'Flip');
    while KbCheck; end
    KbWait;
    
    quitExp;

catch

    quitExp;
    
end

end


%----------------------------------------------------------------------
function quitExp
%----------------------------------------------------------------------
%super-slick bit of code to gracefully exit any time the 'ESC' key is
%pressed during the experiment.

global DATA

save(cfg.matFileName,'DATA');

Screen('Flip', cfg.win);

%stop NetStation recording
NetStation('StopRecording');

%disconnect NetStation
NetStation('Disconnect');

DrawFormattedText(cfg.win, 'Thank you!', 'center', 'center',[0,0,0,255]);
Screen('Flip',cfg.win);
while KbCheck; end;
KbWait;

Screen('closeall');
ListenChar(0);
end



