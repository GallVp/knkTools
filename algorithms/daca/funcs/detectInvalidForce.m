function [ invalidForceInfo ] = detectInvalidForce( plateData, noiseLevelWnSz, numConsecNLs, modeTimes, intLengthFactor)
%DETECTINVALIDFORCE Takes the force data and detect invalid force
%   point and invalid force intervals.
%
%   Inputs:
%   plateData is a structure that contain following variables:
%   a. data: A column vector of raw force values.
%   b. plateFs: Sampling rate for force data.
%   noiseLevelWnSz is the size of the window used to generate noise
%   profile.
%   numConsecNLs is the number of consecutive noise events required for
%   flagging a force point as invalid.
%   intLengthFactor is a scalar containg value of interval length
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Find noise level values for the plate
[plateNL, nlTime] = winNL(plateData.data, plateData.plateFs, noiseLevelWnSz);

%% Detect invalid force if noise level is above mean by one std and there
% are 'numConsecNLs' such consecutive occurances.
highNoiseEvents = plateNL > mean(plateNL(isfinite(plateNL))) + std(plateNL(isfinite(plateNL)));
consecNoiseEvents = consecEvents(highNoiseEvents, numConsecNLs);
invalidForcePoints = nlTime(consecNoiseEvents);


%% Find intervals of invalid force
gaitPhaseEstimate = isnan(plateNL);
% Find the indices where plateNL is nan
nanPoints = find(gaitPhaseEstimate);

% Find distance between nans/when force is zero and thus noiseLevel is NaN

distBwNans = diff(nanPoints);
% Take mode of distance excluding 1, i.e. consecutive nans
modeOfDist = mode(distBwNans(distBwNans ~= 1));
modeStanceLength = modeOfDist * noiseLevelWnSz;


% Now find those nanpoints for which the distance is larger than modeTimes times
% mode. Use these points to get time points
invalidForceIntervals = [nlTime(nanPoints([distBwNans > modeTimes * modeOfDist;0==1]))' distBwNans(distBwNans > modeTimes * modeOfDist)];
invalidForceIntervals(:, 2) = invalidForceIntervals(:, 1) + invalidForceIntervals(:, 2) .* noiseLevelWnSz;

%% Adjust width of intervals
adjustedIntervals = invalidForceIntervals;
adjustedIntervals(:, 1) = invalidForceIntervals(:, 1) + modeStanceLength / 2;
adjustedIntervals(:, 2) = invalidForceIntervals(:, 2) - modeStanceLength / 2;


%% Exclude those invalid time points which lie in invalid intervals
pointsFilter = ones(1, length(invalidForcePoints));
for i= 1:length(invalidForcePoints)
    for j = 1:size(adjustedIntervals, 1)
        if(invalidForcePoints(i) <= adjustedIntervals(j, 2) && invalidForcePoints(i) >= adjustedIntervals(j, 1))
            pointsFilter(i) = 0; % 0 for not include
            break;
        end
    end
end
invalidForcePoints = invalidForcePoints(pointsFilter == 1);

% Convert invalidPoints to an intervals
ipInterval = [(invalidForcePoints - modeStanceLength * intLengthFactor)'  (invalidForcePoints + modeStanceLength * intLengthFactor)'];

invalidForceInfo.gaitPhaseEstimate      = gaitPhaseEstimate;
invalidForceInfo.plateNL                = plateNL;
invalidForceInfo.nlTime                 = nlTime;
invalidForceInfo.modeStanceLength       = modeStanceLength;
invalidForceInfo.invalidForcePoints     = invalidForcePoints;
invalidForceInfo.ipInterval             = ipInterval;
invalidForceInfo.adjustedIntervals      = adjustedIntervals;
invalidForceInfo.invalidForceIntervals  = invalidForceIntervals;


