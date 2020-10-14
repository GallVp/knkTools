function dataSeries = simExpData(withParams, andVariance, forStrides)
%simExpData Simulate symmetry series based on parameters of an exponential
%   model with a specified variance.
%
%   Inputs:
%   a. withParams: A vector of parameters of a model. If the number of
%   parameters is 3, a single exponential model is assumed. If the
%   number of parameters is 5, a double exponential model is assumed.
%   b. andVariance: Value of variance.
%   c. forStrides: The number of strides to simulate
%
%   Output:
%   a. dataSeries: Simulated step length symmetry data as a vector.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.


strides         = 1:forStrides;

if length(withParams) == 3
    P           = withParams;
    dataSeries  = P(1) .* exp(strides.*P(2)) +...
        P(3) + sqrt(andVariance).*randn(1, forStrides);
else
    P           = withParams;
    dataSeries  = P(1) .* exp(strides.*P(2)) +...
        P(3) .* exp(strides.*P(4)) + P(5) +...
        sqrt(andVariance).*randn(1, forStrides);
end

end

