function [ fitted, resids, fitParams, linearCIs, aic] = fitDoubleExpPSO(dataSeries, fixJthTheta, atThetaJ)
%fitDoubleExpPSO Fit the double exponential model using the particle swarm
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
LAMBDA               = 1e3;


%% Detect direction of symmetry series and set upper and lower bounds

% These bounds correspond to No-overshoot.
if(mean(dataSeries(1:NUM_DCSN_STRDS)) < mean(dataSeries(length(dataSeries) - NUM_DCSN_STRDS:end)))
    lb              = [-1,   -log(2),   -1,     -log(2),    -1];
    ub              = [0,    0,         0,      0,          1];
else
    lb              = [0,   -log(2),    0,      -log(2),    -1];
    ub              = [1,    0,         1,      0,          1];
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
numParam            = 5;
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
    fitParamA       = fitParam1;
    cA              = c1;
else
    fitParamA       = fitParam2;
    cA              = c2;
end

%% Detect direction of symmetry series and set upper and lower bounds

% These bounds correspond to Yes-overshoot.
if(mean(dataSeries(1:NUM_DCSN_STRDS)) < mean(dataSeries(length(dataSeries) - NUM_DCSN_STRDS:end)))
    lb              = [0,   -log(2),    -1,     -log(2),    -1];
    ub              = [1,    0,         0,      0,          1];
else
    lb              = [-1,   -log(2),   0,      -log(2),    -1];
    ub              = [0,    0,         1,      0,          1];
end

% Fix jth theta at the provided value if additional arguments are passed
if nargin > 1
    lb(fixJthTheta) = atThetaJ;
    ub(fixJthTheta) = atThetaJ;
end

%% Run optimisation twice and chose the solution with the smaller cost
fitParam3           = particleswarm(fun, numParam, lb, ub, options);
fitParam4           = particleswarm(fun, numParam, lb, ub, options);
c3                  = expCostFunc(xData, dataSeries, fitParam3);
c4                  = expCostFunc(xData, dataSeries, fitParam4);

if c3 < c4
    fitParamB       = fitParam3;
    cB              = c3;
else
    fitParamB       = fitParam4;
    cB              = c4;
end

% Chose the best solution from No-overshoot and Yes-overshoot solutions
if cA < cB
    fitParams       = fitParamA;
else
    fitParams       = fitParamB;
end

%% Assign outputs
fitted              = fitParams(1) .* exp(xData.*fitParams(2)) + fitParams(3) .* exp(xData.*fitParams(4)) + fitParams(5);
xData               = xData';
J                   = [exp(fitParams(2).*xData) xData.*fitParams(1).*exp(fitParams(2).*xData)...
    exp(fitParams(4).*xData) xData.*fitParams(3).*exp(fitParams(4).*xData)...
    ones(length(xData), 1)];
resids              = dataSeries - fitted;
linearCIs           = nlparci(fitParams, resids,'jacobian', J);
aic                 = 2*(numParam+1) + length(resids)*log(sum(resids.^2));

% Cost function
    function c      = expCostFunc(X, Y, P)
        fitY        = P(1) .* exp(X.*P(2)) + P(3) .* exp(X.*P(4)) + P(5);
        ratePen     = max(0, P(4) - P(2) + 1e-3).^2;
        amountPen   = max(0, abs(P(1) + P(3)) - 2).^2;
        c           = sum((Y - fitY).^2) + LAMBDA*ratePen + LAMBDA*amountPen;
    end
end

