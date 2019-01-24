function [ vEventsL, reEventsL, vEventsR, reEventsR ] = detectAndCorrectAlgo( leftPlateData, rightPlateData, lHeelMarker, rHeelMarker, lToeMarker, rToeMarker, options )
%detectAndCorrectAlgo
%   Takes kinetic data from two force plates and kinematic
%   data from two markers. Detects gait events from force plates. If the
%   force data becomes invalid, it automatically switches to marker data
%   for gait events and back to force data again.
%
%   Inputs:
%   leftPlateData, rightPlateData
%   Structures that contain following variables:
%   data: A column vector of raw force values
%   plateFs: Sampling rate for force data
%
%   leftMarkerData, rightMarkerData
%   Structures that contain following variables:
%   data: A column vector of raw position values
%   frameRate: Frame rate for marker data.
%
%   options (optional) A structure with following variables:
%   forceThreshLevel: Threshhold level for detecting events from force data.
%   Default value 20 Newtons.
%   forceFilterCutoff: Cutoff frequency for the lowpass butterworth filter
%   used on force data. Default value 10 Hz.
%   noiseLevelWnSz: Window size for noise function. Default value 50
%   miliseconds (0.05).
%   numConsecNLs: Number of consececutive noise levels required for
%   detecting invalid force. Default value 2.
%   markerFilterCutoff: Cutoff frequency for the lowpass butterworth filter
%   used on marker data. Default value 25 Hz.
%   modeTimes: Number of modes used to detect invalid intervals of force.
%   Default value 2.
%   intLengthFactor: A scalar factor used to shorten or elongate the length
%   of interval constructed around an invalid force point.
%   debugMode: Flag for plotting figures and displaying statistics. Default
%   value 1 (1/0).
%
%   Outputs:
%   vEventsL, vEventsR are gait events for left and right force place
%   respectively; excluding the events marked as invalid.
%   reEventsL, reEventsR are gait events detected from marker data as
%   replacement of gait events detected from force plates.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

defaultOptions.forceThreshLevel                        =   20;
defaultOptions.forceFilterCutoff                       =   10;
defaultOptions.markerFilterCutoff                      =   25;

defaultOptions.noiseLevelWnSz                          =   0.025;  % Seconds
defaultOptions.numConsecNLs                            =   5;
defaultOptions.modeTimes                               =   2;

defaultOptions.intLengthFactor                         =   0.75;

defaultOptions.debugMode                               =   1;
defaultOptions.saveFigs                                =   0;
defaultOptions.outputFolder                            =   pwd;

if nargin < 7
    options = defaultOptions;
else
    options = assignOptions(options, defaultOptions);
end

%% Step I: Detect events from force data
leftFootEvents = geForceThresh(leftPlateData, options.forceThreshLevel, options.forceFilterCutoff);
rightFootEvents = geForceThresh(rightPlateData, options.forceThreshLevel, options.forceFilterCutoff);

%% Step II: Detect invalid force points and intervals
leftPlateInvalidForceInfo = detectInvalidForce(leftPlateData, options.noiseLevelWnSz, options.numConsecNLs,...
    options.modeTimes, defaultOptions.intLengthFactor);
rightPlateInvalidForceInfo = detectInvalidForce(rightPlateData, options.noiseLevelWnSz, options.numConsecNLs,...
    options.modeTimes, defaultOptions.intLengthFactor);

leftPlateInvalidForceInfo.forceThreshLevel = options.forceThreshLevel;
rightPlateInvalidForceInfo.forceThreshLevel = options.forceThreshLevel;

%% Intermediary step for visualisation of results in advanced debugging
% excludeEvents(leftFootEvents, leftPlateInvalidForceInfo);
% excludeEvents(rightFootEvents, rightPlateInvalidForceInfo);

%% Step III: Include gait events detected from marker data

% Detect events from marker data
leftMarkerEvents.heelStrikes = geMarkerCTA(lHeelMarker, options.markerFilterCutoff);
leftMarkerEvents.toeOffs = geMarkerCTA(lToeMarker, options.markerFilterCutoff, 1);
rightMarkerEvents.heelStrikes = geMarkerCTA(rHeelMarker, options.markerFilterCutoff);
rightMarkerEvents.toeOffs = geMarkerCTA(rToeMarker, options.markerFilterCutoff, 1);

% Include marker events
[vEventsL, reEventsL] = replaceEvents(leftFootEvents, leftMarkerEvents, leftPlateInvalidForceInfo);
[vEventsR, reEventsR] = replaceEvents(rightFootEvents, rightMarkerEvents, rightPlateInvalidForceInfo);

% Add thresholds to the structure
reEventsL.threshLevel = options.forceThreshLevel;
reEventsR.threshLevel = options.forceThreshLevel;


%% Do plotting if required
if(options.debugMode)
    detectionFigure = plotInvalidForce(leftPlateData, rightPlateData, leftFootEvents, rightFootEvents,...
        leftPlateInvalidForceInfo, rightPlateInvalidForceInfo);
    
    correctionFigure = plotCorrectedForce(leftPlateData, rightPlateData, vEventsL, reEventsL, vEventsR, reEventsR,...
        leftPlateInvalidForceInfo, rightPlateInvalidForceInfo);
    
    if options.saveFigs
        savefig(detectionFigure, fullfile(options.outputFolder, 'detectionFigure.fig'));
        savefig(correctionFigure, fullfile(options.outputFolder, 'correctionFigure.fig'));
    end
end