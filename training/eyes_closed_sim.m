% Load Settings and initialize 
clear, clc, close all
settings_main_sim;

% Init
tr_final    = (6*60)/2;    % Number of triggers
tr_trigger  = 0;           % TR trigger counter
slice_n     = 0;           % Refers to slice signals?
flag_first  = 1;           % Flag for first trigger

% Pyschtoolblox prelim
Priority(MaxPriority(window1)); % Give priority of resources to experiment
Screen('TextSize', window1, 50);
Screen('DrawText',window1,'A experiência começará em breve', (W/3), (H/2), textColor);
Screen('Flip',window1);

% Start resting state
prevDigit = -1;  % Initialize prevDigit to a value that firstDigit will never be
tic;
while 1 

    % SIMULATING SERIAL PORT COMMUNICATION
    timetmp = toc;
    firstDigit = str2double(num2str(floor(timetmp)));
    if mod(firstDigit, 2) == 0 && firstDigit ~= prevDigit && firstDigit ~= 0
        aux = 115;
        beep
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
        if keyCode(hotkey) % Check if the hotkey was pressed
            aux = 115;
        end
    end

    if ~isempty(aux) && aux==115 % 115 is the ASCII code for 's'
        
        tr_trigger = tr_trigger + 1;
        if tr_trigger == tr_final
            finish = GetSecs;
            break
        end

        if flag_first

            beg = GetSecs;
            % Blank screen 
            Screen(window1, 'FillRect', backgroundColor);
            Screen('Flip', window1)
            disp('Estado: Ecrã branco')
            flag_first = 0;
            
        end
    end
end

sca; % sca -- Execute Screen('CloseAll');
fprintf('Tempo total: %f seconds\n', finish-beg)
fprintf('Número de eventos "100": %f \n', slice_n)
