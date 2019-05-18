function [ d ] = noiseLevel( x, fs )
%NOISELEVEL Computes noise level for the given samples
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.
xPeak = max(x);
xDiff = diff(diff(diff(x).*fs) .* fs) .* fs;

d = log((1/xPeak^2) * sum((xDiff.^2) ./fs));

end