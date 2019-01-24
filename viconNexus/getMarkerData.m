function [ markerData ] = getMarkerData( vHandle, markerName )
%getMarkerData Retrives marker data from from vicon nexus.
%
%   Inputs:
%   vHandle is a handle to ViconNexus
%   markerName is the name of the marker. Examples: RHEE:X or RTOE:Z
%
%   Output:
%   markerData is structure containing following variables
%   a. data: A vector of frame values
%   b. frameRate: Frame rate
%   c. totalFrames: Total number of frames
%   d. recordingTime: Total recording time
%   e. markerName: Name of the marker
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% The current problem with getting subjectName in this way is that the
% subjects have to be loaded in a sequence in vicon.
subjectName = vHandle.GetSubjectNames;
subjectName = subjectName{end};

% Get data for the marker
mName = strsplit(markerName, ':');
markerName = mName{1};
dimName = mName{2};
switch(dimName)
    case 'X'
        [data, ~, ~]    = vHandle.GetTrajectory(subjectName, markerName);
        [e, f]          = vHandle.GetTrialRegionOfInterest;
    case 'Y'
        [~, data, ~]    = vHandle.GetTrajectory(subjectName, markerName);
        [e, f]          = vHandle.GetTrialRegionOfInterest;
    case 'Z'
        [~, ~, data]    = vHandle.GetTrajectory(subjectName, markerName);
        [e, f]          = vHandle.GetTrialRegionOfInterest;
end
data = data(e:f);
markerData.data = data';

% Compute time vector
markerData.frameRate = vHandle.GetFrameRate;
markerData.totalFrames = vHandle.GetFrameCount;
markerData.recordingTime = double(markerData.totalFrames) / double(markerData.frameRate); % In seconds
markerData.markerName = markerName;

end

