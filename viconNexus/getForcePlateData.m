function [ forceData ] = getForcePlateData(vHandle, plateName, dims)
%getForcePlateData Retrives force plate data from vicon nexus.
%
%   Inputs:
%   vHandle is a handle to ViconNexus
%   plateName is the name of the plate
%   dims is a vector specifying which dimensions to get. [1 2 3].
%   1=x, 2=y, 3=z. Default is z. More than one dmensions can be loaded
%   at once.
%
%   Output:
%   forceData is structure containing following variables
%   a. data: A matrix with frames across rows and channels across columns
%   b. plateFs: Sampling rate
%   c. plateUnits: Units of force
%   d. channelNames: Nmaes of channels
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Set default dims
if nargin < 3
    dims = 3;
end

% Get data for each plate

plateID = vHandle.GetDeviceIDFromName(plateName);
[~,~, forceData.plateFs, plateOutID] = vHandle.GetDeviceDetails(plateID);
[~,~, forceData.plateUnits, ~, channelNames, channelIDs] = vHandle.GetDeviceOutputDetails(plateID, plateOutID(1));
forceData.data = [];
for j = 1 : length(dims)
    channelData = vHandle.GetDeviceChannel(plateID, plateOutID(1), channelIDs(dims(j)));
    channelData = reshape(channelData, length(channelData), 1);
    forceData.data = [forceData.data -channelData];
    forceData.channelNames{j} = channelNames{dims(j)};
end
end