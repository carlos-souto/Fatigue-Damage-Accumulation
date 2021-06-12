% ---------------------------------------------------------------------------- %
% Description:                                                                 %
% Executes a fatigue analysis using a linear damage accumulation method        %
% (Palmgren-Miner rule). Design S-N curves are specified based on EN 1993-1-9  %
% parameters. Cycle counts are done using a rainflow counting algorithm based  %
% on ASTM E1049-85.                                                            %
% ---------------------------------------------------------------------------- %
% Input:                                                                       %
% history: the provided stress-time history vector                             %
% detail: the detail category (see EN 1993-1-9)                                %
% ---------------------------------------------------------------------------- %
% Optional Name-Value Input Arguments:                                         %
% 'StressType': the stress type, 'direct' (default) or 'shear'                 %
% 'FirstSlope': the first slope of the direct S-N curve (by default, m1 = 3)   %
% 'SecondSlope': the second slope of the direct S-N curve (by default, m2 = 5) %
% 'ShearSlope': the slope of the shear S-N curve (by default, m = 5)           %
% 'ConstantAmplitudeFactor': the partial safety factor for equivalent constant %
%                            amplitude stress ranges (1 is the default value)  %
% 'FatigueStrengthFactor': the partial safety factor for fatigue strength (1   %
%                          is the default value)                               %
% 'Repetitions': the number of times the stress-time history sample is         %
%                repeated (1 is the default value)                             %
% 'NumberOfBins': number of bins in each dimension in the rainflow histogram   %
%                 (10 is the default value):                                   %
%                 * if scalar, X and Y will have the same number of bins       %
%                 * if 1x2 vector, the first value is the number of bins in X, %
%                   analogous for Y                                            %
% 'NumberOfColors': the number of colors in the colormap (default is 10)       %
% ---------------------------------------------------------------------------- %
% Output:                                                                      %
% damage: the linearly accumulated fatigue damage (if damage >= 1, failure     %
%         occurs)                                                              %
% ---------------------------------------------------------------------------- %
% Copyright (c) 2021, Carlos Daniel Santos Souto.                              %
% All rights reserved.                                                         %
% License: BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)         %
% Contact: csouto@fe.up.pt                                                     %
% ---------------------------------------------------------------------------- %

function damage = fatdamage(history, detail, NameValueArgs)
    
    arguments
        history (:, 1) double
        detail (1, 1) double
        NameValueArgs.StressType (1, :) char = 'direct'
        NameValueArgs.FirstSlope (1, 1) double = 3
        NameValueArgs.SecondSlope (1, 1) double = 5
        NameValueArgs.ShearSlope (1, 1) double = 5
        NameValueArgs.ConstantAmplitudeFactor (1, 1) double = 1
        NameValueArgs.FatigueStrengthFactor (1, 1) double = 1
        NameValueArgs.Repetitions (1, 1) double = 1
        NameValueArgs.NumberOfBins (1, 2) uint32 = 10
        NameValueArgs.NumberOfColors (1, 1) uint32 = 10
    end
    
    gammaFf = NameValueArgs.ConstantAmplitudeFactor;
    gammaMf = NameValueArgs.FatigueStrengthFactor;
    reps = NameValueArgs.Repetitions;
    
    [counts, extrema] = raincount(history); % rainflow counting
    
    Ni = fatcurve(counts(:, 2) * gammaFf, detail / gammaMf,...
        'StressType', NameValueArgs.StressType,...
        'FirstSlope', NameValueArgs.FirstSlope,...
        'SecondSlope', NameValueArgs.SecondSlope,...
        'ShearSlope', NameValueArgs.ShearSlope);
    
    ni = counts(:, 1) * reps;
    
    damage = sum(ni ./ Ni); % Palmgren-Miner linear damage rule
    
    % ----- %
    % PLOTS %
    % ----- %
    figure();
    
    % Stress-Time History
    subplot(3, 2, 1); hold on; grid on;
    title('(A) Stress-Time History');
    subtitle(sprintf('Number of Repetitions: %.1f', NameValueArgs.Repetitions));
    xlabel('Samples [Index]');
    ylabel('Stress Range [MPa]');
    plot(history, '-k');
    
    % Reversals
    subplot(3, 2, 3); hold on; grid on;
    title('(B) Reversals');
    subtitle(sprintf('Number of Repetitions: %.1f', NameValueArgs.Repetitions));
    xlabel('Samples [Index]');
    ylabel('Stress Range [MPa]');
    plot(extrema, '-b');
    
    % Rainflow Histogram
    subplot(3, 2, [2, 4]); hold on; grid on;
    view(3);
    title('(C) Rainflow Histogram');
    xlabel('Stress Range [MPa]');
    ylabel('Mean Stress [MPa]');
    zlabel('Counts [Cycles]');
    h = histogram2(counts(:, 2), counts(:, 3), NameValueArgs.NumberOfBins, 'FaceColor', 'flat');
    c = colorbar('Ticks', linspace(0, max(max(h.Values)), NameValueArgs.NumberOfColors + 1));
    c.Label.String = 'Cycles';
    colormap(turbo(NameValueArgs.NumberOfColors));
    
    % S-N Fatigue Strength Curve
    subplot(3, 2, 5); hold on; grid on; legend show;
    set(gca, 'XScale', 'log', 'YScale', 'log');
    switch lower(NameValueArgs.StressType)
        case 'direct'
            st = sprintf('Direct Stress, Cat. %.1f MPa, m1=%.1f, m2=%.1f', detail, NameValueArgs.FirstSlope, NameValueArgs.SecondSlope);
        case 'shear'
            st = sprintf('Shear Stress, Cat. %.1f MPa, m=%.1f', detail, NameValueArgs.ShearSlope);
        otherwise
            error('fatdamage:unexpectedStressType', 'Unexpected stress type.');
    end
    title('(D) S-N Fatigue Strength Curve');
    subtitle(st);
    xlabel('Endurance [Cycles]');
    ylabel('Stress Range [MPa]');
    xlim([1e4, 1e9]);
    ylim([1e1, 1e3]);
    plot([1, 1]*2e6, [1e1, 1e3], 'Color', [1, 1, 1]*0.5, 'HandleVisibility', 'off');
    plot([1, 1]*5e6, [1e1, 1e3], 'Color', [1, 1, 1]*0.5, 'HandleVisibility', 'off');
    plot([1, 1]*1e8, [1e1, 1e3], 'Color', [1, 1, 1]*0.5, 'HandleVisibility', 'off');
    plot_s = linspace(1e1, 1e3, 5e3);
    plot_n = fatcurve(plot_s, detail,...
        'StressType', NameValueArgs.StressType,...
        'FirstSlope', NameValueArgs.FirstSlope,...
        'SecondSlope', NameValueArgs.SecondSlope,...
        'ShearSlope', NameValueArgs.ShearSlope);
    plot_n(plot_n == +Inf) = 1e12;
    scatter_s = extrema;
    scatter_n = fatcurve(scatter_s, detail,...
        'StressType', NameValueArgs.StressType,...
        'FirstSlope', NameValueArgs.FirstSlope,...
        'SecondSlope', NameValueArgs.SecondSlope,...
        'ShearSlope', NameValueArgs.ShearSlope);
    plot(plot_n, plot_s, '-r', 'DisplayName', 'Design S-N Curve');
    scatter(scatter_n, scatter_s, '.r', 'DisplayName', 'Reversals');
    
    % Damage Bar
    subplot(3, 2, 6); hold on; grid on; legend show;
    title('(E) Palmgren-Miner Rule');
    subtitle(sprintf('Const. Amp. Factor: %.2f, Fatigue Strength Factor: %.2f', NameValueArgs.ConstantAmplitudeFactor, NameValueArgs.FatigueStrengthFactor));
    ylim([0, 2]);
    yticklabels([]);
    xlabel('Linear Damage Accumulation');
    if damage < 1.0
        color = 'g';
    else
        color = 'r';
    end
    barh(damage, color, 'DisplayName', sprintf('Damage = %.3e', damage));
    
end
