function [obj,grad] = pairWiseHinge(v,parameter)
% remove computation base on sample size
% introduce batch-wise update
Y = parameter.Y;
lambda = parameter.lambda;
p = parameter.p;
pairWiseUser = parameter.pairWiseUser;
itemInPair = parameter.itemInPair;
batchWisePairs = parameter.batchWisePairs;
maxBatch = parameter.maxBatch;
alpha = parameter.alpha;
clear parameter

[n,m] = size(Y);
U = reshape(v(1:n*p),n,p);
V = reshape(v(n*p+1:n*p+m*p),m,p);
clear v;


% Unorm = sum(U(:).^2);
% Vnorm = sum(V(:).^2);
%
% t = (Vnorm/Unorm).^0.25;
% U = t.*U;
% V = (1./t).*V;

Unorm = sum(U(:).^2);
Vnorm = sum(V(:).^2);
regobj =  (lambda/2).*(Unorm + Vnorm);
%regobj = lambda.*( sum(U(:).^2) + sum(V(:).^2) )./2; % [scalar]

U = sparse(U);
V = sparse(V);

dU = lambda.*U;
dV = lambda.*V;

X = U*V';

lossObj = 0;

% BZ =  Y .* X ;
% lossObj = lossObj + sum(sum(h(BZ) .* (Y ~= 0)));
% tmp = hprime(BZ) ;
% clear BZ;
% dU = dU + ( (tmp .* Y) * V );
% dV = dV + ( (tmp' .* Y') * U );



% YMX = (Y-X).*(Y~=0);
% dU = dU - YMX*V;
% dV = dV - YMX'*U;
% lossSquare = 0.5.*sum(sum(YMX.^2));
% lossObj = lossObj + lossSquare;


parfor batchNo=1:maxBatch
    batch = batchWisePairs{batchNo};
    noOfSample = length(batch);
    UVminusUV = zeros(n,noOfSample);
    VminusV = zeros(noOfSample,p);
    userInSamplesFlag = zeros(n, noOfSample);
    itemInSamplesFlag = zeros(noOfSample, m);  
    for sampleNo=1:noOfSample
        key = batch{sampleNo};
        %fprintf('\n%s', key);
        itemPair = itemInPair(key);
        %UVminusUV(:,sampleNo) = X(:,itemPair(1)) - X(:,itemPair(2));
        %VminusV(sampleNo,:) = V(itemPair(1),:) - V(itemPair(2),:);
        UVminusUV(:,sampleNo) = X(:,itemPair(2)) - X(:,itemPair(1));
        VminusV(sampleNo,:) =   V(itemPair(2),:) - V(itemPair(1),:);
        userVec = pairWiseUser(key);
        userInSamplesFlag(userVec',sampleNo) =  1;
        itemInSamplesFlag(sampleNo,itemPair(1)) = -1;
        itemInSamplesFlag(sampleNo,itemPair(2)) = 1;
    end
    itemInSamplesFlag = sparse(itemInSamplesFlag);
    userInSamplesFlag = sparse(userInSamplesFlag);
    
    lossInBatch = sum(sum(h(UVminusUV -alpha).*userInSamplesFlag));
    lossObj = lossObj + lossInBatch;
    
    dH = hprime(UVminusUV -alpha).*userInSamplesFlag;
    %dH = hprime(UVminusUV -alpha);    
    
    dU = dU +  dH * VminusV;
    
    tmp = dH*(itemInSamplesFlag);
    dV = dV +  tmp'*U;    
end



%clear X

obj = regobj + lossObj;
grad = [dU(:) ; dV(:)];
clear dU dV regobj;


function [ret] = h(z)
zin01 = (z>0)-(z>=1);
zle0 = z<0;
ret = ( ( (zin01./2 - zin01.*z ) + zin01.*z.^2./2 ) + zle0./2 ) - zle0.*z;
clear zin01 zle0


function [ret] = hprime(z)
zin01 = (z>0)-(z>=1);
zle0 = z<0;
ret = zin01.*z - zin01 - zle0;
clear zin01 zle0

