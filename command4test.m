% path to resolution test images
% '/mnt/snapper/Lee/maizeData_resTest'
% order input variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cob function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 300 dpi
% 600 dpi
% 800 dpi
singleCobImage(fileName,noe,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,
defaultAreaPix,fracDpi,rho,addcut,baselineBlue,colRange1,colRange2,fill,
toSave,toDisplay)

singleCobImage(I800,3,oPut,1,.25,1000000,2,300/2,100/2,600,70,166,50,1,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ear function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oPut = '/mnt/snapper/Lee/maizeData_resTest_Result/earData_Result/';

% 300 dpi
I300 = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-300.tif';
% 600 dpi
I600 = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-600.tif'
% 800 dpi
I800 = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160125-0026-800.tif'
[KernelLength sM] = singleEarImage(fileName,noe,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,
fracDpi,addcut,baselineBlue,fill,CHUNK,toSave,toDisplay)
[KernelLength sM] = singleEarImage(I800,3,oPut,1,.25,1000000,2,100/2,600,31,10,1,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% kernel function %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oPutK = '/mnt/snapper/Lee/maizeData_resTest_Result/kernelData_Result/'

I300K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-300.tif'
I600K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-600.tif'
I800K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-800.tif'


singleKernelImage(I800K,oPutK,1,1);