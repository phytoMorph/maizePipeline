function [S] = singleCobImage(fileName,noe,oPath,rPath,rawImage_scaleFactor,checkBlue_scaleFactor,defaultAreaPix,rho,addcut,baselineBlue,colRange1,colRange2,fill,toSave,toDisplay)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                singleCobImage.m is main function to handle cob analysis. It takes all input variables 
                for its dependent functions. This function returns final result including image with 
                bounding box and color circle. (Inputs are relative to 1200dpi)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                StoN.m, checkBlue.m, maizeCob.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                fileName:       An image to be analyze in a string that includes path and file name.
                noe:            Number of cobs that are expected to be analyzed. 
                oPath:          A path to result of analysis in a string that includes '/'.
                checkBlue_scaleFactor:  A desired percentage to resize the image in checkBlue.
                rawImage_scaleFactor:   A desired percentage to resize the image.
                defaultAreaPix: The default pixel to be considered noise relative to 1200 dpi.
                rho:            The radius of color circle, relative to 1200 dpi.
                addcut:         The boarder handle for checkBlue. This is an addition to blue top computed in checkBlue.
                baselineBlue:   The baseline threshold to remove blue header in checkBlue.
                colRange1:      The color range for back ground to be removed in getcobMask.
                colRange2:      The color range for back ground to be removed in getcobMask.
                fill:           The radius of disk for Kernel of an image close operation.
                toSave:         0 - not to save, 1 - to save.
                toDisplay:      0 - not to save, 1 - to save.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    versionString = ['Starting cob analysis algorithm. \nPublication Version 1.0 - Monday, March 28, 2016. \n'];
    fprintf(versionString);
    totalTimeInit = clock;
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
        noe = StoN(noe);
        checkBlue_scaleFactor = StoN(checkBlue_scaleFactor);
        rawImage_scaleFactor = StoN(rawImage_scaleFactor);
        defaultAreaPix = StoN(defaultAreaPix);       
        rho = StoN(rho);
        addcut = StoN(addcut);    
        baselineBlue = StoN(baselineBlue);
        colRange1 = StoN(colRange1);
        colRange2 = StoN(colRange2);
        fill = StoN(fill);
        %%%%%%%%%%%%%%%%%%%%%%%
        % print out the input variables
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['FileName:' fileName '\n']);
        fprintf(['Number of Ears:' num2str(noe) '\n']);
        fprintf(['OutPath:' oPath '\n']);     
        fprintf(['Image resize in checkBlue:' num2str(checkBlue_scaleFactor) '\n']); 
        fprintf(['Raw image resize:' num2str(rawImage_scaleFactor) '\n']);  
        fprintf(['Threshold noise size:' num2str(defaultAreaPix) '\n']);
        fprintf(['The radius of color circle:' num2str(rho) '\n']);
        fprintf(['The boarder handle for checkBlue:' num2str(addcut) '\n']);
        fprintf(['Baseline threshold to remove blue header:' num2str(baselineBlue) '\n']);
        fprintf(['Background Color Range I:' num2str(colRange1) '\n']);
        fprintf(['Background Color Range II:' num2str(colRange2) '\n']);
        fprintf(['The radius of disk for closing:' num2str(fill) '\n']);
        %%%%%%%%%%%%%%%%%%%%%%%
        % make output directory
        %%%%%%%%%%%%%%%%%%%%%%%
        mkdir(oPath);
        [pth nm ext] = fileparts(fileName);
        fprintf(['ending with variable and environment initialization.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%
        % read the image and take off the blue strip for bar code
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting with image load.\n']);
        I = imread(fileName);
        % rawImage_scaleFactor to lower 'DPI' effect, by fraction
        % If resize factor is 1, do not excecute imresize
        if rawImage_scaleFactor ~= 1;I = imresize(I,rawImage_scaleFactor);end
        % check blue header and remove
        I = checkBlue(I,checkBlue_scaleFactor,addcut,baselineBlue);
        fprintf(['ending with image load.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % INIT VARS - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ANALYSIS - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        % main measurement code call
        fprintf(['starting with image analysis \n']);
        % convert to single
        %I = single(I)/255;
        % run the analysis
        [BB S] = maizeCob(I,noe,defaultAreaPix,colRange1,colRange2,fill);
        % stack the results from the bounding box
        DATA = [];
        for b = 1:numel(BB)                
            DATA = [DATA;[BB{b}(3:4) S.average_WIDTH(b)]];        
        end    
        DATA = reshape(DATA',[1 numel(DATA)]);
        fprintf(['ending with image analysis \n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ANALYSIS - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DISLAY - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        if toDisplay
            fprintf(['starting with image and results display \n']);
            h = image(I);
            hold on
            % make rectangle around the cob
            for b = 1:numel(BB)
                rectangle('Position',BB{b},'EdgeColor','r');
                UR = BB{b}(1:2);
                UR(1) = UR(1) + BB{b}(3);
                rectangle('Position',[UR rho rho],'EdgeColor','none','Curvature',[1 1],'FaceColor',S.RGB(b,:)/255);
            end
            %%%%%%%%%%%%%%%%%%%%%%%
            % format the image
            axis equal;axis off;drawnow;set(gca,'Position',[0 0 1 1]);
            fprintf(['ending with image and results display \n']);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DISLAY - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        if toSave
            fprintf(['starting save phase \n']);
            % save image
            imageFile = [oPath nm '_result.tif' ];
            saveas(h,imageFile);
            % save mat file
            matFile = [oPath nm '.mat'];
            save(matFile,'BB','fileName','S');
            % save the global parameters in file
            csvOut = [oPath nm '.csv'];
            csvwrite(csvOut,DATA);
            % save the width parameters
            csvOut = [oPath nm '_width_results.csv'];
            csvwrite(csvOut,S.widthProfile);
            % save the colror values
            csvOut = [oPath nm '_cobRGB.csv'];
            csvwrite(csvOut,S.RGB);
            fprintf(['ending save phase \n']);
        end
        close all;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:singleCobImage.m******\n']);
    end
    fprintf(['Total Running Time: ' num2str(etime(clock,totalTimeInit)) '\n']);
    versionString = ['Ending cob analysis algorithm. \nPublication Version 1.0 - Monday, March 28, 2016. \n'];
    fprintf(versionString);
end
%{

    TODO: 
    %%We need to handle reporting. For now if the number of cobs to find is
    %%three and the number of cobs to be found is two, no error message. If
    %%no cobs were found, we still get image from checkblue and error
    %%message. addcut value is reponsible for cutting off blue top from
    %%the image in checkblue.    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compile_directory = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeCob/tmpSubmitFiles/';
    CMD = ['mcc -d ' compile_directory ' -m -v -R -singleCompThread singleCobImage.m'];
    eval(CMD);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % run local copy
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fileName ='/iplant/home/garf0012/maizeData/cobData/HOF_NIL/IA01-151210/IA01-151210-0005.tif';
    singleCobImage(fileName,3,[],0,0);
    singleCobImage(fileName,3,oPut,1,1,1000000,4,300/4,100/4,600,70,166,50,1,1);
%}