help NetStation

host = '10.10.10.42'; % check in cmd >>> ipconfig /all
port = 8;
[status, errormsg] = NetStation('Connect', host, address)

[status, errMsg] = NetStation('Connect', '10.10.10.42');

status = NetStation('Synchronize')

NetStation('StartRecording')


ioObj = io64;
status = io64(ioObj);
address = hex2dec('BFF8');
io64(ioObj,address,data_out); % send a signal
