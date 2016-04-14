function [sites auxData] = mySiteExtract0(I,OP)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % OP.filter_window_size = size of filter window
    % OP.sigma              = sigma of filter window
    % OP.numberCobs         = number of cobs
    % OP.siteSample         = spacing for grid call
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get gray and filter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    grayImage = rgb2gray(I);
    h = fspecial('gaussian',OP.filter_window_size,OP.sigma);
    grayImage = imfilter(grayImage,h);
    level = graythresh(grayImage);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get binary, close, fill holes, remove small objects
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    B = im2bw(grayImage,level);
    B = imclose(B,strel('disk',101));
    B = imfill(B,'holes');
    B = bwareaopen(B,1000000);
    R = regionprops(B,'PixelIdxList','PixelList','Area','Image','BoundingBox');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % iterate over the cobs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for e = 1:OP.numberCobs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % get bounding box
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        BB{e} = R(e).BoundingBox;
        subI = R(e).Image;
        dB = bwboundaries(subI);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % generate aux info
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        auxData(e).cob_width_profile = sum(subI,2)/2;
        auxData(e).mean_width = mean(auxData(e).cob_width_profile);
        auxData(e).width = BB{e}(3);
        auxData(e).height = BB{e}(4);
        auxData(e).BoundingBox = BB{e};
        auxData(e).dB = dB{1};
        auxData(e).dB = bsxfun(@plus,auxData(e).dB,fliplr(round(BB{e}(1:2))));
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % zero fill the boundaries
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        subI(1,:) = 0;
        subI(:,end) = 0;
        subI(end,:) = 0;
        subI(end,:) = 0;
        
        mask = imerode(subI,strel('rectangle',[OP.windowSize 20]));
        sites{e} = generate_checker_board(mask,OP.siteSample);
        sites{e} = bsxfun(@plus,sites{e},fliplr(round(BB{e}(1:2))));
        fprintf(['done with ear ' num2str(e) ':' num2str(OP.numberCobs) '\n']);      
    end
end