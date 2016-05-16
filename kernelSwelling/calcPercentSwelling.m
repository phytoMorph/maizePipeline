function [S] = calcPercentSwelling(A,numInit)
    if nargin == 1
        numInit = 1;
    end
    initA = mean(A(:,1:numInit),2);
    A = bsxfun(@minus,A,initA);
    S = bsxfun(@times,A,initA.^-1);    
end