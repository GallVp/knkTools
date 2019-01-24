function [jScore] = jaccardScore(setA, setB)
%jaccardScore Returns Jaccard similarity coefficient.

jScore = 1;

unionOfSets = union(setA, setB);
if isempty(unionOfSets)
    return;
end

intersectionOsSets = intersect(setA, setB);
jScore = length(intersectionOsSets) / length(unionOfSets);
end

