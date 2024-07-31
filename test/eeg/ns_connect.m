help NetStation

% Set IP to '10.10.10.32'
host = '10.10.10.32'; % check in cmd >>> ipconfig /all
[status, errormsg] = NetStation('Connect', host)
status = NetStation('Synchronize')
NetStation('StartRecording')
