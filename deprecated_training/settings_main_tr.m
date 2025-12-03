% Init pc-specific paths and variables
cfg = setpath();

% Directories
% docs_path     = fullfile(scripts,'docs');
allstim_path  = fullfile(cfg.paths.local.sourcedata, 'supp', 'allStimuli');
stim_path     = fullfile(cfg.paths.local.sourcedata, 'supp', 'stimuliTraining');
logs_path     = fullfile(cfg.paths.sourcedata, 'supp', 'logfiles');
event_path    = fullfile(cfg.paths.sourcedata, 'supp', 'events');
data_path     = fullfile(cfg.paths.sourcedata, 'data');

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
cfg.format.resolx = resolution(3);
cfg.format.resoly = resolution(4);

% cleanup unused variables
clear output_screen screens resolution dual


%% PARAMETERS - SETUP & INITIALISATION
AssertOpenGL; % gives warning if running in PC with non-OpenGL based PTB

% Formatting options
cfg.format.fontSize = 40;
cfg.format.fontSizeFixation = 120;
cfg.format.font = 'Arial';
cfg.format.background_color = [255 255 255]; % grey 150!
% initialise system for key query - changed 'UnifyKeyNames' to 'KeyNames' due to
% the keyboard usage
KbName('UnifyKeyNames')
keyDELETE = KbName('delete'); 
keySPACE  = KbName('space');
keyESCAPE = KbName('escape');
keyZ = KbName('z'); % 1
keyX = KbName('x'); % 2
keyC = KbName('c'); % 3
keyV = KbName('v'); % 4
keyB = KbName('b'); % 5
keyN = KbName('n'); % 6
keyM = KbName('m'); % 7

% instructions definition
cfg.text.taskname          = 'videorating';
cfg.text.getready_en       = 'The experiment will start shortly... Keep your eyes fixed on the cross';
cfg.text.getready_pt       = 'A experiência começará em breve... Mantenha o olhar fixo na cruz';
cfg.text.starting_en       = 'Starting in';
cfg.text.starting_pt       = 'Começa em';
cfg.text.baselineClosed_en = 'Baseline with eyes closed will start shortly';
cfg.text.baselineClosed_pt = 'O periodo de relaxamento com olhos fechados começará em breve';
cfg.text.baselineOpen_en   = 'Baseline with eyes open will start shortly';
cfg.text.baselineOpen_pt   = 'O periodo de relaxamento com olhos abertos começará em breve';

% get rating image & size
imX = 1920; imY = 1080; % image resolution 1920x1080
cfg.image.image_size = ...
    [(cfg.format.resolx - imX)/2, (cfg.format.resoly - imY)/2,...
    imX, imY];
clear imX imY; % cleanup unused variables

% user input - participant information
% get user input for usage or not of eyelink
prompt={'Introduza o ID do participante',...
    'Linguagem da tarefa','Indique o número da sessão (run)'};
dlg_title='Input';
% default: no ID, eyetracker in dummy mode, sequence 1, pupilometry
cfg.input = inputdlg(prompt,dlg_title,1,{'SR','pt','1'});
% get time of experiment
dateOfExp = datetime('now');

% Task Language
if strcmpi(cfg.input{2},'pt')
    lanSuf = '_pt';
elseif strcmpi(cfg.input{2},'en')
    lanSuf = '_en';
end

% Filenames
cfg.text.elFileName        = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_eye'];
cfg.text.logFileName       = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_log'];
cfg.text.eegFileName       = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_eeg'];
cfg.text.eventFileName     = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_event'];

% cleanup unused variables
clear prompt dlg_title num_lines ppid scriptName ii

% Settings for export options
exportXlsx = false;
exportTsv  = false;

% -------------------------------------------------------------------------
%                             SETUP SCREEN
% ------------------------------------------------------------------------- 
backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0;         % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1);   % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output

% -------------------------------------------------------------------------
%                       Initialise Eyelink +  Screen
% -------------------------------------------------------------------------
% edfFileName = [cfg.input{1} '_' cfg.input{3}]; % cannot have more than 8 chars
% [window_1, rect, el] = eyelinkExperiment2(screenNumber, edfFileName, data);

% Open experiment graphics on the specified screen
[window_1, rect] = Screen('Openwindow',cfg.screen.number,cfg.format.backgroundColor,[],[],2);
Screen('TextSize', cfg.screen.pointer,cfg.format.fontSizeText);
Screen('TextFont', cfg.screen.pointer,cfg.format.font);
Screen('TextStyle', cfg.screen.pointer, 1);
Screen('Flip', cfg.screen.pointer); 

% -------------------------------------------------------------------------
%                             Get Screen Center
% -------------------------------------------------------------------------
W=rect(RectRight);                             % screen width
H=rect(RectBottom);                            % screen height
centerX = W / 2;                               % x center
centerY = H / 2;                               % y center
