clear;
addpath(genpath('.'));
gradfun = @pairWiseHinge; %gradient function

[weakR, strongR] = generateData();
%[Ytrn,Ytst] = divideData(weakR);
[Ytrn, Ytst, strongTrn, strongTst] = allBut1Division(weakR, strongR);
clear weakR strongR

[n,m] = size(Ytrn);

[p, alpha, ~, ratingLevel,increment, minRating] = setParameter();%p:-number of latent factor; alpha:-step size
tol = 1e-2;
lambda = 5;
maxiter = 100;
maxBatchSize = 10000;
maxBatchInit = 100;
perItemPairs = m;
noOfGroup = 2;
samplePer = 30;
margin = 0.2;


RFinal = zeros(n,m);

confusingEntriesConfi = zeros(n,m);
confusingEntriesLabel = zeros(n,m);
levelNo=1;
while levelNo< ratingLevel
    maxBatch = maxBatchInit;
    %code for converting into binary rating matrix
    RcapTrn = zeros(n, m);
    RcapTst = zeros(n, m);
    
    RcapTrn( (Ytrn <= levelNo) & ( Ytrn ~= 0 ) ) = -1;
    RcapTst( (Ytst <= levelNo) & ( Ytst ~= 0 ) ) = -1;
    
    RcapTrn( (Ytrn > levelNo) & ( Ytrn ~= 0 ) ) = 1;
    RcapTst( (Ytst > levelNo) & ( Ytst ~= 0 ) ) = 1;
    
    RcapTrn = sparse(RcapTrn);
    RcapTst = sparse(RcapTst);
    %%
    [pairWiseUser, itemInPair] = generatePairs(RcapTrn, perItemPairs);
    %}
    pairs = pairWiseUser.keys;
    randPairsIdx  = randperm(pairWiseUser.length);
    for batchNo=1:maxBatch
        if (batchNo*maxBatchSize) >= length(randPairsIdx)
            batchWisePairs{batchNo} = pairs(randPairsIdx((batchNo-1)*maxBatchSize+1:end));
            maxBatch = batchNo;
            break;
        else
            batchWisePairs{batchNo} = pairs(randPairsIdx((batchNo-1)*maxBatchSize+1:batchNo*maxBatchSize));
        end
    end
    %%
    %%  Parameter Weak
    parameter = {};
    parameter.lineSearchFun = @cgLineSearch;    parameter.c2 = 1e-2;
    parameter.objGrad = gradfun;                parameter.lambda = lambda;
    parameter.tol = tol;                        parameter.maxiter = maxiter;
    parameter.Y = sparse(RcapTrn);                 parameter.p = p;
    parameter.pairWiseUser = pairWiseUser;      parameter.itemInPair = itemInPair;
    parameter.batchWisePairs = batchWisePairs;  parameter.maxBatch = maxBatch;
    parameter.sample = ceil((samplePer*pairWiseUser.length)/100);
    parameter.alpha = alpha;
    %%
    %v = randn(n*parameter.p + m*parameter.p ,1);
    vInit = sprand( n*parameter.p + m*parameter.p,1 ,0.2);
    tic
    [v,numiter,ogcalls, J] = conjgrad(vInit, parameter);
    toc
    fprintf('total conjugate gradient iteration in HMF = %d\n',numiter);
    fprintf('total number of line search call in HMF = %d\n\n',ogcalls);
    
    U = reshape(v(1:n*parameter.p),n,parameter.p);
    V = reshape(v(n*parameter.p+1:n*parameter.p+m*parameter.p),m,parameter.p);
    
    X = U*V';
    
    %confusingEntriesConfi{levelNo} = X.*confusingEntries;
    [RFinal, confusingEntriesConfi, confusingEntriesLabel] = ...
        predictionAtLevel(RFinal,X,RcapTrn, margin, confusingEntriesConfi,confusingEntriesLabel, levelNo);
    
    
    %RFinal( (RFinal == 0) & y & y1) = levelNo;    
    %confusingEntries = y-y1;
    %confusingEntriesConfi{levelNo} = X.*confusingEntries;
    
    levelNo = levelNo + increment;
    clear RcapTst RcapTrn;
end
RFinal = RFinal + confusingEntriesLabel;
RFinal( RFinal == 0 ) = ratingLevel;
%RFinal1( RFinal1 == 0 ) = ratingLevel;
Ytrn = full(Ytrn);
Ytst = full(Ytst);

fprintf('\n\nOUR Training Error With CG:\t\tZOE = %.4f\t\tMAE = %.4f\t\tRMSE = %.4f\t\tAVERAGE-MAE = %.4f\t\tAVERAGE-RMSE = %.4f\n\n',...
    zoe(RFinal, Ytrn), mae(RFinal, Ytrn), RMSE(RFinal, Ytrn), averageMAE(RFinal, Ytrn), averageRMSE(RFinal, Ytrn));
fprintf('OUR Testing Error With CG:\t\tZOE = %.4f\t\tMAE = %.4f\t\tRMSE = %.4f\t\tAVERAGE-MAE = %.4f\t\tAVERAGE-RMSE = %.4f\n\n',...
    zoe(RFinal, Ytst), mae(RFinal, Ytst), RMSE(RFinal, Ytst), averageMAE(RFinal, Ytst), averageRMSE(RFinal, Ytst));
% 
% fprintf('\n\nOUR Training Error With CG:\t\tZOE = %.4f\t\tMAE = %.4f\t\tRMSE = %.4f\t\tAVERAGE-MAE = %.4f\t\tAVERAGE-RMSE = %.4f\n\n',...
%     zoe(RFinal1, Ytrn), mae(RFinal1, Ytrn), RMSE(RFinal1, Ytrn), averageMAE(RFinal1, Ytrn), averageRMSE(RFinal1, Ytrn));
% fprintf('OUR Testing Error With CG:\t\tZOE = %.4f\t\tMAE = %.4f\t\tRMSE = %.4f\t\tAVERAGE-MAE = %.4f\t\tAVERAGE-RMSE = %.4f\n\n',...
%     zoe(RFinal1, Ytst), mae(RFinal1, Ytst), RMSE(RFinal1, Ytst), averageMAE(RFinal1, Ytst), averageRMSE(RFinal1, Ytst));

%zoe(RFinal, Ytrn)
%mae(RFinal, Ytst)