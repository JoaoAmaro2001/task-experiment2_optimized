function labRecorderInit()
    % Remote control over LabRecorder using RCS
    lr = tcpip('localhost', 22345); 
    fopen(lr);
    fprintf(lr, 'select all');
    fprintf(lr, ['filename {root:C:\Data\} '...
                '{task:MemoryGuided} ' ...
                '{template:s_%p_%n.xdf ' ...
                '{modality:ieeg}']); 
    fprintf(lr, 'start');
    pause(5)
    fprintf(lr, 'stop');
end