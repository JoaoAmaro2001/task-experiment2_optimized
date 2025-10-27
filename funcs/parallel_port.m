% Use this function to send dat via parallel port

function parallel_port(data_out)

ioObj = io64;
[~, status] = evalc('io64(ioObj)'); % use evalc to hide output
if status ~= 0
    error('io64 installation failed');
end
address = hex2dec('BFF8');
%-------------------------------------------------
io64(ioObj,address,data_out); % send a signal
% change this setting based on task
% if sr=500Hz=2ms delta t, then the pause is double this value
% pause(0.004)                  
flush    = 0;
io64(ioObj,address,flush);    % flush
clear io64

end


