function [] = mecka(algorithm,fileName,numberOfObjects,oPath,toSave,toDisplay,scanResolution,rawImage_scaleFactor)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                mecka.m is wrapper function to handle Maize Ear Cob Kernel Analysis. A users are 
                to choose one of three algorithm to use. (Inputs are relative to 1200dpi)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                StoN.m, singleCobImage.m, singleEarImage.m, singleKernelImage.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                algorithm:      The argorithm to use. 'c' for singleCobImage.m, 'e' for singleEarImage.m, and 'k' for singleKernelImage.m
                fileName:       An image to be analyze in a string that includes path and file name.
                numberOfObjects:            Number of cobs that are expected to be analyzed. 
                oPath:          A path to result of analysis in a string that includes '/'.
                toSave:         0 - not to save, 1 - to save.
                toDisplay:      0 - not to save, 1 - to save.
                scanResolution: The resolution that image was scanned in DPI. 
                rawImage_scaleFactor:   A desired percentage to resize the image. If no input, default is 1, noresizing.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    if nargin ~= 6
        % set to default value of 1
        rawImage_scaleFactor = 1;
    end
    % set to default value of 1200
    defaultResolution = 1200;
    scanResolution = StoN(scanResolution);
    % compute proportion of resolution over default
    fracDpi = scanResolution/defaultResolution;
    
  
  
    % set to default value of .25
    checkBlue_scaleFactor = .25;
    switch algorithm
        case 'e'
            
        case 'c'
            % set to default value of 10^6
            defaultAreaPix = 10^6;
            defaultAreaPix = round(defaultAreaPix/fracDpi);
            % set to default value of 300
            rho = 300;
            rho = round(rho/fracDpi);
            % set to default value of 100
            addcut = 100;
            addcut = round(addcut/fracDpi);
            % set to default value of 600
            baselineBlue = 600;
            baselineBlue = round(baselineBlue/fracDpi);
            % set to default value of 70
            colRange1 = 70;
            % set to default value of 166
            colRange2 = 166;
            % set to default value of 50
            fill = 50;
            singleCobImage(fileName,numberOfObjects,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,rho,addcut,baselineBlue,colRange1,colRange2,fill,toSave,toDisplay)
        case 'k'
            
    end
end

%{
April 27 2016
1. clean main functions.
2. fill this function
3. headers
%}