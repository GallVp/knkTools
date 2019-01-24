function [TPR, TNR, FPR, FNR, F1] = genConfusionMatrix(TP, TN, FP, FN)
%genConfusionMatrix Generates confusion matrix from classes.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

TPR     = sum(TP) / (sum(TP) + sum(FN)) * 100;
TNR     = sum(TN) / (sum(TN) + sum(FP)) * 100;
FPR     = sum(FP) / (sum(FP) + sum(TN)) * 100;
FNR     = sum(FN) / (sum(FN) + sum(TP)) * 100;

F1      = 2 * sum(TP) / (2*sum(TP) + sum(FN) + sum(FP)) * 100;
end