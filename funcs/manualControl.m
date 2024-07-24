% MANUAL CONTROL
[keyIsDown, ~, keyCode] = KbCheck; % Check for keyboard press
if keyIsDown
    if keyCode(keyESCAPE) % Check if the terminate key was pressed
        elFinish;
        error('Forced exit') % Exit the function or script
    end
end