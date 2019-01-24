function [detectionFigure] = plotInvalidForce(leftPlateData, rightPlateData, leftFootEvents, rightFootEvents,...
    leftPlateInvalidForceInfo, rightPlateInvalidForceInfo)
%plotInvalidForce Plots points and intervals of invalid force on the
%   provided figure with legends, noise levels and gait phases.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.


detectionFigure = figure;

% Plot force data
ax(1) = subplot(3,1,1);
plotForceData(detectionFigure, leftPlateData);
plotForceData(detectionFigure, rightPlateData);

% plot events on the same figure
[p{1}, p{2}] = plotEventData(detectionFigure, leftFootEvents);
plotEventData(detectionFigure, rightFootEvents);

% Draw the invalid time points as "*" and intervals as lines.
[p{3}, p{4}]    = plotInvalidForceMarkers( detectionFigure, leftPlateInvalidForceInfo);
plotInvalidForceMarkers( detectionFigure, rightPlateInvalidForceInfo);
xlabel('');
ylabel('Force (N)');
set(gca,'TickLength',[0, 0]);
legend([p{1} p{2} p{3} p{4}], {'Heel-strike',...
    'Toe-off', 'Invalid point', 'Invalid Interval'}, 'Box', 'off', 'Orientation', 'horizontal');
xticks([]);
set(gca, 'XColor', 'none');


% Plot force data with corrected intervals and events
ax(2) = subplot(3,1,2);
plot(leftPlateInvalidForceInfo.nlTime, leftPlateInvalidForceInfo.plateNL);
hold on;
plot(rightPlateInvalidForceInfo.nlTime, rightPlateInvalidForceInfo.plateNL);
hold off;
box off;
ylabel('Noise level');
set(gca,'TickLength',[0, 0]);
xticks([]);
set(gca, 'XColor', 'none');

ax(3) = subplot(3,1,3);
plot(leftPlateInvalidForceInfo.nlTime, (1.2 .* leftPlateInvalidForceInfo.gaitPhaseEstimate) - 0.2);
hold on;
plot(rightPlateInvalidForceInfo.nlTime, rightPlateInvalidForceInfo.gaitPhaseEstimate);
hold off;
axInfo = axis;
axis([axInfo(1) axInfo(2) -0.5 1.5]);
box off;
xlabel('Time (s)');
ylabel('Gait phase');
yticks([-0.1 1]);
yticklabels({'Stance', 'Swing'});
set(gca,'TickLength',[0, 0]);
legend({'Left plate', 'Right plate'}, 'Box', 'off', 'Orientation', 'horizontal');
linkaxes(ax, 'x');
end