%% Screen parameters. You'll probably want to call these at the top of your script
screenNumber = max(Screen('Screens'));
Screen ('Preference', 'SkipSyncTests', 1);
Screen ('Preference', 'VisualDebugLevel', 1);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange'); % Make colours be from 0 to 1
[w, scrRect] = PsychImaging('OpenWindow', screenNumber, [1, 1,1]); 

[xCenter, yCenter] = RectCenter(scrRect);
slack = Screen('GetFlipInterval', w); 
vbl = Screen('Flip', w);

%% Parameters for your scale and text that you want
question = 'How structured was the stimulus? ';
lowerText = 'Not';
upperText = 'Very';
pixelsPerPress = 2;
waitframes = 1;
lineLength = 500; % pixels
halfLength = lineLength/2; 
divider = lineLength/10; % for a rating of 1:10

baseRect = [0 0 10 30]; % size of slider
LineX = xCenter;
LineY = yCenter;

rectColor = [0 0 0]; % color for slider
lineColor = [0 0 0]; % color for line
textColor = [0 0 0]; % color for text


Screen('TextFont',w, 'Helvetica');  % font parameters
Screen('TextSize',w, 32);
Screen('TextStyle', w, 0);

%% set up what keys you want to use
KbName('UnifyKeyNames');
RightKey = KbName('RightArrow');
LeftKey = KbName('LeftArrow');
ResponseKey = KbName('Space');
escapeKey = KbName('ESCAPE');

%% Actual bit that draws the scale
while KbCheck; end
while true
    [ keyIsDown, secs, keyCode ] = KbCheck;
    pressedKeys = find(keyCode);
    if pressedKeys == escapeKey
        break
    elseif keyCode(LeftKey)
        LineX = LineX - pixelsPerPress;
    elseif keyCode(RightKey)
        LineX = LineX + pixelsPerPress;
    elseif pressedKeys == ResponseKey
        StopPixel_M = ((LineX - xCenter) + halfLength)/divider; % for a rating of between 0 and 10. Tweak this as necessary.
        break;
    end
    if LineX < (xCenter-halfLength)
        LineX = (xCenter-halfLength);
    elseif LineX > (xCenter+halfLength)
        LineX = (xCenter+halfLength);
    end
    if LineY < 0
        LineY = 0;
    elseif LineY > (yCenter+10)
        LineY = (yCenter+10);
    end
    
    centeredRect = CenterRectOnPointd(baseRect, LineX, LineY);
  
    currentRating = ((LineX - xCenter) +  halfLength)/divider;  %
    ratingText = num2str(currentRating); % to make this display whole numbers, use "round(currentRating)"

    DrawFormattedText(w, ratingText ,'center', (yCenter-200), textColor, [],[],[],5); % display current rating 
    DrawFormattedText(w, question ,'center', (yCenter-100), textColor, [],[],[],5);
    
    Screen('DrawLine', w,  lineColor, (xCenter+halfLength ), (yCenter),(xCenter-halfLength), (yCenter), 1);
    Screen('DrawLine', w,  lineColor, (xCenter+halfLength ), (yCenter +10), (xCenter+halfLength), (yCenter-10), 1);
    Screen('DrawLine', w,  lineColor, (xCenter-halfLength ), (yCenter+10), (xCenter- halfLength), (yCenter-10), 1);
    
    Screen('DrawText', w, lowerText, (xCenter-halfLength), (yCenter+25),  textColor);
    Screen('DrawText', w, upperText , (xCenter+halfLength) , (yCenter+25), textColor);
    Screen('FillRect', w, rectColor, centeredRect);
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) *  slack);
end

%% Close everything and display the rating. If you're doing this during a script, just put in a flip and save the rating somewhere. 

disp('Rating: ') ;
disp(StopPixel_M);
sca;
Screen('CloseAll');