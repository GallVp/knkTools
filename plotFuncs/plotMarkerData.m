function [dataLine, hsLine, toLine] = plotMarkerData( figHandle, markerData, eventData )
%PLOTMARKERDATA Plots marker data and events if available.
%
%   Inputs:
%   figHandle is a MATLAB figure handle
%   markerData is a structure that contain following variables:
%       a. data: A column vector of marker position.
%       b. frameRate: Frame rate of 3-D Motion capture system.
%       c. markerName: Name of the marker.
%   eventData is a structure that contain following variables:
%       a. heelStrikes: A column vector containg time points for heel
%       strikes
%       b. toeOffs: A column vector containg time points for toe Offs
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 3
    eventData = [];
end

% Default markers
markers = {'ks'};

%% Set given figure as current and hold on
set(0, 'CurrentFigure', figHandle)
hold on

%% Plot marker
timeVector = (1:length(markerData.data)) ./ markerData.frameRate;

dataLine = plot(timeVector, markerData.data);

if(~isempty(eventData.heelStrikes)) % If event data is present, plot it
    indices = round(eventData.heelStrikes .* markerData.frameRate);
    indices(indices == 0) = 1;
    hsLine = plot(eventData.heelStrikes, markerData.data(indices), markers{1});
else
    hsLine = [];
end
if(~isempty(eventData.toeOffs)) % If event data is present, plot it
    indices = round(eventData.toeOffs .* markerData.frameRate);
    indices(indices == 0) = 1;
    toLine = plot(eventData.toeOffs, markerData.data(indices), markers{1});
else
    toLine = [];
end

xlabel('Time (s)')
ylabel('Displacement (mm)')
title(sprintf('Data of %s', markerData.markerName));
end

