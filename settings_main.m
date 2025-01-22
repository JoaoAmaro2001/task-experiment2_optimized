% Init pc-specific paths and variables
setpath; cd(scripts);

% Check version ('(R2018a)' or "R2024a")
% ver_info = matlabRelease;

% Directories
docs_path     = fullfile(scripts,'docs');
allstim_path  = fullfile(sourcedata, 'supp', 'allStimuli');
stim_path     = fullfile(sourcedata, 'supp', 'stimuli');
logs_path     = fullfile(sourcedata, 'supp', 'logfiles');
event_path    = fullfile(sourcedata, 'supp', 'events');
sequence_path = fullfile(sourcedata, 'supp', 'sequences');
data_path     = fullfile(sourcedata, 'data');

%  SCREEN SETUP
output_screen = 2; % 1 for primary, 2 for secondary, ...
screens       = Screen('Screens');
screenNumber  = max(screens);

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
data.format.fontSize         = 40;
data.format.fontSizeFixation = 120;
data.format.font             = 'Arial';
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
data.text.baselineClosed_pt = 'O período de relaxamento com olhos fechados começará em breve';
data.text.baselineOpen_en   = 'Baseline with eyes open will start shortly';
data.text.baselineOpen_pt   = 'O período de relaxamento com olhos abertos começará em breve';

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
% Fot this experiment participant_id will be SRxxx (scenario rating)
data.input = inputdlg(prompt,dlg_title,1,{'SR','pt','1'});
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
data.text.eventSequence     = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_seq'];

% Task parameters
data.task.numberOfRuns         = 2;
data.task.stimsPerRun          = 30;
data.task.eyes_closed_duration = 1; % in secs
data.task.eyes_open_duration   = 1; % in secs
data.task.preparation_duration = 5;  % in secs

% select sequence to use
if str2double(data.input{3}) == 1
    run = 1;
    generate_sequences;  % Generate new stimuli sequence
    sequence1 = load('sequences\sequence1.mat');
    % save information from chosen sequence in the 'data' structure
    data.sequences.files = sequence1.sequenceFiles1;
    save(fullfile(sequence_path, data.text.eventSequence), 'sequence1')
elseif str2double(data.input{3}) == 2
    run = 2;
    sequence2 = load('sequences\sequence2.mat');
    % save information from chosen sequence in the 'data' structure
    data.sequences.files = sequence2.sequenceFiles2;
    save(fullfile(sequence_path, data.text.eventSequence), 'sequence2')
else
    warning('Selected sequence does not exist');
end

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
%                             SETUP SCREEN
% ------------------------------------------------------------------------- 
backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0;         % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 0);   % Is this safe?
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
