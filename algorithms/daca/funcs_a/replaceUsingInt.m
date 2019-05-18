function [ includedPoints, replacementPoints ] = replaceUsingInt( points, intervalsMat, replaceWith )
%replaceUsingInt Replace points using the intervals.
%
%   Inputs:
%   points is a vector containing decision points.
%   intervalstMatrix: A matrix of intervals. Intervals are across rows.
%   First column is the start point and 2nd column is the end point of each
%   interval.
%   replaceWith is a vector containing replacement points.
%
%   Outputs:
%   includedPoints is a vector containing included points.
%   replacementPoints is a vector containing replacement points.
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Exclude points using interval
pointsFilter = ones(1, length(points));
for i= 1:length(points)
    for j = 1:size(intervalsMat, 1)
        if(points(i) <= intervalsMat(j, 2) && points(i) >= intervalsMat(j, 1))
            pointsFilter(i) = 0; % 0 for not include
            break;
        end
    end
end
includedPoints = points(pointsFilter == 1);

% Include replaceWith using interval
pointsFilter = zeros(1, length(replaceWith));
for i= 1:length(replaceWith)
    for j = 1:size(intervalsMat, 1)
        if(replaceWith(i) <= intervalsMat(j, 2) && replaceWith(i) >= intervalsMat(j, 1))
            pointsFilter(i) = 1; % 1 for include
            break;
        end
    end
end
replacementPoints = replaceWith(pointsFilter == 1);
end

