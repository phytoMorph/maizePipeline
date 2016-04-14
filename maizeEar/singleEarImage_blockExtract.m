function [KernelLength sM] = singleEarImage_blockExtract(fileName,noe,oPath,toZip,toSave)
    ret = 0;
    sM = [];
    toDisplay = 1;
    try
        
        
        fprintf(['FileName:' fileName '\n']);
        fprintf(['Number of Ears:' noe '\n']);
        fprintf(['OutPath:' oPath '\n']);
        fprintf(['toZip:' toZip '\n']);

        mkdir(oPath);
        [pth nm ext] = fileparts(fileName);

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % read the image
        I = imread(fileName);
        if ischar(noe)
            noe = str2num(noe);
        end
        if ischar(toZip)
            toZip = str2num(toZip);
        end
        if ischar(toSave)
            toSave = str2num(toSave);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % measure the number of cobs
        RAD = 1200:25:1600;
        gridSites = 10;
        [KernelLength FT BB S MT] = measureKernelLength_forcondor(I,noe,RAD,gridSites);        
        uT = nanmean(KernelLength,2);
        fprintf(['KernelLengths @' num2str(uT') ':' fileName '\n']);
 
        
        
        
        
        if toSave
            imageFile = [oPath nm '_result.tif' ];
            saveas(h,imageFile);
            matFile = [oPath nm '.mat'];
            %save(matFile,'BB','fileName','KernelLength','sM','FT');
            save(matFile,'BB','fileName','KernelLength','FT');
            csvOut = [oPath nm '.csv'];
            csvwrite(csvOut,DATA);
            close all
        end

        if toZip
            zipFiles{1} = matFile;
            zipFiles{2} = csvOut;
            zip([oPath nm '.zip'],zipFiles);
        end
        
        ret = 1;
        
    catch ME
        getReport(ME)
        
        ret = 0;
    end
end
%{
    oPath = '/mnt/spaldingdata/nate/communications/nickHaase/output_TEST_JUNK/';
    mkdir(oPath);        
    % dig for images
    inPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/earData/';    
    FilePath = inPath;    
    FileList = {};
    FileExt = {'tif','TIF'};
    verbose = 0;
    [FileList] = gdig(FilePath,FileList,FileExt,verbose);
    
    noe = 3;
    parfor e = 1:100
        try
            [K{e} P{e}] = singleEarImage(FileList{e},noe,oPath,0,0);
        catch ME
            ME
        end
    end
    
    for t = 1:numel(P)
        for e = 1:numel(P{t})
            uK(t,e) = mean(K{t}(e,:));    
            for i = 1:numel(P{t}{e}.height)
                HT{t}{e}(i) = mean(P{t}{e}.height{i});                
            end
            [delta(t,e)  sidx] = min(abs(HT{t}{e} - uK(t,e)));
            UH(t,e) = HT{t}{e}(sidx);
        end
    end

    rmidx = any(isnan(uK),2) | any(uK == 0,2);
    uK(rmidx,:) = [];
    UH(rmidx,:) = [];


    fileName = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/earData/3-18-14/Scan-140318-0081.tif';
    singleEarImage(fileName,3,'',1);
    
    
%}