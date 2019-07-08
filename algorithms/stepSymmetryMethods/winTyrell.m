function [ consecBinsStartAt ] = winTyrell( sig, winSize, numLeastEvents, numLeastBins )
%winTyrell Compute tyrell events from sig using a window of winSize. sig is
%   logical.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

winSamples = winSize;

numBins = floor(length(sig) / winSamples);
tyrellEventWins = zeros(numBins, 1);

for i = 1: numBins
    tyrellEventWins(i) = isTyrellEvent(sig((1:winSamples) + (i - 1) * winSamples), numLeastEvents);
end

consecBinsStartAt = find(consecEvents(tyrellEventWins, numLeastBins), 1, 'first') * winSize;
end

