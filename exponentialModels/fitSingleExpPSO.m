function [ fitted, resids, fitParams, linearCIs, aic] = fitSingleExpPSO(dataSeries, fixJthTheta, atThetaJ)
%fitSingleExpPSO Fit the single exponential model using the particle swarm
%   algorithm 
%
%   Inputs:
%   a. dataSeries: Step length symmetry data as a vector.
%   b. fixThetaJ (optional): Index of the jth theta. This is used when
%   confidence intervals are to be obtained using the method which does not
%   make the assumption of linearisation.
%   c. atThetaJStar (optional): Vale to be used for the jth theta.
%
%   Output:
%   a. fitted: Fitted values of symmetry.
%   b. resids: Model residuals.
%   c. fitParams: Parameters of the fitted model.
%   d. linearCIs: CIs based on the assumption of linearisation.
%   e. aic: AIC value for the fitted model.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

%% Constants
NUM_DCSN_STRDS       = 50; % Number of strides used to detect overall trend

%% Detect direction of symmetry series and set upper and lower bounds
if(mean(dataSeries(1:NUM_DCSN_STRDS)) < mean(dataSeries(length(dataSeries) - NUM_DCSN_STRDS:end)))
    lb              = [-2,  -log(2),    -1];
    ub              = [0,   0,          1];
else
    lb              = [0,   -log(2),    -1];
    ub              = [2,   0,          1];
end

% Fix jth theta at the provided value if additional arguments are passed
if nargin > 1
    lb(fixJthTheta) = atThetaJ;
    ub(fixJthTheta) = atThetaJ;
end

%% Set up particle swarm algorithm for optimisation
rng shuffle;
xData               = 1:length(dataSeries);
fun                 = @(x)expCostFunc(xData, dataSeries, x);
numParam            = 3;
hybridopts          = optimoptions('fmincon', 'Display', 'iter',...
    'Algorithm', 'interior-point',...
    'FunctionTolerance', 1e-6);
options             = optimoptions('particleswarm',...
    'SwarmSize', numParam * 3,...
    'UseParallel', false,...
    'Display', 'iter',...
    'HybridFcn', {@fmincon, hybridopts},...
    'FunctionTolerance', 1e-3);

%% Run optimisation twice and chose the solution with the smaller cost
fitParam1           = particleswarm(fun, numParam, lb, ub, options);
fitParam2           = particleswarm(fun, numParam, lb, ub, options);

c1                  = expCostFunc(xData, dataSeries, fitParam1);
c2                  = expCostFunc(xData, dataSeries, fitParam2);

if c1 < c2
    fitParams       = fitParam1;
else
    fitParams       = fitParam2;
end

%% Assign outputs
fitted              = fitParams(1) .* exp(xData.*fitParams(2)) + fitParams(3);
xData               = xData';
J                   = [exp(fitParams(2).*xData) xData.*fitParams(1).*exp(fitParams(2).*xData) ones(length(xData), 1)];
resids              = dataSeries - fitted;
linearCIs           = nlparci(fitParams, resids,'jacobian', J);
aic                 = 2*(numParam+1) + length(resids)*log(sum(resids.^2));

%% Define the cost function
    function c      = expCostFunc(X, Y, P)
        fitY        = P(1) .* exp(X.*P(2)) + P(3);
        c           = sum((Y - fitY).^2);
    end
end