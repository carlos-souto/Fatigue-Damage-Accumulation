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
% 'Bins': number of bins in each dimension in the rainflow histogram (0 means  %
%         automatic and is the default value):                                 %
%         * if scalar, X and Y will have the same number of bins               %
%         * if 1x2 vector, the first value is the number of bins in X, and the %
%           second value is the number of bins in Y                            %
% 'Colors': the number of colors in the colormap (default is 10)               %
% 'Plot': plots the fatigue analysis results, true (default) or false          %
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
        NameValueArgs.Bins (1, 2) double = 0
        NameValueArgs.Colors (1, 1) double = 10
        NameValueArgs.Plot (1, 1) logical = true
    end
    
    gammaFf = NameValueArgs.ConstantAmplitudeFactor;
    gammaMf = NameValueArgs.FatigueStrengthFactor;
    reps = NameValueArgs.Repetitions;
    
    [counts, ex, ey] = raincount(history); % rainflow counting
    
    Ni = fatcurve(counts(:, 2)*gammaFf, detail/gammaMf, ...
        'StressType', NameValueArgs.StressType, ...
        'FirstSlope', NameValueArgs.FirstSlope, ...
        'SecondSlope', NameValueArgs.SecondSlope, ...
        'ShearSlope', NameValueArgs.ShearSlope);
    
    ni = counts(:, 1)*reps;
    
    damage = sum(ni ./ Ni); % Palmgren-Miner linear damage rule
    
    % ----- %
    % PLOTS %
    % ----- %
    
    if NameValueArgs.Plot
        figure();
        
        % (A) Stress-Time History
        subplot(3, 2, 1); hold on; grid on;
        title_('(A) Stress-Time History', ['Number of Repetitions: ', num2str(reps)]);
        xlabel('Sample [Index]');
        ylabel('Stress Range [MPa]');
        plot(history, 'r');
        
        % (B) Reversals
        subplot(3, 2, 3); hold on; grid on;
        title_('(B) Reversals', ['Number of Repetitions: ', num2str(reps)]);
        xlabel('Sample [Index]');
        ylabel('Stress Range [MPa]');
        plot(ex, ey, '-b');
        
        % (C) Rainflow Histogram
        subplot(3, 2, [2, 4]); hold on; grid on; view(3);
        title('(C) Rainflow Histogram');
        xlabel('Stress Range [MPa]');
        ylabel('Mean Stress [MPa]');
        zlabel('Counts [Cycles]');
        if NameValueArgs.Bins == 0
            h = histogram2(counts(:, 2), counts(:, 3), 'FaceColor', 'flat');
        else
            h = histogram2(counts(:, 2), counts(:, 3), NameValueArgs.Bins, 'FaceColor', 'flat');
        end
        c = colorbar('Ticks', linspace(0, max(max(h.Values)), NameValueArgs.Colors + 1));
        c.Label.String = 'Cycles';
        colormap(jet(NameValueArgs.Colors));
        
        % (D) S-N Fatigue Strength Curve
        subplot(3, 2, 5); hold on; grid minor; legend show;
        set(gca, 'XScale', 'log', 'YScale', 'log');
        switch lower(NameValueArgs.StressType)
            case 'direct'
                st = ['Direct Stress, Cat. ' num2str(detail) ', m_1=' num2str(NameValueArgs.FirstSlope) ', m_2=' num2str(NameValueArgs.SecondSlope)];
            case 'shear'
                st = ['Shear Stress, Cat. ' num2str(detail) ', m=' num2str(NameValueArgs.ShearSlope)];
            otherwise
                error('fatdamage:unexpectedStressType', 'Unexpected stress type.');
        end
        title_('(D) S-N Fatigue Strength Curve', st);
        xlabel('Endurance [Cycles]');
        ylabel('Stress Range [MPa]');
        xlim([1e4, 1e9]);
        ylim([1e1, 1e3]);
        plot([1, 1]*2e6, [1e1, 1e3], '--k', 'HandleVisibility', 'off');
        plot([1, 1]*5e6, [1e1, 1e3], '--k', 'HandleVisibility', 'off');
        plot([1, 1]*1e8, [1e1, 1e3], '--k', 'HandleVisibility', 'off');
        plot_s = linspace(1e1, 1e3, 5e3);
        plot_n = fatcurve(plot_s, detail, ...
            'StressType', NameValueArgs.StressType, ...
            'FirstSlope', NameValueArgs.FirstSlope, ...
            'SecondSlope', NameValueArgs.SecondSlope, ...
            'ShearSlope', NameValueArgs.ShearSlope);
        plot_n(plot_n == +Inf) = 1e12; % force plot horizontal line
        scatter_s = ey;
        scatter_n = fatcurve(scatter_s, detail, ...
            'StressType', NameValueArgs.StressType, ...
            'FirstSlope', NameValueArgs.FirstSlope, ...
            'SecondSlope', NameValueArgs.SecondSlope, ...
            'ShearSlope', NameValueArgs.ShearSlope);
        plot(plot_n, plot_s, 'Color', [0 .5 0], 'DisplayName', 'Design S-N Curve');
        scatter(scatter_n, scatter_s, '.', 'MarkerEdgeColor', [0 .5 0], 'DisplayName', 'Reversals');
        
        % (E) Palmgren-Miner Rule
        subplot(3, 2, 6); hold on; grid on; legend show;
        title_('(E) Palmgren-Miner Rule', ['Const. Amp. Factor: ' num2str(NameValueArgs.ConstantAmplitudeFactor) ', Fatigue Strength Factor: ' num2str(NameValueArgs.FatigueStrengthFactor)]);
        ylim([0, 2]);
        yticklabels([]);
        xlabel('Linear Damage Accumulation');
        if damage < 1.0
            color = 'g';
        else
            color = 'r';
        end
        barh(damage, color, 'DisplayName', sprintf('Damage = %.4e', damage));
        
    end
    
end

% ---------------------------------------------------------------------------- %
% Utility function to set the titles/subtitles                                 %
% ---------------------------------------------------------------------------- %

function title_(titletext, subtitletext)
    if verLessThan('MATLAB', '9.9')
        title([titletext ' (' subtitletext ')']);
    else
        title(titletext);
        subtitle(subtitletext);
    end
end
