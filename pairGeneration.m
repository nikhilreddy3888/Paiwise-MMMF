function [pairWiseUser, itemInPair,batchWisePairs, maxBatch] = pairGeneration(Ytrn,perItemPairs,maxBatch,maxBatchSize)

    [pairWiseUser, itemInPair] = generatePairs(Ytrn, perItemPairs);
    pairs = pairWiseUser.keys;
    randPairsIdx  = randperm(pairWiseUser.length);
    %batchWisePairs = cell(1,maxBatch);
    for i=1:maxBatch
           if (i*maxBatchSize) >= length(randPairsIdx)
               batchWisePairs{i} = pairs(randPairsIdx((i-1)*maxBatchSize+1:end));
               maxBatch = i;
               break;
           else
               batchWisePairs{i} = pairs(randPairsIdx((i-1)*maxBatchSize+1:i*maxBatchSize));
           end
    end
end