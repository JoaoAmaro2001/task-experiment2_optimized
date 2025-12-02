function taskCleanup()
    try Screen('CloseAll'); end
    try ListenChar(0); end
    try ShowCursor; end
    try Priority(0); end
    fprintf('\n[Cleanup executed automatically]\n'); 
end