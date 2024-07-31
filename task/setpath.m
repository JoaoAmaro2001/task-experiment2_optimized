cdir = pwd;
user = getenv('USER');
if isempty(user)
  user = getenv('UserName');
end

switch user
    case 'joaop'          % Personal computer
    try
    root        = 'Z:\Exp_4-outdoor_walk\lisbon'; % LAN
    cd(root); 
    cd(cdir);
    catch
    root        = 'D:\Joao\Exp_4-outdoor_walk\lisbon'; % Local
    end
    scripts     = 'C:\Users\joaop\git\JoaoAmaro2001\WorkRepo'; % specify path to scripts; 
    sourcedata  = fullfile(root,'sourcedata'); 
    bidsroot    = fullfile(root,'bids'); 
    results     = fullfile(root,'results');
    derivatives = fullfile(root,'derivatives'); 

    case 'Administrator' % MSI computer
    try
    root        = 'Z:\Exp_4-outdoor_walk\lisbon'; % LAN
    cd(root); 
    cd(cdir);
    catch
    root        = 'I:\Joao\Exp_4-outdoor_walk\lisbon'; % Local
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