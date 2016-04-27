function [S] = wrap(fileName,noe,oPath,rawImage_scaleFactor)
    %{
        wrap4Cob is to handle singleCobImage. FracDpi will be computed and
        other relative variables will be adjusted. 
        Decision of base resolution needed.
        Universiality of wrapper function is considered.
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Variable Definition
    %{
    fileName: An image to be analyze in a string that includes path and file name.
    noe: Number of cobs that are expected to be analyzed. 
    oPath: A path to result of analysis in a string that includes '/'.
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
% This function takes inputs and compute relative inputs with fraction
% Get resolution of the image frosingleCobImagem its filename
[pth nm ext] = fileparts(fileName);
% Expect same filename format
% i.e. 'MN03-160125-0026-300.tif'
        nums = regexp(nm,'-','split');
        % get resolution for the current image 
        res = nums(end);
        res = cell2mat(res);
        %baseRes = 1200;
        baseRes = 800;
        res = StoN(res);
        baseRes = StoN(baseRes);
        rawImage_scaleFactor = StoN(rawImage_scaleFactor);
        fracDpi = round(baseRes/res);
        fracDpi = round(fracDpi/rawImage_scaleFactor);
        % return measured values
        [S] = singleCobImage(fileName,noe,oPath,rawImage_scaleFactor,1,1000000,fracDpi,300,100,600,70,166,50,0,0);
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:wrap4Cob.m******\n']);
        [setS] = loop4Scale(I800,noe,oPutC,20);
    end
end

%{
singleCobImage(fileName,noe,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,
defaultAreaPix,fracDpi,rho,addcut,baselineBlue,colRange1,colRange2,fill,
toSave,toDisplay)

singleCobImage(I800,3,oPut,1,.25,1000000,2,300/2,100/2,600,70,166,50,1,1);

wrap4Cob([]@singleCobImage(),fileName,noe,oPath,rawImage_scaleFactor)
%}