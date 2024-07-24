% CREATE VARIABLES FOR DATAVIEWER; END TRIAL

function elCreateVariables(i, stimName, reactionTime)
        
        % Write !V TRIAL_VAR messages to EDF file: creates trial variables in DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Trial Message Commands
        Eyelink('Message', '!V TRIAL_VAR iteration %d', i); % Trial iteration
        Eyelink('Message', '!V TRIAL_VAR image %s', stimName); % Image name
        WaitSecs(0.001); % Allow some time between messages. Some messages can be lost if too many are written at the same time
        reactionTimeMs = round(reactionTime * 1000);
        Eyelink('Message', '!V TRIAL_VAR rt %d', reactionTimeMs); % Reaction time

end