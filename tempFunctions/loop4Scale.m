function [setS] = loop4Scale(fileName,noe,oPath,numLoop)
    %{
        loop4Scale is to test theory that there is a linear relation
        between fraction of resolution relative to base resolution and
        result of average_WIDTH. (Area added)
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Variable Definition
    %{
    fileName: An image to be analyze in a string that includes path and file name.
    noe: Number of cobs that are expected to be analyzed. 
    oPath: A path to result of analysis in a string that includes '/'.
    numLoop: Number of iteration wanted.
    
    checkBlue_scaleFactor: A desired percentage to resize the image in checkBlue.
    rawImage_scaleFactor: A desired percentage to resize the image.
    defaultAreaPix: The default pixel to be considered noise relative to 1200 dpi.
    fracDpi: The fraction relative to 1200 dpi.
    rho: The radius of color circle, relative to 1200 dpi.
    addcut: The boarder handle for checkBlue. This is an addition to blue top computed in checkBlue.
    baselineBlue: The baseline threshold to remove blue header in checkBlue.
    colRange1: The color range for back ground to be removed in getcobMask.
    colRange2: The color range for back ground to be removed in getcobMask.
    fill: The radius of disk for Kernel of an image close operation.
    toSave: 0 - not to save, 1 - to save.
    toDisplay: 0 - not to save, 1 - to save.
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try    
        %%%%%%%%%%%%%%%%%%%%%%%
        % print out the input variables
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['FileName:' fileName '\n']);
        fprintf(['Number of Ears:' num2str(noe) '\n']);
        fprintf(['Number of iteration:' num2str(numLoop) '\n']);
        fprintf(['OutPath:' oPath '\n']);
        numLoop = StoN(numLoop);
        setS = zeros(numLoop,7,'single');
        %setD = zeros(numLoop,1,'single');
        for e = 1:numLoop
            div = StoN(e);
            % below .2 does not work
            scale = .2 + (0.8/numLoop)*div;
            S = wrap4Cob(fileName,noe,oPath,scale);
            % width
            setS(e,1:3) = S.average_WIDTH;
            setS(e,4) = scale;
            % area = sum of width profile
            setS(e,5:7) = sum(S.widthProfile,2);
        end 
        %S = wrap4Cob(I800,noe,oPutC,0.18);
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:loop4Scale.m******\n']);
    end
end

%{
    [setS] = loop4Scale(I800,noe,oPutC,20);
%}