clear all
close all
subID = input('subID:', 's');
settings_main; % Load all the settings from the file
HideCursor;

% -------------------------------------------------------------------------
%                       Set variables
% -------------------------------------------------------------------------
% Number of trials/videos based on available videos
n                 = length(videoList);
% n                = 2;
trial_            = 1;
t                 = trial_;

% Initialize time variables
FixTime           = zeros(1,n); 
VideoTime         = zeros(1,n);
Ego_Time          = zeros(1,n);
Allo_Time         = zeros(1,n);
Valence_Time      = zeros(1,n);
Arousal_Time      = zeros(1,n);
Blank_Time        = zeros(1,n); 

video_name        = cell(1,n)

% Reaction times and choices for valence and arousal
rt_ego            = zeros(1,n);
rt_allo           = zeros(1,n);
rt_valence        = zeros(1,n); 
rt_arousal        = zeros(1,n); 

ego_coordinate_x  = zeros(1,n);
ego_coordinate_y  = zeros(1,n);
allo_coordinate_x = zeros(1,n);
allo_coordinate_y = zeros(1,n);
choiceValence     = zeros(1,n); 
choiceArousal     = zeros(1,n);

state = 0; % Start with state 0

% -------------------------------------------------------------------------
%                       Start experiment
% -------------------------------------------------------------------------
prevDigit = -1;  % Initialize prevDigit to a value that firstDigit will never be
tic;

while trial_ <= n
    switch state

% -------------------------------------------------------------------------
%                       Countdown for empathic sync
% -------------------------------------------------------------------------
        case 0
            countdown_from = 10; % Start countdown from 10
            for i = countdown_from:-1:1
                Screen('TextSize', window_1, 60);
                Screen('TextFont', window_1, 'Arial');
                message = sprintf('Starting in %d', i);
                DrawFormattedText(window_1, message, 'center', 'center', textColor);
                Screen('Flip', window_1);
                WaitSecs(1);
            end
            state = 1;  % Proceed to the message state

% -------------------------------------------------------------------------
%                             Message
% -------------------------------------------------------------------------
        case 1
            Screen('TextSize', window_1, 50);
            DrawFormattedText(window_1, ['The experiment will start shortly, ' ...
                'please focus on the black cross'], 'center', 'center', textColor);
            InitialDisplayTime = Screen('Flip', window_1);
            WaitSecs(5);
            state = 2;

% -------------------------------------------------------------------------
%                             Cross
% -------------------------------------------------------------------------
        case 2
            drawCross(window_1, W, H);
            tFixation = Screen('Flip', window_1);
            [ret, outlet] = MatNICMarkerSendLSL(1, outlet); % Cross event code to NIC
            FixTime(trial_) = tFixation - start_exp;
            disp('FixTime:')
            disp(FixTime)
            WaitSecs(3);
            state = 3;  % Proceed to next state to play video

% -------------------------------------------------------------------------
%                             Video
% -------------------------------------------------------------------------
        case 3
            % Load and play video
            columnName = sprintf('Var%d', trial_);
            trial_index = randomizedTrials.(columnName);
            video_name{trial_} = videoList{randomizedTrials.(trial_)};
            disp(video_name)
            file = ['C:\Users\SpikeUrban\Documents\Exp5\task\task5\Scripts\Videos_session_1\',video_name{trial_}];
           
            try
                [movie, duration, fps, width, height, count, aspectRatio] = Screen('OpenMovie', window_1, file);
                Screen('PlayMovie', movie, 1);  % Play movie at normal speed
                videoStartTime = Screen('Flip', window_1);  % This will update the display and return the timestamp
                [ret, outlet] = MatNICMarkerSendLSL(2, outlet); % Video event code to NIC
                VideoTime(trial_) = videoStartTime - start_exp;  % Store the elapsed time since the experiment started
                disp('VideoTime:')
                disp(VideoTime)
            catch ME
                disp(['Failed to open movie file: ', file]);
                rethrow(ME);
            end

                % Get the size of the screen
                [screenWidth, screenHeight] = Screen('WindowSize', window_1);
    
                % Define new dimensions for the video, four times smaller
                newWidth = screenWidth / 1.5;
                newHeight = screenHeight / 1.5;
    
                % Calculate the position to center the smaller video on the screen
                dst_rect = [...
                    (screenWidth - newWidth) / 2, ...
                    (screenHeight - newHeight) / 2, ...
                    (screenWidth + newWidth) / 2, ...
                    (screenHeight + newHeight) / 2];
    
            Screen('FillRect', window_1, backgroundColor);
            state = 4;
            %dst_rect = [0 0 W H];

            case 4
                % Play and display the movie
                tex = 0;
                while ~KbCheck && tex~=-1  % Continue until keyboard press or movie ends
                    [tex, pts] = Screen('GetMovieImage', window_1, movie, 1);

                    if tex > 0  % If a valid texture was returned
                        % Draw the texture on the screen
                        Screen('DrawTexture', window_1, tex, [], dst_rect);
                        % Update the screen to show the current frame
                        Screen('Flip', window_1);
                        % Release the texture
                        Screen('Close', tex);
                    end
                end

        % Stop playback:
        Screen('PlayMovie', movie, 0);
        % Close movie:
        Screen('CloseMovie', movie);
        state = 5;  

% -------------------------------------------------------------------------
%                             Egocentric
% -------------------------------------------------------------------------
        case 5
            ShowCursor('CrossHair'); % Crosshair, useful for precision tasks
            centerX = screenWidth / 2;
            centerY = screenHeight / 2;

            % Set the mouse cursor to the center of the screen
            SetMouse(centerX, centerY, window_1);

            file_ego = 'C:\Users\SpikeUrban\Documents\Exp5\task\task5\Scripts\images\Egocentric\img_1.png';
    
            % Load the image from the file
            imageArray_ego = imread(file_ego);
    
            % Make texture from the image array
            texture = Screen('MakeTexture', window_1, imageArray_ego);

             % Define the destination rectangle to draw the image in its original size
            dst_rect_ego = CenterRectOnPointd([0 0 size(imageArray_ego, 2) size(imageArray_ego, 1)], centerX, centerY);
    
            % Draw the texture to the window
            Screen('DrawTexture', window_1, texture, [], dst_rect_ego);
    
            % Flip the window to update the screen display
            EgoStartTime = Screen('Flip', window_1);
            [ret, outlet] = MatNICMarkerSendLSL(3, outlet); % Nav Ego event code to NIC
            Ego_Time(trial_) = EgoStartTime - start_exp;  % Store the elapsed time since the experiment started
            disp('Ego_Time:')
            disp(Ego_Time)
    
            % Wait for a mouse click to proceed
            [~, x, y] = GetClicks(window_1);
            ego_coordinate_x(trial_) = x;  % Store x coordinate in ego_answer_x
            ego_coordinate_y(trial_) = y;  % Store y coordinate in ego_answer_y
            disp(['EGO coordinates X: ', num2str(x), ' Y: ', num2str(y)]);
            %disp('EGO coordinates:')
            %disp(ego_answer)
            
            % Close the texture to free memory
            Screen('Close', texture);
    
            % Update state or trial counters as necessary
            state = 6; % Proceed to next state or end of trial

% -------------------------------------------------------------------------
%                             Allocentric
% -------------------------------------------------------------------------
        case 6
            % Set the mouse cursor to the center of the screen
            SetMouse(centerX, centerY, window_1);
            
            img_allo = imgList_allo{randomizedTrials.(trial_)};
            disp(img_allo);
            file_allo = ['C:\Users\SpikeUrban\Documents\Exp5\task\task5\Scripts\images\Allocentric\', img_allo];
    
            % Load the image from the file
            imageArray_allo = imread(file_allo);
    
            % Make texture from the image array
            texture = Screen('MakeTexture', window_1, imageArray_allo);
    
            % Draw the texture to the window
            Screen('DrawTexture', window_1, texture, [], dst_rect);
    
            % Flip the window to update the screen display
            AlloStartTime = Screen('Flip', window_1);
            [ret, outlet] = MatNICMarkerSendLSL(4, outlet); % Nav Allo event code to NIC
            Allo_Time(trial_) = AlloStartTime - start_exp;  % Store the elapsed time since the experiment started
            disp('Allo_Time:')
            disp(Allo_Time)
            rt_ego(trial_) = Allo_Time(trial_) - Ego_Time(trial_);
            disp('rt_ego:')
            disp(rt_ego)
    
            % Wait for a mouse click to proceed
            [~, x, y] = GetClicks(window_1);
            allo_coordinate_x(trial_) = x;  % Store x coordinate in allo_answer_x
            allo_coordinate_y(trial_) = y;  % Store y coordinate in allo_answer_y
            disp(['ALLO coordinates X: ', num2str(x), ' Y: ', num2str(y)]);
            
            % Close the texture to free memory
            Screen('Close', texture);
    
            % Update state or trial counters as necessary
            state = 7; % Proceed to next state or end of trial

% -------------------------------------------------------------------------
%                             Valence
% -------------------------------------------------------------------------
        case 7 
            % Set the mouse cursor to the center of the screen
            SetMouse(centerX, centerY, window_1);
            file_valence = 'C:\Users\SpikeUrban\Documents\Exp5\task\task5\Scripts\score_images\Score_Valence.png';

            % Load the image from the file
            imageArray_valence = imread(file_valence);

            % Make texture from the image array
            texture = Screen('MakeTexture', window_1, imageArray_valence);

            % Define the destination rectangle to draw the image in its original size
            dst_rect_valence = CenterRectOnPointd([0 0 size(imageArray_valence, 2) size(imageArray_valence, 1)], centerX, centerY);

            % Set text size and font
            Screen('TextSize', window_1, 40);
            Screen('TextFont', window_1, 'Arial');

            % Calculate positions for the circles
            circle_radius = 45;
            contour_thickness = 3;
            space_between_circles = 175;
            total_length = 8 * space_between_circles + 2 * (circle_radius + contour_thickness);
            start_x = centerX - total_length / 2 + circle_radius + contour_thickness;
            y_position = centerY + size(imageArray_valence, 1) / 2 + 100;

            % Initialize variables for circle clicks
            clicked_in_circle = false;
            clicked_circle_index = 0;

            while ~clicked_in_circle
                % Draw the texture to the window
                Screen('DrawTexture', window_1, texture, [], dst_rect_valence);

                % Draw and number circles with contours
                for i = 1:9
                    current_x = start_x + (i-1) * space_between_circles;

                    % Draw contour and circle
                    Screen('FillOval', window_1, [0 0 0], ...
                        [current_x - (circle_radius + contour_thickness), y_position - (circle_radius + contour_thickness), ...
                        current_x + (circle_radius + contour_thickness), y_position + (circle_radius + contour_thickness)]);
                    Screen('FillOval', window_1, [255 255 255], ...
                        [current_x - circle_radius, y_position - circle_radius, ...
                        current_x + circle_radius, y_position + circle_radius]);

                     % Draw the number centered in the circle
                    number_str = num2str(i);
                    text_bounds = Screen('TextBounds', window_1, number_str);
                    text_width = text_bounds(3) - text_bounds(1);
                    text_height = text_bounds(4) - text_bounds(2);
                    text_x = current_x - text_width / 2;
                    text_y = y_position - text_height / 2000;
                    DrawFormattedText(window_1, number_str, text_x, text_y, [0 0 0]);
                end

                % Update the display
                ValenceTime = Screen('Flip', window_1);
                [ret, outlet] = MatNICMarkerSendLSL(5, outlet); % Valence event code to NIC
                Valence_Time(trial_) = ValenceTime - start_exp;  % Store the elapsed time since the experiment started
                disp('Valence_Time:')
                disp(Valence_Time)
                rt_allo(trial_) = Valence_Time(trial_) - Allo_Time(trial_);
                disp('rt_allo:')
                disp(rt_allo)


                % Check for mouse clicks
                [clicks, x, y, whichButton] = GetClicks(window_1, 0);
                if clicks
                    for i = 1:9
                        current_x = start_x + (i-1) * space_between_circles;
                        distance_squared = (x - current_x)^2 + (y - y_position)^2;
                        if distance_squared <= circle_radius^2
                            clicked_circle_index = i;  % Update the clicked circle index
                            clicked_in_circle = true;
                            choiceValence(trial_) = i;
                            disp('choice_Valence')
                            disp(choiceValence)
                            break;  % Exit the for loop since circle is found
                        end
                    end
                end
            end
            state = 8;

% -------------------------------------------------------------------------
%                             Arousal
% -------------------------------------------------------------------------            
        case 8
             SetMouse(centerX, centerY, window_1);
             file_arousal = 'C:\Users\SpikeUrban\Documents\Exp5\task\task5\Scripts\score_images\Score_Arousal.png';

            % Load the image from the file
            imageArray_arousal = imread(file_arousal);

            % Make texture from the image array
            texture = Screen('MakeTexture', window_1, imageArray_arousal);

            % Define the destination rectangle to draw the image in its original size
            dst_rect_arousal = CenterRectOnPointd([0 0 size(imageArray_arousal, 2) size(imageArray_arousal, 1)], centerX, centerY);

            % Set text size and font
            Screen('TextSize', window_1, 40);
            Screen('TextFont', window_1, 'Arial');

            % Calculate positions for the circles
            circle_radius = 45;
            contour_thickness = 3;
            space_between_circles = 175;
            total_length = 8 * space_between_circles + 2 * (circle_radius + contour_thickness);
            start_x = centerX - total_length / 2 + circle_radius + contour_thickness;
            y_position = centerY + size(imageArray_valence, 1) / 2 + 100;

            % Initialize variables for circle clicks
            clicked_in_circle = false;
            clicked_circle_index = 0;

            while ~clicked_in_circle
                % Draw the texture to the window
                Screen('DrawTexture', window_1, texture, [], dst_rect_arousal);

                % Draw and number circles with contours
                for i = 1:9
                    current_x = start_x + (i-1) * space_between_circles;

                    % Draw contour and circle
                    Screen('FillOval', window_1, [0 0 0], ...
                        [current_x - (circle_radius + contour_thickness), y_position - (circle_radius + contour_thickness), ...
                        current_x + (circle_radius + contour_thickness), y_position + (circle_radius + contour_thickness)]);
                    Screen('FillOval', window_1, [255 255 255], ...
                        [current_x - circle_radius, y_position - circle_radius, ...
                        current_x + circle_radius, y_position + circle_radius]);

                     % Draw the number centered in the circle
                    number_str = num2str(i);
                    text_bounds = Screen('TextBounds', window_1, number_str);
                    text_width = text_bounds(3) - text_bounds(1);
                    text_height = text_bounds(4) - text_bounds(2);
                    text_x = current_x - text_width / 2;
                    text_y = y_position - text_height / 2000;
                    DrawFormattedText(window_1, number_str, text_x, text_y, [0 0 0]);
                end

                % Update the display
                ArousalTime = Screen('Flip', window_1);
                [ret, outlet] = MatNICMarkerSendLSL(6, outlet); % Arousal event code to NIC
                Arousal_Time(trial_) = ArousalTime - start_exp;  % Store the elapsed time since the experiment started
                disp('Arousal_Time:')
                disp(Arousal_Time)
                rt_valence(trial_) = Arousal_Time(trial_) - Valence_Time(trial_);
                disp('rt_valence:')
                disp(rt_valence)

                % Check for mouse clicks
                [clicks, x, y, whichButton] = GetClicks(window_1, 0);
                if clicks
                    for i = 1:9
                        current_x = start_x + (i-1) * space_between_circles;
                        distance_squared = (x - current_x)^2 + (y - y_position)^2;
                        if distance_squared <= circle_radius^2
                            clicked_circle_index = i;  % Update the clicked circle index
                            clicked_in_circle = true;
                            choiceArousal(trial_) = i;
                            disp('choice_Arousal')
                            disp(choiceArousal)
                            HideCursor;
                            break;  % Exit the for loop since circle is found
                        end
                    end
                end
            end
            state = 9;
        
        case 9
            % Fill the screen with black color
            Screen('FillRect', window_1, [255 255 255]);  % Assuming 0 is the color code for black
            % Update the display to show the black screen
            BlankTime = Screen('Flip', window_1);
            [ret, outlet] = MatNICMarkerSendLSL(7, outlet); % Nav Ego event code to NIC

            Blank_Time(trial_) = BlankTime - start_exp;  % Store the elapsed time since the experiment started
            disp('Blank_Time:')
            disp(Blank_Time)
            rt_arousal(trial_) = Blank_Time(trial_) - Arousal_Time(trial_);
            disp('rt_arousal:')
            disp(rt_arousal)

            % Wait for one and a half seconds
            WaitSecs(1.5);
            % Increase the trial counter if necessary, or reset any trial-specific variables
            trial_ = trial_ + 1;  % Make sure this doesn't exceed your number of trials (n)
            % Go back to state 2 for the next trial
            state = 2;
       
    end
end

% -------------------------------------------------------------------------
%                          Results file
% -------------------------------------------------------------------------
name_file = [results_path '/resultfile_' num2str(subID) '.xlsx'];

M = [FixTime', VideoTime', Ego_Time', Allo_Time', ...
    Valence_Time', Arousal_Time', Blank_Time', ego_coordinate_x', ego_coordinate_y', ...
    allo_coordinate_x', allo_coordinate_y', rt_ego', rt_allo', rt_valence', rt_arousal', ... 
    choiceValence', choiceArousal'];

T = [array2table(M), cell2table(video_name')];

T.Properties.VariableNames = {'FixTime', 'VideoTime', 'Ego_Time', 'Allo_Time', ...
    'Valence_Time', 'Arousal_Time', 'Blank_Time', 'ego_coordinate_x', 'ego_coordinate_y', ...
    'allo_coordinate_x', 'allo_coordinate_y', 'rt_ego', 'rt_allo', 'rt_valence', 'rt_arousal', ... 
    'choiceValence', 'choiceArousal', 'Video_name_trial'};
writetable(T,name_file);

sca;
[ret, outlet] = MatNICMarkerSendLSL(8, outlet); % End event code to NIC





