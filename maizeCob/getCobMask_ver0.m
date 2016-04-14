function [B] = getCobMask_ver0(I)
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get gray and filter
        h = fspecial('gaussian',[51 51],11);
        sI = imfilter(I,h,'replicate');
        %hI = rgb2hsv(I); 
        
        %gsI = hI(:,:,1);        
        averageBackground = [0.268125854993160 0.438850889192886 0.064386684906521];
        for e = 1:size(sI,3)
            oI(:,:,e) = sI(:,:,e) - averageBackground(e);
        end
        oI = sum(oI.*oI,3).^.5;

        
        oIs = bindVec(oI);
        level = graythresh(oIs);
        [f x] = hist(oIs(:),linspace(min(oIs(:)),max(oIs(:)),1200));
        fe = imerode(f,strel('disk',71,0));
        fidx = find(fe == f);
        fidx = x(fidx);
        [J midx] = min(abs(fidx - level));
        level = fidx(midx);
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get binary, close, fill holes, remove small objects
        B = im2bw(oIs,level);
        B = imclearborder(B);        
        B = imfill(B,'holes');
        B = bwareaopen(B,1000000);
end