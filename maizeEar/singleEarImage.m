function [KernelLength sM] = singleEarImage(fileName,noe,oPath,defaultAreaPix,fracDpi,checkBlue_scaleFactor,addcut,baselineBlue,toSave,toDisplay)
    %{
        April 14 2016
        1. copy and add variable info from cob func
        2. change same update first 
        3. make it work for 300 dpi
    %}
    versionString = ['Starting ear analysis algorithm. \nPublication Version 1.0 - Monday, March 28, 2016. \n'];
    fprintf(versionString);
    totalTimeInit = clock;
    %%%%%%%%%%%%%%%%%%%%%%%
    % init return vars    
    sM = [];   
    KernelLength = [];
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
        if ischar(noe)
            noe = str2num(noe);
        end
        if ischar(toSave)
            toSave = str2num(toSave);
        end
        %%%%%%%%%%%%%%%%%%%%%%%
        % print out the fileName, number of ears, output path
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['FileName:' fileName '\n']);
        fprintf(['Number of Ears:' num2str(noe) '\n']);
        fprintf(['OutPath:' oPath '\n']);
        %%%%%%%%%%%%%%%%%%%%%%%
        % make output directory
        %%%%%%%%%%%%%%%%%%%%%%%
        mkdir(oPath);
        [pth nm ext] = fileparts(fileName);
        fprintf(['ending with variable and environment initialization.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%
        % read the image and take off the blue strip for bar codedefaultAreaPix,fracDpi
        %%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting with image load.\n']);
        I = imread(fileName);
        I = checkBlue(I,checkBlue_scaleFactor,addcut,baselineBlue)
        %I = checkBlue(I);
        fprintf(['ending with image load.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % INIT VARS - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ANALYSIS - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                       
        fprintf(['starting with image analysis. \n']);
        % make the window sizes
        %%window size matters for dpi. It is based on 1200 dpi
        RAD = 1200:25:1600;
        % the number of down sample grid sites
        gridSites = 10;
        [KernelLength FT BB S MT] = measureKernelLength(I,noe,RAD,gridSites);        
        % average kernel height
        uT = nanmean(KernelLength,2);        
        DATA = [];             
        % gather the data together for the bounding box
        for b = 1:numel(BB)            
            DATA = [DATA;[BB{b}(3:4) S.average_WIDTH(b)]];
        end
        % for new format for saving
        DATA = [DATA uT];
        DATA = reshape(DATA',[1 numel(DATA)]);
        fprintf(['ending with image analysis. \n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ANALYSIS - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DISLAY - start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
        if toDisplay
            fprintf(['starting with image and results display \n']);
            %%%%%%%%%%%%%%%%%%%%%%%
            % display the results
            %%%%%%%%%%%%%%%%%%%%%%%
            h = image(I);
            hold on
            %%%%%%%%%%%%%%%%%%%%%%%
            % make rectangle around the cob and plot the cosine function
            %%%%%%%%%%%%%%%%%%%%%%%
            for b = 1:numel(BB)
                rectangle('Position',BB{b},'EdgeColor','r');
                CS = [1:BB{b}(4)] + BB{b}(2);
                Func = 100*cos(2*pi/uT(b)*CS) + BB{b}(3)/2 + BB{b}(1);
                plot(Func,CS,'r');                
            end
            title(['Kernel Length:' num2str(nanmean(KernelLength,2)')]);
            %%%%%%%%%%%%%%%%%%%%%%%
            % format the return image
            %%%%%%%%%%%%%%%%%%%%%%%
            axis equal;axis off;drawnow;set(gca,'Position',[0 0 1 1]);
            fprintf(['ending with image and results display \n']);
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
            % save image file
            imageFile = [oPath nm '_result.tif' ];
            saveas(h,imageFile);
            % save mat file
            matFile = [oPath nm '.mat'];
            save(matFile,'BB','fileName','KernelLength','FT','S','RAD');
            % save csv data
            csvOut = [oPath nm 'compile_results.csv'];
            csvwrite(csvOut,DATA);
            csvOut = [oPath nm 'width_results.csv'];
            csvwrite(csvOut,S.widthProfile);
            fprintf(['ending save phase \n ']);
        end
        close all;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE - end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:singleEarImage.m******\n']);
    end
    fprintf(['Total Running Time: ' num2str(etime(clock,totalTimeInit)) '\n']);
    versionString = ['Ending ear analysis algorithm. \nPublication Version 1.0 - Monday, March 28, 2016. \n'];
    fprintf(versionString);
end
%{  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compile_directory = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeEar/tmpSubmitFiles/';
    CMD = ['mcc -d ' compile_directory ' -a im2single.m -m -v -R -singleCompThread singleEarImage.m'];
    eval(CMD);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % run on single mazie ear(s)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fileName = '/mnt/snapper/Lee/code_2016/production/memory_use_producution/MatlabMemoryUse_verMarch012016/input/Scan1-160129-0043.tif';
    [KernelLength sM] = singleEarImage(fileName,3,'/home/nate/Downloads/',1,1);
%}