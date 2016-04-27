function [] = mecka(algorithm,fileName,numberOfObjects,oPath,toSave,toDisplay,scanResolution,rawImage_scaleFactor)
    if nargin ~= 6
        rawImage_scaleFactor = 1;
    end
    
  
  
    % set to default value of .25
    checkBlue_scaleFactor = .25;
    switch algorithm
        case 'e'
            
        case 'c'
            % set to default value of 10^6
            defaultAreaPix = 10^6;
            singleCobImage(fileName,numberOfObjects,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,fracDpi,rho,addcut,baselineBlue,colRange1,colRange2,fill,toSave,toDisplay)
        case 'k'
            
    end
end