% SFIX -> start fixation
% EFIX -> end fixation
% SSACC -> start saccade
% ESACC -> end saccade

filename_eye = 'C:\Exp_2_optimized-video_rating\sourcedata\supp\eyelinkAscii\SR001_1.asc';

cfg = [];
cfg.dataset = filename_eye;
data_eye = ft_preprocessing(cfg);

cfg = [];
cfg.dataset          = filename_eye;
cfg.montage.tra      = eye(4);
cfg.montage.labelorg = {'1', '2', '3', '4'};
cfg.montage.labelnew = {'EYE_TIMESTAMP', 'EYE_HORIZONTAL', 'EYE_VERTICAL', 'EYE_DIAMETER'};
data_eye = ft_preprocessing(cfg);

event_eye = ft_read_event(filename_eye);

disp(unique({event_eye.type}))

figure
plot([event_eye.sample]./data_eye.hdr.Fs, [event_eye.duration], '.')
title('EYE INPUT')
xlabel('time (s)');
ylabel('trigger duration');

cfg = [];
cfg.viewmode       = 'vertical';
cfg.preproc.demean = 'yes';
cfg.event          = event_eye;
ft_databrowser(cfg, data_eye);

cfg = [];
cfg.dataset = filename_eye;
ft_databrowser(cfg);