% reset workspace
clear all; close all; clc;

% add to path: parent_directoy\source
addpath([pwd, '\..\source\']);

% number of tests per run
n = 50;

% history size for each run
history_size = 100:1000:100000;

% plot variables
y_matlab = zeros(length(history_size), 1);
y_custom = zeros(length(history_size), 1);

% run loop
for k = 1:1:length(history_size)
    
    fprintf('Run %i of %i (data array size = %i)...\n', k, length(history_size), history_size(k));
    
    % timers
    matlab_elapsed = 0;
    custom_elapsed = 0;
    
    % test loop
    for i = 1:1:n
        
        % generate random stress-time history
        history = rand(history_size(k), 1)';
        
        % get expected
        tic;
        counts_matab = rainflow(history);
        matlab_elapsed = matlab_elapsed + toc;
        
        % test
        tic;
        counts_custom = raincount(history);
        custom_elapsed = custom_elapsed + toc;
        
        % check results
        if ~isequal(counts_matab(:, 1:3), counts_custom)
            error('Test %i of run %i failed.\n', i, k);
        else
            %fprintf('Test %i of run %i passed.\n', i, k);
        end
        
    end
    
    y_matlab(k) = 1000*matlab_elapsed/n;
    y_custom(k) = 1000*custom_elapsed/n;
    
end

figure(1); hold on; grid on; legend show;
set(gca, 'FontSize', 14);
legend('Location', 'nw');
xlabel('Stress-time history array size');
ylabel('Averaged elapsed time [ms]');
title(sprintf('Averaged elapsed time (%i runs) vs. data size', n));
plot(history_size, y_matlab, '-b', 'LineWidth', 2, 'DisplayName', 'MATLAB’s implementation');
plot(history_size, y_custom, '-r', 'LineWidth', 2, 'DisplayName', 'Custom code');
