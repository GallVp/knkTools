function [ outEvents ] = combineUniqueEvents( inEvents1, inEvents2, minTimeDiff )
%COMBINEUNIQUEEVENTS Take two event structures and combines them into one
%structure with unique events separated by 'minTimeDiff'

outEvents = inEvents1;
outEvents.heelStrikes = unique([inEvents1.heelStrikes;inEvents2.heelStrikes]);
outEvents.toeOffs = unique([inEvents1.toeOffs;inEvents2.toeOffs]);

outEvents.heelStrikes = outEvents.heelStrikes(diff([0;outEvents.heelStrikes]) > minTimeDiff);
outEvents.toeOffs = outEvents.toeOffs(diff([0;outEvents.toeOffs]) > minTimeDiff);
end

