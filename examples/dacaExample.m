%dacaExample
%   This example script loads force plate data and marker data from Vicon
%   Nexus and applies Detect and Correct Algorithm (DACA). The results are
%   plotted.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

clear
close all
clc

%% System parameters
vHandle = ViconNexus;
leftPlateName = 'Left Plate';
rightPlateName = 'Right Plate';

%% Get data for both plates along Z dimension only.
dim = 3;
leftPlateData = getForcePlateData(vHandle, leftPlateName, dim);
rightPlateData = getForcePlateData(vHandle, rightPlateName, dim);

%% Retrieve marker Data in Y direction only
lHeelMarker = getMarkerData(vHandle, 'LHEE:Y');
rHeelMarker = getMarkerData(vHandle, 'RHEE:Y');
lToeMarker = getMarkerData(vHandle, 'LTOE:Y');
rToeMarker = getMarkerData(vHandle, 'RTOE:Y');

%% Run Detect and Correction Algorithm with following options
options.noiseLevelWnSz                          =   0.025;  % Seconds
options.numConsecNLs                            =   5;
options.modeTimes                               =   2;
options.debugMode                               =   1;

[vEventsL, reEventsL, vEventsR, reEventsR] = detectAndCorrectAlgo(leftPlateData,...
    rightPlateData, lHeelMarker, rHeelMarker, lToeMarker, rToeMarker, options);