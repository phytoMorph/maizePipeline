function [] = main_swell_HT(inFilePath,oPath,expectedImageNumber)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% scan for new images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileList = {};
    FileExt = {'tiff','TIF','tif'};
    verbose = 1;
    SET = sdig(inFilePath,FileList,FileExt,verbose);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% sort SET
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for e = 1:numel(SET)
        N = [];
        for img = 1:numel(SET{e})
            [p n ex] = fileparts(SET{e}{img});
            N(img) = str2num(n);
        end
        [N sidx] = sort(N);
        SET{e} = SET{e}(sidx);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% remove those which are in the junk folder
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for e = 1:numel(SET)
        fidx = strfind(SET{e}{1},'junk');
        if ~isempty(fidx)
            rmidx(e) = 1;
        else
            rmidx(e) = 0;
        end
    end
    SET(find(rmidx)) = [];    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% find sets with more than 250
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for e = 1:numel(SET)
        numImages(e) = numel(SET{e});
    end
    rmidx = numImages < expectedImageNumber;
    SET(rmidx) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% generate output file names
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for e = 1:numel(SET)
        [swell{e} area{e} para{e} err{e} fit{e}] = generateOutFileBase(SET{e}{1},oPath,1);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% remove sets which have data in the oPath
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% remove compiled results
    oFileList = {};
    FileExt = {'csv'};
    verbose = 1;
    oSET = gdig(oPath,FileList,FileExt,verbose);
    rmidx = [];
    for e = 1:numel(oSET)
        fidx = strfind(oSET{e},'compiled_results');
        if ~isempty(fidx)
            rmidx(e) = 1;
        else
            rmidx(e) = 0;
        end
    end
    oSET(find(rmidx)) = [];
    %%% look for data which already is run through algo
    rmidx = zeros(numel(SET),1);    
    for e = 1:numel(oSET)
        fidx1 = strfind(oSET{e},filesep);
        fidx2 = strfind(oSET{e},'--');
        snipFile = oSET{e}(fidx1(end)+1:fidx2(end)-1);
        for i = 1:numel(swell)
            fidx1 = strfind(swell{i},filesep);
            fidx2 = strfind(swell{i},'--');
            isnipFile = swell{i}(fidx1(end)+1:fidx2(end)-1);
            if strcmp(snipFile,isnipFile)
                rmidx(i) = 1;
            end
        end
    end
    SET(find(rmidx)) = [];
    swell(find(rmidx)) = [];
    area(find(rmidx)) = [];
    para(find(rmidx)) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% analyze the data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tm = clock;
    mainBOX = 10^3*[0.0589 0.0512 0.9612 1.3176]; % fixed crop box due to template
    for e = 1:numel(SET)
        % measure the data
        [swellValue areaValue] = measureStack_ver2(SET{e},[500 500],mainBOX,-1,12,0);
        % reshape the data
        sz2 = 9;
        sz1 = size(swellValue,1)/sz2;
        bS = reshape(swellValue',[size(swellValue,2) sz1 sz2]);
        bS = permute(bS,[2 3 1]);
        bA = reshape(areaValue',[size(areaValue,2) sz1 sz2]);
        bA = permute(bA,[2 3 1]);
        % loop over each row
        clear x0;
        clear f
        for genoType = 1:size(bS,1)
            % get a row of data
            tmpData = squeeze(bS(genoType,:,:));
            tmpArea = squeeze(bA(genoType,:,:));
            % write to disk
            csvwrite(strrep(swell{e},'#ROWNUM#',num2str(genoType)),tmpData');
            csvwrite(strrep(area{e},'#ROWNUM#',num2str(genoType)),tmpArea');            
            % fit the data on kernel at a time            
            for tr = 1:size(tmpData,1)
                toFit = tmpData(tr,:);
                [x0{genoType}(tr,:) er(tr)] = fminsearch(@(X)mySwellFit(toFit,X),[10^4 .01]);                
                prediction_f{genoType}(tr,:) = func(x0{genoType}(tr,1),x0{genoType}(tr,2),1:3*size(tmpData,2));
                f{genoType}(tr,:) = func(x0{genoType}(tr,1),x0{genoType}(tr,2),1:size(tmpData,2));
                UerrorInFit{genoType}(tr) = mean(toFit - f{genoType}(tr,:));
                %{
                plot(f{genoType}(tr,:),'r');
                hold on
                plot(tmpData(tr,:),'b');
                plot(toFit,'b');
                drawnow                
                %}
            end
            %{
            hold off
            waitforbuttonpress
            %}
            csvwrite(strrep(para{e},'#ROWNUM#',num2str(genoType)),x0{genoType});
            csvwrite(strrep(err{e},'#ROWNUM#',num2str(genoType)),UerrorInFit{genoType});
            csvwrite(strrep(fit{e},'#ROWNUM#',num2str(genoType)),f{genoType}');
        end
    end
    fprintf(['Average time per stack:' num2str(etime(clock,tm)/numel(SET))/60 '\n']);
    
    
    
    
end


%{
    inFilePath = '/mnt/snapper/kernelSwellingData/Scott/rawData/';
    oPath = '/mnt/snapper/kernelSwellingData/Scott/return/';
    main_swell_HT(inFilePath,oPath,120);
%}


