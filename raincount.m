% ---------------------------------------------------------------------------- %
% Description:                                                                 %
% Rainflow cycle counting algorithm according to ASTM E1049-85                 %
% ---------------------------------------------------------------------------- %
% Input:                                                                       %
% history: the provided stress-time history vector                             %
% ---------------------------------------------------------------------------- %
% Output:                                                                      %
% counts: the cycle counts returned as a matrix:                               %
%         column 1 are the counts                                              %
%         column 2 are the ranges                                              %
%         column 3 are the mean values                                         %
% ---------------------------------------------------------------------------- %
% Copyright (c) 2021, Carlos Daniel Santos Souto.                              %
% All rights reserved.                                                         %
% License: BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)         %
% Contact: csouto@fe.up.pt                                                     %
% ---------------------------------------------------------------------------- %

function counts = raincount(history)
    
    arguments
        history (:, 1) double
    end
    
    extrema = getextrema(history);
    
    counts = zeros(length(extrema), 3);
    points = zeros(length(extrema), 1);
    pidx = 0; eidx = 0; cidx = 0;
    
    for i = 1:1:length(extrema)
        pidx = pidx + 1;
        eidx = eidx + 1;
        points(pidx) = eidx;
        while pidx >= 3
            xrange = abs(extrema(points(pidx - 1)) - extrema(points(pidx - 0)));
            yrange = abs(extrema(points(pidx - 2)) - extrema(points(pidx - 1)));
            if xrange >= yrange
                ymean = 0.5 * (extrema(points(pidx - 2)) + extrema(points(pidx - 1)));
                cidx = cidx + 1;
                if pidx == 3
                    counts(cidx, :) = [0.5, yrange, ymean];
                    points(1) = points(2);
                    points(2) = points(3);
                    pidx = 2;     
                else
                    counts(cidx, :) = [1.0, yrange, ymean];
                    points(pidx - 2) = points(pidx);
                    pidx = pidx - 2;
                end
            else
                break
            end
        end
    end
    
    for i = 1:1:(pidx - 1)
        range = abs(extrema(points(i)) - extrema(points(i + 1)));
        mean = 0.5 * (extrema(points(i)) + extrema(points(i + 1)));
        cidx = cidx + 1;
        counts(cidx, :) = [0.5, range, mean];
    end
    
    counts = counts(1:cidx, :);
    
end
