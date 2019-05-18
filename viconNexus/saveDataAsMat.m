%saveDataAsMat
%   This script loads force plate data and marker data from Vicon
%   and saves it in mat format.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

clear
close all
clc

%% File name and save location
fileName = 'sub30_sess01_phase02.mat';

saveFolder = fullfile(pwd, 'Data');
mkdir(saveFolder);

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

%% Save force plate data and marker data
fullfileName = fullfile(saveFolder, fileName);
save(fullfileName, 'leftPlateData', 'rightPlateData', 'lHeelMarker', 'rHeelMarker', 'lToeMarker', 'rToeMarker');
fprintf('Saved file: %s\n', fullfileName);