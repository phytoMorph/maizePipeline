function [] = singleSeedlingImage(imageFile,smoothValue,threshSIG,EXT,topTRIM,SNIP,oPath)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % imageFile : the image file to operate on
    % smoothValue : the smooth value for the integration signal along 1 dim
    % threshSIG : the threshold for finding the cone-tainers
    % EXT : the extension around the cone-tainers left and right
    % topTRIM : the amount to trim off the top
    % SNIP : the amont to use to find the base of the plant
    % oPath : the location to save the results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % convert the strings to numbers if they are strings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ischar(smoothValue)
        smoothValue = str2num(smoothValue);
    end
    if ischar(threshSIG)
        threshSIG = str2num(threshSIG);
    end
    if ischar(EXT)
        EXT = str2num(EXT);
    end
    if ischar(topTRIM)
        topTRIM = str2num(topTRIM);
    end
    if ischar(SNIP)
        SNIP = str2num(SNIP);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % convert the strings to numbers if they are strings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % init the icommands and create output directory
    initIrods();
    mkdir(oPath);
    try
        OFFSET = 40;
        sigFILL = 1100;
        eT = 120;
        thresP = .1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % load the image, make gray, edge 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting: image load, gray, and edge \n']);
        fprintf(['working on: ' imageFile '\n']);
        % path and name
        [p nm] = fileparts(imageFile);
        % read the image
        I = imread(imageFile);
        % rectifiy
        I = rectifyImage(I);
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
        % integrate
        sig = sum(E,1);
        % smooth the sig
        sig = imfilter(sig,fspecial('average',[1 smoothValue]),'replicate');
        % find the gaps
        BLOCK = sig < threshSIG;
        % remove the non-gaps that are less than 50
        BLOCK = bwareaopen(BLOCK,50);
        % close the pot holder chunks
        BLOCK = imclose(BLOCK,strel('disk',100));
        % extend the conetainers holder blocks
        eBLOCK = imerode(BLOCK,strel('disk',[EXT]));
        % make an image mask
        MASK = repmat(eBLOCK,[size(I,1) 1]);
        % get the bounding boxes for each mask
        R = regionprops(~MASK,'BoundingBox');
        fprintf(['starting: find the cone-tainer :' num2str(numel(R)) '\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find the cone-tainers
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % for each block
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
            % find the top of the container
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(['starting: find the top of the cone-tainer\n']);
            % gray scale for the strip
            G = rgb2gray(tmpD);
            % filter and edge
            G = imfilter(G,fspecial('disk',15),'replicate');
            SZ = size(I);
            E = edge(G);
            % integrate the edge
            sig = sum(E,2);
            % threshold the integrated edge
            sig = sig > eT;
            % fill in the sig
            sig(1:sigFILL) = 0;
            nidx = find(sig);
            if ~isempty(nidx)
                nidx = nidx(1);
                nR(e).BoundingBox(4) = (nidx-OFFSET)-nR(e).BoundingBox(2);
            end
            fprintf(['ending: find the top of the cone-tainer\n']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % find the top of the container
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
           

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % crop, get mask, 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(['starting: get the plant mask\n']);
            tmpD = imcrop(I,nR(e).BoundingBox);
            % make plant mask
            MASK = getMASK_ver0(tmpD);
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
            if sum(MASK(:))/prod(size(MASK)) < thresP & dBIOMASS(e) > 300 & plantHEIGHT(e) > 50
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
                % display the results
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
                hold on
                Xbar = nR(e).BoundingBox(1):nR(e).BoundingBox(1)+nR(e).BoundingBox(3) - xOFFSET;
                Ybar = (nR(e).BoundingBox(2)+nR(e).BoundingBox(4))*ones(size(Xbar)) - yOFFSET;


                plot(Xbar,Ybar,'r')
                Ybar = (HEIGHT(e))*ones(size(Xbar));
                plot(Xbar,Ybar,'r')


                for i = 1:numel(data.PATHS{e})
                    plot(data.PATHS{e}{i}(1,:) - xOFFSET,data.PATHS{e}{i}(2,:) - yOFFSET,'r','LineWidth',2);
                end

                plot(data.PATHS{e}{data.longestPath(e)}(1,:)-xOFFSET,data.PATHS{e}{data.longestPath(e)}(2,:)-yOFFSET,'k','LineWidth',2);
                title(['plant ' num2str(e)]);
                drawnow
                %axis equal;
                axis off;drawnow;set(gca,'Position',[0 0 1 1]);
                saveas(gca,[oPath nm '_result_' num2str(e) '.tif']);
                close all
                fprintf(['ending: display single plant\n']);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % display the results
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        
    catch ME
        getReport(ME)
        close all
    end
    try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % display the results
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
                % plot paths for tracing
                for i = 1:numel(data.PATHS{e})
                    plot(data.PATHS{e}{i}(1,:),data.PATHS{e}{i}(2,:),'r','LineWidth',2);
                end
                % plot ongest path
                plot(data.PATHS{e}{data.longestPath(e)}(1,:),data.PATHS{e}{data.longestPath(e)}(2,:),'k','LineWidth',2);
                drawnow
                fprintf(['ending with image and results display \n']);
            end
        end
        axis equal;axis off;drawnow;set(gca,'Position',[0 0 1 1]);
        saveas(gca,[oPath nm '_result' '.tif']);
        close all
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % display the results
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        csvwrite([oPath nm '_digital_biomass.csv'],dBIOMASS);
        csvwrite([oPath nm '_plant_height.csv'],plantHEIGHT);
        csvwrite([oPath nm '_longest_path.csv'],data.longestPath);
        for e = 1:numel(HEIGHT)
            if (plantHEIGHT(e)==0)
                data.K{e} = NaN;
            end
            csvwrite([oPath nm '_curvature_' num2str(e) '.csv'],data.K{e});
        end
    catch ME
        getReport(ME)
        close all
    end
end


%{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compile_directory = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeSeedling/tmpSubmitFiles/';
    CMD = ['mcc -d ' compile_directory ' -a im2single.m -m -v -R -singleCompThread singleSeedlingImage.m'];
    eval(CMD);
%}