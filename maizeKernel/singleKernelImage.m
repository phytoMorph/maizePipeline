function [] = singleKernelImage(fileName,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,addcut,baselineBlue,toSave,toDisplay)
    versionString = ['Starting kernel analysis algorithm. \n Publication Version 1.0 - Monday, March 28, 2016. \n'];
    fprintf(versionString);
    %{  
        April 19 2016
        par removed
    %}
    %{
    fileName: An image to be analyze in a string that includes path and file name.
    noe: Number of cobs that are expected to be analyzed. 
    oPath: A path to result of analysis in a string that includes '/'.
    checkBlue_scaleFactor: A desired percentage to resize the image in checkBlue.
    rawImage_scaleFactor: A desired percentage to resize the image.
    defaultAreaPix: The default pixel to be considered noise relative to 1200 dpi.
    fracDpi: The fraction relative to 1200 dpi.
    rho: The radius of color circle, relative to 1200 dpi.
    addcut: The boarder handle for checkBlue. This is an addition to blue top computed in checkBlue.
    baselineBlue: The baseline threshold to remove blue header in checkBlue.
    colRange1: The color range for back ground to be removed in getcobMask.
    colRange2: The color range for back ground to be removed in getcobMask.
    fill: The radius of disk for Kernel of an image close operation.
    CHUNK: The number of chunk for input for FFT in myBlock0;
    toSave: 0 - not to save, 1 - to save.,checkBlue_scaleFactor,addcut,baselineBlue
    toDisplay: 0 - not to save, 1 - to save.
    %}
    %%%%%%%%%%%%%%%%%%%%%%%
    % init vars
    MAJOR = [];
    MINOR = [];
    toSaveContour = [];
    %%%%%%%%%%%%%%%%%%%%%%%
    try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % INIT VARS - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting with variable and environment initialization.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%
        % init the icommands
        %%%%%%%%%%%%%%%%%%%%%%%
        initIrods();
        %%%%%%%%%%%%%%%%%%%%%%%
        % convert the strings to numbers if they are strings
        %%%%%%%%%%%%%%%%%%%%%%%
        %noe = StoN(noe);
        checkBlue_scaleFactor = StoN(checkBlue_scaleFactor);
        rawImage_scaleFactor = StoN(rawImage_scaleFactor);
        %fracDpi = StoN(fracDpi);
        addcut = StoN(addcut);
        %defaultAreaPix = StoN(defaultAreaPix);
        baselineBlue = StoN(baselineBlue);
        %colRange1 = StoN(colRange1);
        %colRange2 = StoN(colRange2);
        %fill = StoN(fill);
        %CHUNK = StoN(CHUNK);
        %%%%%%%%%%%%%%%%%%%%%%%
        % print out the fileName, number of ears, output path
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['FileName:' fileName '\n']);
        %fprintf(['Number of Ears:' num2str(noe) '\n']);
        fprintf(['OutPath:' oPath '\n']);
        fprintf(['Image resize in checkBlue:' num2str(checkBlue_scaleFactor) '\n']); 
        fprintf(['Raw image resize:' num2str(rawImage_scaleFactor) '\n']);  
        %fprintf(['Threshold noise size:' num2str(defaultAreaPix) '\n']);
        %fprintf(['Fraction relative to 1200 dpi:' num2str(fracDpi) '\n']);  
        %fprintf(['The radius of color circle:' num2str(rho) '\n']);
        fprintf(['The boarder handle for checkBlue:' num2str(addcut) '\n']);
        fprintf(['Baseline threshold to remove blue header:' num2str(baselineBlue) '\n']);
        %fprintf(['Background Color Range I:' num2str(colRange1) '\n']);
        %fprintf(['Background Color Range II:' num2str(colRange2) '\n']);
        %fprintf(['The radius of disk for closing:' num2str(fill) '\n']);
        %fprintf(['The number of chunk of blocks for FFT:' num2str(CHUNK) '\n']);

        %%%%%%%%%%%%%%%%%%%%%%%
        % get the file parts
        %%%%%%%%%%%%%%%%%%%%%%%
        [pth nm ext] = fileparts(fileName);
        %%%%%%%%%%%%%%%%%%%%%%%
        % make output directory
        %%%%%%%%%%%%%%%%%%%%%%%
        mkdir(oPath);
        [pth nm ext] = fileparts(fileName);
        fprintf(['starting with variable and environment initialization.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%
        % read the image and take off the blue strip for bar code
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting with image load.\n']);
        %%add resize 
        I = imread(fileName);
        % TO REMOVE WAS 100 second arg
        % rawImage_scaleFactor to lower 'DPI' effect, by fraction 
        I = imresize(I,rawImage_scaleFactor);
        I = checkBlue(I,checkBlue_scaleFactor,addcut,baselineBlue);
        %I = checkBlue(I);
        fprintf(['ending with image load.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % INIT VARS - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ANALYSIS - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                       
        fprintf(['starting with image analysis\n']);
        %%%%%%%%%%%%%%%%%%%%%%%
        % main part of code - threshold,filter and count
        % get the threshold level
        [level,G] = getThresholdLevel(I);        
        % threshold the image
        B = single(G) > level;        
        % remove small objects
        %%take out constant
        B = bwareaopen(B,50000);                
        % fill holes
        B = imfill(B,8,'holes');
        % remove objects connected to the kernel and are thin
        B = imopen(B,strel('disk',31,8));
        % fill holes
        B = imfill(B,4,'holes');
        % re-remove small objects
        B = bwareaopen(B,50000);        
        % measure region props
        R = regionprops(B,'Area','MajorAxis','MinorAxis','Image','Centroid','Orientation','Eccentricity');
        % stack the area
        AREA = [R.Area];
        [fidx sel uA] = count(AREA);
        AREA = AREA(fidx);
        % get the kernel count
        KC = sum(fidx);
        %%%%%%%%%%%%%%%%%%%%%%%
        % boundary analysis        
        dB = bwboundaries(B);
        % select boundaries of single kernels
        dB = dB(fidx);
        [tipPoint dB] = getInitialGuessForTip(dB);
        [dB] = findTipPoints_fast(dB,B,I,toDisplay);
        
        dB = Econtour(dB,B,I);
        [M] = getKernelMeasurements(B,dB);
        MAJOR = [M.MajorLength];
        MINOR = [M.MinorLength];
        toSaveContour = [];
        for e = 1:numel(M)
            toSaveContour = [toSaveContour M(e).iContour(:)];
        end
        
        
        
        
        fprintf(['ending with image analysis\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ANALYSIS - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DISLAY - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        if toDisplay
            renderResults(M,I,KC);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DISLAY - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if toSave
            fprintf(['starting save phase \n']);
            % write out csv data
            csvwrite([oPath nm '-indiv.csv'],[MAJOR' MINOR' AREA']);
            csvwrite([oPath nm '.csv'],[mean(MAJOR) std(MAJOR) mean(MINOR) std(MINOR) mean(AREA) std(AREA) KC]);
            csvwrite([oPath nm '-contours.csv'],toSaveContour');
            saveas(gca,[oPath nm '.tif']);
            fprintf(['ending save phase \n']);
        end
        toc;
        close all;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    catch ME
        close all;
        getReport(ME)
    end
end


%{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compile_directory = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeKernel/tmpSubmitFiles/';
    CMD = ['mcc -d ' compile_directory ' -m -v -R -singleCompThread singleKernelImage.m'];
    eval(CMD);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % single kernel call
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    singleFile = '/mnt/spaldingdata/nate/mirror_images/maizeData/gxe/kernelData/2-17-15-Scan2k/Scan2-150217-0142.tif';
    singleKernelImage(singleFile,'./output/',1,1);
   
%}