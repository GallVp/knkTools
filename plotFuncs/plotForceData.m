function plottedLine = plotForceData( figHandle, forceData, plotOpts )
%PLOTFORCEDATA Plots force data on the provided figure handle.
%   Default force units are Newtons.
%
%   Inputs:
%   figHandle is a MATLAB figure handle
%   forceData is a structure that contain following variables:
%   a. data: A column vector of raw force values.
%   b. plateFs: Sampling rate for force data.
%   c. plateUnits: Units of force. (Optional)
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 3
    plotOpts = [];
end

%% Set given figure as current and hold on
set(0, 'CurrentFigure', figHandle)
hold on;

%% Plot force
timeVect = (1:size(forceData.data, 1)) ./ forceData.plateFs;
if(isempty(plotOpts))
    plottedLine = plot(timeVect, forceData.data);
else
    plottedLine = plot(timeVect, forceData.data, plotOpts);
end

xlabel('Time (s)');
if(isfield(forceData, 'plateUnits'))
    ylabel(sprintf('Force (%s)', forceData.plateUnits));
else
    ylabel('Force (N)');
end
end

