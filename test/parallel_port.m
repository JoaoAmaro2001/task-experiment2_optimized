%% If Psychtoolbox wanted to be use at the same time
% NetStation('Connect', '10.10.10.42')
% NetStation('Synchronize')


%% When the computer has a parallel port
ioObj = io64;
status = io64(ioObj);
address = hex2dec('BFF8');
for j=1:10
    for i=1:100 
    data_out=1 %i
    io64(ioObj,address,data_out); % send a signal
    pause(0.00005)
% pause(1)
%     start_t=NetStation('Event', 'Start');
    data_out=0;
     io64(ioObj,address,data_out); % stop sending a signal
    pause(1)
% pause(1)
    end
end

%% with the parallel port using nidaq (NI board)
% clear all
% close all
% clc
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% putvalue(dio,[0 0 0 0 0 0 0 0]);
% putvalue(dio,[1 1 1 1 1 1 1 1]);



% tic; putvalue(dio,[0 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% clear all
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[0 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% fprintf('putvalue: %s s\n',toc);
% tic; putvalue(dio,[0 0 0 0 0 0 0 1]);
% %-- 09/06/2022 15:16 --%
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[0 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 0 0 0 0 1]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 0 0 0 0 1]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 1 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('nidaq','Dev1');
% addline(dio,0:7,'Out');
% tic; putvalue(dio,[1 0 0 0 0 0 0 0]);
% fprintf('putvalue: %s s\n',toc);
% dio = digitalio('parallel','lpt3');
% addline(dio,0:7,'out')   %pin 8
% putvalue(dio.line,[1 1 1 1 1 1 1 1]);
% dio = digitalio('parallel','lpt1');
% addline(dio,0:7,'out')   %pin 8
% putvalue(dio.line,[1 1 1 1 1 1 1 1]);
% dio = digitalio('parallel','lpt3');
% addline(dio,0:7,'out')   %pin 8
% putvalue(dio.line,[1 1 1 1 1 1 1 1]);
% clear all