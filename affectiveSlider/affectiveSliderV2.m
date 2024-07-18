% Step 1: Initialize Psychtoolbox and open a screen window
Screen('Preference', 'SkipSyncTests', 1); % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output
screenNumber = max(Screen('Screens'));
[window, windowRect] = Screen('OpenWindow', screenNumber, [255 255 255]);


% Step 2: Prepare required parameters
question = 'How satisfied are you with this product?';
rect = windowRect; % Use the windowRect as the rect parameter
anchors = {'Not at all', 'Extremely'}; % Define the scale anchors

% Optional parameters can be defined as well, for example:
lineLength = 15;
width = 5;
range = 1; % -100 to 100
startPosition = 'center';
scalaLength = 0.9;
scalaPosition = 0.8;
device = 'mouse'; % Use mouse as input device

% Step 3: Call slideScale function
[position, RT, answer] = slideScale(window, question, rect, anchors, ...
    'linelength', lineLength, 'width', width, 'range', range, ...
    'startposition', startPosition, 'scalalength', scalaLength, ...
    'scalaposition', scalaPosition, 'device', device);

% Step 4: Handle the output
% For demonstration, simply display the results in the command window
disp(['Position: ', num2str(position)]);
disp(['Reaction Time: ', num2str(RT), ' ms']);
if answer == 1
    disp('An answer was given.');
else
    disp('No answer was given.');
end

% Close the screen window when done
Screen('CloseAll');