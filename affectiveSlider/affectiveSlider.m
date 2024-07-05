function affectiveSlider()
    try
        %% Screen parameters
        screenNumber = max(Screen('Screens'));
        Screen('Preference', 'SkipSyncTests', 1);
        Screen('Preference', 'VisualDebugLevel', 1);
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
        [w, scrRect] = PsychImaging('OpenWindow', screenNumber, [1, 1, 1]); 
        [xCenter, yCenter] = RectCenter(scrRect);
        slack = Screen('GetFlipInterval', w); 
        vbl = Screen('Flip', w);

        %% Parameters for scale and text
        question = 'How do you feel?';
        lowerText = 'Unhappy';
        upperText = 'Happy';
        pixelsPerPress = 2;
        waitframes = 1;
        lineLength = 500; % pixels
        halfLength = lineLength/2; 
        baseRect = [0 0 10 30]; % size of slider
        LineX = xCenter;
        LineY = yCenter;
        rectColor = [0 0 0]; % color for slider
        lineColor = [0 0 0]; % color for line
        textColor = [0 0 0]; % color for text
        Screen('TextFont', w, 'Helvetica');
        Screen('TextSize', w, 32);
        Screen('TextStyle', w, 0);


        %% Load emoji images
        leftEmojiTexture = Screen('MakeTexture', w, imread('AS_unhappy.png'));
        rightEmojiTexture = Screen('MakeTexture', w, imread('AS_happy.png'));
        intensityCueTexture = Screen('MakeTexture', w, imread('AS_intensity_cue.png'));

        %% Set up keys
        KbName('UnifyKeyNames');
        RightKey = KbName('RightArrow');
        LeftKey = KbName('LeftArrow');
        ResponseKey = KbName('Space');
        escapeKey = KbName('ESCAPE');

        %% Draw the scale
        while KbCheck; end
        while true
            [keyIsDown, secs, keyCode] = KbCheck;
            pressedKeys = find(keyCode);
            if pressedKeys == escapeKey
                break
            elseif keyCode(LeftKey)
                LineX = LineX - pixelsPerPress;
            elseif keyCode(RightKey)
                LineX = LineX + pixelsPerPress;
            elseif pressedKeys == ResponseKey
                finalValue = (LineX - (xCenter - halfLength)) / lineLength;
                break;
            end

            LineX = max(xCenter - halfLength, min(LineX, xCenter + halfLength));

            centeredRect = CenterRectOnPointd(baseRect, LineX, LineY);

            currentRating = (LineX - (xCenter - halfLength)) / lineLength;
            ratingText = num2str(currentRating, '%.2f');

            % Draw question and rating
            DrawFormattedText(w, ratingText, 'center', (yCenter - 200), textColor, [], [], [], 5);
            DrawFormattedText(w, question, 'center', (yCenter - 100), textColor, [], [], [], 5);

            % Draw slider line and end markers
            Screen('DrawLine', w, lineColor, xCenter - halfLength, yCenter, xCenter + halfLength, yCenter, 1);
            Screen('DrawLine', w, lineColor, xCenter + halfLength, yCenter + 10, xCenter + halfLength, yCenter - 10, 1);
            Screen('DrawLine', w, lineColor, xCenter - halfLength, yCenter + 10, xCenter - halfLength, yCenter - 10, 1);

            % Draw text labels
            Screen('DrawText', w, lowerText, xCenter - halfLength, yCenter + 25, textColor);
            Screen('DrawText', w, upperText, xCenter + halfLength, yCenter + 25, textColor);

            % Draw slider
            Screen('FillRect', w, rectColor, centeredRect);

            % Draw emojis
            Screen('DrawTexture', w, leftEmojiTexture, [], [xCenter - halfLength - 50, yCenter - 25, xCenter - halfLength, yCenter + 25]);
            Screen('DrawTexture', w, rightEmojiTexture, [], [xCenter + halfLength, yCenter - 25, xCenter + halfLength + 50, yCenter + 25]);

            % Draw intensity cue
            Screen('DrawTexture', w, intensityCueTexture, [], [xCenter - 100, yCenter + 50, xCenter + 100, yCenter + 100]);

            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * slack);
        end

        %% Display the rating
        disp('Rating: ');
        disp(finalValue);

    catch
        sca;
        psychrethrow(psychlasterror);
    end

    %% Close everything
    sca;
    Screen('CloseAll');
end