function [clParams, clParamCIs] = clParameters(fitParams, paramCIs)
%clParameters Takes the model fitted parameters and confidence intervals
%   and transforms them into common language parameters and their confidence
%   intervals. If no output argument is assigned, a table is generated and
%   printed in MATLAB's command window.
%
%   Inputs:
%   a. fitParams: A vector of parameters of a model. If the number of
%   parameters is 3, a single exponential model is assumed. If the
%   number of parameters is 5, a double exponential model is assumed.
%   b. paramCIs: A matrix of parameter confidence intervals. The number of
%   rows of this matrix should be equal to the number of elements of
%   fitParams.
%
%   Output:
%   a. clParams: A vector of common language parameters.
%       For single exponential model, following parameters are returned:
%       1. Initial asymmetry:                   a+c
%       2. Total change in symmetry:            a
%       3. Strides to 50% completion of change: floor(1/abs(b))
%       4. Final asymmetry:                     c
%       For double exponential model, following parameters are returned:
%       1. Initial asymmetry:                   as+af+c
%       2. Total change in symmetry:            as+af
%       3., 4. Strides to 50% completion of
%           changes:                            floor(1/abs(bs)), floor(1/abs(bf))
%       5. Final asymmetry:                     c
%       6. Overshoot:                           ycrit
%   b. clParamCIs: A matrix of parameter confidence intervals.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.


if length(fitParams)    == 3 % If single exponential
    clParams(1)         = fitParams(1) + fitParams(3);
    clParams(2)         = fitParams(1);
    clParams(3)         = floor(1./abs(fitParams(2)));
    clParams(4)         = fitParams(3);
    
    % Confidence intervals
    clParamCIs(1, :)    = paramCIs(1,:) + paramCIs(3,:);
    clParamCIs(2, :)    = paramCIs(1,:);
    clParamCIs(3, :)    = floor(1./abs(paramCIs(2,:)));
    clParamCIs(4, :)    = paramCIs(3,:);
else% Double exponential model
    clParams(1)         = fitParams(1) + fitParams(3) + fitParams(5);
    clParams(2)         = fitParams(1) + fitParams(3);
    clParams(3)         = floor(1./abs(fitParams(2)));
    clParams(4)         = floor(1./abs(fitParams(4)));
    clParams(5)         = fitParams(5);
    clParams(6)         = ycrit(fitParams(1), fitParams(2),...
        fitParams(3), fitParams(4), fitParams(5));
    
    % Confidence intervals
    clParamCIs(1, :)    = paramCIs(1, :) + paramCIs(3, :) + paramCIs(5, :);
    clParamCIs(2, :)    = paramCIs(1, :) + paramCIs(3, :);
    clParamCIs(3, :)    = floor(1./abs(paramCIs(2, :)));
    clParamCIs(4, :)    = floor(1./abs(paramCIs(4, :)));
    clParamCIs(5, :)    = paramCIs(5, :);
    clParamCIs(6, 1)    = ycrit(paramCIs(1, 1), paramCIs(2, 1),...
        paramCIs(3, 1), paramCIs(4, 1), paramCIs(5, 1));
    clParamCIs(6, 2)    = ycrit(paramCIs(1, 2), paramCIs(2, 2),...
        paramCIs(3, 2), paramCIs(4, 2), paramCIs(5, 2));
end

if nargout              < 1 % Print a table
    if length(fitParams)== 3
        fprintf('Common language parameters with 95pc CIs for single exp. model:\n\n');
        fprintf('1. Initial asymmetry (a+c): %.3f [%.3f, %.3f]\n', clParams(1), clParamCIs(1, 1), clParamCIs(1, 2));
        fprintf('2. Total change in symmetry (a): %.3f [%.3f, %.3f]\n', clParams(2), clParamCIs(2, 1), clParamCIs(2, 2));
        fprintf('3. Strides to 50pc completion of change {floor(1/abs(b))}: %d [%d, %d]\n', clParams(3), clParamCIs(3, 1), clParamCIs(3, 2));
        fprintf('4. Final asymmetry (c): %.3f [%.3f, %.3f]\n', clParams(4), clParamCIs(4, 1), clParamCIs(4, 2));
    else
        fprintf('Common language parameters with 95pc CIs for double exp. model:\n\n');
        fprintf('1. Initial asymmetry (as+af+c): %.3f [%.3f, %.3f]\n', clParams(1), clParamCIs(1, 1), clParamCIs(1, 2));
        fprintf('2. Total change in symmetry (as+af): %.3f [%.3f, %.3f]\n', clParams(2), clParamCIs(2, 1), clParamCIs(2, 2));
        fprintf('3. Strides to 50pc completion of\n change {floor(1/abs(bs)); floor(1/abs(bf))}: {%d [%d, %d]; %d [%d, %d]}\n',...
            clParams(3), clParamCIs(3, 1), clParamCIs(3, 2), clParams(4), clParamCIs(4, 1), clParamCIs(4, 2));
        fprintf('4. Final asymmetry (c): %.3f [%.3f, %.3f]\n', clParams(5), clParamCIs(5, 1), clParamCIs(5, 2));
        fprintf('5. Overshoot (ycrit): %.3f [%.3f, %.3f]\n', clParams(6), clParamCIs(6, 1), clParamCIs(6, 2));
    end
end
end

