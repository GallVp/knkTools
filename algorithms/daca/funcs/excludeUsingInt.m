function [ includedPoints, excludedPoints ] = excludeUsingInt( points, intervalstMatrix )
%EXCLUDEUSINGINT Exclude points using the intervals.
%
%   Inputs:
%   points is a vector containing decision points.
%   intervalstMatrix: A matrix of intervals. Intervals are across rows.
%   First column is the start point and 2nd column is the end point of each
%   interval.
%
%   Outputs:
%   includedPoints is a vector containing included points.
%   excludedPoints is a vector containing excluded points.
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% IntMat is a n by 2 matrics, where each row is an interval.

% Exclude using interval
pointsFilter = ones(1, length(points));
for i= 1:length(points)
    for j = 1:size(intervalstMatrix, 1)
        if(points(i) <= intervalstMatrix(j, 2) && points(i) >= intervalstMatrix(j, 1))
            pointsFilter(i) = 0; % 0 for not include
            break;
        end
    end
end
includedPoints = points(pointsFilter == 1);
excludedPoints = points(pointsFilter ~= 1);
end