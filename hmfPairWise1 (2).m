clear;
addpath(genpath('.'));

%% %%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nRun    = 3;    nRows   = 20;   nColumns= 20;   non0Per = 100;   tstPer  = 20;
ttlEvaluationMetrices = 3; l = 5;    i = (40:-1:1)./16; regvals = power(10,i);
ratingLevel    = 5;
%% HMF-Pairwise parameter
maxBatchSize = 5000;                    maxBatchInit = 20;
perItemPairs = 50;                      
samplePer    = 30;                      margin = 0.2;
gradfun      = @pairWiseHinge;          lambda = regvals(17);
alpha        = 5;

%% Required Parameter
optpar.lineSearchFun = @cgLineSearch;  optpar.c2 = 1e-2;
optpar.tol = 1e-2;                     optpar.maxiter = 500;
optpar.p = 100;

%%
ResultTrnPairHMF = zeros(ttlEvaluationMetrices,nRun);
ResultTstPairHMF = zeros(ttlEvaluationMetrices,nRun);
filename = strcat( 'Result/resultFinalPairwise.txt');
fs = fopen(filename,'a');

for runNo = 1:nRun
    %% Data Generation
    %Y = load('movielens.txt');
    Y = generateData(nRows,nColumns,non0Per);
    fprintf(fs,'\n\nrows:      %d\t column:       %d\t\t non0:  %d',size(Y,1),size(Y,2),non0Per);
    %% data pre-processing
    Y(sum(Y~=0,2)==0,:) = []; %code to delete user who has not given any rating
    Y = sparse(Y);
    [Ytrn,Ytst] = divideData(Y,tstPer);
    [n,m] = size(Ytrn);
    fprintf(fs,'\nrows left: %d\t column left:  %d\n',n,m);
    L = full(max(max(Ytrn(:),Ytst(:))));
    minRating =full(min(min(Ytrn(Ytrn>0)), min(Ytst(Ytst>0))));
    %%
    RFinal = zeros(n,m);
    levelNo=1;
    while levelNo< L
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
        %%  Parameter Pairwise HMF
        parameter = optpar;
        parameter.objGrad = gradfun;                                    parameter.lambda = lambda;
        parameter.Y = RcapTrn;
        parameter.alpha = alpha;
        parameter.pairWiseUser = pairWiseUser;                          parameter.itemInPair = itemInPair;
        parameter.batchWisePairs = batchWisePairs;                      parameter.maxBatch = maxBatch;
        parameter.sample = ceil((samplePer*pairWiseUser.length)/100);
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
        [RFinal] = ...
            predictionAtLevel(RFinal,X,RcapTrn, levelNo);
        
        
        %RFinal( (RFinal == 0) & y & y1) = levelNo;
        %confusingEntries = y-y1;
        %confusingEntriesConfi{levelNo} = X.*confusingEntries;
        
        levelNo = levelNo + 1;
        clear RcapTst RcapTrn;
    end
    RFinal( RFinal == 0 ) = L;
    ResultTrnPairHMF(:,runNo) = EvaluationAll(RFinal, Ytrn);
    ResultTstPairHMF(:,runNo) = EvaluationAll(RFinal, Ytst);
end