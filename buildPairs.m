function [pairWiseUser, itemInPair] = buildPairs(Y,pairWiseUser,itemInPair,perItemPairs,distanceMeasure)
[~,m] = size(Y);
for i=1:m
    i
    [~,kFarthestItems] = calculateDistance(Y,i,perItemPairs,distanceMeasure);
    pairs = [repmat(i,perItemPairs,1),kFarthestItems'];
    for pairNo =1:length(kFarthestItems)
        tmp = strrep(num2str(pairs(pairNo,1:2)), '  ', '_');
        usersWithThisPair = find(Y(:,pairs(pairNo,1))==-1 & Y(:,pairs(pairNo,2))==1);
            if(~isempty(usersWithThisPair))
                pairWiseUser(tmp) = usersWithThisPair';
                itemInPair(tmp) = pairs(pairNo,:);
            end           
    end
end

end
