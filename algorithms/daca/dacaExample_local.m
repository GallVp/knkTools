%dacaExample_local
%   This example script loads force plate data and marker data from example
%   data files and applies Detect and Correct Algorithm
%   (DACA). The results are plotted.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

clear
close all
clc

%% Load Data
load(fullfile(pwd, 'Data', 'example01_DS.mat'));
%load(fullfile(pwd, 'Data', 'example01_SS.mat'));

%% Run Detect and Correction Algorithm with following options
options.noiseLevelWnSz                          =   0.025;  % Seconds
% Number of bins. Recommended: 3 for DS and 5 for SS
options.numConsecNLs                            =   3;
options.debugMode                               =   1;

[vEventsL, reEventsL, vEventsR, reEventsR] = detectAndCorrectAlgo(leftPlateData,...
    rightPlateData, lHeelMarker, rHeelMarker, lToeMarker, rToeMarker, options);

%% Diagnostics: Plot Uncorrected and Corrected Step lengths
% Step length = Distance between heel markers at heel strikes
minTimeDiff = 0.05;
leftFootEvents = combineUniqueEvents(vEventsL, reEventsL, minTimeDiff);
rightFootEvents = combineUniqueEvents(vEventsR, reEventsR, minTimeDiff);

%%  Find Distance between Heel markers at Heel strikes
stepCount = min([length(leftFootEvents.heelStrikes) length(rightFootEvents.heelStrikes)]);
% Left step length
lStepLength = zeros(1, stepCount);
for i = 1: stepCount
    timeOfHS = round(leftFootEvents.heelStrikes(i) .* lHeelMarker.frameRate);
    lStepLength(i) = lHeelMarker.data(timeOfHS) - rHeelMarker.data(timeOfHS);
end
% Right step length
rStepLength = zeros(1, stepCount);
for i = 1: stepCount
    timeOfHS =round(rightFootEvents.heelStrikes(i) .* rHeelMarker.frameRate);
    rStepLength(i) = rHeelMarker.data(timeOfHS) - lHeelMarker.data(timeOfHS);
end
lsCorrected = lStepLength;
rsCorrected = rStepLength;

% Find uncorrected events
leftFootEvents = geForceThresh(leftPlateData, 20, 10);
rightFootEvents = geForceThresh(rightPlateData, 20, 10);

stepCount = min([length(leftFootEvents.heelStrikes) length(rightFootEvents.heelStrikes)]);
% Left step length
lStepLength = zeros(1, stepCount);
for i = 1: stepCount
    timeOfHS = round(leftFootEvents.heelStrikes(i) .* lHeelMarker.frameRate);
    lStepLength(i) = lHeelMarker.data(timeOfHS) - rHeelMarker.data(timeOfHS);
end
% Right step length
rStepLength = zeros(1, stepCount);
for i = 1: stepCount
    timeOfHS =round(rightFootEvents.heelStrikes(i) .* rHeelMarker.frameRate);
    rStepLength(i) = rHeelMarker.data(timeOfHS) - lHeelMarker.data(timeOfHS);
end

lsUncorrected = lStepLength;
rsUncorrected = rStepLength;

figure
scatterhist(lsUncorrected, rsUncorrected);
title(sprintf('Step lengths from uncorrected gait events #: %d', length(lsUncorrected)));
xlabel('Left side step length');
ylabel('Right side step length');
figure
scatterhist(lsCorrected, rsCorrected);
title(sprintf('Step lengths from corrected gait events #: %d', length(lsCorrected)));
xlabel('Left side step length');
ylabel('Right side step length');