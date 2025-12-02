function cfg = settings_main()
% function containing settings for running the main task

% Init pc-specific paths and variables via setpath
cfg = setpath();

% Testing
cfg.debug = false;
if cfg.debug
    Screen('Preference','Verbosity', 1);
    Screen('Preference','Warnings', 1);
    Screen('Preference', 'SkipSyncTests', 1);
    VBLSyncTest(630) % save figures
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% Paths
cfg.paths.allstim_path  = fullfile(cfg.paths.local.sourcedata, 'supp', 'allStimuli');
cfg.paths.stim_path     = fullfile(cfg.paths.local.sourcedata, 'supp', 'stimuli');
cfg.paths.logs_path     = fullfile(cfg.paths.sourcedata, 'supp', 'logfiles');
cfg.paths.event_path    = fullfile(cfg.paths.sourcedata, 'supp', 'events');
cfg.paths.sequence_path = fullfile(cfg.paths.sourcedata, 'supp', 'sequences');
cfg.paths.data_path     = fullfile(cfg.paths.sourcedata, 'data');

% Setup Information
cfg.info.matlab = matlabRelease();
cfg.info.ptb.version = Screen('Version');
cfg.info.ptb.machine = Screen('Computer');

cfg.info.lan = true;
cfg.info.lsl = false;
cfg.info.parallel_port = true;
cfg.info.network.ipv4.network = '10.10.10.xxx';
cfg.info.network.ipv4.eeg = '10.10.10.42';
cfg.info.network.ipv4.eyetracker = '10.10.10.70';
cfg.info.network.ipv4.machine = '10.10.10.31';
cfg.info.network.ipv4.subnet = '255.255.255.0';

%% PARAMETERS - SETUP & INITIALISATION

AssertOpenGL(); % gives warning if running in PC with non-OpenGL based PTB

% Formatting options
cfg.format.stimSize         = 2/3; % proportion of full screen 
cfg.format.fontSizeText     = 40;
cfg.format.fontSizeFixation = 120;
cfg.format.font             = 'Arial';
cfg.format.backgroundColor  = [255 255 255]; % grey is 150!
cfg.format.foregroundColor  = [0 0 0]; % black
cfg.format.textColor        = 0;  % Text color: choose a number from 0 (black) to 255 (white)

% initialise system for key query - changed 'UnifyKeyNames' to 'KeyNames' due to
% the keyboard usage
KbName('UnifyKeyNames')
cfg.keys.keyDELETE = KbName('delete'); 
cfg.keys.keySPACE  = KbName('space');
cfg.keys.keyESCAPE = KbName('escape');
cfg.keys.keyZ = KbName('z'); % 1
cfg.keys.keyX = KbName('x'); % 2
cfg.keys.keyC = KbName('c'); % 3
cfg.keys.keyV = KbName('v'); % 4
cfg.keys.keyB = KbName('b'); % 5
cfg.keys.keyN = KbName('n'); % 6
cfg.keys.keyM = KbName('m'); % 7

% instructions definition
cfg.text.taskname          = 'videorating';
cfg.text.getready_en       = 'The experiment will start shortly... Keep your eyes fixed on the cross';
cfg.text.getready_pt       = 'A experiência começará em breve... Mantenha o olhar fixo na cruz';
cfg.text.starting_en       = 'Starting in';
cfg.text.starting_pt       = 'Começa em';
cfg.text.baselineClosed_en = 'Baseline with eyes closed will start shortly';
cfg.text.baselineClosed_pt = 'O período de relaxamento com olhos fechados começará em breve';
cfg.text.baselineOpen_en   = 'Baseline with eyes open will start shortly';
cfg.text.baselineOpen_pt   = 'O período de relaxamento com olhos abertos começará em breve';

%% SCREEN SETUP
% TIP: create a virtual screen to use MATLAB while the task is running
cfg.screen.number   = 1; % 1 for primary, 2 for secondary, ...
cfg.screen.pointers = Screen('Windows');
screens             = Screen('Screens');
if cfg.screen.number > max(screens)
    % if you are using a duplicated display on windows, for example
    cfg.screen.number = max(screens);
end
% Ensure resources
Priority(MaxPriority(cfg.screen.number));

% Get screen resolution
if cfg.screen.number > 0 % find out if there is more than one screen
    dual = get(0,'MonitorPositions');
    resolution = [0,0,dual(cfg.screen.number,3),dual(cfg.screen.number,4)];
elseif cfg.screen.number == 0 % if not, get the normal screen's resolution
    resolution = get(0,'ScreenSize');
end
cfg.screen.resolx = resolution(3);
cfg.screen.resoly = resolution(4);
cfg.screen.centerX = cfg.screen.resolx / 2; % x center
cfg.screen.centerY = cfg.screen.resoly / 2; % y center

% Define new dimensions for the video, 1.5x1.5 times smaller
newWidth  = cfg.screen.resolx * cfg.format.stimSize;
newHeight = cfg.screen.resoly * cfg.format.stimSize;
% Calculate the position to center the smaller video on the screen
cfg.screen.stim = [...
    (cfg.screen.resolx - newWidth) / 2, ...
    (cfg.screen.resoly - newHeight) / 2, ...
    (cfg.screen.resolx + newWidth) / 2, ...
    (cfg.screen.resoly + newHeight) / 2];

% cleanup unused variables
clear screens resolution dual newHeight newWidth

% user input - participant information
% get user input for usage or not of eyelink
prompt={'Introduza o ID do participante',...
    'Linguagem da tarefa','Indique o número da sessão (run)'};
dlg_title='Input';
% Fot this experiment participant_id will be SRxxx (scenario rating)
cfg.input = inputdlg(prompt,dlg_title,1,{'SR','pt','1'});
% get time of experiment
cfg.task.dateOfExp = datetime('now');

% Task Language
if strcmpi(cfg.input{2},'pt')
    cfg.task.languageSuffix = '_pt';
elseif strcmpi(cfg.input{2},'en')
    cfg.task.languageSuffix = '_en';
end

% Filenames
cfg.text.elFileName        = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_eye'];
cfg.text.logFileName       = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_log'];
cfg.text.eegFileName       = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_eeg'];
cfg.text.eventFileName     = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_event'];
cfg.text.flipFileName      = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_flips'];
cfg.text.eventSequence     = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_seq'];

% Task parameters
cfg.task.description          = '';
cfg.task.numberOfStates       = 10;
cfg.task.numberOfRuns         = 2;
cfg.task.stimsPerRun          = 30;
cfg.task.eyes_closed_duration = 30; % in secs
cfg.task.eyes_open_duration   = 30; % in secs
cfg.task.preparation_duration = 5;  % in secs

% BIDS and HED info
cfg.BIDS.modalities = {'eeg','eyetrack'};
cfg.BIDS.eeg.provider = 'EGI';
cfg.BIDS.eyetrack.provider = 'EyeLink';
cfg.BIDS.sub = '';
cfg.BIDS.run = '';
cfg.BIDS.ses = '';
cfg.BIDS.desc = '';
cfg.BIDS.task = '';
cfg.HED.events = {};

% select sequence to use
if str2double(cfg.input{3}) == 1
    cfg.BIDS.run = 1;
    generate_sequences(cfg);  % Generate new stimuli sequence
    sequence1 = load('sequences\sequence1.mat');
    % save information from chosen sequence in the 'data' structure
    cfg.sequences.files = sequence1.sequenceFiles1;
    save(fullfile(cfg.paths.sequence_path, cfg.text.eventSequence), 'sequence1')
elseif str2double(cfg.input{3}) == 2
    cfg.BIDS.run = 2;
    sequence2 = load('sequences\sequence2.mat');
    % save information from chosen sequence in the 'data' structure
    cfg.sequences.files = sequence2.sequenceFiles2;
    save(fullfile(cfg.paths.sequence_path, cfg.text.eventSequence), 'sequence2')
else
    warning('Selected sequence does not exist');
end

% get subject id folder to store result files
cfg.BIDS.sub = ['sub-',cfg.input{1}];
if ~isfolder(fullfile(cfg.paths.data_path, cfg.BIDS.sub))
    mkdir(fullfile(cfg.paths.data_path, cfg.BIDS.sub));
end

% cleanup unused variables
clear prompt dlg_title num_lines ppid scriptName ii

% Settings for export options
cfg.export.exportXlsx = true;
cfg.export.exportTsv  = true;

% Initialise EEG -> Open NetStationAcquisition and start recording
NetStation('Connect', cfg.info.network.ipv4.eeg)
disp('Connection with NetStation successfull!');

% -------------------------------------------------------------------------
%                             SETUP SCREEN
% ------------------------------------------------------------------------- 

% clear screen
Screen('OpenWindow',0,[128 128 128]);

        
% -------------------------------------------------------------------------
%                       Initialise Eyelink +  Screen
% -------------------------------------------------------------------------
try 
    Eyelink('SetAddress', cfg.info.network.ipv4.eyetracker);
catch ME
    fprintf(2,'Error:\n%s\n',ME.message)   
end

% Init eyelink
edfFileName = [cfg.input{1} '_' cfg.input{3}]; % cannot have more than 8 chars
[cfg.screen.pointer, cfg.screen.rect, cfg.el] = elInitiate(cfg, edfFileName);    
% % Open experiment graphics on the specified screen
% [cfg.screen.pointer, rect] = Screen('Openwindow',cfg.screen.number,cfg.format.backgroundColor,[],[],2);
% Screen('TextSize', cfg.screen.pointer,cfg.format.fontSizeText);
% Screen('TextFont', cfg.screen.pointer,cfg.format.font);
% Screen('TextStyle', cfg.screen.pointer, 1);
% Screen('Flip', cfg.screen.pointer); 


% Return width and height of the graphics window/screen in pixels
% [width, height] = Screen('WindowSize', cfg.screen.pointer);

% Stimulus
cfg.stim.isVideo = true;
cfg.stim.preloaded = false;
if cfg.stim.isVideo
    % another recommendation is to process them all with ffmpeg
    % cache videos to improve performance
    % Videos standardized with ffmpeg
    % foreach ($f in Get-ChildItem *.mp4) {
    % ffmpeg -i $f.FullName -an -pix_fmt yuv420p -c:v libx264 -profile:v high -preset fast -crf 17 -r 30 -movflags +faststart ($f.BaseName + ".mp4")
    % }
    disp('Preloading videos...')
    cfg.stim.moviePntrs = zeros(numel(cfg.sequences.files),1);
    for t = 1:numel(cfg.sequences.files)
        file = fullfile(cfg.paths.stim_path, cfg.sequences.files{t});
        cfg.stim.moviePntrs(t) = Screen('OpenMovie', cfg.screen.pointer, file, 0, inf, 2);
        Screen('SetMovieTimeIndex', cfg.stim.moviePntrs(t), 0);
    end
    cfg.stim.preloaded = true;
end

% -------------------------------------------------------------------------
%                             Get Screen Center
% -------------------------------------------------------------------------

% Get existing pointers
cfg.info.pointer = Screen('GetWindowInfo', cfg.screen.pointer);


% Using parallel port
if cfg.info.parallel_port
    exists_mex = which("io64");
    if isempty(exists_mex)
        error("Executable not found in the path. Ensure you downloaded it and added it to path.")
        cfg.info.parallel_port = false;
    end
end

% Save cfg to .mat and .json

end



