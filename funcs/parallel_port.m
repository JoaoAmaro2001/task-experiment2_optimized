% When the computer has a parallel port, use this function
% If Psychtoolbox needs to be used at the same time then:
% NetStation('Connect', '10.10.10.42') -> IPV4 10.10.10.XX and same subnet as MAC
% NetStation('Synchronize')

function parallel_port(data_out)

ioObj = io64;
[~, status] = evalc('io64(ioObj)'); % use evalc to hide output
if status ~= 0
    error('io64 installation failed');
end
address = hex2dec('BFF8');
%-------------------------------------------------
io64(ioObj,address,data_out); % send a signal
pause(0.05)                   % change this setting based on task
flush    = 0;
io64(ioObj,address,flush);    % flush

end


