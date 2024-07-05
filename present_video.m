function [vid, vid_Time] = present_video(window1, movie, dst_rect)
% Function present_video: Shows video given as input,
%                         and returns vid (screen with video)
% Receives window (window1) and movie (not 'moviename', but screen with
%                           movie with that 'moviename')

vid_Time = GetSecs;
while 1
    vid = Screen('GetMovieImage', window1, movie);
    
    % Check if the movie frame was obtained successfully
    if vid <= 0
        % If no valid texture, and the reason is end of movie or error, break out of loop:
        break;
    end

    % Draw the new texture immediately to screen:
    Screen('DrawTexture', window1, vid, [], dst_rect);

    % Update display:
    Screen('Flip', window1);

    % Important: Release texture to avoid memory leak
    Screen('Close', vid);
end

% Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie:
Screen('CloseMovie', movie);
end

