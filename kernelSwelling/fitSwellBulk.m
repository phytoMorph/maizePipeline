function [p ep er] = fitSwellBulk(d,ft)
    numberOfVariables = 2;
    options = optimset('MaxFunEvals',3000*numberOfVariables,'TolFun',10^-6);
    for tr = 1:size(d,2)        
        %[p(tr,:) er(tr)] = fminsearch(@(X)mySwellFit(d(:,tr),X),[10^4 .01]);
        [p(tr,:) er(tr) ef(tr) output{tr}] = fminsearch(@(X)mySwellFit(d(:,tr)',X),[.2 .01],options);
        ep(tr,:) = func(p(tr,1),p(tr,2),0:(ft-1));
    end
end