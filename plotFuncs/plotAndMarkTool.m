function [markedIntervals, includedForceEvents, includedMarkerEvents ] = plotAndMarkTool(leftForcePlateData,...
    rightForcePlateData, forceEvents, markerEvents)
%plotAndMarkTool Create a figure and axes showing data from left and right
%   force plates. Allows the user to mark regions of invalid force. On
%   marked regions <=, >= rule is applied. All the labelling is done in
%   sample numbers and in the end sample numbers are converted back to
%   sample time. This is done to make sure that the
%
%   Inputs:
%   leftForcePlateData, rightForcePlateData are structures that contain
%   following variables:
%   a. data: A column vector of raw force values.
%   b. plateFs: Sampling rate for force data.
%   c. plateUnits: Units of force. (Optional)
%   forceEvents
%   Structures with following two variables:
%   leftFootEvents, rightFootEvents which are structures with vectors:
%   heelStrikes, toeOffs
%   markerEvents
%   Structures with following two variables:
%   leftMarkerEvents, rightMarkerEvents which are structures with vectors:
%   heelStrikes, toeOffs
%
%   Outputs:
%   markedIntervals is a matrix with start and end sample of invalid force
%   interval along columns and occurances across rows.
%   includedForceEvents, includedMarkerEvents
%   Structures with following two variables:
%   leftFootEvents, rightFootEvents which are structures with vectors:
%   heelStrikes, toeOffs
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Default return value
markedIntervals = [];

% Encapsulate constants
vars.MARKER_Y_POS       = 60;
vars.EVENT_MARKER_Y_POS = 20;

% Encapsulate useful variables
vars.fs = leftForcePlateData.plateFs;
vars.leftPlateData = leftForcePlateData.data;
vars.rightPlateData = rightForcePlateData.data;
if(isfield(leftForcePlateData, 'plateUnits'))
    vars.yLabel = sprintf('Force (%s)', leftForcePlateData.plateUnits);
else
    vars.yLabel     = 'Force';
end
vars.xLabel         = 'Sample No. (n)';
vars.legendInfo     = {'Left Plate', 'Right Plate'};
vars.forceEvents    = forceEvents;
vars.markerEvents   = markerEvents;

% Convert to sample space
vars.forceEvents.leftFootEvents.heelStrikes = round(vars.forceEvents.leftFootEvents.heelStrikes .* vars.fs);
vars.forceEvents.leftFootEvents.toeOffs = round(vars.forceEvents.leftFootEvents.toeOffs .* vars.fs);

vars.forceEvents.rightFootEvents.heelStrikes = round(vars.forceEvents.rightFootEvents.heelStrikes .* vars.fs);
vars.forceEvents.rightFootEvents.toeOffs = round(vars.forceEvents.rightFootEvents.toeOffs .* vars.fs);

vars.markerEvents.leftMarkerEvents.heelStrikes = round(vars.markerEvents.leftMarkerEvents.heelStrikes .* vars.fs);
vars.markerEvents.leftMarkerEvents.toeOffs = round(vars.markerEvents.leftMarkerEvents.toeOffs .* vars.fs);

vars.markerEvents.rightMarkerEvents.heelStrikes = round(vars.markerEvents.rightMarkerEvents.heelStrikes .* vars.fs);
vars.markerEvents.rightMarkerEvents.toeOffs = round(vars.markerEvents.rightMarkerEvents.toeOffs .* vars.fs);


% Set scroll size and location
vars.scrollSize = 5 .* vars.fs;         % In samples = T * fs
vars.scrollPos = [1 vars.scrollSize];   % In samples

% For interval marking
vars.markedIntervals = [];

% For including events
vars.includedForceEvents.leftFootEvents.heelStrikes     = [];
vars.includedForceEvents.leftFootEvents.toeOffs         = [];
vars.includedForceEvents.rightFootEvents.heelStrikes    = [];
vars.includedForceEvents.rightFootEvents.toeOffs        = [];
vars.includedMarkerEvents.leftMarkerEvents.heelStrikes    = [];
vars.includedMarkerEvents.leftMarkerEvents.toeOffs        = [];
vars.includedMarkerEvents.rightMarkerEvents.heelStrikes   = [];
vars.includedMarkerEvents.rightMarkerEvents.toeOffs       = [];

% Event Selection
vars.selectedEventForce = [];
vars.selectedEventMarker = [];


% Figure setup
H = figure('Visible', 'off',...
    'Units', 'pixels',...
    'ResizeFcn', @handleResize,...
    'Name', 'plotAndMarkTool',...
    'numbertitle','off',...
    'CloseRequestFcn',  @closeFigure, ...
    'KeyPressFcn', @keyPressHandler);

vars.enlargeFactor = 50;
hPos = get(H, 'Position');
hPos(4) = hPos(4) + vars.enlargeFactor;
set(H, 'Position', hPos);

% View setup
heightRatio = 0.8;
widthRatio = 0.7;
set(0,'units','characters');

displayResolution = get(0,'screensize');

width = displayResolution(3) * widthRatio;
height = displayResolution(4) * heightRatio;
x_x = (displayResolution(3) - width) / 2;
y = (displayResolution(4) - height) / 2;
set(H,'units','characters');
windowPosition = [x_x y width height];
set(H, 'pos', windowPosition);

% Create push buttons
vars.btnNext = uicontrol('Style', 'pushbutton', 'String', 'Right',...
    'Position', [300 20 75 20],...
    'Callback', @next);

vars.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Left',...
    'Position', [200 20 75 20],...
    'Callback', @previous);

vars.btnMark = uicontrol('Style', 'pushbutton', 'String', 'Mark',...
    'Position', [400 20 75 20],...
    'Callback', @markInterval);

vars.btnResetView = uicontrol('Style', 'pushbutton', 'String', 'Reset View',...
    'Position', [500 20 75 20],...
    'Callback', @resetView);

vars.btnDelete = uicontrol('Style', 'pushbutton', 'String', 'Delete',...
    'Position', [600 20 75 20],...
    'Callback', @delEvent);


% Add a text uicontrol.
vars.txtInfo = uicontrol('Style','text',...
    'Position',[75 17 120 20]);

updateView(1);

% Make figure visble after adding all components
set(H, 'Visible','on');

% Send into uiwait loop
uiwait(H);

% Callback functions
    function resetView(~,~)
        updateView();
    end

    function delEvent(~,~)
        if(~isempty(vars.selectedEventForce))
            vars.includedForceEvents.leftFootEvents.heelStrikes     = setdiff(vars.includedForceEvents.leftFootEvents.heelStrikes,...
                vars.selectedEventForce);
            vars.forceEvents.leftFootEvents.heelStrikes             = setdiff(vars.forceEvents.leftFootEvents.heelStrikes,...
                vars.selectedEventForce);
            
            vars.includedForceEvents.leftFootEvents.toeOffs         = setdiff(vars.includedForceEvents.leftFootEvents.toeOffs,...
                vars.selectedEventForce);
            vars.forceEvents.leftFootEvents.toeOffs                 = setdiff(vars.forceEvents.leftFootEvents.toeOffs,...
                vars.selectedEventForce);
            
            vars.includedForceEvents.rightFootEvents.heelStrikes    = setdiff(vars.includedForceEvents.rightFootEvents.heelStrikes,...
                vars.selectedEventForce);
            vars.forceEvents.rightFootEvents.heelStrikes             = setdiff(vars.forceEvents.rightFootEvents.heelStrikes,...
                vars.selectedEventForce);
            
            vars.includedForceEvents.rightFootEvents.toeOffs        = setdiff(vars.includedForceEvents.rightFootEvents.toeOffs,...
                vars.selectedEventForce);
            vars.forceEvents.rightFootEvents.toeOffs                = setdiff(vars.forceEvents.rightFootEvents.toeOffs,...
                vars.selectedEventForce);
        elseif(~isempty(vars.selectedEventMarker))
            vars.includedMarkerEvents.leftMarkerEvents.heelStrikes    = setdiff(vars.includedMarkerEvents.leftMarkerEvents.heelStrikes,...
                vars.selectedEventMarker);
            vars.markerEvents.leftMarkerEvents.heelStrikes          = setdiff(vars.markerEvents.leftMarkerEvents.heelStrikes,...
                vars.selectedEventMarker);
            
            vars.includedMarkerEvents.leftMarkerEvents.toeOffs        = setdiff(vars.includedMarkerEvents.leftMarkerEvents.toeOffs,...
                vars.selectedEventMarker);
            vars.markerEvents.leftMarkerEvents.toeOffs              = setdiff(vars.markerEvents.leftMarkerEvents.toeOffs,...
                vars.selectedEventMarker);
            
            vars.includedMarkerEvents.rightMarkerEvents.heelStrikes   = setdiff(vars.includedMarkerEvents.rightMarkerEvents.heelStrikes,...
                vars.selectedEventMarker);
            vars.markerEvents.rightMarkerEvents.heelStrikes         = setdiff(vars.markerEvents.rightMarkerEvents.heelStrikes,...
                vars.selectedEventMarker);
            
            vars.includedMarkerEvents.rightMarkerEvents.toeOffs       = setdiff(vars.includedMarkerEvents.rightMarkerEvents.toeOffs,...
                vars.selectedEventMarker);
            vars.markerEvents.rightMarkerEvents.toeOffs             = setdiff(vars.markerEvents.rightMarkerEvents.toeOffs,...
                vars.selectedEventMarker);
        end
        vars.selectedEventForce = [];
        vars.selectedEventMarker = [];
        updateView(2);
    end

    function next(~,~)
        vars.scrollPos = vars.scrollPos + vars.scrollSize;
        updateView
    end

    function previous(~,~)
        vars.scrollPos = vars.scrollPos - vars.scrollSize;
        updateView
    end

    function markInterval(~, ~)
        axH = gca;
        hold on;
        [mousePosX, ~] = ginputWithPlot(axH, 2);
        hold off;
        if(~isempty(mousePosX))
            % Left force events
            vars.includedForceEvents.leftFootEvents.heelStrikes = unique([vars.includedForceEvents.leftFootEvents.heelStrikes;...
                vars.forceEvents.leftFootEvents.heelStrikes(...
                vars.forceEvents.leftFootEvents.heelStrikes(:) >= mousePosX(1) &...
                vars.forceEvents.leftFootEvents.heelStrikes(:) <= mousePosX(2))]);
            vars.includedForceEvents.leftFootEvents.toeOffs = unique([vars.includedForceEvents.leftFootEvents.toeOffs;...
                vars.forceEvents.leftFootEvents.toeOffs(...
                vars.forceEvents.leftFootEvents.toeOffs(:) >= mousePosX(1) &...
                vars.forceEvents.leftFootEvents.toeOffs(:) <= mousePosX(2))]);
            % Right force events
            vars.includedForceEvents.rightFootEvents.heelStrikes = unique([vars.includedForceEvents.rightFootEvents.heelStrikes;...
                vars.forceEvents.rightFootEvents.heelStrikes(...
                vars.forceEvents.rightFootEvents.heelStrikes(:) >= mousePosX(1) &...
                vars.forceEvents.rightFootEvents.heelStrikes(:) <= mousePosX(2))]);
            vars.includedForceEvents.rightFootEvents.toeOffs = unique([vars.includedForceEvents.rightFootEvents.toeOffs;...
                vars.forceEvents.rightFootEvents.toeOffs(...
                vars.forceEvents.rightFootEvents.toeOffs(:) >= mousePosX(1) &...
                vars.forceEvents.rightFootEvents.toeOffs(:) <= mousePosX(2))]);
            
            % Left marker events
            vars.includedMarkerEvents.leftMarkerEvents.heelStrikes = unique([vars.includedMarkerEvents.leftMarkerEvents.heelStrikes;...
                vars.markerEvents.leftMarkerEvents.heelStrikes(...
                vars.markerEvents.leftMarkerEvents.heelStrikes(:) >= mousePosX(1) &...
                vars.markerEvents.leftMarkerEvents.heelStrikes(:) <= mousePosX(2))]);
            vars.includedMarkerEvents.leftMarkerEvents.toeOffs = unique([vars.includedMarkerEvents.leftMarkerEvents.toeOffs;...
                vars.markerEvents.leftMarkerEvents.toeOffs(...
                vars.markerEvents.leftMarkerEvents.toeOffs(:) >= mousePosX(1) &...
                vars.markerEvents.leftMarkerEvents.toeOffs(:) <= mousePosX(2))]);
            % Right marker events
            vars.includedMarkerEvents.rightMarkerEvents.heelStrikes = unique([vars.includedMarkerEvents.rightMarkerEvents.heelStrikes;...
                vars.markerEvents.rightMarkerEvents.heelStrikes(...
                vars.markerEvents.rightMarkerEvents.heelStrikes(:) >= mousePosX(1) &...
                vars.markerEvents.rightMarkerEvents.heelStrikes(:) <= mousePosX(2))]);
            vars.includedMarkerEvents.rightMarkerEvents.toeOffs = unique([vars.includedMarkerEvents.rightMarkerEvents.toeOffs;...
                vars.markerEvents.rightMarkerEvents.toeOffs(...
                vars.markerEvents.rightMarkerEvents.toeOffs(:) >= mousePosX(1) &...
                vars.markerEvents.rightMarkerEvents.toeOffs(:) <= mousePosX(2))]);
            
            vars.markedIntervals = [vars.markedIntervals; mousePosX'];
            
            updateView(2);
        end
    end

    function handleResize(~,~)
        updateView
    end
    function highlightEventForce(~,callbackdata)
        vars.selectedEventMarker = [];
        vars.selectedEventForce = callbackdata.IntersectionPoint(1);
        updateView(2);
    end
    function highlightEventMarker(~,callbackdata)
        vars.selectedEventForce = [];
        vars.selectedEventMarker = callbackdata.IntersectionPoint(1);
        updateView(2);
    end
    function axesWhiteSpaceClicked(~, ~)
        vars.selectedEventForce = [];
        vars.selectedEventMarker = [];
        if(~isempty(vars.selectedEventMarker) || ~isempty(vars.selectedEventForce))
            updateView(2);
        else
            updateView(1);
        end
    end

    function keyPressHandler(~, eventData)
        if(strcmp(eventData.Key, 'rightarrow'))
            next([], []);
        end
        if(strcmp(eventData.Key, 'leftarrow'))
            previous([], []);
        end
        if(strcmp(eventData.Key, 'space') && isempty(vars.selectedEventMarker) && isempty(vars.selectedEventForce))
            markInterval([], []);
        end
        if((strcmp(eventData.Key, 'd') || strcmp(eventData.Key, 'D')) && (~isempty(vars.selectedEventMarker) || ~isempty(vars.selectedEventForce)))
            delEvent([], []);
        end
        if(strcmp(eventData.Key, 'escape'))
            resetView([], []);
        end
    end

    function updateView(redrawFlag)
        
        if nargin < 1
            redrawFlag = 0;
        end
        
        if(redrawFlag)
            ax = subplot(1, 1, 1, 'Units', 'pixels', 'buttonDownfcn', @axesWhiteSpaceClicked, 'NextPlot', 'add');
            
            dat = [vars.leftPlateData vars.rightPlateData];
            
            p1 = plot(dat);
            pos = get(ax, 'Position');
            pos(2) = pos(2) + vars.enlargeFactor / 2;
            pos(4) = pos(4) - vars.enlargeFactor / 3;
            set(ax, 'Position', pos);
            
            if(~isempty(vars.markedIntervals))
                hold on
                for i=1:size(vars.markedIntervals)
                    xDat = linspace(vars.markedIntervals(i, 1), vars.markedIntervals(i, 2));
                    yDat = xDat ./ xDat .* vars.MARKER_Y_POS;
                    plot(xDat, yDat, 'r-.', 'LineWidth', 2, 'MarkerSize', 15);
                    plot(xDat(1), yDat(1), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
                    plot(xDat(end), yDat(end), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
                end
                % Plot included left side force heelStrikes
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedForceEvents.leftFootEvents.heelStrikes;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'r+', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventForce);
                end
                % Plot included left side force toeOffs
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedForceEvents.leftFootEvents.toeOffs;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'ko', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventForce);
                end
                % Plot included right side force heelStrikes
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedForceEvents.rightFootEvents.heelStrikes;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'r+', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventForce);
                end
                % Plot included right side force toeOffs
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedForceEvents.rightFootEvents.toeOffs;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'ko', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventForce);
                end
                
                % Do same for marker events
                % Plot included left side marker heelStrikes
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedMarkerEvents.leftMarkerEvents.heelStrikes;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'mx', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventMarker);
                end
                % Plot included left side marker toeOffs
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedMarkerEvents.leftMarkerEvents.toeOffs;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'cs', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventMarker);
                end
                % Plot included right side marker heelStrikes
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedMarkerEvents.rightMarkerEvents.heelStrikes;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'mx', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventMarker);
                end
                % Plot included right side marker toeOffs
                yDat = vars.EVENT_MARKER_Y_POS;
                xDat = vars.includedMarkerEvents.rightMarkerEvents.toeOffs;
                if(~isempty(xDat))
                    plot(xDat, yDat, 'cs', 'MarkerSize', 10, 'LineWidth', 2,'buttonDownfcn', @highlightEventMarker);
                end
                
                hold off
            end
            
            set(vars.txtInfo, 'String', sprintf('Marked Intervals: %d', size(vars.markedIntervals, 1)));
            
            ylabel(vars.yLabel);
            xlabel(vars.xLabel);
            legend(p1, vars.legendInfo);
        end
        % Plot selection points
        set(vars.btnDelete, 'Enable', 'off');
        hold on
        yDat = vars.EVENT_MARKER_Y_POS;
        xDat = vars.selectedEventForce;
        if(~isempty(xDat))
            pm = plot(xDat, yDat, 'bo', 'MarkerSize', 20);
            set(pm, 'DisplayName', 'Force Event');
            set(vars.btnDelete, 'Enable', 'on');
        end
        yDat = vars.EVENT_MARKER_Y_POS;
        xDat = vars.selectedEventMarker;
        if(~isempty(xDat))
            pm = plot(xDat, yDat, 'gs', 'MarkerSize', 20);
            set(pm, 'DisplayName', 'Marker Event');
            set(vars.btnDelete, 'Enable', 'on');
        end
        hold off
        axisInfo = axis;
        if(redrawFlag == 2)
            axis([vars.markedIntervals(end, 1)- vars.scrollSize/100 vars.markedIntervals(end, 2)+ vars.scrollSize/100 axisInfo(3) axisInfo(4)]);
            set(vars.btnNext, 'Enable', 'off');
            set(vars.btnPrevious, 'Enable', 'off');
            set(vars.btnMark, 'Enable', 'off');
        else
            axis([vars.scrollPos(1)-vars.scrollSize/10 vars.scrollPos(2)+vars.scrollSize/10 axisInfo(3) axisInfo(4)]);
            set(vars.btnNext, 'Enable', 'On');
            set(vars.btnPrevious, 'Enable', 'On');
            set(vars.btnMark, 'Enable', 'On');
        end
    end

    function closeFigure(~,~)
        % Go back to time space
        % Report included marker events and remaining force events
        vars.forceEvents.leftFootEvents.heelStrikes = vars.forceEvents.leftFootEvents.heelStrikes ./ vars.fs;
        vars.forceEvents.leftFootEvents.toeOffs = vars.forceEvents.leftFootEvents.toeOffs ./ vars.fs;
        
        vars.forceEvents.rightFootEvents.heelStrikes = vars.forceEvents.rightFootEvents.heelStrikes ./ vars.fs;
        vars.forceEvents.rightFootEvents.toeOffs = vars.forceEvents.rightFootEvents.toeOffs ./ vars.fs;
        
        vars.includedMarkerEvents.leftMarkerEvents.heelStrikes = vars.includedMarkerEvents.leftMarkerEvents.heelStrikes ./ vars.fs;
        vars.includedMarkerEvents.leftMarkerEvents.toeOffs = vars.includedMarkerEvents.leftMarkerEvents.toeOffs ./ vars.fs;
        
        vars.includedMarkerEvents.rightMarkerEvents.heelStrikes = vars.includedMarkerEvents.rightMarkerEvents.heelStrikes ./ vars.fs;
        vars.includedMarkerEvents.rightMarkerEvents.toeOffs = vars.includedMarkerEvents.rightMarkerEvents.toeOffs ./ vars.fs;
        
        markedIntervals = vars.markedIntervals ./ vars.fs;
        includedForceEvents = vars.forceEvents;
        
        includedMarkerEvents = vars.includedMarkerEvents;
        delete(gcf);
    end
end