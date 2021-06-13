% ---------------------------------------------------------------------------- %
% Description:                                                                 %
% Gets the local extrema (maxima and minima) of the provided stress-time       %
% history as a sequence of peaks and valleys (bad in-between data points –     %
% that are neither peaks nor valleys – are removed)                            %
% ---------------------------------------------------------------------------- %
% Input:                                                                       %
% history: the provided stress-time history vector                             %
% ---------------------------------------------------------------------------- %
% Output:                                                                      %
% ex: abscissas of the obtained sequence of peaks and valleys (local extrema)  %
% ey: ordinates of the obtained sequence of peaks and valleys (local extrema)  %
% ---------------------------------------------------------------------------- %
% Copyright (c) 2021, Carlos Daniel Santos Souto.                              %
% All rights reserved.                                                         %
% License: BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)         %
% Contact: csouto@fe.up.pt                                                     %
% ---------------------------------------------------------------------------- %

function [ex, ey] = extrema(history)
    
    arguments
        history (:, 1) double
    end
    
    ex = zeros(size(history));
    ey = zeros(size(history));
    
    eidx = 1;
    ex(1) = 1; ey(1) = history(1);
    for hidx = 2:1:(length(history) - 1)
        peak   = history(hidx) > ey(eidx) && history(hidx) > history(hidx + 1);
        valley = history(hidx) < ey(eidx) && history(hidx) < history(hidx + 1);
        if peak || valley
            eidx = eidx + 1;
            ex(eidx) = hidx; ey(eidx) = history(hidx);
        end
    end
    eidx = eidx + 1;
    ex(eidx) = length(history); ey(eidx) = history(end);
    
    ex = ex(1:eidx);
    ey = ey(1:eidx);
    
end
