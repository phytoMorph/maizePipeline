% path to resolution test images
% '/mnt/snapper/Lee/maizeData_resTest'
% order input variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% wrapper function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mecka(algorithm,fileName,numberOfObjects,oPath,toSave,toDisplay,scanResolution,rawImage_scaleFactor)
% for cob
oPutC = '/mnt/snapper/Lee/maizeData_resTest_Result/cobData_Result/';
I800C = '/mnt/snapper/Lee/maizeData_resTest/cobData/MN03-160129-0054-800.tif';
I600C = '/mnt/snapper/Lee/maizeData_resTest/cobData/MN03-160129-0054-600.tif';
I300C = '/mnt/snapper/Lee/maizeData_resTest/cobData/MN03-160129-0054-300.tif';
mecka('c',I800C,3,oPutC,1,1,800);
mecka('c',I600C,3,oPutC,1,1,600);
mecka('c',I300C,3,oPutC,1,1,300);

% for ear
oPutE = '/mnt/snapper/Lee/maizeData_resTest_Result/earData_Result/';
I800E = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-800.tif'
I600E = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-600.tif'
I300E = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-300.tif'
mecka('e',I800E,3,oPutE,1,1,800);
mecka('e',I600E,3,oPutE,1,1,600);
mecka('e',I300E,3,oPutE,1,1,300);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cob function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oPutC = '/mnt/snapper/Lee/maizeData_resTest_Result/cobData_Result/';
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

singleKernelImage(fileName,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,addcut,baselineBlue,fill,toSave,toDisplay)
singleKernelImage(I600K,oPutK,1,.25,50000/2,100/2,600/2,31,1,1);