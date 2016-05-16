function [centers] = getCenters(fileName,mainBOX)
    %I = imread(fileName);
    %{
    %I = imcrop(I,mainBOX);
    %I = rgb2hsv(I);
    I = rgb2hsv_fast(I,'single','H');
    
    %{
    % simpler for problem
    fI = imfilter(I,fspecial('disk',31),'replicate');
    BK = imdilate(imresize(fI,.25),strel('disk',61,0));
    BK = imfilter(BK,fspecial('average',211),'replicate');
    BK = imresize(BK,size(I));
    I = I - BK;
    I = bindVec(I);
    % simpler for problem
    %}
    
    %I = double(I(:,:,1));
    
    %}
    
    
    
    % read the image
    I = imread(fileName);
    % get the hue channel
    I = rgb2hsv_fast(I,'single','H');
    % filter the background
    I = I < .2 | I > .5;
    % remove small objects
    I = bwareaopen(I,2000);
    % get the regionprops
    R = regionprops(I,'Area','PixelIdxList','Perimeter');
    % count objects on area
    [fidx1] = count([R.Area]);
    % count objects on perimeter
    [fidx2] = count([R.Perimeter]);
    % find those that match for both
    fidx = fidx1 & fidx2;
    fidx = find(fidx);
    % make mask
    MASK = zeros(size(I));
    for e = 1:numel(fidx)
        MASK(R(fidx(e)).PixelIdxList) = 1;
    end
    
    
    
    
    
    
    %{
    I = I < graythresh(I);
    I = imclearborder(I);
    I = bwareaopen(I,2000);
    %}
    
    
    
    S1 = std(MASK,1,1);
    bk1 = imerode(S1,ones(1,500));
    bk1 = imfilter(bk1,fspecial('disk',201));
    S1 = imfilter(S1,fspecial('disk',101));
    [lm1] = nonmaxsuppts(S1,601);
    R1 = regionprops(lm1,'Centroid');
    lm1 = zeros(size(lm1));
    for e = 1:numel(R1)
        lm1(round(R1(e).Centroid(1))) = 1;
    end
    S1 = bindVec(S1);
    level = graythresh(S1);
    lm1 = lm1 & S1 > level;
    
    S2 = std(MASK,1,2);
    bk2 = imerode(S2,ones(500,1));
    bk2 = imfilter(bk2,fspecial('disk',201));
    S2 = imfilter(S2,fspecial('disk',101));
    [lm2] = nonmaxsuppts(S2,601);
    R2 = regionprops(lm2,'Centroid');
    lm2 = zeros(size(lm2));
    for e = 1:numel(R2)
        lm2(round(R2(e).Centroid(2))) = 1;
    end
    S2 = bindVec(S2);
    level = graythresh(S2);
    lm2 = lm2 & S2 > level;
   
    M = double(lm2)*double(lm1);
    [c1 c2] = find(M);
    centers = [c1 c2];
    
    %centers = [c1+mainBOX(2) c2+mainBOX(1)];
    
    
end