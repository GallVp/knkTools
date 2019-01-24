function [ipLine, iiLine] = plotInvalidForceMarkers( figHandle, invalidForceInfo, isAdjusted, markers, markerSize )
%plotInvalidForceMarkers Plots points and intervals of invalid force on the
%   provided figure.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% set Deafault parameters
if nargin < 3
    isAdjusted = 0;
    markers = {'k+', 'k-'};
    markerSize = 8;
elseif nargin < 4
    markers = {'k+', 'k-'};
    markerSize = 8;
elseif nargin < 5
    markerSize = 8;
end
%% Set given figure as current and hold on
set(0, 'CurrentFigure', figHandle)
hold on;
if ~isAdjusted
    invalidPoints       = invalidForceInfo.invalidForcePoints;
    invalidIntervals    = invalidForceInfo.invalidForceIntervals;
    markerYValue        = invalidForceInfo.forceThreshLevel;
    
    % Draw the invalid time points and intervals.
    if(~isempty(invalidPoints))
        ipLine = plot(invalidPoints, markerYValue .* 3 .* ones(size(invalidPoints)), markers{1}, 'MarkerSize', markerSize);
    else
        ipLine = matlab.graphics.chart.primitive.Line.empty;
    end
    if(~isempty(invalidIntervals))
        for i=1:size(invalidIntervals, 1)
            p = plot(invalidIntervals(i, :), [markerYValue markerYValue] .* 8,  markers{2}, 'MarkerSize', markerSize, 'LineWidth', 1.5);
            if(i == size(invalidIntervals, 1))
                iiLine = p;
            end
        end
    else
        iiLine = matlab.graphics.chart.primitive.Line.empty;
    end
else
    invalidIntervals    = invalidForceInfo.adjustedIntervals;
    ipInterval          = invalidForceInfo.ipInterval;
    markerYValue        = invalidForceInfo.forceThreshLevel;
    
    if(~isempty(ipInterval))
        for i=1:size(ipInterval, 1)
            p = plot(ipInterval(i, :), [markerYValue markerYValue] .* 8,  markers{2}, 'MarkerSize', markerSize, 'LineWidth', 1.5);
            if(i == size(ipInterval, 1))
                ipLine = p;
            end
        end
    else
        ipLine = matlab.graphics.chart.primitive.Line.empty;
    end
    
    if(~isempty(invalidIntervals))
        for i=1:size(invalidIntervals, 1)
            p = plot(invalidIntervals(i, :), [markerYValue markerYValue] .* 8,  markers{2}, 'MarkerSize', markerSize, 'LineWidth', 1.5);
            if(i == size(invalidIntervals, 1))
                iiLine = p;
            end
        end
    else
        iiLine = matlab.graphics.chart.primitive.Line.empty;
    end
end
end

