function [hsLine, toLine] = plotEventData( figHandle, eventData, markers )
%PLOTEVENTDATA Plots events data on the provided figure handle.
%
%   Inputs:
%   figHandle is a MATLAB figure handle
%   eventData is a structure that contain following variables:
%   a. heelStrikes: A column vector containg time points for heel
%   strikes
%   b. toeOffs: A column vector containg time points for toe Offs
%   markers is a cell array of markers used for plotting events.
%   Default markers: {'r+', 'ko'}
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% set Deafault markers
if nargin < 3
    markers = {'kv', 'ko'};
end
%% Set given figure as current and hold on
set(0, 'CurrentFigure', figHandle)
hold on
% plot the events

if(~isempty(eventData.heelStrikes)) % If event data is present, plot it
    hsLine = plot(eventData.heelStrikes, eventData.threshLevel .* ones(size(eventData.heelStrikes)), markers{1});
else
    hsLine = matlab.graphics.chart.primitive.Line.empty;
end
if(~isempty(eventData.toeOffs)) % If event data is present, plot it
    toLine = plot(eventData.toeOffs, eventData.threshLevel .* ones(size(eventData.toeOffs)), markers{2});
else
    toLine = matlab.graphics.chart.primitive.Line.empty;
end
end

