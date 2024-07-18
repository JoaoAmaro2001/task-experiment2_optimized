setpath;

% Directories
docs_path     = fullfile(scripts,'docs');
allstim_path  = fullfile(sourcedata, 'supp', 'allStimuli');
stim_path     = fullfile(sourcedata, 'supp', 'stimuli');
logs_path     = fullfile(sourcedata, 'supp', 'logfiles');
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
data.text.taskname          = 'video_rating';
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
clock_var = clock; clock_var = [num2str(clock_var(4)),'_',...
    num2str(clock_var(5)),'_',num2str(round(clock_var(6)))];
% name for log file
ppid = [data.input{1},'_',date,'_',clock_var];

% select sequence to use
if str2double(data.input{3}) == 1
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

% Initialise Eyelink
dummymode = str2double(data.input(2)); % set to 1 to initialise in dummymode
data.leadout_duration = 5;

% Initialise Psychtoolbox
Screen('Preference','SkipSyncTests', 1);
[w,~] = Screen('OpenWindow',screenNumber,data.format.background_color);
% HideCursor(w);
PsychTweak('UseGPUIndex', 1);
Screen('TextSize',w,data.format.fontSize);
Screen('TextFont',w,data.format.font);
Screen('TextStyle', w, 1);