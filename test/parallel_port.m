% When the computer has a parallel port, use this function
% If Psychtoolbox wanted to be use at the same time
% NetStation('Connect', '10.10.10.42')
% NetStation('Synchronize')

function parallel_port(data_out)

ioObj = io64;
status = io64(ioObj);
address = hex2dec('BFF8');
%-------------------------------------------------
io64(ioObj,address,data_out); % send a signal
pause(0.05)                   % change this setting based on task
flush    = 0;
io64(ioObj,address,flush);    % flush

end


