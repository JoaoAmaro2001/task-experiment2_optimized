help Eyelink
Eyelink Initialize?

ipadress = '100.1.1.2'; % check in cmd >>> ipconfig /all
status = Eyelink('SetAddress', ipadress); % Check connection

% Eye dir
outeye = fullfile(scripts, 'test', 'eye');
subid  = 'test';


status = Eyelink('IsConnected')


% EYELINK - start
Screen('BlendFunction',w,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');


el = EyelinkInitDefaults(w);

% open file to record data
edfF = Eyelink('Openfile',[fullfile(outeye,subid),'.edf']);
if edfF ~= 0
    fprintf('Cannot create EDF file ''%s''',[fullfile(outeye,subid),'.edf']);
    Eyelink('Shutdown');
    Screen('CloseAll');
end