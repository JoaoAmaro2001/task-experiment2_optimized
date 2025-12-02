function ev = logEventDurations(ev)
%COMPUTEEVENTDURATIONS Compute missing durations from onset differences.
%
%   Only rows with duration = NaN are updated.
%   Last event remains 0 if duration = NaN.
        
    for i = 1:ev.numEvents-1
        if isnan(ev.durations(i)) && ev.onsets(i) > 0 && ev.onsets(i+1) > 0
            ev.durations(i) = ev.onsets(i+1) - ev.onsets(i);
        end
    end

    % Last event: if duration = NaN, set to 0 (BIDS-standard for instantaneous)
    if isnan(ev.durations(end))
        ev.durations(end) = 0;
    end
end
