function [forceVectL, markerVectL, forceVectR, markerVectR] = eventS2eventV(forceStruct, markerStruct)
%eventS2eventV Converts an event structure to event vector by pooling all
%   the events.
forceVectL = sort([forceStruct.leftFootEvents.heelStrikes;forceStruct.leftFootEvents.toeOffs]);

markerVectL = sort([markerStruct.leftMarkerEvents.heelStrikes; markerStruct.leftMarkerEvents.toeOffs]);

forceVectR = sort([forceStruct.rightFootEvents.heelStrikes; forceStruct.rightFootEvents.toeOffs]);

markerVectR = sort([markerStruct.rightMarkerEvents.heelStrikes; markerStruct.rightMarkerEvents.toeOffs]);
end

