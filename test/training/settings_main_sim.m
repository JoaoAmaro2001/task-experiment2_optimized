% -------------------------------------------------------------------------
%                             Directories
% ------------------------------------------------------------------------- 
docs_path     = fullfile(scripts,'docs');
stim_path     = fullfile(sourcedata, 'supp', 'allStimuli');
logs_path     = fullfile(sourcedata, 'supp', 'logfiles');
data_path     = fullfile(sourcedata, 'data');

% -------------------------------------------------------------------------
%                             SETUP SCREEN
% ------------------------------------------------------------------------- 
backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0; % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1); % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output
% -------------------------------------------------------------------------
%                             1 SCREEN
% % ------------------------------------------------------------------------- 
whichScreenMin = min(Screen('Screens')); % Get the screen numbers
[screenWidth, screenHeight] = Screen('WindowSize', whichScreenMin); % Get the screen size
[window1, rect] = Screen('OpenWindow', whichScreenMin, backgroundColor, [0 0 screenWidth, screenHeight/2]);
% -------------------------------------------------------------------------
%                             2 SCREENS
% ------------------------------------------------------------------------- 
% whichScreenMax = max(Screen('Screens')); % Get the screen numbers
% [window1, rect] = Screen('Openwindow',whichScreenMax,backgroundColor,[],[],2);
% -------------------------------------------------------------------------
%                             Continue
% ------------------------------------------------------------------------- 
slack = Screen('GetFlipInterval', window1)/2; %The flip interval is half of the monitor refresh rate; why is it here?
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen('FillRect',window1, backgroundColor); % Fills the screen with the background color
Screen('Flip', window1); % Updates the screen (flip the offscreen buffer to the screen)

% -------------------------------------------------------------------------
%                         Setup the joysticks
% -------------------------------------------------------------------------
KbName('UnifyKeyNames') % Unify key names
hotkey          = KbName('LeftControl'); % Updates state
terminateKey    = KbName('ESCAPE');      % Key code for escape key

% -------------------------------------------------------------------------
%                              Text Stimuli
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
%                       Version and Testing
% -------------------------------------------------------------------------
PsychtoolboxVersion     % Get the Psychtoolbox version
% PerceptualVBLSyncTest % Perform test for synch issues
