function [S] = wrap4Cob(fileName,noe,oPath,rawImage_scaleFactor)
    %{
    %}
    try
% This function takes inputs and compute relative inputs with fraction
% Get resolution of the image frosingleCobImagem its filename
[pth nm ext] = fileparts(fileName);
% Expect same filename format
% i.e. 'MN03-160125-0026-300.tif'
        nums = regexp(nm,'-','split');
        res = nums(end);
        res = cell2mat(res);
        %baseRes = 1200;
        baseRes = 800;
        res = StoN(res);
        baseRes = StoN(baseRes);
        rawImage_scaleFactor = StoN(rawImage_scaleFactor);
        fracDpi = round(baseRes/res);
        fracDpi = round(fracDpi/rawImage_scaleFactor);
        [S] = singleCobImage(fileName,noe,oPath,rawImage_scaleFactor,1,1000000,fracDpi,300,100,600,70,166,50,0,0);
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:wrap4Cob.m******\n']);
    end
end

%{
singleCobImage(fileName,noe,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,
defaultAreaPix,fracDpi,rho,addcut,baselineBlue,colRange1,colRange2,fill,
toSave,toDisplay)

singleCobImage(I800,3,oPut,1,.25,1000000,2,300/2,100/2,600,70,166,50,1,1);

wrap4Cob([]@singleCobImage(),fileName,noe,oPath,rawImage_scaleFactor)
%}