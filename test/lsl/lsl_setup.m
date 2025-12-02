% load the library
lib = lsl_loadlib();

streaminfos = lsl_resolve_all(lib);

% resolve a stream...
disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); end

streams = {};
while isempty(streams)
    streams = lsl_resolve_byprop(lib, 'type', 'mac_address');
end 

result{1}

% Define stream info
info = lsl_streaminfo(lib, 'PTB_Markers', 'Markers', 1, 0, 'cf_string', 'myuniquesourceid12345');

% Visualize streams
vis_stream

% Create the outlet
outlet = lsl_outlet(info);

% create a stream info and outlet based on the stream info
stream_name = 'MyMarkerStream';  % set the marker stream name according to your needs
info = lsl_streaminfo(lib,stream_name,'Markers',1,0,'cf_string','myuniquesourceid23443');
marker_outlet = lsl_outlet(info);

% push a marker to the marker_outlet with the current LSL time
marker_string = 'Marker101';  % set the marker string value according to your needs
marker_outlet.push_sample({marker_string});

eye = {};
while isempty(eye)
    eye = lsl_resolve_byprop(lib,'type','Gaze'); 
end




info = lsl_streaminfo(lib,'EyeLinkStream','Gaze',4,1000,'cf_double64','eyelink123');
% channels: [x, y, pupil, validity]
outlet = lsl_outlet(info);

Eyelink('Initialize');
Eyelink('StartRecording');
Eyelink('NewestFloatSample?')
vis_stream()
tim = tic();
while Eyelink('IsConnected')
    display(toc(tim))
    evt = Eyelink('NewestFloatSample');
    if ~isempty(evt)
        gaze = [evt.gx(1) evt.gy(1) evt.pa(1) evt.flags];
        disp(gaze)
        outlet.push_sample(gaze);
    end
    if toc(tim)>5
        Eyelink('command', 'set_idle_mode');
        break
    end
end

Eyelink('ShutDown');


% add fieldtrip and load_xdf 
ft_defaults()
ftPath = fileparts(which('ft_defaults'));
addpath(fullfile(ftPath, 'external','xdf'));

xdfFilePath = 'C:\Users\Bruno Miranda\Downloads\lsl_test\sub-P001\ses-S001\eeg\sub-P001_ses-S001_task-Default_run-001_eeg.xdf'

% load xdf streams
xdfStreams                  = load_xdf(xdfFilePath);
nStreams                    = numel(xdfStreams);

% list all channel names per stream
for iStream = 1:nStreams
    
    % different data "streams" correspond to different "tracking systems (for motion)"
    % or "modalities (such as EEG or Motion)"
    xdfStreams{iStream}.info.name
  
    % check if channels field is present (if not, it is a marker stream)
    if isfield(xdfStreams{iStream}.info.desc, 'channels')
        cellfun(@(x) x.label, xdfStreams{iStream}.info.desc.channels.channel, 'UniformOutput', false)
    end
    
end


