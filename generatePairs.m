function [pairWiseUser, itemInPair] = generatePairs(Y, perItemPairs)

minUsersPairs = 1;

pairWiseUser = containers.Map('KeyType','char', 'ValueType','any');
itemInPair = containers.Map('KeyType','char', 'ValueType','any');
[~, m] = size(Y);

for itemNo = 1:m
    items = setdiff(1:m,itemNo);
    %%
    itemsIdxrandPerm = items(randperm(m-1));
    pairs = zeros(perItemPairs,2);
    selectedIdx = 1;
    usersPairs = cell(1,perItemPairs);
    for pairNo =1:m-1
        usersWithThisPair = find(Y(:,itemNo)==-1 & Y(:,itemsIdxrandPerm(pairNo))==1);
        if length(usersWithThisPair) >= minUsersPairs
            pairs(selectedIdx,:) = [itemNo,itemsIdxrandPerm(pairNo)];
            usersPairs{selectedIdx} = usersWithThisPair';
                        selectedIdx = selectedIdx +1;
        end
        if selectedIdx > perItemPairs
            break;
        end        
    end
    
    for pairNo =1:selectedIdx-1
        tmp = strrep(num2str(pairs(pairNo,1:2)), '  ', '_');
        if(isKey(pairWiseUser,tmp))
            pairWiseUser(tmp) = [pairWiseUser(tmp),usersPairs{pairNo}];
        else
            pairWiseUser(tmp) = usersPairs{pairNo};
            itemInPair(tmp) = pairs(pairNo,:);
        end
    end    
end

%
notSelectedItems = setdiff(1:m,unique(cell2mat(itemInPair.values)));
%m = length(notSelectedItems);
for itemNo = 1:length(notSelectedItems)
    items = setdiff(1:m,notSelectedItems(itemNo));    
    itemsIdxrandPerm = items(randperm(m-1));
    
    pairs = zeros(perItemPairs,2);
    selectedIdx = 1;
    usersPairs = cell(1,perItemPairs);
    for pairNo =1:m-1
        usersWithThisPair = find(Y(:,notSelectedItems(itemNo))== 1 & Y(:,itemsIdxrandPerm(pairNo))==-1);
        if length(usersWithThisPair) >= minUsersPairs
            pairs(selectedIdx,:) = [itemsIdxrandPerm(pairNo),notSelectedItems(itemNo)];
            usersPairs{selectedIdx} = usersWithThisPair';
                        selectedIdx = selectedIdx +1;
        end
        if selectedIdx > perItemPairs
            break;
        end        
    end
    
    for pairNo =1:selectedIdx-1
        tmp = strrep(num2str(pairs(pairNo,1:2)), '  ', '_');
        if(isKey(pairWiseUser,tmp))
            pairWiseUser(tmp) = [pairWiseUser(tmp),usersPairs{pairNo}];
        else
            pairWiseUser(tmp) = usersPairs{pairNo};
            itemInPair(tmp) = pairs(pairNo,:);
        end
    end
end
%}
end