help NetStation

% Set IP to '10.10.10.32'
host = '10.10.10.42'; % check in cmd >>> ipconfig /all
port = 8;
[status, errormsg] = NetStation('Connect', host)

[status, errMsg] = NetStation('Connect', '192.168.89.134', '55513');

ntpserver = '10.10.10.51';
[status, error] = NetStation( 'GetNTPSynchronize', ntpserver )

status = NetStation('Synchronize')

NetStation('StartRecording')


ioObj = io64;
status = io64(ioObj);
address = hex2dec('BFF8');
io64(ioObj,address,data_out); % send a signal
