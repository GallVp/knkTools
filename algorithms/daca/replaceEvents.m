function [ validEvents, addedEvents ] = replaceEvents( forceEvents, markerEvents, invalidForceInfo )
%REPLACEEVENTS This function takes force events and invalid
%   points/intervals from force data and substitutes marker events
%   accordingly.
%
%   Inputs:
%   forceEvents, markerEvents are structures that contain following variables:
%       a. heelStrikes: A column vector of heel strikes.
%       b. toeOffs: A column vector of toe offs.
%
%   Outputs:
%   validEvents, addedEvents
%   Structures that contain following variables:
%       a. heelStrikes: A column vector of heel strikes.
%       b. toeOffs: A column vector of toe offs.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Take events as is
validEvents = forceEvents;
addedEvents = markerEvents;

% Exclude using interval
ifiRowWise = invalidForceInfo.adjustedIntervals;

[validEvents.heelStrikes, addedEvents.heelStrikes]= replaceUsingInt(forceEvents.heelStrikes, ifiRowWise, markerEvents.heelStrikes);

[validEvents.toeOffs, addedEvents.toeOffs]= replaceUsingInt(forceEvents.toeOffs, ifiRowWise, markerEvents.toeOffs);

% Replace using intervals from points
ipInterval = invalidForceInfo.ipInterval;
% Now use the above method again
[validEvents.heelStrikes, newAdditions] = replaceUsingInt(validEvents.heelStrikes, ipInterval,  markerEvents.heelStrikes);
addedEvents.heelStrikes = unique([addedEvents.heelStrikes;newAdditions]);

[validEvents.toeOffs, newAdditions] = replaceUsingInt(validEvents.toeOffs, ipInterval,  markerEvents.toeOffs);
addedEvents.toeOffs = unique([addedEvents.toeOffs;newAdditions]);
end

