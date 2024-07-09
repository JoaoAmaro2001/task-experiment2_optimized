setpath;

%  SCREEN SETUP
output_screen = 2; % 1 for primary, 2 for secondary, ...
screens = Screen('Screens');
screenNumber = max(screens);

if screenNumber > 0 % find out if there is more than one screen
    dual = get(0,'MonitorPositions');
    resolution = [0,0,dual(output_screen,3),dual(output_screen,4)];
elseif screenNumber == 0 % if not, get the normal screen's resolution
    resolution = get(0,'ScreenSize');
end
data.format.resolx = resolution(3);
data.format.resoly = resolution(4);

% cleanup unused variables
clear output_screen screens resolution dual


%% PARAMETERS - SETUP & INITIALISATION
AssertOpenGL; % gives warning if running in PC with non-OpenGL based PTB

% task path
if (~isdeployed)
    scriptName = mfilename('fullpath'); [pathz,~,~]= fileparts(scriptName);
else
    pathz = uigetdir(...
        'C:\Users\DPrataLab\Documents\Tarefas\VocalizationPTB\LAB',...
        'Select task path:');
end
cd(pathz) % go to path where task is running

% Initialise sound driver - changed to low latency? - & open audio device
InitializePsychSound(1); phndl = PsychPortAudio('Open',[],[],0,44100,1);

% Formatting options
data.format.fontSize = 40;
data.format.fontSizeFixation = 120;
data.format.font = 'Arial';
data.format.background_color = [150 150 150]; % grey 150!
% initialise system for key query - changed 'UnifyKeyNames' to 'KeyNames' due to
% the keyboard usage
KbName('KeyNames');
keyDELETE = KbName('delete'); keySPACE = KbName('space');
keyZ = KbName('z'); % 1
keyX = KbName('x'); % 2
keyC = KbName('c'); % 3
keyV = KbName('v'); % 4
keyB = KbName('b'); % 5
keyN = KbName('n'); % 6
keyM = KbName('m'); % 7

% instructions definition
data.text.getready = 'Quando estiver pronto pressione a tecla SPACE.';
data.text.instructions_p1 = ['Nesta tarefa irá ouvir sons. \n\n',...
    'Será pedido que faça diferentes julgamentos \n',...
    'acerca da autenticidade de sons emocionais, \n',...
    'enquanto em sons neutros pedimos apenas que \n',...
    'preste atenção. \n\n',...
    'A autenticidade é definida como a propriedade de \n',...
    'genuinidade de uma emoção, podendo ser classificada \n',...
    'como genuína (autêntica) ou forçada (não autêntica).\n\n',...
    'Por favor, responda apenas no fim de cada som, \n',...
    'e efetue a resposta com base na sua primeira impressão.\n\n',...
    'Pressione a tecla SPACE para começar.'];

% get rating image & size
imX = 1920; imY = 1080; % image resolution 1920x1080
data.image.image_size = ...
    [(data.format.resolx - imX)/2, (data.format.resoly - imY)/2,...
    imX, imY];
clear imX imY; % cleanup unused variables

% user input - participant information
% get user input for usage or not of eyelink
prompt={'Introduza o ID do participante',...
    'dummymode = 1 | recolha = 0',...
    'Escolha a sequencia pretendida (1 - 4)'};
dlg_title='Input';
% default: no ID, eyetracker in dummy mode, sequence 1, pupilometry
data.input = inputdlg(prompt,dlg_title,1,{'...','1','1'});
% get time of experiment
clock_var = clock; clock_var = [num2str(clock_var(4)),'_',...
    num2str(clock_var(5)),'_',num2str(round(clock_var(6)))];
% name for log file
ppid = [data.input{1},'_',date,'_',clock_var];

% select sequence to use
if str2double(data.input{3}) == 1
    load('sequences\sequence1.mat');
elseif str2double(data.input{3}) == 2
    load('sequences\sequence2.mat');
elseif str2double(data.input{3}) == 3
    load('sequences\sequence3.mat');
elseif str2double(data.input{3}) == 4
    load('sequences\sequence4.mat');
else
    error('Selected sequence does not exist');
end

% save information from chosen sequence in the 'data' structure
data.sequences.trialOrder = trialOrder; 
data.sequences.jitt_def1 = jitter_def;
data.sounds.files = sound_name;

% get subject id folder to store result files
if ~isdir(['RESULTS_AUT\',data.input{1}])
    mkdir(['RESULTS_AUT\',data.input{1}]);
end

% log file creation + open file
logFile = strcat(['RESULTS_AUT\',data.input{1},'\',ppid,'.results']);
logfid = fopen(logFile,'a');

% subject identification
fprintf(logfid,'%s%s\t\t%s%s\t\t%s%s\t\t%s%s',...
    'ID: ',data.input{1},...
    'Date: ',date,...
    'Time: ', [num2str(clock_var(5)),'h ',num2str(round(clock_var(6))),'m'],...
    'Sequence: ',data.input{3});
% table header
fprintf(logfid,'\n\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
    'Trial #','Trial start (s)','Sound Name','Sound file duration (s)',...
    'Sound start (s)','Sound end (s)',...
    'Scale presentation - aut (s)',...
    'Autenticidade - Response','Res (s)','ResTime (s)');

% cleanup unused variables
clear prompt dlg_title num_lines ppid scriptName ii


% Initialise EEG
config_io
outp(888,0);
LPT_interval = 0.01; % edited - 10 ms
WaitSecs(LPT_interval);

% Initialise Eyelink
dummymode = str2double(data.input(2)); % set to 1 to initialise in dummymode
data.leadout_duration = 5;


Screen('Preference','SkipSyncTests', 1);
[w,~] = Screen('OpenWindow',screenNumber,data.format.background_color);
% HideCursor(w);
PsychTweak('UseGPUIndex', 1);
Screen('TextSize',w,data.format.fontSize);
Screen('TextFont',w,data.format.font);
Screen('TextStyle', w, 1);