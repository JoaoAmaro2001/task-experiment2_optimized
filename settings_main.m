% -------------------------------------------------------------------------
%                             Directories
% ------------------------------------------------------------------------- 

setpath;

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
whichScreenMin = min(Screen('Screens')); % Get the screen numbers
[screenWidth, screenHeight] = Screen('WindowSize', whichScreenMin); % Get the screen size
[window_1, rect] = Screen('OpenWindow', whichScreenMin, backgroundColor, [0 0 screenWidth/2, screenHeight/2]);

% -------------------------------------------------------------------------
%                             Continue
% -------------------------------------------------------------------------
slack = Screen('GetFlipInterval', window_1)/2; %The flip interval is half of the monitor refresh rate; why is it here?
W=rect(RectRight);                            % screen width
H=rect(RectBottom);                           % screen height
Screen('FillRect',window_1, backgroundColor);  % Fills the screen with the background color
Screen('Flip', window_1);                      % Updates the screen (flip the offscreen buffer to the screen)

% -------------------------------------------------------------------------
%                         Time trial settings
% -------------------------------------------------------------------------
breakAfterTrials = 100000;
timeBetweenTrials = 1; % How long to pause in between trials (if 0, the experiment will wait for
                       % the subject to press a key before every trial)

% -------------------------------------------------------------------------
%                    Stimuli lists and results files
% -------------------------------------------------------------------------
% videos of different trajectories
videoFolder = [scripts '\Videos_session_1'];
disp(['Video folder: ' videoFolder]);

% Check if the directory exists
if isfolder(videoFolder)
    disp('Directory exists.');

    % List all files in the directory
    videoFiles = dir(videoFolder);
    disp('Contents of videoFolder:');
    disp({videoFiles(:).name});

    % Filter out the .mp4 files
    videoFormat = 'mp4';
    videoList = dir(fullfile(videoFolder, ['*.' videoFormat]));
    videoList = {videoList(:).name};
    disp('Filtered videoList:');
    disp(videoList);

    nTrials = length(videoList); %1
else
    disp('Directory does not exist.');
end

% Navigation questions
imageFolder = 'images';
imageFormat = 'png';
imgList = dir(fullfile(scripts, imageFolder, ['*.' imageFormat]));
imgList = {imgList(:).name};
disp(imgList);

% score images
imageFolder_score = 'score_images';
imageFormat = 'JPG';
imgList2 = dir(fullfile(scripts, imageFolder_score, ['*.' imageFormat]));
imgList2 = {imgList2(:).name};
disp(imgList2);

min_secs = 0.5;
max_secs = 1.5; 
fixationDuration = min_secs + (max_secs - min_secs) * rand(1, nTrials);

% -------------------------------------------------------------------------
%                            Randomize trials
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
%                                Start
% -------------------------------------------------------------------------
load('randomizedTrials_all.mat')

% Ensure subID is valid
while true
    subID = input('subID:', 's');
    if length(subID) >= 2
        break;
    else
        disp('subID must be at least 10 characters long. Please re-enter.');
    end
end

disp(['Current subID: ', subID]);  % This will show the current value of subID
disp(['Length of subID: ', num2str(length(subID))]);  % This will display the length of subID

codeID=subID(1:2);
randomizedTrials = randomizedTrials_all(str2num(codeID),:);

terminateKey = KbName('return');      % Key code for escape key
start_exp = GetSecs;