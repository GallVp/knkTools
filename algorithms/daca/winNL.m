function [ nlSig, nlTimeVect ] = winNL( sig, fs, winT )
%WINNL Computes noiseLevel of the signal using a window of size winT
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

winSamples = winT * fs;

numBins = floor(length(sig) / winSamples);
nlSig = zeros(numBins, 1);

for i = 1: numBins
    nlSig(i) = noiseLevel(sig((1:winSamples) + (i - 1) * winSamples), fs);
end

nlTimeVect = (1:numBins) .* winT;
end

