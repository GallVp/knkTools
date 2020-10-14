function [ fitted, resids, fitParam, linearCIs, wlFCIs] = wlCIs(dataSeries, forSingle)
%wlCIs Estimate 95% CIs for parameters of the single or double
%   exponential model. CIs based on linearisation and without linearisation
%   assumption are estimated.
%   
%
%   Inputs:
%   a. dataSeries: Step length symmetry data as a vector.
%   b. forSingle (optional, default 1): Should the confidence intervals be
%   estimated for the single exponential model or the double exponential
%   model (1=single, 0=double).
%
%   Output:
%   a. fitted: Fitted values of symmetry.
%   b. resids: Model residuals.
%   c. fitParams: Parameters of the fitted model.
%   d. linearCIs: CIs based on the assumption of linearisation.
%   e. wlFCIs: CIs without the assumption of linearisation.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 2
    forSingle = 1;
end

%% Detect direction of symmetry series and set upper and lower bounds
if(forSingle)
    NUM_PARAM       = 3;
    if(mean(dataSeries(1:50)) < mean(dataSeries(length(dataSeries) - 50:end)))
        LB          = [-2,  -log(2),    -1];
        UB          = [0,   0,          1];
    else
        LB          = [0,   -log(2),    -1];
        UB          = [2,   0,          1];
    end
else
    NUM_PARAM       = 5;
    % Both the No-overshoot and Yes-overshoot bounds are combined as these
    % are only used to provide good starting points for the fzero function.
    if(mean(dataSeries(1:50)) < mean(dataSeries(length(dataSeries) - 50:end)))
        LB          = [-1,   -log(2),   -1,     -log(2),    -1];
        UB          = [1,    0,         0,      0,          1];
    else
        LB          = [-1,   -log(2),   0,      -log(2),    -1];
        UB          = [1,    0,         1,      0,          1];
    end
end

XTOL                = 1e-6;

%% Find optimal values of the parameters with all parameters free-rolling.
if(forSingle)
    [fitted, resids, thetaHat, linearCIs, ~]    = fitSingleExpPSO(dataSeries);
else
    [fitted, resids, thetaHat, linearCIs, ~]    = fitDoubleExpPSO(dataSeries);
end

sThetaHat           = sum(resids.^2);

%% Function to find sTilde for the jth parameter at its thetaJth value

    function [sTilde]                           = findSTilde(dataSeries, fixJthTheta, atThetaJ)
        if(forSingle)
            [ ~, constrainedResids, ~, ~, ~]    = fitSingleExpPSO(dataSeries, fixJthTheta, atThetaJ);
        else
            [ ~, constrainedResids, ~, ~, ~]    = fitDoubleExpPSO(dataSeries, fixJthTheta, atThetaJ);
        end
        sTilde                                  = sum(constrainedResids.^2);
    end

%% Setup single parameter function to be solved for fCI

    function value                              = solveForfCI(atThetaJ, onDataseries, fixJthTheta)
        qF                                      = finv(0.95, 1, length(onDataseries) - NUM_PARAM);
        sTilde                                  = findSTilde(onDataseries, fixJthTheta, atThetaJ);
        sRatio                                  = (sTilde - sThetaHat) / sThetaHat;
        value                                   = qF - ((length(onDataseries) - NUM_PARAM)*(sRatio));
    end

%% Solve for upper and lower fCIs
wlFCIs              = NaN.*ones(size(linearCIs));
for j               = 1:size(wlFCIs, 1)
    fun             = @(x)solveForfCI(x, dataSeries, j);
    options         = optimset('PlotFcns',{@optimplotx,@optimplotfval}, 'TolX', XTOL);
    
    % Lower 95% CI
    x0(1)           = LB(j);
    x0(2)           = thetaHat(j);
    try
        wlFCIs(j, 1)= fzero(fun, x0, options);
    catch ME
        disp(ME.message);
        x0(1)       = -1e2;
        x0(2)       = thetaHat(j);
        wlFCIs(j, 1)= fzero(fun, x0, options);
    end
    
    % Upper 95% CI
    x0(1)           = thetaHat(j);
    x0(2)           = UB(j);
    try
        wlFCIs(j, 2)= fzero(fun, x0, options);
    catch ME
        disp(ME.message);
        x0(1)       = thetaHat(j);
        x0(2)       = 1e2;
        wlFCIs(j, 2)= fzero(fun, x0, options);
    end
end

fitParam = thetaHat;
end