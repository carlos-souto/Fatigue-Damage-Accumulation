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
% ex: abscissas of the obtained sequence of peaks and valleys (local extrema)  %
% ey: ordinates of the obtained sequence of peaks and valleys (local extrema)  %
% ---------------------------------------------------------------------------- %
% Copyright (c) 2021, Carlos Daniel Santos Souto.                              %
% All rights reserved.                                                         %
% License: BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)         %
% Contact: csouto@fe.up.pt                                                     %
% ---------------------------------------------------------------------------- %

function [counts, ex, ey] = raincount(history)
    
    arguments
        history (:, 1) double
    end
    
    [ex, ey] = extrema(history);
    
    counts = zeros(length(ey), 3);
    points = zeros(length(ey), 1);
    cidx = 0; pidx = 0;
    
    for eidx = 1:1:length(ey)
        pidx = pidx + 1;
        points(pidx) = eidx;
        while pidx >= 3
            xrange = abs(ey(points(pidx - 1)) - ey(points(pidx - 0)));
            yrange = abs(ey(points(pidx - 2)) - ey(points(pidx - 1)));
            if xrange >= yrange
                ymean = 0.5 * (ey(points(pidx - 2)) + ey(points(pidx - 1)));
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
    
    for c = 1:1:(pidx - 1)
        range = abs(ey(points(c)) - ey(points(c + 1)));
        mean = 0.5 * (ey(points(c)) + ey(points(c + 1)));
        cidx = cidx + 1;
        counts(cidx, :) = [0.5, range, mean];
    end
    
    counts = counts(1:cidx, :);
    
end
