%% =======================================================================
%  COMPUTING TASK LATENCIES (EXTENDED)
%  -----------------------------------------------------------------------
%  Includes:
%   - datetime() precision levels
%   - Screen('Flip') vs GetSecs()
%   - if vs switch vs no condition overhead
%  -----------------------------------------------------------------------

clear; clc; close all;
fprintf('\n--- COMPUTING FUNCTION LATENCIES (EXTENDED) ---\n\n');

nIter = 1000;

%% ----------------------------------------------------------
% 1. DATETIME() PRECISION LEVELS
% -----------------------------------------------------------
fprintf('Measuring datetime() precision levels...\n');

t_datetime_default = zeros(1,nIter);
t_datetime_sec = zeros(1,nIter);
t_datetime_micro = zeros(1,nIter);

for i = 1:nIter
    t1 = tic;
    datetime('now');
    t_datetime_default(i) = toc(t1);

    t1 = tic;
    datetime('now','Format','yyyy-MM-dd HH:mm:ss');
    t_datetime_sec(i) = toc(t1);

    t1 = tic;
    datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSSSSS');
    t_datetime_micro(i) = toc(t1);
end

%% ----------------------------------------------------------
% 2. GETSECS() TIMING PRECISION (baseline)
% -----------------------------------------------------------
fprintf('Measuring GetSecs() baseline...\n');
t_getsecs = zeros(1,nIter);
for i = 1:nIter
    t1 = tic;
    GetSecs;
    t_getsecs(i) = toc(t1);
end

%% ----------------------------------------------------------
% 3. SCREEN('Flip') TIMESTAMP VS GETSECS
% -----------------------------------------------------------
fprintf('Measuring Screen(''Flip'') timestamp vs GetSecs() difference...\n');

try
    Screen('Preference','SkipSyncTests',1);
    [win, rect] = Screen('OpenWindow',0,[128 128 128]);
    Screen('TextSize',win,24);

    diff_flip_vs_getsecs = zeros(1,100);
    for i = 1:100
        DrawFormattedText(win,'Flip test','center','center',[255 255 255]);
        vbl = Screen('Flip',win);
        after = GetSecs;
        diff_flip_vs_getsecs(i) = (after - vbl)*1000; % ms difference
    end
    Screen('CloseAll');
catch ME
    fprintf(2,'Screen test skipped: %s',ME.message);
    diff_flip_vs_getsecs = nan(1,100);
end

%% ----------------------------------------------------------
% 4. IF vs SWITCH vs DIRECT CODE EXECUTION
% -----------------------------------------------------------
fprintf('Measuring conditional overhead (if vs switch vs direct)...\n');

code_iterations = 1000;
samples_per_condition = 10000;
t_no_condition = zeros(1,code_iterations);
t_if_condition = zeros(1,code_iterations);
t_switch_condition = zeros(1,code_iterations);

for k = 1:code_iterations
    % --- no condition ---
    t1 = tic;
    a = 0;
    for i = 1:samples_per_condition
        a = a + sin(i); 
    end
    t_no_condition(k) = toc(t1);

    % --- IF condition ---
    t1 = tic;
    a = 0;
    for i = 1:samples_per_condition
        if mod(i,2)==0
            a = a + sin(i);
        else
            a = a + cos(i);
        end
    end
    t_if_condition(k) = toc(t1);

    % --- SWITCH condition ---
    t1 = tic;
    a = 0;
    for i = 1:samples_per_condition
        switch mod(i,2)
            case 0
                a = a + sin(i);
            otherwise
                a = a + cos(i);
        end
    end
    t_switch_condition(k) = toc(t1);
end

%% ----------------------------------------------------------
% 5. SUMMARY TABLE
% -----------------------------------------------------------
fprintf('\n--- MEAN EXECUTION TIMES (ms) ---\n');
fprintf('datetime(now) ......................... %.4f\n', mean(t_datetime_default)*1000);
fprintf('datetime(now,"Format","HH:mm:ss") ..... %.4f\n', mean(t_datetime_sec)*1000);
fprintf('datetime(now,"Format","HH:mm:ss.SSSSSS") %.4f\n', mean(t_datetime_micro)*1000);
fprintf('GetSecs() ............................. %.4f\n', mean(t_getsecs)*1000);

fprintf('\n--- Conditional execution cost (ms per 10000 ops) ---\n');
fprintf('Direct ................................ %.4f\n', mean(t_no_condition)*1000);
fprintf('If condition .......................... %.4f\n', mean(t_if_condition)*1000);
fprintf('Switch condition ...................... %.4f\n', mean(t_switch_condition)*1000);

fprintf('\n--- Screen Flip difference ---\n');
fprintf('Mean Screen(''Flip'') vs GetSecs delta: %.4f ms\n', mean(diff_flip_vs_getsecs));
fprintf('Std dev: %.4f ms\n', std(diff_flip_vs_getsecs));

%% ----------------------------------------------------------
% 6. PLOTS
% -----------------------------------------------------------
figure('Name','Timing Benchmarks (Extended)','Color','w','Position',[100 100 1200 500]);

subplot(1,3,1)
boxchart([t_datetime_default'*1000, t_datetime_sec'*1000, t_datetime_micro'*1000, t_getsecs'*1000]);
set(gca,'XTickLabel',{'datetime','datetime-sec','datetime-micro','GetSecs'});
ylabel('Execution time (ms)');
title('Datetime precision levels');

subplot(1,3,2)
bar([mean(t_no_condition), mean(t_if_condition), mean(t_switch_condition)]*1000);
set(gca,'XTickLabel',{'Direct','If','Switch'});
ylabel('Total time (ms per 10000 ops)');
title('Conditional overhead');

subplot(1,3,3)
histogram(diff_flip_vs_getsecs,15);
xlabel('Difference (ms)'); ylabel('Count');
title('Screen(''Flip'') vs GetSecs timing diff');

sgtitle('MATLAB vs PTB Extended Timing Benchmarks');

%% ----------------------------------------------------------
% 7. RELATIVE COST SUMMARY
% -----------------------------------------------------------
fprintf('\n--- RELATIVE COSTS (GetSecs=100%% baseline) ---\n');
baseline = mean(t_getsecs);
costs = [mean(t_datetime_default), mean(t_datetime_sec), mean(t_datetime_micro)] / baseline * 100;
names = {'datetime','datetime (sec)','datetime (micro)'};
for i = 1:length(names)
    fprintf('%-25s : %8.1f %% of GetSecs cost\n', names{i}, costs(i));
end

fprintf('\n--- Conditional Overhead (relative to direct) ---\n');
fprintf('If condition ........................... %.2fx slower\n', mean(t_if_condition)/mean(t_no_condition));
fprintf('Switch condition ....................... %.2fx slower\n', mean(t_switch_condition)/mean(t_no_condition));

fprintf('\nDone.\n');

% Parallel port

%% ================================================================
%  PARALLEL PORT LATENCY TEST
%  ----------------------------------------------------------------
%  Purpose: Measure timing consistency of parallel_port() calls
%           under 1000 iterations.
%  Outputs:
%    - Mean / SD latency
%    - Histogram of distribution
%    - Jitter plot (time series)
%  ----------------------------------------------------------------
%  Author: (you)
%  Date:   (today)
% ================================================================

clear; close all; clc;

fprintf('\n=== Parallel Port Latency Test ===\n');

% ------------------------------------------------------------
% Parameters
% ------------------------------------------------------------
N = 1000;             % number of iterations
parallel = true;      % toggle additional call (double send)
pause_between = 0.01; % seconds between triggers (optional)

lat_single = zeros(N,1);
lat_double = zeros(N,1);

fprintf('Running %d iterations...\n', N);

% ------------------------------------------------------------
% Main loop
% ------------------------------------------------------------
for i = 1:N
    t1 = tic;
    parallel_port(2);   % send single trigger
    lat_single(i) = toc(t1);

    if parallel
        t2 = tic;
        parallel_port(2);  % send second trigger
        lat_double(i) = toc(t2);
    end

    WaitSecs(pause_between);
end

fprintf('Done.\n\n');

% ------------------------------------------------------------
% Compute Statistics
% ------------------------------------------------------------
valid_single = lat_single(lat_single > 0);
valid_double = lat_double(lat_double > 0);

mean_single = mean(valid_single);
std_single  = std(valid_single);
min_single  = min(valid_single);
max_single  = max(valid_single);

fprintf('--- Single Trigger ---\n');
fprintf('Mean = %.6f s\nSD = %.6f s\nMin = %.6f s\nMax = %.6f s\n\n',...
    mean_single, std_single, min_single, max_single);

if parallel
    mean_double = mean(valid_double);
    std_double  = std(valid_double);
    fprintf('--- Double Trigger ---\n');
    fprintf('Mean = %.6f s\nSD = %.6f s\n', mean_double, std_double);
end

% ------------------------------------------------------------
% Save Results
% ------------------------------------------------------------
results.lat_single = lat_single;
results.lat_double = lat_double;
results.time = datetime('now');
save('parallel_latency_results.mat','results');

% ------------------------------------------------------------
% Plot results
% ------------------------------------------------------------
figure('Name','Parallel Port Latency','Color','w','Position',[300 200 1200 500]);

subplot(1,2,1);
histogram(lat_single*1000,30,'FaceColor',[0.2 0.5 0.8],'EdgeColor','none');
title('Single Trigger Latency');
xlabel('Latency (ms)');
ylabel('Frequency');
grid on;

subplot(1,2,2);
plot(lat_single*1000,'-','Color',[0.1 0.4 0.7]);
title('Latency Over Iterations');
xlabel('Iteration');
ylabel('Latency (ms)');
grid on;

if parallel
    hold on;
    plot(lat_double*1000,'--r');
    legend('Single','Double');
end

sgtitle('Parallel Port Timing Consistency Benchmark');

% ------------------------------------------------------------
% Summary report
% ------------------------------------------------------------
fprintf('\nSummary:\n');
fprintf('Average single trigger latency: %.3f ms ± %.3f ms (jitter)\n',...
    mean_single*1000,std_single*1000);
if parallel
    fprintf('Average double trigger latency: %.3f ms ± %.3f ms (jitter)\n',...
        mean_double*1000,std_double*1000);
end

fprintf('\nResults saved to: parallel_latency_results.mat\n');

%% =======================================================================
%  COMPARE LATENCY: Direct vs. IF Condition
%  -----------------------------------------------------------------------
%  Goal: Check if adding an 'if' statement changes trigger latency.
%  -----------------------------------------------------------------------

clear; close all; clc;

fprintf('\n=== Parallel Port Latency: IF vs Direct ===\n');

% ------------------------------------------------------------
% Parameters
% ------------------------------------------------------------
N = 1000;           % number of iterations
parallel = true;    % the boolean used in the if condition
pause_between = 0.01; % pause between trials (s)

lat_direct = zeros(N,1);
lat_ifcond = zeros(N,1);

fprintf('Running %d iterations per condition...\n', N);

% ------------------------------------------------------------
% Case A: Direct call
% ------------------------------------------------------------
for i = 1:N
    t1 = tic;
    parallel_port(2);
    lat_direct(i) = toc(t1);
    WaitSecs(pause_between);
end

% ------------------------------------------------------------
% Case B: Inside IF statement
% ------------------------------------------------------------
for i = 1:N
    if parallel
        t2 = tic;
        parallel_port(2);
        lat_ifcond(i) = toc(t2);
    end
    WaitSecs(pause_between);
end

fprintf('Done.\n\n');

% ------------------------------------------------------------
% Compute statistics
% ------------------------------------------------------------
mean_direct = mean(lat_direct);
std_direct  = std(lat_direct);
mean_ifcond = mean(lat_ifcond);
std_ifcond  = std(lat_ifcond);

diffs = lat_ifcond - lat_direct;

fprintf('--- Direct ---\n');
fprintf('Mean = %.6f s | SD = %.6f s\n', mean_direct, std_direct);
fprintf('--- If condition ---\n');
fprintf('Mean = %.6f s | SD = %.6f s\n', mean_ifcond, std_ifcond);
fprintf('--- Difference ---\n');
fprintf('Mean Δ = %.6f s (%.3f µs) | SD Δ = %.6f s\n',...
    mean(diffs), mean(diffs)*1e6, std(diffs));

% ------------------------------------------------------------
% Save results
% ------------------------------------------------------------
results.lat_direct = lat_direct;
results.lat_ifcond = lat_ifcond;
results.diff = diffs;
results.time = datetime('now');
save('parallel_if_comparison.mat','results');

% ------------------------------------------------------------
% Plot results
% ------------------------------------------------------------
figure('Name','IF Condition Latency Comparison','Color','w','Position',[300 200 1200 500]);

subplot(1,3,1)
histogram(lat_direct*1000,30,'FaceColor',[0.3 0.6 0.8],'EdgeColor','none');
title('Direct call latency');
xlabel('Latency (ms)');
ylabel('Count');
grid on;

subplot(1,3,2)
histogram(lat_ifcond*1000,30,'FaceColor',[0.8 0.4 0.4],'EdgeColor','none');
title('IF condition latency');
xlabel('Latency (ms)');
ylabel('Count');
grid on;

subplot(1,3,3)
histogram(diffs*1e6,30,'FaceColor',[0.4 0.7 0.4],'EdgeColor','none');
title('Difference (IF - Direct)');
xlabel('Δ Latency (µs)');
ylabel('Count');
grid on;

sgtitle('Parallel Port Timing: Direct vs IF Condition');

% ------------------------------------------------------------
% Display summary
% ------------------------------------------------------------
fprintf('\nSummary:\n');
fprintf('Direct mean latency: %.3f ms ± %.3f ms\n', mean_direct*1000, std_direct*1000);
fprintf('If-condition mean latency: %.3f ms ± %.3f ms\n', mean_ifcond*1000, std_ifcond*1000);
fprintf('Average difference: %.3f µs\n', mean(diffs)*1e6);
fprintf('Results saved to: parallel_if_comparison.mat\n');


