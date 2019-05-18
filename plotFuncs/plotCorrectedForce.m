function [correctionFigure] = plotCorrectedForce(leftPlateData, rightPlateData, vEventsL, reEventsL, vEventsR, reEventsR,...
    leftPlateInvalidForceInfo, rightPlateInvalidForceInfo)
%plotCorrectedForce Plots corrected gait events along with adjusted
%   intervals.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

correctionFigure = figure;

% Plot force data
plotForceData(correctionFigure, leftPlateData);
plotForceData(correctionFigure, rightPlateData);

% plot force events on the same figure
plotEventData(correctionFigure, vEventsL);
plotEventData(correctionFigure, vEventsR);

% plot marker events on the same figure
[p{1}, p{2}] = plotEventData(correctionFigure, reEventsL,  {'kd', 'ks'});
plotEventData(correctionFigure, reEventsR, {'kd', 'ks'});

% Draw the invalid time points as "*" and intervals as lines.
plotInvalidForceMarkers( correctionFigure, leftPlateInvalidForceInfo, 1);
[p{3}, ~]    = plotInvalidForceMarkers( correctionFigure, rightPlateInvalidForceInfo, 1);
set(gca,'TickLength',[0, 0]);
legend([p{1} p{2} p{3}], {'Corrected Heel-strike',...
    'Corrected Toe-off', 'Correction interval'}, 'Box', 'off', 'Orientation', 'horizontal');
xlabel('Time (s)');
ylabel('Force (N)');
end