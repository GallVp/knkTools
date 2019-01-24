function [X, Y] = ginputWithPlot(axH, numMarkers, markerNames)
%ginputWithPlot Same as MATLAB's ginput along with printing the markers and
%   names along the way.
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 3
    markerNames = {};
end

axisInfo = axis(axH);
textY = axisInfo(4) - (axisInfo(4) - axisInfo(3)) / 10;
textX = axisInfo(1) + (axisInfo(2) - axisInfo(1)) / 10;

if(~isempty(markerNames))
    markerNames = strsplit(markerNames, ';');
    T = text(axH, textX, textY, sprintf('Mark: %s', markerNames{1}), 'FontSize', 12, 'Color','red');
end


X = zeros(numMarkers, 1);
Y = zeros(numMarkers, 1);
for i=1:numMarkers
    if(~isempty(markerNames))
        set(T, 'String', sprintf('Mark: %s', markerNames{i}));
    end
    [x, y] = ginput(1);
    plot(axH, x, y, 'r.', 'LineWidth', 2, 'MarkerSize', 15);
    if(~isempty(markerNames))
        text(axH, x, y, sprintf(' --> %s', markerNames{i}), 'FontSize', 12);
    end
    X(i) = x;
    Y(i) = y;
end
if(~isempty(markerNames))
    delete(T);
end
end

