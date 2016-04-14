function [] = bayesianBurn(contours,initGuess)
    Kpara{1} = [10:100];
    for e = 1:numel(contours)
        D1 = getKurvatureDistribution(contours,initGuess,Kpara);
    end

end

function [] = getKurvatureDistribution(contours,initGuess,para)
    for e = 1:numel(contours)        
        out = cwtK_closed_imfilter(contours{e},para);
        out.K
    end
end