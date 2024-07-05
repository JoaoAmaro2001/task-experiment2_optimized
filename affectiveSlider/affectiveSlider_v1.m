% Use claude
%
% Version 1 - It runs but I need to adjust the scale.

function affectiveSlider_v1()
    try
        % Initialize Psychtoolbox
        PsychDefaultSetup(2);
        screenNumber = max(Screen('Screens'));
        [window, windowRect] = Screen('OpenWindow', screenNumber, [255 255 255]);
        Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
        % Load emoji images
        leftEmoji = imread('AS_unhappy.png');
        rightEmoji = imread('AS_happy.png');
        intensityCue = imread('AS_intensity_cue.png');
        
        % Check if images are loaded correctly
        if isempty(leftEmoji) || isempty(rightEmoji) || isempty(intensityCue)
            error('One or more images failed to load.');
        end
        
        % Ensure all images have 3 color channels
        if size(leftEmoji, 3) == 1
            leftEmoji = repmat(leftEmoji, [1 1 3]);
        end
        if size(rightEmoji, 3) == 1
            rightEmoji = repmat(rightEmoji, [1 1 3]);
        end
        if size(intensityCue, 3) == 1
            intensityCue = repmat(intensityCue, [1 1 3]);
        end
        
        % Resize images to have the same height
        maxHeight = max([size(leftEmoji, 1), size(rightEmoji, 1)]);
        leftEmoji = imresize(leftEmoji, [maxHeight, NaN]);
        rightEmoji = imresize(rightEmoji, [maxHeight, NaN]);
        
        % Combine emojis into one image
        combinedWidth = size(leftEmoji, 2) + size(rightEmoji, 2);
        combinedImage = uint8(zeros(maxHeight, combinedWidth, 3));
        combinedImage(:, 1:size(leftEmoji,2), :) = leftEmoji;
        combinedImage(:, end-size(rightEmoji,2)+1:end, :) = rightEmoji;
        
        % Add intensity cue below the emojis
        cueHeight = size(intensityCue, 1);
        fullImage = uint8(zeros(maxHeight + cueHeight, combinedWidth, 3));
        fullImage(1:maxHeight, :, :) = combinedImage;
        cueStart = max(1, round((combinedWidth - size(intensityCue,2)) / 2));
        cueEnd = min(combinedWidth, cueStart + size(intensityCue,2) - 1);
        fullImage(maxHeight+1:end, cueStart:cueEnd, :) = intensityCue(:, 1:(cueEnd-cueStart+1), :);
        
        % Set up slide scale parameters
        question = 'How do you feel?';
        anchors = {'Unhappy', 'Neutral', 'Happy'};  % Non-empty anchors
        
        % Call slideScale function
        [position, RT, answer] = slideScale(window, question, windowRect, anchors, ...
            'image', fullImage, ...
            'scalaposition', 0.8, ...
            'scalalength', 0.6, ...
            'slidercolor', [255 0 0], ...
            'scalacolor', [0 0 0], ...
            'startposition', 'center', ...
            'range', 2, ...
            'displayposition', true);
        
        % Display results
        if answer
            fprintf('Position: %.2f\n', position);
            fprintf('Reaction Time: %.2f ms\n', RT);
        else
            fprintf('No response given.\n');
        end
        
        % Clean up
        sca;
        
    catch e
        sca;
        fprintf('Error: %s\n', e.message);
        fprintf('Error occurred in %s at line %d\n', e.stack(1).name, e.stack(1).line);
        psychrethrow(psychlasterror);
    end
end