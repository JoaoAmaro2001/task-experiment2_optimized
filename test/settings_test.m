% Init pc-specific paths and variables
setpath;

% Directories
docs_path     = fullfile(scripts,'docs');
allstim_path  = fullfile(sourcedata, 'supp', 'allStimuli');
stim_path     = fullfile(sourcedata, 'supp', 'stimuli');
logs_path     = fullfile(sourcedata, 'supp', 'logfiles');
event_path    = fullfile(sourcedata, 'supp', 'events');
data_path     = fullfile(sourcedata, 'data');

%  SCREEN SETUP
output_screen = 2; % 1 for primary, 2 for secondary, ...
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

% Formatting options
data.format.fontSize = 40;
data.format.fontSizeFixation = 120;
data.format.font = 'Arial';
data.format.background_color = [255 255 255]; % grey 150!
% initialise system for key query - changed 'UnifyKeyNames' to 'KeyNames' due to
% the keyboard usage
KbName('UnifyKeyNames')
keyDELETE = KbName('delete'); keySPACE = KbName('space');
keyZ = KbName('z'); % 1
keyX = KbName('x'); % 2
keyC = KbName('c'); % 3
keyV = KbName('v'); % 4
keyB = KbName('b'); % 5
keyN = KbName('n'); % 6
keyM = KbName('m'); % 7

% instructions definition
data.text.taskname          = 'videorating';
data.text.getready_en       = 'The experiment will start shortly';
data.text.getready_pt       = 'A experiência começará em breve';
data.text.starting_en       = 'Starting in';
data.text.starting_pt       = 'Começa em';
data.text.baselineClosed_en = 'Baseline with eyes closed will start shortly';
data.text.baselineClosed_pt = 'O periodo de relaxamento com olhos fechados começará em breve';
data.text.baselineOpen_en   = 'Baseline with eyes closed will start shortly';
data.text.baselineOpen_pt   = 'O periodo de relaxamento com olhos fechados começará em breve';

% get rating image & size
imX = 1920; imY = 1080; % image resolution 1920x1080
data.image.image_size = ...
    [(data.format.resolx - imX)/2, (data.format.resoly - imY)/2,...
    imX, imY];
clear imX imY; % cleanup unused variables

% user input - participant information
% get user input for usage or not of eyelink
prompt={'Introduza o ID do participante',...
    'dummymode = 1 | recolha = 0','Indique o número da sessão (run)'};
dlg_title='Input';
% default: no ID, eyetracker in dummy mode, sequence 1, pupilometry
data.input = inputdlg(prompt,dlg_title,1,{'...','1','1'});
% get time of experiment
dateOfExp = datetime('now');

% Filenames
data.text.elFileName        = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_eye'];
data.text.logFileName       = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_log'];
data.text.eegFileName       = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_eeg'];
data.text.eventFileName     = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_event'];

% select sequence to use
if str2double(data.input{3}) == 1
    generate_sequences;  % Generate new stimuli sequence
    sequence = load('sequences\sequence1.mat');
elseif str2double(data.input{3}) == 2
    sequence = load('sequences\sequence2.mat');
else
    warning('Selected sequence does not exist');
end

% save information from chosen sequence in the 'data' structure
data.sequences.trialOrder = sequence.sequenceNumbers; 
data.sequences.files      = sequence.sequenceFiles;

% get subject id folder to store result files
subjRootFolderName = ['sub-',data.input{1}];
if ~isfolder(fullfile(data_path, subjRootFolderName))
    mkdir(fullfile(data_path, subjRootFolderName));
end

% cleanup unused variables
clear prompt dlg_title num_lines ppid scriptName ii

% Settings for export options
exportXlsx = true;
exportTsv  = true;

% Initialise EEG -> Open NetStationAcquisition and start recording
input('Press Enter if NetStation Acquisition is running and recording.');

% -------------------------------------------------------------------------
%                   Initialise Psychtoolbox (original script)
% ------------------------------------------------------------------------- 

% Screen('Preference','SkipSyncTests', 1);
% [w,~] = Screen('OpenWindow',screenNumber,data.format.background_color);
% % HideCursor(w);
% PsychTweak('UseGPUIndex', 1);
% Screen('TextSize',w,data.format.fontSize);
% Screen('TextFont',w,data.format.font);
% Screen('TextStyle', w, 1);

% -------------------------------------------------------------------------
%                             SETUP SCREEN
% ------------------------------------------------------------------------- 
backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0;         % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1);   % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output

% -------------------------------------------------------------------------
%                             1 SCREEN
% -------------------------------------------------------------------------
% whichScreenMin = min(Screen('Screens')); % Get the screen numbers
% [screenWidth, screenHeight] = Screen('WindowSize', whichScreenMin); % Get the screen size
% 
% 
% [window_1, rect] = Screen('OpenWindow', whichScreenMin, backgroundColor, [0 0 screenWidth/2, screenHeight/2]);

% -------------------------------------------------------------------------
%                             2 SCREENS
% ------------------------------------------------------------------------- 
% whichScreenMax = max(Screen('Screens')); % Get the screen numbers
% [window_1, rect] = Screen('Openwindow',whichScreenMax,backgroundColor,[],[],2);

% -------------------------------------------------------------------------
%                             Continue
% -------------------------------------------------------------------------
% Screen('TextSize',window_1,data.format.fontSize);
% Screen('TextFont',window_1,data.format.font);
% Screen('TextStyle', window_1, 1);
% slack = Screen('GetFlipInterval', window_1)/2; %The flip interval is half of the monitor refresh rate; why is it here?
% Screen('FillRect',window_1, backgroundColor);  % Fills the screen with the background color
% Screen('Flip', window_1);                      % Updates the screen (flip the offscreen buffer to the screen)

% -------------------------------------------------------------------------
%                          Initialise Eyelink
% -------------------------------------------------------------------------
edfFileName = [data.input{1} '_' data.input{3}]; % cannot have more than 8 chars
[window_1, rect, el] = eyelinkExperiment2(screenNumber, edfFileName, data);

% -------------------------------------------------------------------------
%                             Get Screen Center
% -------------------------------------------------------------------------
W=rect(RectRight);                             % screen width
H=rect(RectBottom);                            % screen height
centerX = W / 2; 
centerY = H / 2;


% return;
% 
% [out, exitFlag] = rd_eyeLink('eyestart', window_1,[data.input{1},'.edf'])
% 
% 
% el.backgroundcolour = [150 150 150]; % original - 255 255 255
% el.calibrationtargetcolour = [0 0 0];
% el.msgfontcolour = [0 0 0];
% el.calibrationtargetwidth = 0.5;
% % parameters are in frequency, volume and duration
% % set the second value in each line to 0 to turn off the sound
% el.cal_target_beep = [600 0.5 0.05];
% el.drift_correction_target_beep = [600 0.5 0.05];
% el.calibration_failed_beep = [400 0.5 0.25];
% el.calibration_success_beep = [800 0.5 0.25];
% el.drift_correction_failed_beep = [400 0.5 0.25];
% el.drift_correction_success_beep = [800 0.5 0.25];
% 
% [out, exitFlag] = rd_eyeLink('calibrate', window_1, el);
% 
% while 1
%     [keyIsDown, ~, keyCode] = KbCheck;
%     if keyIsDown
%         if keyCode(keyDELETE)
%             disp('Delete key pressed, breaking the loop.');
%             break; % Exit the loop
%         end
%     end
% end
% 
% dummymode = str2double(data.input(2)); % set to 1 to initialise in dummymode
% data.leadout_duration = 5;
% 
% status_el   = Eyelink('IsConnected');
% % if status_el ~= 1
% % ipadress    = '100.1.1.2'; % check in cmd >>> ipconfig /all 
% % status_ip   = Eyelink('SetAddress', ipadress); % Check connection
% % status_el   = Eyelink('IsConnected');
% % end
% 
% % EYELINK - start
% Screen('BlendFunction',window_1,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
% el = EyelinkInitDefaults(window_1);
% 
% % Initialisation of the connection with the Eyelink Gazetracker
% % exits if this fails
% if ~EyelinkInit(dummymode)
%     fprintf('Eyelink Init aborted.\n');
%     cleanup;
% end
% 
% % check the eyetracker and host software versions
% [v, vs] = Eyelink('GetTrackerVersion');
% fprintf('Running experiment on a ''%s'' tracker.\n',vs);
% 
% % open file to record data
% edfF = Eyelink('Openfile',[data.input{1},'.edf']);
% if edfF ~= 0
%     fprintf('Cannot create EDF file ''%s''',[data.input{1},'.edf']);
%     Eyelink('Shutdown');
%     Screen('CloseAll');
% end
% 
% % first message
% Eyelink('command',...
%     'add_file_preamble_text ''AutenticidadeC Recorded by EyeLink 1000 Plus''');
% 
% 
% % SET UP TRACKER CONFIGURATION
% % setting: proper recording resolution, calibration type and data file content
% Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld',...
%     0,0,data.format.resolx-1,data.format.resoly-1);
% Eyelink('command','DISPLAY_COORDS %ld %ld %ld %ld',...
%     0,0,data.format.resolx-1,data.format.resoly-1);
% % calibration type - set
% Eyelink('command','calibration_type = HV9');
% 
% % set parser (conservative saccade thresholds)
% % set EDF file using the file_sample_data and file-event_filter commands
% % set link data through link_sample_data and link_event_filter
% Eyelink('command',...
%     ['file_event_filter = '...
%     'LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT']);
% Eyelink('command',...
%     ['link_event_filter = '...
%     'LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT']);
% % check the software version
% % add "HTARGET" to record possible target data for EyeLink Remote
% % if it doesn't work switch condition with this: sscanf(vs(12:end),'%f') >= 4
% if v >= 4 
%     Eyelink('command',...
%         ['file_sample_data = '...
%         'LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,PUPIL,GAZERES,STATUS,INPUT']);
%     Eyelink('command',...
%         ['link_sample_data = '...
%         'LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,PUPIL,STATUS,INPUT']);
% else
%     Eyelink('command',...
%         ['file_sample_data = '...
%         'LEFT,RIGHT,GAZE,HREF,AREA,PUPIL,GAZERES,STATUS,INPUT']);
%     Eyelink('command',...
%         ['link_sample_data = '...
%         'LEFT,RIGHT,GAZE,GAZERES,AREA,PUPIL,STATUS,INPUT']);
% end
% 
% % make sure we're still connected
% if Eyelink('IsConnected') ~= 1 && dummymode == 0
%     fprintf('not connected, clean up\n');
%     Eyelink('Shutdown');
%     Screen('CloseAll');
% end
% 
% % EYELINK - end
% 
% % -------------------------------------------------------------------------
% %                       Eyelink Calibration
% % -------------------------------------------------------------------------
% 
% %% EYELINK - calibration
% % setup the proper calibration foreground and background colors
% el.backgroundcolour = [150 150 150]; % original - 255 255 255
% el.calibrationtargetcolour = [0 0 0];
% el.msgfontcolour = [0 0 0];
% el.calibrationtargetwidth = 0.5;
% 
% % parameters are in frequency, volume and duration
% % set the second value in each line to 0 to turn off the sound
% el.cal_target_beep = [600 0.5 0.05];
% el.drift_correction_target_beep = [600 0.5 0.05];
% el.calibration_failed_beep = [400 0.5 0.25];
% el.calibration_success_beep = [800 0.5 0.25];
% el.drift_correction_failed_beep = [400 0.5 0.25];
% el.drift_correction_success_beep = [800 0.5 0.25];
% 
% % apply changes above
% EyelinkUpdateDefaults(el);
% % do setup and calibrate the eye tracker
% EyelinkDoTrackerSetup(el, 'c');
% 
% 
% 
% % % do a final check of calibration using drift correction
% % % you have to hit esc before return
% % EyelinkDoDriftCorrection(el);
% WaitSecs(0.5);
% 
% % EYELINK - calibration - end
% 
% [out, exitFlag] = rd_eyeLink(command, window_1,[data.input{1},'.edf'])
% [out, exitFlag] = rd_eyeLink('calibrate', window_1, el);
