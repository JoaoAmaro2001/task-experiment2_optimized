% Scripted by Carina Mendes (cmendes) 
% acmendes@medicina.ulisboa.pt / acarinapmendes@gmail.com
% LAB - signals - EEG + EYETRACKING (pupilometry)
% Updated by João Amaro
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

% -------------------------------------------------------------------------
%                             Eyelink Help
% -------------------------------------------------------------------------

% % Scripts
% C:\toolbox\Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkDemos\SR-ResearchDemos\SimplePicture\EyeLink_SimplePicture.m

% % Functions
% help Eyelink
% Eyelink Initialize?

% -------------------------------------------------------------------------
%                             Eyelink setup
% -------------------------------------------------------------------------

% % Make sure there is a connection via IT/CP (see tutorial at https://www.sr-research.com/support/thread-281.html)
% ipadress = '100.1.1.2'; % check in cmd >>> ipconfig /all 
% status   = Eyelink('SetAddress', ipadress); % Check connection



% Bring the Command Window to the front if it is already open
if ~IsOctave; commandwindow; end

% Initialize PsychSound for calibration/validation audio feedback
InitializePsychSound();

% Use default screenNumber if none specified
screens = Screen('Screens');
screenNumber = max(screens);

try
    %% STEP 1: INITIALIZE EYELINK CONNECTION; OPEN EDF FILE; GET EYELINK TRACKER VERSION
    
    % Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
    dummymode = 0;
    
    % Optional: Set IP address of eyelink tracker computer to connect to.
    % Call this before initializing an EyeLink connection if you want to use a non-default IP address for the Host PC.
    %Eyelink('SetAddress', '10.10.10.240');
    
    EyelinkInit(dummymode); % Initialize EyeLink connection
    status = Eyelink('IsConnected');
    if status < 1 % If EyeLink not connected
        dummymode = 1; 
    end
       
    % Open dialog box for EyeLink Data file name entry. File name up to 8 characters
    prompt = {'Enter EDF file name (up to 8 characters)'};
    dlg_title = 'Create EDF file';
    def = {'demo'}; % Create a default edf file name
    answer = inputdlg(prompt, dlg_title, 1, def); % Prompt for new EDF file name    
    % Print some text in Matlab's Command Window if a file name has not been entered
    if  isempty(answer)
        fprintf('Session cancelled by user\n')
        error('Session cancelled by user'); % Abort experiment (see cleanup function below)
    end    
    edfFile = answer{1}; % Save file name to a variable    
    % Print some text in Matlab's Command Window if file name is longer than 8 characters
    if length(edfFile) > 8
        fprintf('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)\n');
        error('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)');
    end
 
    % Open an EDF file and name it
    failOpen = Eyelink('OpenFile', edfFile);
    if failOpen ~= 0 % Abort if it fails to open
        fprintf('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
        error('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
    end
    
    % Get EyeLink tracker and software version
    % <ver> returns 0 if not connected
    % <versionstring> returns 'EYELINK I', 'EYELINK II x.xx', 'EYELINK CL x.xx' where 'x.xx' is the software version
    ELsoftwareVersion = 0; % Default EyeLink version in dummy mode
    [ver, versionstring] = Eyelink('GetTrackerVersion');
    if dummymode == 0 % If connected to EyeLink
        % Extract software version number. 
        [~, vnumcell] = regexp(versionstring,'.*?(\d)\.\d*?','Match','Tokens'); % Extract EL version before decimal point
        ELsoftwareVersion = str2double(vnumcell{1}{1}); % Returns 1 for EyeLink I, 2 for EyeLink II, 3/4 for EyeLink 1K, 5 for EyeLink 1KPlus, 6 for Portable Duo         
        % Print some text in Matlab's Command Window
        fprintf('Running experiment on %s version %d\n', versionstring, ver );
    end
    % Add a line of text in the EDF file to identify the current experimemt name and session. This is optional.
    % If your text starts with "RECORDED BY " it will be available in DataViewer's Inspector window by clicking
    % the EDF session node in the top panel and looking for the "Recorded By:" field in the bottom panel of the Inspector.
    preambleText = sprintf('RECORDED BY Psychtoolbox demo %s session name: %s', mfilename, edfFile);
    Eyelink('Command', 'add_file_preamble_text "%s"', preambleText);
catch
end
% -------------------------------------------------------------------------
%                      Communication with Eyelink
% -------------------------------------------------------------------------

% Communication with the EyeLink1000 system is done through messages
% Trial #d
% rest start (30s)/ rest end (30s) - every 20 trials
% Fixation Cross
% Start of sound presentation, 'type of sound' - 'name of sound'
% End of sound presentation, 'type of sound' - 'name of sound'
% Choice Screen - Autenticidade
% IF PARTICIPANT CHOOSES AN OPTION: Answered - autenticidade
% End of trial #d


% EYELINK - start
Screen('BlendFunction',w,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');


el = EyelinkInitDefaults(w);

% open file to record data
edfF = Eyelink('Openfile',[fullfile(outeye,subid),'.edf']);
if edfF ~= 0
    fprintf('Cannot create EDF file ''%s''',[fullfile(outeye,subid),'.edf']);
    Eyelink('Shutdown');
    Screen('CloseAll');
end


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