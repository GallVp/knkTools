function [ eventData ] = geForceThresh( forceData, threshLevel, filterCutoff )
%geForceThresh Generates events from force data using thresholding Method.
%   The default threshhold level is 20 Newtons and filter cuttoff
%   frequency is 10 Hz.
%
%   Inputs:
%   forceData is a structure that contain following variables:
%   a. data: A column vector of raw force values.
%   b. plateFs: Sampling rate for force data.
%
%   Output:
%   eventData is a structure that contain following variables:
%   a. heelStrikes: A column vector containg time points for heel
%   strikes
%   b. toeOffs: A column vector containg time points for toe Offs
%   c. threshLevel: The value of force at which the events
%   were detected
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 3
    filterCutoff = 10;
elseif nargin < 2
    filterCutoff = 10;
    threshLevel = 20;
end

% Filter force data
filteredData = lowPassStream(forceData.data, forceData.plateFs, filterCutoff);

% Threshold at the set level
forceThresh = (filteredData) > threshLevel;

% Take differential
forceDiff = diff(forceThresh);

% Take positive differential points as Heel strikes and convert to time
eventData.heelStrikes = find(forceDiff > 0) ./ forceData.plateFs;

% Take negative differential points as toe offs and convert to time
eventData.toeOffs = find(forceDiff < 0) ./ forceData.plateFs;

% Add threshlevel to eventData
eventData.threshLevel = threshLevel;
end

