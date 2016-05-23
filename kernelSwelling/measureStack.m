function [S A] = measureStack(Stack,BOX,mainBOX,numtoMeasure,numCOLS,SKIP,disp)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                measureStack.m is 
                
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                getCenters.m, realignCenters.m, getKernelImage.m, getKernelArea.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                Stack:
                BOX:
                mainBOX:
                numtoMeasure:
                numCOLS:
                SKIP:
                disp:
    Output Variable Definition:
                S:
                A:

                fileName:       An image to be analyze in a string that includes path and file name.
                oPath:          A path to result of analysis in a string that includes '/'.
                rawImage_scaleFactor:   A desired percentage to resize the image.
                checkBlue_scaleFactor:  A desired percentage to resize the image in checkBlue.
                defaultAreaPix: The default pixel to be considered noise relative to 1200 dpi.
                addcut:         The boarder handle for checkBlue. This is an addition to blue top computed in checkBlue.
                baselineBlue:   The baseline threshold to remove blue header in checkBlue.
                fill:           The radius of disk for Kernel of an image close operation.
                toSave:         0 - not to save, 1 - to save.
                toDisplay:      0 - not to save, 1 - to save.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    try
        % create figures for display
        if disp
            h1 = figure;
            h2 = figure;
        else
            h1 = [];
            h2 = [];
        end

        % get the centers of the kernels
        C = getCenters(Stack{1},mainBOX);
        C = realignCenters(Stack{1},C,BOX);  

        % call to manual crop if centers are not found
        if isempty(C) | mod(size(C,1),numCOLS) ~= 0
            I = imread(Stack{1});
            [I mainBOX] = imcrop(I);
            C = getCenters(Stack{1},mainBOX);
        end

        % measure all if numtoMeasure is less than 0
        if numtoMeasure < 0
            numtoMeasure = numel(Stack);
        end


        % loop over the centers
        parfor e = 1:size(C,1)
            try
               cnt = 1;
               tS = [];
               boundary = {};
               F = {};
               for img = 1:SKIP:numtoMeasure
                    I = getKernelImage(Stack{img},C(e,:),BOX);
                    [boundary{cnt} currentArea] = getKernelArea(I,10^4);
                    tS(cnt) = currentArea;
                    if disp
                        figure(h1);
                        imshow(I,[])
                        hold on
                        plot(boundary{cnt}(:,2),boundary{cnt}(:,1),'r');
                        hold off
                        figure(h2);
                        plot(calcPercentSwelling(tS));
                    end
                    cnt = cnt +1;
                    fprintf(['Done with kernel:' num2str(e) ':' num2str(size(C,1)) ':image:' num2str(img) '\n']);
               end

               A{e} = tS;
               fprintf(['Done with kernel:' num2str(e) '\n']);
            catch ME
                fprintf(['Error on kernel:' num2str(e) '\n']);
                A{e} = zeros(1,numel(Stack));
            end
        end
        A = cell2mat(A');
        for e = 1:size(A,1)
            S(e,:) = calcPercentSwelling(A(e,:),3);
        end
        close all;
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:measureStack.m******\n']);
    end
end