% Scripted by Carina Mendes (cmendes) 
% acmendes@medicina.ulisboa.pt / acarinapmendes@gmail.com
% LAB - signals - EEG + EYETRACKING (pupilometry)
% 
% INFORMATION GIVEN BY THE EXPERIMENTER
% 1. Subject ID - must contain up to 8 characters (letters, numbers or special
% characters)
% 2. EyeLink mode - insert 1 or 0. If 1 is inserted, the task will run with
% Eyelink in dummy mode, thus no eye tracking data will be recorded, and Esc 
% should be pressed when EyeLink options show up. If 0 is inserted, eye tracking
% data will be recorded.
% NOTE: if the user chooses to use the eyetracker, calibration should be
% performed (instructions on which keys to press will show up on screen).
% 3. Sequence - choose pseudo-randomised sequence. For EEG acquisitions
% (more trials), choose from 1 to 4, and for shorter acquisitions choose a
% sequence from 5 to 8. There are 4 sequences in total for each setup.
% Information contained by this sequences include: (1) Type of trial order,
% (2) stimuli order according the type, and (3) jitter order.
% 
% INFORMATION SAVED IN THE LOGFILE
% A logfile is saved in the folder
% RESULTS_AUT\'ID_inserted_by_user'\'ID_inserted_by_user_date_time.results'
% for example
% if the experiment was ran on 16.12 @14h00, and the ID was 'sub01', the
% logfile would be stored in:
% RESULTS_AUT\sub01\sub01_16-Dez-2016_14_00_00.results'
% Contents of this file include (title in log file -- description):
% subject ID  script started (s) - time when script started -- file header
% (a) Trial start (s) -- moment when the trial starts
% (b) Trial # -- trial number
% (c) Sound Name -- name of presented stimulus
% (d) Sound file duration (s) -- duration of sound stimulus
% (d) Sound start (s) -- moment when stimulus was presented to the subject
% (e) Sound end (s) -- moment when stimulus ended
% (f) Scale presentation - aut (s) -- moment when first scale was presented
% (g) Autenticidade - Response -- participant response
% (h) Res (s) -- moment when participant responded
% (i) ResTime (s) -- time between scale presentation and response
% 
% Information of each trial is recorded as a new line in this log.
% If for some reason the experimenter decides to interrupt the task, that
% information is recorded in the logfile with the following message:
% "The task was interrupted by the user! (in trial #)"
% 
% 
% IMPORTANT NOTES FOR CODERS
% Sequences used
% These are loaded from the folder 'sequences', and should follow the
% naming 'sequence#.mat'.
% The variables saved in the sequence mat file, in order to work with this 
% script should be called:
% (1) trialOrder
% (2) sound_name
% (3) jitter_def
% 
% trialOrder is a double vector and can contain 5 different type of entries:
% 1	- REAL LAUGHTER
% 2	- POSED LAUGHTER
% 3	- REAL CRYING
% 4	- POSED CRYING
% 5	- NEUTRAL NT (INVERSOES ESPECTRAIS)
% 6 - NEUTRAL NTV (VOCALIZACOES)
% 
% sound_name is a cell vector and contains the sound names to be called in
% this script. Each sound entry should correspond to the entry in
% trialOrder.
% Example: if trialOrder(24) = 2, sound_name(24) = 'posed_laughter_sound'
% 
% jitter is a double vector and can contain 3 different type of entries
% 0 - 4 sec
% 1 - 3 sec
% 2 - 3.5 sec
% 
% 
% For EEG markers look for '% EEG'
% For eyetracking code look for '% EYELINK'
% 
% marker information (LPT port) for the biopac and EEG systems:
% 1 - start of trial
% 2 - 1st scale presentation (autenticidade)
% 3 - 1st choice
% 4 - end of trial
% markers for sounds:
% 5 - start Real laughter
% 6 - end Real laughter
% 7 - start posed laughter
% 8 - end posed laughter
% 9 - start baseline (neutral) - spectral inversion
% 10 - end baseline (neutral) - spectral inversion
% 11 - start Real crying
% 12 - end Real crying
% 13 - start posed crying
% 14 - end posed crying
% 15 - start baseline (ntv) - neutral vocalisation
% 16 - end baseline (ntv) - neutral vocalisation
% markers for rest trial
% 17 - start of 30s pause
% 18 - end of 30s pause
% 
% Communication with the EyeLink1000 system is done through messages
% Trial #d
% rest start (30s)/ rest end (30s) - every 20 trials
% Fixation Cross
% Start of sound presentation, 'type of sound' - 'name of sound'
% End of sound presentation, 'type of sound' - 'name of sound'
% Choice Screen - Autenticidade
% IF PARTICIPANT CHOOSES AN OPTION: Answered - autenticidade
% End of trial #d
%
%% CLEANUP - make sure no variables are in the workspace
clear all; clc

%%  SCREEN SETUP
output_screen = 1; % 1 for primary, 2 for secondary, ...
screens = Screen('Screens');
screenNumber = max(screens);

if screenNumber > 0 % find out if there is more than one screen
    dual = get(0,'MonitorPositions');
    resolution = [0,0,dual(output_screen,3),dual(output_screen,4)];
elseif screenNumber == 0 % if not, get the normal screen's resolution
    resolution = get(0,'ScreenSize');
end
data.format.resolx = resolution(3);
data.format.resoly = resolution(4);

% cleanup unused variables
clear output_screen screens resolution dual


%% PARAMETERS - SETUP & INITIALISATION
AssertOpenGL; % gives warning if running in PC with non-OpenGL based PTB

% task path
if (~isdeployed)
    scriptName = mfilename('fullpath'); [pathz,~,~]= fileparts(scriptName);
else
    pathz = uigetdir(...
        'C:\Users\DPrataLab\Documents\Tarefas\VocalizationPTB\LAB',...
        'Select task path:');
end
cd(pathz) % go to path where task is running

% Initialise sound driver - changed to low latency? - & open audio device
InitializePsychSound(1); phndl = PsychPortAudio('Open',[],[],0,44100,1);

% Formatting options
data.format.fontSize = 40;
data.format.fontSizeFixation = 120;
data.format.font = 'Arial';
data.format.background_color = [150 150 150]; % grey 150!
% initialise system for key query - changed 'UnifyKeyNames' to 'KeyNames' due to
% the keyboard usage
KbName('KeyNames');
keyDELETE = KbName('delete'); keySPACE = KbName('space');
keyZ = KbName('z'); % 1
keyX = KbName('x'); % 2
keyC = KbName('c'); % 3
keyV = KbName('v'); % 4
keyB = KbName('b'); % 5
keyN = KbName('n'); % 6
keyM = KbName('m'); % 7

% instructions definition
data.text.getready = 'Quando estiver pronto pressione a tecla SPACE.';
data.text.instructions_p1 = ['Nesta tarefa irá ouvir sons. \n\n',...
    'Será pedido que faça diferentes julgamentos \n',...
    'acerca da autenticidade de sons emocionais, \n',...
    'enquanto em sons neutros pedimos apenas que \n',...
    'preste atenção. \n\n',...
    'A autenticidade é definida como a propriedade de \n',...
    'genuinidade de uma emoção, podendo ser classificada \n',...
    'como genuína (autêntica) ou forçada (não autêntica).\n\n',...
    'Por favor, responda apenas no fim de cada som, \n',...
    'e efetue a resposta com base na sua primeira impressão.\n\n',...
    'Pressione a tecla SPACE para começar.'];

% get rating image & size
data.image.ima = imread('aut1_full.jpg');
imX = 1920; imY = 1080; % image resolution 1920x1080
data.image.image_size = ...
    [(data.format.resolx - imX)/2, (data.format.resoly - imY)/2,...
    imX, imY];
clear imX imY; % cleanup unused variables

% user input - participant information
% get user input for usage or not of eyelink
prompt={'Introduza o ID do participante',...
    'dummymode = 1 | recolha = 0',...
    'Escolha a sequencia pretendida (1 - 4)'};
dlg_title='Input';
% default: no ID, eyetracker in dummy mode, sequence 1, pupilometry
data.input = inputdlg(prompt,dlg_title,1,{'...','1','1'});
% get time of experiment
clock_var = clock; clock_var = [num2str(clock_var(4)),'_',...
    num2str(clock_var(5)),'_',num2str(round(clock_var(6)))];
% name for log file
ppid = [data.input{1},'_',date,'_',clock_var];

% select sequence to use
if str2double(data.input{3}) == 1
    load('sequences\sequence1.mat');
elseif str2double(data.input{3}) == 2
    load('sequences\sequence2.mat');
elseif str2double(data.input{3}) == 3
    load('sequences\sequence3.mat');
elseif str2double(data.input{3}) == 4
    load('sequences\sequence4.mat');
else
    error('Selected sequence does not exist');
end

% save information from chosen sequence in the 'data' structure
data.sequences.trialOrder = trialOrder; 
data.sequences.jitt_def1 = jitter_def;
data.sounds.files = sound_name;

% get subject id folder to store result files
if ~isdir(['RESULTS_AUT\',data.input{1}])
    mkdir(['RESULTS_AUT\',data.input{1}]);
end

% log file creation + open file
logFile = strcat(['RESULTS_AUT\',data.input{1},'\',ppid,'.results']);
logfid = fopen(logFile,'a');

% subject identification
fprintf(logfid,'%s%s\t\t%s%s\t\t%s%s\t\t%s%s',...
    'ID: ',data.input{1},...
    'Date: ',date,...
    'Time: ', [num2str(clock_var(5)),'h ',num2str(round(clock_var(6))),'m'],...
    'Sequence: ',data.input{3});
% table header
fprintf(logfid,'\n\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
    'Trial #','Trial start (s)','Sound Name','Sound file duration (s)',...
    'Sound start (s)','Sound end (s)',...
    'Scale presentation - aut (s)',...
    'Autenticidade - Response','Res (s)','ResTime (s)');

% cleanup unused variables
clear prompt dlg_title num_lines ppid scriptName ii


% Initialise EEG
config_io
outp(888,0);
LPT_interval = 0.01; % edited - 10 ms
WaitSecs(LPT_interval);

% Initialise Eyelink
dummymode = str2double(data.input(2)); % set to 1 to initialise in dummymode
data.leadout_duration = 5;


%% INITIALISE WINDOW
% Open window with default settings:
% PTB screen & keyboard
% set 1 in the SkipSyncTests for debugging purposes and 0 for real aquisitions
Screen('Preference','SkipSyncTests', 1);
[w,~] = Screen('OpenWindow',screenNumber,data.format.background_color);
HideCursor(w);
PsychTweak('UseGPUIndex', 1);
Screen('TextSize',w,data.format.fontSize);
Screen('TextFont',w,data.format.font);
Screen('TextStyle', w, 1);

% prepare texture with scale to use
tex = Screen('MakeTexture',w,data.image.ima);

% get monitor frame rate
nominalFrameRate = Screen('NominalFrameRate', w);

% EYELINK - start
Screen('BlendFunction',w,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
el = EyelinkInitDefaults(w);

% Initialisation of the connection with the Eyelink Gazetracker
% exits if this fails
if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
    cleanup;
end

% check the eyetracker and host software versions
[v, vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n',vs);

% open file to record data
edfF = Eyelink('Openfile',[data.input{1},'.edf']);
if edfF ~= 0
    fprintf('Cannot create EDF file ''%s''',[data.input{1},'.edf']);
    Eyelink('Shutdown');
    Screen('CloseAll');
end


% first message
Eyelink('command',...
    'add_file_preamble_text ''AutenticidadeC Recorded by EyeLink 1000 Plus''');


% SET UP TRACKER CONFIGURATION
% setting: proper recording resolution, calibration type and data file content
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld',...
    0,0,data.format.resolx-1,data.format.resoly-1);
Eyelink('command','DISPLAY_COORDS %ld %ld %ld %ld',...
    0,0,data.format.resolx-1,data.format.resoly-1);
% calibration type - set
Eyelink('command','calibration_type = HV9');

% set parser (conservative saccade thresholds)
% set EDF file using the file_sample_data and file-event_filter commands
% set link data through link_sample_data and link_event_filter
Eyelink('command',...
    ['file_event_filter = '...
    'LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT']);
Eyelink('command',...
    ['link_event_filter = '...
    'LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT']);
% check the software version
% add "HTARGET" to record possible target data for EyeLink Remote
% if it doesn't work switch condition with this: sscanf(vs(12:end),'%f') >= 4
if v >= 4 
    Eyelink('command',...
        ['file_sample_data = '...
        'LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,PUPIL,GAZERES,STATUS,INPUT']);
    Eyelink('command',...
        ['link_sample_data = '...
        'LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,PUPIL,STATUS,INPUT']);
else
    Eyelink('command',...
        ['file_sample_data = '...
        'LEFT,RIGHT,GAZE,HREF,AREA,PUPIL,GAZERES,STATUS,INPUT']);
    Eyelink('command',...
        ['link_sample_data = '...
        'LEFT,RIGHT,GAZE,GAZERES,AREA,PUPIL,STATUS,INPUT']);
end

% make sure we're still connected
if Eyelink('IsConnected') ~= 1 && dummymode == 0
    fprintf('not connected, clean up\n');
    Eyelink('Shutdown');
    Screen('CloseAll');
end

% EYELINK - end
    

%% EYELINK - calibration
% setup the proper calibration foreground and background colors
el.backgroundcolour = [150 150 150]; % original - 255 255 255
el.calibrationtargetcolour = [0 0 0];
el.msgfontcolour = [0 0 0];
el.calibrationtargetwidth = 0.5;

% parameters are in frequency, volume and duration
% set the second value in each line to 0 to turn off the sound
el.cal_target_beep = [600 0.5 0.05];
el.drift_correction_target_beep = [600 0.5 0.05];
el.calibration_failed_beep = [400 0.5 0.25];
el.calibration_success_beep = [800 0.5 0.25];
el.drift_correction_failed_beep = [400 0.5 0.25];
el.drift_correction_success_beep = [800 0.5 0.25];

% apply changes above
EyelinkUpdateDefaults(el);
% do setup and calibrate the eye tracker
EyelinkDoTrackerSetup(el);

% % do a final check of calibration using drift correction
% % you have to hit esc before return
% EyelinkDoDriftCorrection(el);
WaitSecs(0.5);

% EYELINK - calibration - end

%% INITIALISE VARIABLES

% flag - 1 if user decides to end task
interrupt = 0;

wait_time = 3; % definition of time to wait after stimulus presentation
scale_presentation_time = 5; % duration of scale presentation

% variable to create 30s countdown
data.values.restTrial = sort(repmat(1:30, 1, nominalFrameRate), 'descend');
%
% allocate variable space
% allocation of other struct data fields (double/cell)
% double variables
data.values.trialStart = zeros(1,size(data.sequences.trialOrder,1));
data.values.soundStart = zeros(1,size(data.sequences.trialOrder,1));
data.values.soundEnd = zeros(1,size(data.sequences.trialOrder,1));
data.values.off = zeros(1,size(data.sequences.trialOrder,1));
data.values.offoff = zeros(1,size(data.sequences.trialOrder,1));
data.values.rtime_aut = zeros(1,size(data.sequences.trialOrder,1));
% cell variables
data.values.response_aut = cell(1,size(data.sequences.trialOrder,1));
%
% AUX script to pre-load sounds to be used during the task
aut_compS_aux_loadSounds

%% STARTUP - INSTRUCTIONS
% startup screen - press space when ready to read the instructions
DrawFormattedText(w,data.text.getready,'center','center',0);

% EYELINK
Eyelink('Message','Initial Screen');
% this supplies the title at the bottom of the tracker display
Eyelink('command','record_status_message "Initial Screen"');

Screen('Flip',w);

nextScreen = 1;
while nextScreen == 1
    [~,keyCode,~] = KbPressWait();
    if keyCode(keyDELETE)
        sca;
        Eyelink('Shutdown');
        
        % terminate the task
        warndlg('You decided to terminate the task!')
        return;
        
    elseif keyCode(keySPACE)
        nextScreen = 0;
    end
end

% instruction screen
DrawFormattedText(w,data.text.instructions_p1,'center','center',0);

% EYELINK
Eyelink('Message','Instructions Screen');
% this supplies the title at the bottom of the tracker display
Eyelink('command','record_status_message "Instructions Screen"');

Screen('Flip',w);

% exits with DELETE keypress
nextScreen = 1;
while nextScreen == 1
    [~,keyCode,~]=KbPressWait();
    if keyCode(keyDELETE)
        sca;
        Eyelink('Shutdown');
        
        % terminate the task
        warndlg('You decided to terminate the task!')
        return;
        
    elseif keyCode(keySPACE)
        nextScreen = 0;
    end
end

clear nextScreen keyCode % cleanup

% get fontsize = 120 - to present text bigger throughout the task
% it does not affect the scale since it is presented as an image!
Screen('TextSize',w,data.format.fontSizeFixation);

%% TASK
for i = 1:size(data.sequences.trialOrder,1)

    if i == 1
        first_trial = GetSecs;
        data.values.trialStart(i) = GetSecs - first_trial;
    else
        data.values.trialStart(i) = GetSecs - first_trial;
    end
    
    % get fixation cross
    % shows throughout both fixation and sound presentation blocks
    DrawFormattedText(w,'+','center','center');
    
    % EYELINK - start
    % before the flip to the fixation screen and start the trial 
    % - send information about which trial we are in and start recording
    Eyelink('Message','TRIALID %d',i);
    Eyelink('command','record_status_message "TRIAL %d/%d"',...
        i,size(data.sequences.trialOrder,1));
    % before recording place reference graphics on the host display must be
    % offline to draw to Eyelink screen
    Eyelink('command','set_idle_mode');
    % clears tracker display and draw cross at center
    Eyelink('command','clear_screen 0');
    Eyelink('command','draw_cross %d %d',...
        data.format.resolx/2,data.format.resoly/2);
    % EYELINK - end
    
    Screen('Flip',w);
    
    % EYELINK - start recording
    Eyelink('command','set_idle_mode');
    Eyelink('StartRecording');
    
    % have a 30s rest at 3 different moments
    if i == 51 || i == 102 || i == 153
        
        % EYELINK - start of rest moment before trial (30s)
        Eyelink('Message','rest start (30s)');
        
        % EEG
        outp(888,17); % start of 30s rest trial
        
        for m = 1:length(data.values.restTrial)
            numStr = ['Relaxe\n',...
                num2str(data.values.restTrial(m))];
            
            DrawFormattedText(w,numStr,'center','center');
            Screen('Flip', w);
        end
        % restart the task
        DrawFormattedText(w,'Agora preste atenção.','center','center');
        Screen('Flip',w);
        
        % EYELINK - end of rest moment before trial
        Eyelink('Message','rest end (30s)');
        
        % EEG
        outp(888,18); % end of 30s rest trial
        
        WaitSecs(2);
        
        % fixation cross
        DrawFormattedText(w,'+','center','center');
        Screen('Flip',w);
    end
    
    % EYELINK - start of trial - 1st fixation cross
    Eyelink('Message','Fixation Cross');

    % EEG
    outp(888,1); %1 - Start of trial

    % definition of jitter (3.5 +/- 0.5 sec)
    if data.sequences.jitt_def1(i) == 1
        WaitSecs(3);
    elseif data.sequences.jitt_def1(i) == 2
        WaitSecs(3.5);
    else
        WaitSecs(4);
    end

    PsychPortAudio('FillBuffer', phndl, data.sound.y{1,i}'); % load    
    
    % EYELINK - write out message to get moment where sound was presented
    % trial type (from 1 to 5) - sound name
    Eyelink('Message','Start of sound presentation, %d - %s',...
        data.sequences.trialOrder(i),data.sounds.files{i});
    
    data.values.soundStart(i) = GetSecs - first_trial;
    PsychPortAudio('Start', phndl); % play sound
    
    % EEG
    outp(888,marker_start(i)); % - Start of sound - is dependent of sound type!
    
    % sound duration
    WaitSecs(data.sound.lenghtOrig(i));
    
    data.values.soundEnd(i) = GetSecs - first_trial;
    
    % EYELINK - write out message to get moment where sound ended
    Eye
    link('Message','End of sound presentation, %d - %s',...
        data.sequences.trialOrder(i),data.sounds.files{i});
    
    % EEG
    outp(888,marker_end(i)); % - End of sound - is dependent of sound type
    
    WaitSecs(wait_time);

    if data.sequences.trialOrder(i) ~= 5 && data.sequences.trialOrder(i) ~= 6
        
        % present AUTENTICIDADE scale
        Screen('DrawTexture', w, tex,[],data.image.image_size);
        Screen('Flip',w);
        
        % moment of scale presentation
        data.values.off1(i) = ...
            GetSecs - first_trial;
        
        % Eyelink - write out message to get moment of scale presentation
        Eyelink('Message','Choice Screen - Autenticidade');
        
        % EEG
        outp(888,2); % 2 - Autenticidade - scale
         
        KbQueueCreate; KbQueueStart;
        while (GetSecs - first_trial - data.values.off1(i)) ...
                <= scale_presentation_time
            
            % no subject response
            data.values.response_aut{i} = 'NaN';
            
            [pressed,firstPress,~,~]= KbQueueCheck;
            if pressed
                if firstPress(keyDELETE)
                    interrupt = 1;
                    sca;
                    % aux function - write to log file
                    aut_compS_aux_writeLogFile(logfid,i,data,interrupt);
                    Eyelink('ShutDown');
                    
                    fprintf('\n\n\nSaving data, do not close matlab.\n');
                    if ~exist('BACKUP\','dir')
                        mkdir('BACKUP');
                    end
                    save(['BACKUP\interrupted_data_',data.input{1},'_',date,'_',clock_var],'data');
                    
                    % check if the edf file exists
                    if exist([data.input{1},'.edf'],'file') && dummymode == 0
                        movefile([data.input{1},'.edf'],['RESULTS_AUT\',data.input{1}]);
                    end
                    
                    % terminate the task
                    warndlg('You decided to terminate the task!')
                    return;
                    
                elseif firstPress(keyZ) || firstPress(keyX) || ...
                        firstPress(keyC) || firstPress(keyV) || ...
                        firstPress(keyB) || firstPress(keyN) || ...
                        firstPress(keyM)
                    
                    if firstPress(keyZ)
                        data.values.response_aut{i} = '1';
                    elseif firstPress(keyX)
                        data.values.response_aut{i} = '2';
                    elseif firstPress(keyC)
                        data.values.response_aut{i} = '3';
                    elseif firstPress(keyV)
                        data.values.response_aut{i} = '4';
                    elseif firstPress(keyB)
                        data.values.response_aut{i} = '5';
                    elseif firstPress(keyN)
                        data.values.response_aut{i} = '6';
                    else
                        data.values.response_aut{i} = '7';
                    end
                    
                    % EYELINK - register subject choice
                    Eyelink('Message','Answered - autenticidade');
                    
                    % moment of response
                    data.values.offoff1(i) = ...
                        GetSecs - first_trial; 
                    data.values.response_aut{i} = ...
                        data.values.response_aut{i}(1);
                    % response time
                    data.values.rtime_aut(i) = ...
                        data.values.offoff1(i) - data.values.off1(i); 
                    
                    % EEG
                    outp(888,3); % 3 - Choice
                    
                    break;
                end
            end
        end
        KbQueueStop; KbQueueRelease; % stop key query

        if i == size(data.sequences.trialOrder,1)
            DrawFormattedText(w,'+','center','center');
            Screen('Flip',w);
        end
        
    end
    % EEG
    outp(888,4); %4 - End of trial
    
    % EYELINK
    % - write out message that registers the end of trial and stop recording
    Eyelink('Message','End of trial %d',i);
    Eyelink('StopRecording');
    Eyelink('Message','TRIAL_RESULT 0');
    
    %% CLEANUP BEFORE NEXT TRIAL
    clear n
    
end

% aux function - write to log file
aut_compS_aux_writeLogFile(logfid,i,data,interrupt);

%% CLOSING EYETRACKER FILE

Eyelink('command', 'set_idle_mode');
WaitSecs(data.leadout_duration);
Eyelink('CloseFile');

try
    fprintf('Receiving data file ''%s''\n',...
        [data.input{1},'.edf'] );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n',...
            [data.input{1},'.edf'], pwd );
    end
catch
    fprintf('Problem receiving data file ''%s''\n',...
        [data.input{1},'.edf'] );
end

% close the eye tracker and window
Eyelink('ShutDown');
Screen('CloseAll');


%% CLOSE FINAL SCREEN
fprintf('\n\n\nSaving data, do not close matlab.\n');
save(['backup\data_',data.input{1},'_',date,'_',clock_var],'data');

% check if the edf file exists
if exist([data.input{1},'.edf'],'file') && dummymode == 0
    movefile([data.input{1},'.edf'],['RESULTS_AUT\',data.input{1}]);
end

% final cleanup
clear pathz w screenNumber i n flag pressed firstPress phndl logfid clock_var...
    keyDELETE keySPACE logFile marker_end marker start