function [kSortedScore,kFarthestItems] = calculateDistance(Y,sourceId,perItemPairs,distanceMeasure)

[~,m] = size(Y);
scoreVec = zeros(1,m);
%tic
for i=1:m
    tmpIdx = Y(:,sourceId)==-1 & Y(:,i)==1;
%     if sum(tmpIdx == 0)
%         fprintf('\ncorrections required');
%     end
    warning('off', 'stats:pdist2:ZeroPoints')
    scoreVec(i) = sum(tmpIdx)*pdist2(Y(tmpIdx,sourceId)',Y(tmpIdx,i)',distanceMeasure);
end
%toc
[sortedScore,FarthestItems] = sort(scoreVec,'descend');
FarthestItems(sortedScore<=0) =[];
sortedScore(sortedScore<=0) = [];
if length(FarthestItems) < perItemPairs
    perItemPairs = length(FarthestItems);
end
kSortedScore = sortedScore(1:perItemPairs);
kFarthestItems = FarthestItems(1:perItemPairs);
end