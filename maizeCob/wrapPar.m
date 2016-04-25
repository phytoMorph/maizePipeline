function [] = wrap4Cob(func,fileName,noe,oPath,rawImage_scaleFactor)
% This function takes inputs and compute relative inputs with fraction
% Get resolution of the image from its filename
[pth nm ext] = fileparts(fileName);
% Expect same filename format
% i.e. 'MN03-160125-0026-300.tif'
nums = regexp(nm,'-','split');
res = nums(end);
baseRes = 1200;
res = StoN(res);
baseRes = StoN(baseRes);
fracDpi = round(res/baseRes);
end