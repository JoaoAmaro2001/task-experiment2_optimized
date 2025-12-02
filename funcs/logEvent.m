function ev = logEvent(ev, idx, evtStart, evtDuration, evtType, evtValue, start_exp, fs)
%LOGEVENT Store one event in the event struct.
%
%   ev           : event struct
%   idx          : event index (event_)
%   evtStart     : GetSecs timestamp of event onset
%   evtDuration  : Duration OR NaN (NaN -> computed at end; 0 -> instantaneous)
%   evtType      : string label, e.g. 'DI98'
%   evtValue     : numeric code, e.g. 98
%   start_exp    : experiment start timestamp (GetSecs)
%   fs           : sampling rate (e.g., 500 Hz)

    onsetSec            = evtStart - start_exp;

    ev.onsets(idx)      = onsetSec;
    ev.time{idx}        = datetime('now');
    ev.types{idx}       = evtType;
    ev.values(idx)      = evtValue;
    ev.samples(idx)     = round(onsetSec * fs);

    % Duration provided manually (0 or a positive number) OR NaN to mark "compute later"
    ev.durations(idx)   = evtDuration;

end
