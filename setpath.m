cdir = pwd;
user = getenv('USER');
if isempty(user)
  user = getenv('UserName');
end

switch user
    case 'Bruno Miranda'          % Tower computer
    try
    root        = 'Z:\Exp_2_optimized-video_rating'; % LAN
    cd(root); 
    cd(cdir);
    catch
    root        = 'C:\Exp_2_optimized-video_rating'; % Local
    end
    scripts     = 'C:\github\JoaoAmaro2001\task-experiment2_optimized'; % specify path to scripts; 
    sourcedata  = fullfile(root,'sourcedata'); 
    bidsroot    = fullfile(root,'bids'); 
    results     = fullfile(root,'results');
    derivatives = fullfile(root,'derivatives'); 

    case 'NGR_FMUL'          % VR-accelerated computer
    try
    root        = 'Z:\Exp_2_optimized-video_rating'; % LAN
    cd(root); 
    cd(cdir);
    catch
    root        = 'Z:\Exp_2_optimized-video_rating'; % Local
    end
    scripts     = 'C:\github\JoaoAmaro2001\task-experiment2_optimized'; % specify path to scripts; 
    sourcedata  = fullfile(root,'sourcedata'); 
    bidsroot    = fullfile(root,'bids'); 
    results     = fullfile(root,'results');
    derivatives = fullfile(root,'derivatives'); 
    
    case 'joaop'          % Personal computer
    try
    root        = 'Z:\Exp_2_optimized-video_rating'; % LAN
    cd(root); 
    cd(cdir);
    catch
    root        = 'Z:\Exp_2_optimized-video_rating'; % Local
    cd(root); 
    cd(cdir);
    end
    scripts     = 'C:\Users\joaop\git\JoaoAmaro2001\WorkRepo'; % specify path to scripts; 
    sourcedata  = fullfile(root,'sourcedata'); 
    bidsroot    = fullfile(root,'bids'); 
    results     = fullfile(root,'results');
    derivatives = fullfile(root,'derivatives'); 

    case 'Administrator' % MSI computer
    try
    root        = 'Z:\Exp_2_optimized-video_rating'; % LAN
    cd(root); 
    cd(cdir);
    catch
    root        = 'Z:\Exp_2_optimized-video_rating'; % Local
    end
    scripts     = 'C:\git\JoaoAmaro2001\WorkRepo'; % specify path to scripts; 
    sourcedata  = fullfile(root,'sourcedata'); 
    bidsroot    = fullfile(root,'bids'); 
    results     = fullfile(root,'results');
    derivatives = fullfile(root,'derivatives'); 
  otherwise
    error('The directories for the input and output data could not be found');
end

addpath(genpath(scripts))
addpath('C:\toolbox\Psychtoolbox')
addpath('C:\toolbox\fieldtrip-20240722')
addpath('C:\toolbox\eeglab2024.2')
