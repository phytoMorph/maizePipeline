% path to resolution test images
% '/mnt/snapper/Lee/maizeData_resTest'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cob function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 300 dpi
% 600 dpi
% 800 dpi
singleCobImage(fileName,noe,oPath,checkBlue_scaleFactor,rawImage_scaleFactor,
defaultAreaPix,fracDpi,rho,addcut,baselineBlue,colRange1,colRange2,fill,
toSave,toDisplay)

singleCobImage(I800,3,oPut,.25,1,1000000,2,300/2,100/2,600,70,166,50,1,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ear function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 300 dpi
I300 = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160122-0008-300.tif'
% 800 dpi
I800 = '/mnt/snapper/Lee/maizeData_resTest/earData/MN03-160122-0008-800.tif'
[KernelLength sM] = singleEarImage(fileName,noe,oPath,defaultAreaPix,
fracDpi,checkBlue_scaleFactor,addcut,baselineBlue,toSave,toDisplay)
[KernelLength sM] = singleEarImage(I800,3,oPut,1000000,2,.25,100/2,600,1,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% kernel function %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
