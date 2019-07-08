function tau = plateauFit( stepLengthSymData, method)
%plateauFit Find's strides to symmetry in step length symmetry data with
%   one of the following plateau based methods.
%   
%   1. finley: Finley, J. M., Statton, M. A., & Bastian, A. J. (2013).
%               A novel optic flow pattern speeds split-belt locomotor
%               adaptation. Journal of neurophysiology, 111(5), 969-976.
%
%   2. tyrell: Tyrell, C. M., Helm, E., & Reisman, D. S. (2014). Learning
%               the spatial features of a locomotor task is slowed after
%               stroke. Journal of neurophysiology, 112(2), 480-489.
%
%   Inputs:
%   a. stepLengthSymData: Step length symmetry data as a vector.
%   b. method: 'finley' or 'tyrell'
%
%   Output:
%   a. tau: Strides to symmetry.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.


if nargin < 2
    method  = 'finley';
end

if nargout < 1
    plotFig = 1;
else
    plotFig = 0;
end

%% Output Defaults
tau         = [];

%% Constants
% For Finley's method
NUM_FOR_LAST_PARAM_FINLEY = 100;
NUM_EVENT_PARAM_FINLEY = 30;
NUM_STDS_FINLEY = 2;

% For Tyrell's method
NUM_FOR_LAST_PARAM_TYRELL = 30;
WIN_SIZE_TYRELL = 5;
NUM_EVENT_PARAM_TYRELL = 4;
NUM_CONSEC_BINS_TYRELL = 4;
NUM_STDS_TYRELL = 1;

if strcmp(method, 'finley')
    meanOfParam = mean(stepLengthSymData(end-NUM_FOR_LAST_PARAM_FINLEY+1:end));
    stdOfParam = abs(std(stepLengthSymData(end-NUM_FOR_LAST_PARAM_FINLEY+1:end)));
    events = stepLengthSymData <= meanOfParam + stdOfParam*NUM_STDS_FINLEY & stepLengthSymData >= meanOfParam - stdOfParam*NUM_STDS_FINLEY;
    events = consecEvents(events, NUM_EVENT_PARAM_FINLEY);
    tau = find(events, 1, 'first');
    
    if plotFig
        figure;
        tVect = (1:length(stepLengthSymData))';
        plot(tVect, stepLengthSymData, 'ko');
        xlabel('Stride Number');
        ylabel('Symmetry');
        ax = axis;
        axis([ax(1) ax(2) -0.1 0.1]);
        hold
        if(~isempty(tau))
            line([tau tau], [-0.1 0.1], 'Color', 'red', 'LineWidth', 2);
            legend('Data', 'Finley Plat.');
        else
            legend('Data');
        end
        title('Symmetry data with Finley Plateau');
    end
else
    meanOfParam = mean(stepLengthSymData(end-NUM_FOR_LAST_PARAM_TYRELL+1:end));
    stdOfParam = abs(std(stepLengthSymData(end-NUM_FOR_LAST_PARAM_TYRELL+1:end)));
    events = stepLengthSymData <= meanOfParam + stdOfParam*NUM_STDS_TYRELL & stepLengthSymData >= meanOfParam - stdOfParam*NUM_STDS_TYRELL;
    tau = winTyrell(events, WIN_SIZE_TYRELL, NUM_EVENT_PARAM_TYRELL, NUM_CONSEC_BINS_TYRELL);
    
    if plotFig
        figure;
        tVect = (1:length(stepLengthSymData))';
        plot(tVect, stepLengthSymData, 'ko');
        xlabel('Stride Number');
        ylabel('Symmetry');
        ax = axis;
        axis([ax(1) ax(2) -0.1 0.1]);
        hold
        if(~isempty(tau))
            line([tau tau], [-0.1 0.1], 'Color', 'red', 'LineWidth', 2);
            legend('Data', 'Tyrell Plat.');
        else
            legend('Data');
        end
        title('Symmetry data with Tyrell Plateau');
    end
end
end

