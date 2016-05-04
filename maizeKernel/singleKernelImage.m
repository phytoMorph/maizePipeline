function [] = singleKernelImage(fileName,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,addcut,baselineBlue,toSave,toDisplay)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                singleKernelImage.m is main function to handle kernel analysis. It takes all input variables 
                for its dependent functions. (Inputs are relative to 1200dpi)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                StoN.m, checkBlue.m, getThresholdLevel.m, getInitialGuessForTip.m,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                fileName:       An image to be analyze in a string that includes path and file name.
                oPath:          A path to result of analysis in a string that includes '/'.
                rawImage_scaleFactor:   A desired percentage to resize the image.
                checkBlue_scaleFactor:  A desired percentage to resize the image in checkBlue.
                addcut:         The boarder handle for checkBlue. This is an addition to blue top computed in checkBlue.
                baselineBlue:   The baseline threshold to remove blue header in checkBlue.
                toSave:         0 - not to save, 1 - to save.
                toDisplay:      0 - not to save, 1 - to save.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    versionString = ['Starting kernel analysis algorithm. \nPublication Version 1.0 - Monday, March 28, 2016. \n'];
    fprintf(versionString);
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
        checkBlue_scaleFactor = StoN(checkBlue_scaleFactor);
        rawImage_scaleFactor = StoN(rawImage_scaleFactor);
        addcut = StoN(addcut);
        baselineBlue = StoN(baselineBlue);
        %%%%%%%%%%%%%%%%%%%%%%%
        % print out the fileName, number of ears, output path
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['FileName:' fileName '\n']);
        fprintf(['OutPath:' oPath '\n']);
        fprintf(['Image resize in checkBlue:' num2str(checkBlue_scaleFactor) '\n']); 
        fprintf(['Raw image resize:' num2str(rawImage_scaleFactor) '\n']);  
        fprintf(['The boarder handle for checkBlue:' num2str(addcut) '\n']);
        fprintf(['Baseline threshold to remove blue header:' num2str(baselineBlue) '\n']);
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
        [dB] = findTipPoints_fast(dB,B,I);
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