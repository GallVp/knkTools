function [ includedEvents, excludedEvents ] = excludeEvents( eventData, invalidForceInfo)
%EXCLUDEEVENTS Exclude events according to invalid force info.
%
%   Inputs:
%   eventData is a structure that contain following variables:
%       a. heelStrikes: A column vector of heel strikes.
%       b. toeOffs: A column vector of toe offs.
%   invalidForceInfo is a structure with all the necessary variables from
%       the previous step.
%
%   Outputs:
%   includedEvents, excludedEvents
%   Structures that contain following variables:
%       a. heelStrikes: A column vector of heel strikes.
%       b. toeOffs: A column vector of toe offs.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Take events as is
includedEvents = eventData;
excludedEvents = eventData;

% Exclude using interval
ifiRowWise = invalidForceInfo.adjustedIntervals;

[includedEvents.heelStrikes, excludedEvents.heelStrikes] = excludeUsingInt(eventData.heelStrikes, ifiRowWise);

[includedEvents.toeOffs, excludedEvents.toeOffs] = excludeUsingInt(eventData.toeOffs, ifiRowWise);

% Exclude using intervals from points
ipInterval = invalidForceInfo.ipInterval;
% Now use the above method again
[includedEvents.heelStrikes, newExclusions] = excludeUsingInt(includedEvents.heelStrikes, ipInterval);
excludedEvents.heelStrikes = unique([excludedEvents.heelStrikes;newExclusions]);

[includedEvents.toeOffs, newExclusions] = excludeUsingInt(includedEvents.toeOffs, ipInterval);
excludedEvents.toeOffs = unique([excludedEvents.toeOffs;newExclusions]);
end