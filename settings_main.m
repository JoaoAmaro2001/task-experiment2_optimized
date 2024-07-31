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
data.text.taskname          = 'videorating';
data.text.getready_en       = 'The experiment will start shortly... Keep your eyes fixed on the cross';
data.text.getready_pt       = 'A experiência começará em breve... Mantenha o olhar fixo na cruz';
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
    'Linguagem da tarefa','Indique o número da sessão (run)'};
dlg_title='Input';
% default: no ID, eyetracker in dummy mode, sequence 1, pupilometry
data.input = inputdlg(prompt,dlg_title,1,{'sub','pt','1'});
% get time of experiment
dateOfExp = datetime('now');

% Task Language
if strcmpi(data.input{2},'pt')
    lanSuf = '_pt';
elseif strcmpi(data.input{2},'en')
    lanSuf = '_en';
end

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
% input('Press Enter if NetStation Acquisition is running and recording.');

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
edfFileName = [data.input{1} '_' data.input{3}]; % cannot have more than 8 chars
[window_1, rect, el] = eyelinkExperiment2(screenNumber, edfFileName, data);

% -------------------------------------------------------------------------
%                             Get Screen Center
% -------------------------------------------------------------------------
W=rect(RectRight);                             % screen width
H=rect(RectBottom);                            % screen height
centerX = W / 2;                               % x center
centerY = H / 2;                               % y center
