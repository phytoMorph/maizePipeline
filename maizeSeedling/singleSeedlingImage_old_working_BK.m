function [] = singleSeedlingImage(fileName,smoothValue,threshSIG,EXT,topTRIM,SNIP,rawImage_scaleFactor,OFFSET,sigFILL,eT,thresP,TOP_THRESH,oPath)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                singleSeedlingImage.m is main function to handle ear analysis. It takes all input variables 
                for its dependent functions. This function returns final result including image with 
                bounding box. (Inputs are relative to 1200dpi)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                StoN.m, checkBlue.m, measureKernelLength.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                fileName:               the image file to operate on.
                smoothValue:            the smooth value for the integration signal along 1 dim
                threshSIG:              the threshold for finding the cone-tainers
                EXT:                    the extension around the cone-tainers left and right.
                topTRIM:                the amount to trim off the top.
                SNIP:                   the amont to use to find the base of the plant.
                rawImage_scaleFactor:   A desired percentage to resize the image.
                OFFSET:                 = 40;
                sigFILL:                = 1100;
                eT:                     = 120;
                thresP:                 = .1;
                TOP_THRESH:             = 1150;
                oPath:                  the location to save the results.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % convert the strings to numbers if they are strings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    smoothValue = StoN(smoothValue);
    threshSIG = StoN(threshSIG);
    EXT = StoN(EXT);
    topTRIM = StoN(topTRIM);
    SNIP = StoN(SNIP);
    rawImage_scaleFactor = StoN(rawImage_scaleFactor);
    OFFSET = StoN(OFFSET);
    sigFILL = StoN(sigFILL);
    eT = StoN(eT);
    thresP = StoN(thresP);
    TOP_THRESH = StoN(TOP_THRESH);
    %%%%%%%%%%%%%%%%%%%%%%%
    % print out the fileName, number of ears, output path
    %%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['FileName:' fileName '\n']);
    fprintf(['Smooth Value:' num2str(smoothValue) '\n']);
    fprintf(['OutPath:' oPath '\n']); 
    fprintf(['Extension:' num2str(EXT) '\n']);
    fprintf(['Cone-tainers threshhold:' num2str(threshSIG) '\n']); 
    fprintf(['Image Resize:' num2str(rawImage_scaleFactor) '\n']); 
    fprintf(['Short Explanation Required:' num2str(OFFSET) '\n']);
    fprintf(['Short Explanation Required:' num2str(topTRIM) '\n']); 
    fprintf(['Short Explanation Required:' num2str(SNIP) '\n']); 
    fprintf(['Short Explanation Required:' num2str(sigFILL) '\n']); 
    fprintf(['Short Explanation Required:' num2str(eT) '\n']);
    fprintf(['Short Explanation Required:' num2str(thresP) '\n']); 
    fprintf(['Short Explanation Required:' num2str(TOP_THRESH) '\n']);
    %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % convert the strings to numbers if they are strings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % init the icommands and create output directory
    initIrods();
    mkdir(oPath);
    % I added these to static path
    if isdeployed
        javaaddpath([pwd filesep 'core-3.2.1.jar']);
        javaaddpath([pwd filesep 'javase-3.2.1.jar']);
    end
    try
        %{
        OFFSET = 40;
        sigFILL = 1100;
        eT = 120;
        thresP = .1;
        TOP_THRESH = 1150;
        %}
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % load the image, make gray, edge 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting: image load, gray, and edge \n']);
        fprintf(['working on: ' fileName '\n']);
        % path and name
        [p nm] = fileparts(fileName);
        % read the image
        I = imread(fileName);
        % rawImage_scaleFactor to lower 'DPI' effect, by fraction
        % If resize factor is 1, do not excecute imresize
        if rawImage_scaleFactor ~= 1;I = imresize(I,rawImage_scaleFactor);end
        % rectifiy
        I = rectifyImage(I);
        % get QR code
        nm = getQRcode(I);
        % crop off qr code
        I(1:TOP_THRESH,:,:) = [];
        % trim off X pixles from rotation
        I(:,1:30,:) = [];
        I(:,end-70:end,:) = [];
        % make gray scale

        G = rgb2gray(I);
        % filter the image
        G = imfilter(G,fspecial('gaussian',[13 13],4),'replicate');
        % find edge
        E = edge(G);
        fprintf(['ending: image load, gray, and edge \n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % load the image, make gray, edge 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find the cone-tainers
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting: find the cone-tainer \n']);
        %{
        TOP_THRESH = 970;
        % integrate
        sig = sum(E(TOP_THRESH:end,:),1);
        % smooth the sig
        sig = imfilter(sig,fspecial('average',[1 smoothValue]),'replicate');
        % find the gaps
        BLOCK = sig < threshSIG;
        % remove the non-gaps that are less than 50
        BLOCK = bwareaopen(BLOCK,70);
        % close the pot holder chunks
        BLOCK = imclose(BLOCK,strel('disk',100));
        % extend the conetainers holder blocks
        eBLOCK = imerode(BLOCK,strel('disk',[EXT]));
        % make an image mask
        MASK = repmat(eBLOCK,[size(I,1) 1]);
        %}
        %{
        S = rgb2hsv_fast(I,'single','S');
        sig = sum(S > .08,1) > 100;
        sig(1:500) = 1;
        sig(end-499:end) = 1;
        sig = imclose(sig,strel('disk',100));
        %}
        G = rgb2gray(single(I)/255);
        G = imfilter(G,fspecial('gaussian',[11 11]));
        [d1 d2] = gradient(G);
        d2 = abs(d2) > graythresh(abs(d2));
        d2 = bwareaopen(d2,50);
        d2 = imclose(d2,strel('disk',10));
        sig = sum(abs(d2),1);
        sig = imfilter(sig,fspecial('average',[1 smoothValue]),'replicate');
        sig = bindVec(sig);
        threshSIG = graythresh(sig);
        % find the gaps
        BLOCK = sig > threshSIG;
        % remove the non-gaps that are less than 70
        BLOCK = bwareaopen(BLOCK,70);
        % close the pot holder chunks
        BLOCK = imclose(BLOCK,strel('disk',100));
        eBLOCK = imdilate(BLOCK,strel('disk',[EXT]));
        % make an image mask
        MASK = ~repmat(eBLOCK,[size(I,1) 1]);
        
        % get the bounding boxes for each mask
        R = regionprops(~MASK,'BoundingBox');
        fprintf(['starting: find the cone-tainer :' num2str(numel(R)) '\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find the cone-tainers
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % for each image block
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tmpMASK_final = zeros(size(G));
        out = double(I)/255;
        HEIGHT = NaN*ones(1,numel(R));
        plantHEIGHT = HEIGHT;
        % for each cone-tainer
        for e = 1:numel(R)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % crop a vertical trip for each container
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(['starting: crop the strip\n']);
            % crop the strip
            tmpD = imcrop(I,R(e).BoundingBox);
            % next boundingbox
            nR(e).BoundingBox = R(e).BoundingBox;
            % trim the top
            tmpD(1:topTRIM:end,:,:) = [];
            % get the size
            SZ = size(tmpD);
            fprintf(['ending: crop the strip\n']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % crop a vertical trip for each container
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % find the top of the cone-tainer
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(['starting: find the top of the cone-tainer\n']);
            
            MASK = getMASK_ver0(tmpD);
            MASK = imclose(MASK,strel('disk',5));
            fidx = find(MASK(end,:));
            MASK(end,fidx(1):fidx(end)) = 1;
            MASK = imfill(MASK,'holes');
            
            E = edge(MASK);
            %{
            % gray scale for the strip
            G = rgb2gray(tmpD);
            E = edge(G);
            % integrate the edge
            sig = sum(E,2);
            % threshold the integrated edge
            sig = sig > eT;
            % fill in the sig
            sig(1:sigFILL) = 0;
            nidx = find(sig);
            %}
            
            %{
            % filter and edge
            G = imfilter(G,fspecial('disk',15),'replicate');
            SZ = size(I);
            [d1 d2] = gradient(single(G)/255);
            E = abs(d2) > graythresh(abs(d2));
            %}
            %{
            [H, theta, rho] = hough(E','Theta',linspace(-5,5,20));
            P  = houghpeaks(H,1,'Threshold',0);
            linesV = houghlines(E',theta,rho,P,'FillGap',500,'MinLength',300);
            %}
            
            sig = sum(E,2);
            sig = imfilter(sig,fspecial('average',[5 1]),'replicate');
            [J,nidx] = max(sig);
            
            
            
            %if ~isempty(nidx)
                %nidx = nidx(1);
                %nidx = mean([linesV(1).point1(1) linesV(1).point2(1)]);
                nR(e).BoundingBox(4) = (nidx-OFFSET)-nR(e).BoundingBox(2);
            %end
            fprintf(['ending: find the top of the cone-tainer\n']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % find the top of the cone-tainer
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
           

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % crop, get mask, 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(['starting: get the plant mask\n']);
            flag = 1;
            cnt = 1;
            fprintf(['clipping: the bottom plant mask\n']);
            while flag
                fprintf(['.']);
                tmpD = imcrop(I,nR(e).BoundingBox);
                % make plant mask
                MASK = getMASK_ver0(tmpD);
                if sum(MASK(end,:)) > 80
                    nR(e).BoundingBox(4) = nR(e).BoundingBox(4) -1;
                else
                    flag = 0;
                end
                cnt = cnt +1;
                if cnt > 150
                    flag = 0;
                end
            end
            fprintf(['\n']);
            
            
            
            
            % sum the mask for the height calculation
            sig = sum(MASK,2);
            % find the pixels
            fidx = find(sig);
            if isempty(fidx)
                fidx = size(MASK,1);
            end
            % find the top pixel
            HEIGHT(e) = fidx(1);
            % plant height
            plantHEIGHT(e) = size(MASK,1) - HEIGHT(e);
            % find the biomass
            dBIOMASS(e) = sum(MASK(:));
            fprintf(['ending: get the plant mask\n']);
            % if the mask is blank not blank
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % find the top of the container
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.isPlant(e) = 0;
            if sum(MASK(:))/prod(size(MASK)) < thresP & dBIOMASS(e) > 300 & plantHEIGHT(e) > 50
                data.isPlant(e) = 1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % trace the skeleton
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['starting: skeleton trace\n']);
                % pad the array
                tmpMASK = padarray(MASK, [300 0], 'replicate', 'post');
                % get the skeleton
                SKEL = bwmorph(tmpMASK,'thin',inf);
                % get the skeleton
                SKEL = SKEL(1:size(MASK,1),:);
                % find the skeleton for tracing
                [r c] = find(SKEL);
                % find the tips
                EP = imfilter(double(SKEL),ones(3,3));
                [re ce] = find(EP == 2 & SKEL);
                % SNIP off some stem
                baseMASK = sum(MASK(end-SNIP:end,:),1);
                % mean along the stem snip
                basePoint(1) = mean(find(baseMASK));
                % set the basepoint 1 to the size of the mask
                basePoint(2) = size(MASK,1);
                % find skeleton
                [x y] = find(SKEL);
                % stack the skeleton points for tracing
                DP = [x y]';
                fprintf(['starting: make adjacency matrix\n']);
                % make adjaceny matrix
                T = Radjacency(DP,3);
                fprintf(['ending: make adjacency matrix\n']);
                % find the longest path from the stem end point to the leaf tip
                pathcost = [];
                path = {};
                % snap the base point to the skeleton
                [idx(1)] = snapTo(DP',[fliplr(basePoint)]);
                for i = 1:numel(re)
                    % find the end point in the skeleton
                    [idx(2)] = snapTo(DP',[re(i) ce(i)]);
                    fprintf(['starting: path trace\n']);
                    % trace
                    [path{i} , pathcost(i)]  = dijkstra(T , idx(1) , idx(2));
                    fprintf(['ending: path trace\n']);
                end
                % set pathcost of inf to zero
                pathcost(isinf(pathcost)) = 0;
                % find the zeros - including inf path cost
                ridx = find(pathcost==0);
                % remove the 0 length paths
                pathcost(ridx) = [];
                % remove the 0 length paths
                path(ridx) = [];
                % find the max path cost
                [J,midx] = max(pathcost);
                fprintf(['ending: skeleton trace\n']);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % trace the skeleton
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % make the mask overlay
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['starting: mask overlay\n']);
                % make mask overlay
                [x1 x2] = find(MASK);
                x1 = x1 + floor(nR(e).BoundingBox(2));
                x2 = x2 + floor(nR(e).BoundingBox(1));
                tmpMASK = zeros(size(tmpMASK_final));
                for i = 1:numel(x1)
                    tmpMASK(round(x1(i)),round(x2(i))) = 1;
                end
                tmpMASK_final = tmpMASK + tmpMASK_final;
                fprintf(['ending: mask overlay\n']);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % make the mask overlay
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % store the traced paths and other data
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['starting: storing the phenotypic data\n']);
                data.K{e} = [];
                for i = 1:numel(pathcost)
                    out = cwtK_imfilter(DP(:,path{i})',{5});
                    data.K{e} = [data.K{e};out.K];
                    dL = diff(DP(:,path{i}),1,2);
                    dL = sum(sum(dL.*dL,1).^.5);
                    data.pathLength{e}(i) = dL;
                    data.PATHS{e}{i} = [DP(2,path{i})+nR(e).BoundingBox(1);DP(1,path{i})+nR(e).BoundingBox(2)];
                end
                data.longestPathLength{e} = data.pathLength{e}(midx);
                data.longestPath(e) = midx;
                fprintf(['ending: storing the phenotypic data\n']);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % store the traced paths and other data
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % display the results for each plant
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['starting: display single plant\n']);
                yOFFSET = HEIGHT(e);
                xOFFSET = nR(e).BoundingBox(1);
                E = edge(MASK(yOFFSET:end,:));
                E = imdilate(E,strel('disk',3,0));
                out = flattenMaskOverlay(tmpD(yOFFSET:end,:,:), logical(MASK(yOFFSET:end,:)),.15,'g');
                out = flattenMaskOverlay(out, logical(E),.55,'b');
                h = image(out);
                axis off
                axis equal
                hold on
                Xbar = nR(e).BoundingBox(1):nR(e).BoundingBox(1)+nR(e).BoundingBox(3) - xOFFSET;
                Ybar = (nR(e).BoundingBox(2)+nR(e).BoundingBox(4))*ones(size(Xbar)) - yOFFSET;

                %{
                % something is not right here
                plot(Xbar,Ybar,'r')
                Ybar = (HEIGHT(e))*ones(size(Xbar));
                plot(Xbar,Ybar,'r')
                %}


                for i = 1:numel(data.PATHS{e})
                    plot(data.PATHS{e}{i}(1,:) - xOFFSET,data.PATHS{e}{i}(2,:) - yOFFSET,'r','LineWidth',2);
                end

                plot(data.PATHS{e}{data.longestPath(e)}(1,:)-xOFFSET,data.PATHS{e}{data.longestPath(e)}(2,:)-yOFFSET,'k','LineWidth',2);
                title(['plant ' num2str(e)]);
                drawnow
                %axis equal;
                axis off;drawnow;set(gca,'Position',[0 0 1 1]);
                tmpImageName = [oPath nm '{PlantNumber_' num2str(e) '}{Phenotype_Image}.tif'];
              
                saveas(gca,tmpImageName);
                close all
                fprintf(['ending: display single plant\n']);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % display the results - for each plant
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            
            
        end
        
    catch ME
        close all;
        getReport(ME)
        fprintf(['******error in:singleSeedlingImage.m******\n']);
    end
    
    
    try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % display the results rendered onto the raw image
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        close all
        fprintf(['starting with image and results display \n']);
        out = flattenMaskOverlay(I, logical(tmpMASK_final),.15,'g');
        h = image(out);
        axis off
        hold on
        for e = 1:numel(HEIGHT)
            if ~(plantHEIGHT(e)==0)
                % make the data for the bars for height
                Xbar = nR(e).BoundingBox(1):nR(e).BoundingBox(1)+nR(e).BoundingBox(3);
                Ybar = (nR(e).BoundingBox(2)+nR(e).BoundingBox(4))*ones(size(Xbar));
                % plot bars
                plot(Xbar,Ybar,'r')
                Ybar = (HEIGHT(e))*ones(size(Xbar));
                plot(Xbar,Ybar,'r')
                
                if data.isPlant(e)
                    % plot paths for tracing
                    for i = 1:numel(data.PATHS{e})
                        plot(data.PATHS{e}{i}(1,:),data.PATHS{e}{i}(2,:),'r','LineWidth',2);
                    end
                    % plot longest path
                    plot(data.PATHS{e}{data.longestPath(e)}(1,:),data.PATHS{e}{data.longestPath(e)}(2,:),'k','LineWidth',2);
                end
                
                
                
                drawnow
                fprintf(['ending with image and results display \n']);
            end
        end
        axis equal;axis off;drawnow;set(gca,'Position',[0 0 1 1]);
        tmpImageName = [oPath nm '{PlantNumber_All}{Phenotype_Image}.tif'];
        saveas(gca,tmpImageName);
        close all
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % display the results
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pName1 = [oPath nm '{PlantNumber_All}{Phenotype_DigitalBioMass}.csv'];
        pName2 = [oPath nm '{PlantNumber_All}{Phenotype_PlantHeight}.csv'];
        pName3 = [oPath nm '{PlantNumber_All}{Phenotype_LongestPath}.csv'];
        csvwrite(pName1,dBIOMASS);
        csvwrite(pName2,plantHEIGHT);
        csvwrite(pName3,data.longestPath);
        for e = 1:numel(HEIGHT)
            if (plantHEIGHT(e)==0)
                data.K{e} = NaN;
            end
            pName4 = [oPath nm '{PlantNumber_' num2str(e) '}{Phenotype_Curvature}.csv'];
            csvwrite(pName4,data.K{e});
        end
        pName5 = [oPath nm '{PlantNumber_All}{Phenotype_imageFileName}.txt'];
        fileID = fopen(pName5,'w');
        nbytes = fprintf(fileID,'%s\n',fileName);
    catch ME
        close all;
        getReport(ME)
        fprintf(['******error in:singleSeedlingImage.m******\n']);
    end
end


%{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compile_directory = '/mnt/scratch1/maizePipeline/maizePipeline/maizeSeedling/tmpSubmitFiles/';
    CMD = ['mcc -d ' compile_directory ' -a im2single.m -m -v -R -singleCompThread singleSeedlingImage.m'];
    eval(CMD);


    oPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/hirsc213/return/seedlingData/output/';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/growthchamber12.7.15/day11_b73_10-11.nef';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC4.10.16/plot100.nef';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC3.5.16/plot19c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC3.8.16/plot19c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC3.11.16/plot19c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC4.5.16/plot100.nef';
    %fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC4.6.16/plot100.nef';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC4.2.16/plot100.nef';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC4.8.16/plot100.nef';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC3.28.16/plot100.nef';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.24.16/plot9c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/growthchamber12.7.15/day12_ph207_1-2-3comp.tif';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC3.17.16/plot54c.tiff'; % bad qr
    fileName ='/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC3.12.16/plot40c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.25.16/plot9c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.27.16/plot10c.tiff';
    filename = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.27.16/plot11c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC3.2.16/plot19c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.26.16/plot14c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.22.16/plot11c.tiff';
    %fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.29.16/plot23c.tiff';
    fileName = '/iplant/home/hirsc213/maizeData/seedlingData/one_month_test_mac/GC2.26.16/plot7c.tiff';
    singleSeedlingImage(fileName,100,5,100,100,4,oPath);


    FilePath = '/mnt/spaldingdata/nate/mirror_images/maizeData/hirsc213/return/seedlingData/output/';
    txtFileList = {};
    FileExt = {'txt'};
    txtFileList = gdig(FilePath,txtFileList,FileExt,1);
    [imageFile] = getImageFile(txtFileList,'10','17');
    [imageFile] = getImageFile(txtFileList,'10','19');
    [imageFile] = getImageFile(txtFileList,'106','9');
    [imageFile] = getImageFile(txtFileList,'100','22');
    singleSeedlingImage(imageFile,100,5,100,100,4,oPath);
    parfor e = 1:22
        [imageFile] = getImageFile(txtFileList,'100',num2str(e));
        if ~isempty(imageFile)
            singleSeedlingImage(imageFile,100,5,100,100,4,oPath);
        end
    end
%}

%{
singleSeedlingImage(fileName,smoothValue,threshSIG,EXT,topTRIM,SNIP,rawImage_scaleFactor,oPath)
oPath = '/mnt/snapper/Lee/maizeData_resTest_Result/seedlingData_Result';
fileName = '/mnt/snapper/Lee/maizeData_resTest/seedlingData/plot7c.tiff';
singleSeedlingImage(fileName,100,5,100,100,4,1,40,1100,120,0.1,1150,oPath);
%}