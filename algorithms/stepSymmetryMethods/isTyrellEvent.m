function [ d ] = isTyrellEvent( x, numLeastEvents )
%isTyrellEvent
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

d = sum(x) >= numLeastEvents;

end

