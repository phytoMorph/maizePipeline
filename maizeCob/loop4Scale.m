function [setS] = loop4Scale(fileName,noe,oPath,numLoop)
    %{
        loop4Scale is to test theory that there is a linear relation
        between fraction of resolution relative to base resolution and
        result of average_WIDTH. 
    %}
    try    
        numLoop = StoN(numLoop);
        setS = zeros(numLoop,4,'single');
        %setD = zeros(numLoop,1,'single');
        for e = 1:numLoop
            div = StoN(e);
            % below .2 does not work
            scale = .2 + (0.8/numLoop)*div;
            S = wrap4Cob(fileName,noe,oPath,scale);
            setS(e,1:3) = S.average_WIDTH;
            setS(e,4) = scale;
        end 
        %S = wrap4Cob(I800,noe,oPutC,0.18);
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:wrap4Cob.m******\n']);
    end
end

%{
    [setS] = loop4Scale(I800,noe,oPutC,20);
%}