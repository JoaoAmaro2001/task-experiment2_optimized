clear, clc, close all
setpath;
settings_main_sim; % Load all the settings from the file

% -------------------------------------------------------------------------
%                           State Information:
%                               
% 0. Blank screen
% 1. Blank screen & Cross
% 2. Load active stimulus
% 3. Load neutral stimulus
% -------------------------------------------------------------------------

% Init
tr_final    = (8*32 + 8*32)/2; % Number of triggers
tr_trigger  = 0;                    % TR trigger counter (There are 261 -> ((8*32 + 8*32 + 10)/2) = 8.7 mins)
tr_N        = 0;                    % tr counter inside loop for each block
tr_n        = 0;                    % tr counter inside loop for each stimulus
tr_cross    = 0;                    % tr counter for cross
num_cross   = 0;                    % Counter for the cross state
state       = 0;                    % Gets the state information
ds_block    = 0;                    % Set the ds block counter -> active stimulus
dn_block    = 0;                    % Set the dn block counter -> neutral stimulus
trial_num   = 1;                    % Trial counter
flag_screen = 1;                    % Flag for updating screen
flag_resp   = 1;                    % Flag for response -> can only respond while is 1
flag_cross  = 1;                    % Flag for cross -> first time entering cross
flag_first  = 1;                    % Flag for first time reading the aux
rt_num      = zeros(1,32);          % Reaction time for response
res_num     = zeros(1,32);          % Response number
trial       = zeros(1,32);          % Trial number
stim_txt    = cell(1,32);           % Stimulus text
res_txt     = cell(1,32);           % Response text
cond        = cell(1,32);           % Conditions
boldOption  = [];                   % Variable that carries response info

% Read the subject id - handedness information within the id

% Pyschtoolblox prelim
Priority(MaxPriority(window1)); % Give priority of resources to experiment
Screen('TextSize', window1, 50);
Screen('DrawText',window1,'A experiência começará em breve', (W/3), (H/2), textColor);
Screen('Flip',window1);

% Start Experiment
prevDigit = -1;  % Initialize prevDigit to a value that firstDigit will never be
tic;
while 1

    % SIMULATING SERIAL PORT COMMUNICATION
    timetmp = toc;
    firstDigit = str2double(num2str(floor(timetmp)));
    if mod(firstDigit, 2) == 0 && firstDigit ~= prevDigit && firstDigit ~= 0
        aux = 115;
        beep
        % S(1) = load('gong');
        % S(2) = load('handel');
        % sound(S(1).y,S(1).Fs)
        % sound(S(2).y,S(2).Fs)
        toc
    else
        aux = [];
    end
    prevDigit = firstDigit; % Update prevDigit

    % MANUAL CONTROL
    [keyIsDown, ~, keyCode] = KbCheck; % Check for keyboard press
    if keyIsDown
        if keyCode(terminateKey) % Check if the terminate key was pressed
            break % Exit the function or script
        end
        % if keyCode(hotkey) % Check if the hotkey was pressed
        %     aux = 115;
        % end
    end

    % BUTTON CHECK CONTROL CONTROL (FINISH!)
    if (state == 2 || state == 3) && flag_resp
        [keyIsDown, ~, keyCode] = KbCheck; 
        if state == 2
            text_input = textActiveStimuli;
        elseif state == 3
            text_input = textNeutralStimuli;
        end
        if keyIsDown && keyCode(resp1)
            boldOption              = 1;
            drawText(window1, text_input, trial_num, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 1;  
            res_txt{trial_num}      = responseOptions{1}; 
            flag_resp               = 0;
            boldOption              = [];
        end
        if keyIsDown && keyCode(resp2)
            boldOption              = 2;
            drawText(window1, text_input, trial_num, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 2;  
            res_txt{trial_num}      = responseOptions{2}; 
            flag_resp               = 0;
            boldOption              = [];
        end
        if keyIsDown && keyCode(resp3)
            boldOption              = 3;
            drawText(window1, text_input, trial_num, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 3;  
            res_txt{trial_num}      = responseOptions{3}; 
            flag_resp               = 0;
            boldOption              = [];
        end
        if keyIsDown && keyCode(resp4)
            boldOption              = 4;
            drawText(window1, text_input, trial_num, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 4;  
            res_txt{trial_num}      = responseOptions{4}; 
            flag_resp               = 0;
            boldOption              = [];
        end
    end

    % TR-DEPENDENT STIMULUS CONTROL 
    if ~isempty(aux) && (aux == 115)

        if tr_trigger == 0
            start_exp = GetSecs;
            fprintf('First trigger received\n')
        end
        if tr_trigger == tr_final % end trigger
            break
        end

        switch state

            case 0 
                % 0. Blank screen
                tr_trigger = tr_trigger + 1;
                Screen(window1, 'FillRect', backgroundColor);
                Screen('Flip', window1); % Flip the screen (don't clear the buffer)
                disp('Estado: Ecrã em branco')
                if tr_trigger == 4 % It needs to be 5-1 such that tr = 5 begins case 2
                    state = 2;
                    ds_block = ds_block + 1; % DS is the first block
                end

            case 1
                % 1. Blank screen & Cross
                tr_trigger = tr_trigger + 1;
                tr_cross = tr_cross + 1;
                if flag_cross
                    num_cross = num_cross + 1;
                    drawCross(window1,W,H);
                    Screen('Flip', window1);
                    disp('Estado: Blank / Cross')
                    flag_cross = 0;
                end
                if tr_cross == 15 
                    tr_cross = 0;
                    flag_cross = 1;
                    if mod(num_cross,2) == 0 % Even is active stimulus
                        state = 2;
                        ds_block = ds_block + 1; % DS is the first block
                    elseif mod(num_cross,2) == 1 % Odd is neutral stimulus
                        state = 3;
                        dn_block = dn_block + 1; % DN is the second block 
                    end
                end

            case 2
                % 2. Load active stimulus
                fprintf('Estado: Bloco ativo e frase nº%d\n', trial_num)
                tr_trigger = tr_trigger + 1;
                tr_N = tr_N + 1;
                tr_n = tr_n + 1;
                if flag_screen
                    drawText(window1, textActiveStimuli, trial_num, W, H, backgroundColor, textColor)
                    addResponseOptions(window1, responseOptions, boldOption)
                    rt_beg = GetSecs;
                    flag_screen = 0;
                end
                if tr_n == 4 % 4 because tr_n=1 signifies beginning of first TR
                    % Fill variables
                    if rt_num(trial_num) == 0
                        rt_num(trial_num)   = NaN;
                        res_num(trial_num)  = NaN;         
                        trial(trial_num)    = trial_num;         
                        stim_txt{trial_num} = textActiveStimuli{trial_num};         
                        res_txt{trial_num}   = "";
                        cond{trial_num}     = cond_text{1};
                    else
                        rt_num(trial_num)   = rt_num(trial_num);
                        res_num(trial_num)  = res_num(trial_num);
                        trial(trial_num)    = trial_num;
                        stim_txt{trial_num} = stim_txt{trial_num};
                        res_txt{trial_num}  = res_txt{trial_num};
                        cond{trial_num}     = cond_text{1};
                    end
                    trial_num   = trial_num + 1;
                    tr_n        = 0;
                    flag_screen = 1;
                    flag_resp   = 1;
                end

                if tr_N == 16 % 4*4 TRs
                    state = 1;
                    tr_N = 0;
                end
                
            case 3
                % 3. Load neutral stimulus
                fprintf('Estado: Bloco neutro e frase nº%d\n', trial_num)
                tr_trigger = tr_trigger + 1;
                tr_N = tr_N + 1;
                tr_n = tr_n + 1;
                if tr_n == 4
                    % Fill variables
                    if rt_num(trial_num) == 0
                        rt_num(trial_num)   = NaN;
                        res_num(trial_num)  = NaN;         
                        trial(trial_num)    = trial_num;         
                        stim_txt{trial_num} = stim_txt{trial_num};         
                        res_txt{trial_num}   = "";
                        cond{trial_num}     = cond_text{1};
                    else
                        rt_num(trial_num)   = rt_num(trial_num);
                        res_num(trial_num)  = res_num(trial_num);
                        trial(trial_num)    = trial_num;
                        stim_txt{trial_num} = stim_txt{trial_num};
                        res_txt{trial_num}  = res_txt{trial_num};
                        cond{trial_num}     = cond_text{2};
                    end
                    trial_num   = trial_num + 1;
                    tr_n        = 0;
                    flag_screen = 1;
                    flag_resp   = 1;
                end
                if flag_screen
                    drawText(window1, textNeutralStimuli, trial_num, W, H, backgroundColor, textColor)     
                    addResponseOptions(window1, responseOptions, boldOption)
                    rt_beg = GetSecs;
                    flag_screen = 0;
                end
                if tr_N == 16 % 4*4 TRs
                    state = 1;
                    tr_N = 0;
                end
        end
    end
end

sca;
end_exp = GetSecs;
fprintf('Tempo total: %f seconds\n', end_exp-start_exp) % Total time of the experiment

% Save results in excel file
name_file = [results_path '\resultfile_training.xlsx'];
T = table(trial',stim_txt',res_txt',res_num',rt_num',cond','VariableNames',{'Trial','Stimulus','Response', 'ResponseIndex','ReactionTime','Condition'});
writetable(T,name_file)
