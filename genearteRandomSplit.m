clear;
noSplit=1;
movielens = load('movielens1m.mat');
R = movielens.movielens1m;
%to remove unrated movie
R(:,~any(R)) = [];
weakMax = 5000;
[n, ~] = size(R);

weaktrain1 = cell(1,noSplit);
weaktest1 = cell(1,noSplit);
strongtrain1 = cell(1,noSplit);
strongtest1 = cell(1,noSplit);

for i=1:noSplit
    idx = randperm(n);
    weakR = R(idx(1:weakMax),:);
    strongR = R(idx(weakMax+1:end),:);
    [weakTrn,weakTst,strongTrn,strongTst] = allBut1Division(weakR, strongR);
    weaktrain1{i}  = sparse(weakTrn);
    weaktest1{i}   = sparse(weakTst);
    strongtrain1{i}= sparse(strongTrn);
    strongtest1{i} = sparse(strongTst);
    clear weakR weakTrn strongTrn weakTst strongTst strongR
end

clear i idx movielens n noSplit R weakMax 
