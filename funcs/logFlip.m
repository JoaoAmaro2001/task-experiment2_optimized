function [flipLog, flipIdx] = logFlip(flipLog, flipIdx, code, InitialDisplayTime, StimulusOnsetTime, FlipTimestamp, Missed, Beampos)

    flipLog.initial_call(flipIdx)     = InitialDisplayTime;
    flipLog.predicted_onset(flipIdx)  = StimulusOnsetTime;
    flipLog.timestamp_return(flipIdx) = FlipTimestamp;
    flipLog.missed(flipIdx)           = Missed;
    flipLog.beampos(flipIdx)          = Beampos;
    flipLog.event_code(flipIdx)       = code;

    flipIdx = flipIdx + 1;
end
