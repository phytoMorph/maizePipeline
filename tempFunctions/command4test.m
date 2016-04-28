% path to resolution test images
% '/mnt/snapper/Lee/maizeData_resTest'
% order input variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% wrapper function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mecka(algorithm,fileName,numberOfObjects,oPath,toSave,toDisplay,scanResolution,rawImage_scaleFactor)
mecka('c',I800,3,oPutC,1,1,800);
singleCobImage(I800,3,oPut,1,.25,1000000,2,300/2,100/2,600,70,166,50,1,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cob function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 300 dpi
% 600 dpi
% 800 dpi
I800 = '/mnt/snapper/Lee/maizeData_resTest/cobData/MN03-160129-0054-800.tif';
singleCobImage(fileName,noe,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,
defaultAreaPix,fracDpi,rho,addcut,baselineBlue,colRange1,colRange2,fill,
toSave,toDisplay)

singleCobImage(I800,3,oPut,1,.25,1000000,2,300/2,100/2,600,70,166,50,1,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ear function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oPutE = '/mnt/snapper/Lee/maizeData_resTest_Result/earData_Result/';

% 300 dpi
I300 = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-300.tif';
% 600 dpi
I600 = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-600.tif'
% 800 dpi
I800E = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-800.tif'
[KernelLength sM] = singleEarImage(fileName,noe,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,
fracDpi,addcut,baselineBlue,fill,CHUNK,toSave,toDisplay)
[KernelLength sM] = singleEarImage(I800E,3,oPutE,1,.25,1000000,2,100/2,600/2,31,10,1200/2,12,800,1,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% kernel function %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oPutK = '/mnt/snapper/Lee/maizeData_resTest_Result/kernelData_Result/'

I300K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-300.tif'
I600K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-600.tif'
I800K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-800.tif'

singleKernelImage(fileName,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,addcut,baselineBlue,toSave,toDisplay)
singleKernelImage(I800K,oPutK,1,.25,100/2,600,1,1);