% ---------------------------------------------------------------------------- %
% Description:                                                                 %
% For a given stress range (or stress range vector) returns the fatigue        %
% endurance (or fatigue endurance vector) – computation based on EN 1993-1-9   %
% ---------------------------------------------------------------------------- %
% Input:                                                                       %
% s: the stress range (or stress range vector)                                 %
% c: the detail category (see EN 1993-1-9)                                     %
% ---------------------------------------------------------------------------- %
% Optional Name-Value Input Arguments:                                         %
% 'StressType': the stress type, 'direct' (default) or 'shear'                 %
% 'FirstSlope': the first slope of the direct S-N curve (by default, m1 = 3)   %
% 'SecondSlope': the second slope of the direct S-N curve (by default, m2 = 5) %
% 'ShearSlope': the slope of the shear S-N curve (by default, m = 5)           %
% ---------------------------------------------------------------------------- %
% Output:                                                                      %
% 'n' is the fatigue endurance (or fatigue endurance vector)                   %
% ---------------------------------------------------------------------------- %
% Copyright (c) 2021, Carlos Daniel Santos Souto.                              %
% All rights reserved.                                                         %
% License: BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)         %
% Contact: csouto@fe.up.pt                                                     %
% ---------------------------------------------------------------------------- %

function n = fatcurve(s, c, NameValueArgs)
    
    arguments
        s (:, 1) double
        c (1, 1) double
        NameValueArgs.StressType (1, :) char = 'direct'
        NameValueArgs.FirstSlope (1, 1) double = 3
        NameValueArgs.SecondSlope (1, 1) double = 5
        NameValueArgs.ShearSlope (1, 1) double = 5
    end
    
    m1 = NameValueArgs.FirstSlope;
    m2 = NameValueArgs.SecondSlope;
    ms = NameValueArgs.ShearSlope;
    n = zeros(size(s));
    
    switch lower(NameValueArgs.StressType)
        case 'direct'
            d = (2/5)^(1/m1) * c;   % 'd' is the fatigue limit
           %l = (5/100)^(1/m2) * d; % 'l' is the cut-off limit (not used)
           for i = 1:1:length(n)
                n1 = c^m1 * 2e6 / s(i)^m1; % assume N <= 5e6
                n2 = d^m2 * 5e6 / s(i)^m2; % assume 5e6 < N <= 1e8
                n3 = +Inf;                 % assume N > 1e8
                if n1 <= 5e6
                    n(i) = n1;
                elseif n2 <= 1e8
                    n(i) = n2;
                else
                    n(i) = n3;
                end
            end
        case 'shear'
            for i = 1:1:length(n)
                n1 = c^ms * 2e6 / s(i)^ms; % assume N <= 1e8
                n2 = +Inf;                 % assume N > 1e8
                if n1 <= 1e8
                    n(i) = n1;
                else
                    n(i) = n2;
                end
            end
        otherwise
            error('fatcurve:unexpectedStressType', 'Unexpected stress type.');
    end
    
end
