function [ eventData] = geMarkerCTA( markerData, fCutOff, flagTOs )
%geMarkerCTA Generates events from marker data using the Coordinate Based
%   Treadmil Algorithm[1].
%
%   [1] J. Zeni, J. Richards, J. Higginson, Two simple methods for
%   determining gait events during treadmill and overground walking using
%   kinematic data, Gait & posture 27 (4) (2008) 710 -- 714.
%
%   Inputs:
%   markerData is a structure that contain following variables:
%   a. data: A column vector of raw marker position values in the
%   horizontal (anterior posterior) direction.
%   b. frameRate: Frame rate of the 3D capture system.
%   fCutOff is the frequency cutoff for the low pass filter applied to
%   raw marker data.
%   flagTOs is 1/0 and determines whether the algo detects a toe off
%   or a heel strike depending on axis settings of the 3D Capture System.
%   
%
%   Output:
%   eventData is a column vector of detected event time points.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 3
    flagTOs = 0;
end
% Filter markerData data
filteredData = lowPassStream(markerData.data, markerData.frameRate, fCutOff);

% Find extremas and return
if(flagTOs == 0)
    [~, eventData] = findpeaks(filteredData, markerData.frameRate);
    eventData = eventData + 1 / markerData.frameRate;
else
    [~, eventData] = findpeaks(-filteredData, markerData.frameRate);
    eventData = eventData + 1 / markerData.frameRate;
end
end

