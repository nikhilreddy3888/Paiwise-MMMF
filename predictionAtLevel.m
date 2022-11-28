function [RFinal, confusingEntriesConfi, confusingEntriesLabel] =...
    predictionAtLevel(RFinal,X,RcapTrn, margin, confusingEntriesConfi,confusingEntriesLabel, levelNo)

    [~,m] = size(RFinal);
    
    %theta = sum(X.*(RcapTrn~=0),2)./sum(RcapTrn~=0,2);
    ttlNegative = sum(RcapTrn==-1,2);
    ttlPositive = sum(RcapTrn==1,2);
    
    negativeMean = sum(X.*(RcapTrn==-1),2)./ttlNegative;   
    negativeMean(isnan(negativeMean)) = -1000;     
    
    positiveMean = sum(X.*(RcapTrn==1),2)./ttlPositive;
    positiveMean(isnan(positiveMean)) = 1000;
    %theta = (negativeMean + positiveMean)./2;

    ttlMargin = positiveMean-negativeMean;
    theta = negativeMean + (ttlMargin./(ttlPositive+ttlNegative)).*ttlNegative;
       
    T = theta*ones(1,m);    
    y = (X < T);
    T = T-margin;
    y1 =(X < T);
    
    RFinal(RFinal==0 & y1) = levelNo;
    
    confuseGainConfi = (confusingEntriesConfi~=0) & y1;
    confusingEntriesConfi(confuseGainConfi) = 0;
    confusingEntriesLabel(confuseGainConfi) = 0;   
    
    
    confusingEntries = y-y1;
    confusingEntries = confusingEntries & (RFinal==0);
    
    confidence = abs(T - X).*confusingEntries;
    tmp = confidence > confusingEntriesConfi;
    confusingEntriesConfi(tmp) = confidence(tmp);
    confusingEntriesLabel(tmp) = levelNo;
end