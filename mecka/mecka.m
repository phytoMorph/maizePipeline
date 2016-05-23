function [] = mecka(algorithm,fileName,numberOfObjects,oPath,remotePath,toSave,toDisplay,scanResolution,rawImage_scaleFactor)
    % warnings will not be printed on screen.
    warning off
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                mecka.m is wrapper function to handle Maize Ear Cob Kernel Analysis. A user is 
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
    try
        %%%%%%%%%%%%%%%%%%%%%%%
        % add file separator if needed
        %%%%%%%%%%%%%%%%%%%%%%%
        if ~strcmp(oPath(end),filesep)
            oPath = [oPath filesep];
        end
       
        %%%%%%%%%%%%%%%%%%%%%%%
        % no resize if no input for rawImage_scaleFactor
        %%%%%%%%%%%%%%%%%%%%%%%
        if nargin ~= 8
            % set to default value of 1
            rawImage_scaleFactor = 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% common arguments for Ear, Cob and Kernel %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%
        % convert variables proportion to the resolution
        %%%%%%%%%%%%%%%%%%%%%%%
        % set to default value of 1200
        defaultResolution = 1200;
        scanResolution = StoN(scanResolution);
        % compute proportion of resolution over default
        fracDpi = scanResolution/defaultResolution;
        % set to default value of .25
        checkBlue_scaleFactor = .25;
        %fprintf(['Fraction relative to 1200 dpi:' num2str(fracDpi) '\n']); 
        % set to default value of 100
        addcut = 100;
        addcut = round(addcut*fracDpi);
        % set to default value of 600
        baselineBlue = 600;
        baselineBlue = round(baselineBlue*fracDpi);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%
        % algorithm selection
        %%%%%%%%%%%%%%%%%%%%%%%
        switch algorithm
            case 'e'
                % set to default value of 10
                CHUNK = 10;
                % set to default value of 10^6
                defaultAreaPix = 10^6;
                defaultAreaPix = round(defaultAreaPix*fracDpi);
                % set to default value of 31
                fill = 31;
                % set to default value of 1200:25:1600
                windowSize = round(1200*fracDpi):round(25*fracDpi):round(1600*fracDpi);
                [KernelLength sM] = singleEarImage(fileName,numberOfObjects,oPath,remotePath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,addcut,baselineBlue,fill,CHUNK,windowSize,toSave,toDisplay);
            case 'c'
                % set to default value of 10^6
                defaultAreaPix = 10^6;
                defaultAreaPix = round(defaultAreaPix*fracDpi);
                % set to default value of 300
                rho = 300;
                rho = round(rho*fracDpi);
                % set to default value of 70
                colRange1 = 70;
                % set to default value of 166
                colRange2 = 166;
                % set to default value of 50
                fill = 50;
                singleCobImage(fileName,numberOfObjects,oPath,remotePath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,rho,addcut,baselineBlue,colRange1,colRange2,fill,toSave,toDisplay);
            case 'k'
                numberOfObjects;
                % set to default value of 50000
                defaultAreaPix = 50000;
                defaultAreaPix = round(defaultAreaPix*fracDpi);
                % set to default value of 31
                fill = 31;
                singleKernelImage(fileName,oPath,remotePath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,addcut,baselineBlue,fill,toSave,toDisplay);                
        end
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:mecka.m******\n']);
    end
end

%{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compile_directory = '/mnt/scratch1/maizePipeline/mecka/tmpSubmitFiles/';
    mkdir(compile_directory)
    CMD = ['mcc -d ' compile_directory ' -a im2single.m -m -v -R -singleCompThread mecka.m'];
    eval(CMD);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % run local copy - for cob
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fileName = '/iplant/home/garf0012/maizeData/cobData/HOF_NIL/IA01-151210/IA01-151210-0005.tif';
    fileName = '/iplant/home/gxe/maizeData/cobData/1-26-16-Scan2c/Scan2-160126-0001.tif';
    fileName = '/iplant/home/gxe/maizeData/cobData/2-17-16-Scan2c/Scan2-160217-0047.tif';
    fileName = '/iplant/home/gxe/maizeData/cobData/2-9-16-Scan2c/Scan2-160209-0033.tif';
    
    oPath = '/mnt/scratch1/maizePipeline/testResults/';
    mecka('c',fileName,3,oPath,0,1,1200,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % run local copy - for ear
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fileName = '/mnt/snapper/Lee/code_2016/production/memory_use_producution/MatlabMemoryUse_verMarch012016/input/Scan1-160129-0043.tif';
    oPath = '/mnt/scratch1/maizePipeline/testResults/';    
    mecka('e',fileName,3,oPath,0,1,1200,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % run local copy - for kernel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Test destination for Lee use
    oPutK = '/mnt/snapper/Lee/maizeData_resTest_Result/kernelData_Result/'
    oPath = '/mnt/scratch1/maizePipeline/testResults/';
    I300K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-300.tif'
    I600K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-600.tif'
    I600K2 = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0007-600.tif'
    I600K3 = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0032-600.tif'
    I800K = '/mnt/snapper/Lee/maizeData_resTest/kernelData/MN02-160121-0014-800.tif'
    fileName = '/mnt/snapper/Lee/code_2016/production/memory_use_producution/MatlabMemoryUse_verMarch012016/input/Scan1-160129-0043.tif';       
    mecka('k',I600K,3,oPutK,1,1,600,1);
    This works though only 16 kernels were found.
    mecka('k',I300K,3,oPutK,1,1,240,1);
%}