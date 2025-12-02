% % ====== NI-DAQ change-detection on DI line ======
% d = daq('ni');
% d_list = daqlist;
% d_info = d_list{1,end};
% 
% % Found Photodiode_test_board
% addinput(d,"Photodiode_test_board","port0/line1","Digital");           % DI: P0.1
% d.Rate = 10000;  % any reasonable rate (not critical if using ChangeDetection)

%% LSL – NI-DAQ / BioSemi simulation experiment
clear; clc; close all;

%% Parameters
Fs_NI = 10000;          % NI-DAQ sample rate
Fs_Bio = 2048;          % BioSemi sample rate
pulse_freq = 1;         % 1 Hz square wave
duration = 30/pulse_freq;  % enough for 1500 pulses
t_NI = 0:1/Fs_NI:duration;
t_Bio = 0:1/Fs_Bio:duration;

% simulate hardware delay + jitter for BioSemi
setup_offset = 0.006;   % 6 ms offset
jitter_std = 0.0005;    % 0.5 ms jitter

%% Generate periodic pulse (0/1 square wave)
pulse = square(2*pi*pulse_freq*t_NI, 50);   % 50% duty
pulse(pulse<0) = 0;

%% Simulate BioSemi-delayed version
delay_jitter = setup_offset + randn(size(t_Bio))*jitter_std;
interp_t = t_Bio - delay_jitter;
pulse_bio = interp1(t_NI, pulse, interp_t, 'previous', 0);

%% Detect rising edges (halfway threshold)
thr = 0.5;
rising_NI  = find(diff(pulse > thr) == 1);
rising_Bio = find(diff(pulse_bio > thr) == 1);

% Convert to timestamps
ts_NI  = t_NI(rising_NI);
ts_Bio = t_Bio(rising_Bio);

%% Emulate LSL streams
disp('Creating LSL outlets...');
lib = lsl_loadlib();

info_dataIn = lsl_streaminfo(lib,'NI_DAQ','EEG',1,Fs_NI,'cf_float32','ni_daq_id');
info_bio    = lsl_streaminfo(lib,'BioSemi','EEG',1,Fs_Bio,'cf_float32','biosemi_id');
info_marker = lsl_streaminfo(lib,'Markers','Markers',1,0,'cf_string','marker_id');

outlet_dataIn = lsl_outlet(info_dataIn);
outlet_bio    = lsl_outlet(info_bio);
outlet_marker = lsl_outlet(info_marker);

disp('Streaming simulated cfg...');

tic;
for k = 1:length(t_NI)
    % send NI signal continuously
    outlet_dataIn.push_sample(pulse(k));
    
    % occasionally send marker at rising edges
    if ismember(k, rising_NI)
        outlet_marker.push_sample({'Pulse'});
    end
    
    % simulate ~real time
    pause(1/Fs_NI);
end
toc;
disp('Finished sending NI stream.');

% send BioSemi stream separately (faster)
for k = 1:length(t_Bio)
    outlet_bio.push_sample(pulse_bio(k));
    pause(1/Fs_Bio);
end

disp('All streams sent.');

%% ====== Analysis section ======
% Simulate LabRecorder output: compare timestamps directly
if length(ts_NI) > length(ts_Bio)
    ts_NI = ts_NI(1:length(ts_Bio));
else
    ts_Bio = ts_Bio(1:length(ts_NI));
end

delta_t = ts_Bio - ts_NI; % difference in seconds

fprintf('\nMean setup offset = %.3f ms\n', mean(delta_t)*1000);
fprintf('Std (jitter) = %.3f ms\n', std(delta_t)*1000);

%% Plot
figure;
subplot(2,1,1);
plot(t_NI, pulse, 'k'); hold on;
plot(t_Bio, pulse_bio, 'r');
xlabel('Time (s)'); ylabel('Amplitude');
legend('NI-DAQ signal','BioSemi signal');
title('Simulated Pulse Signals with Offset & Jitter');

subplot(2,1,2);
plot(delta_t*1000,'.-');
xlabel('Pulse #'); ylabel('Offset (ms)');
title('Setup Offset and Jitter per Pulse');
grid on;
