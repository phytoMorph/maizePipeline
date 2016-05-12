function [MASK] = getMASK_ver0(I)
    hI = rgb2hsv_fast(I,'single');
    %I = I(:,:,2);
    level = graythresh(hI(:,:,2));
    level = max(level,.2);
    tmp = hI(:,:,2);
    [y x] = hist(tmp(:),linspace(0,1,256));
    y = log(y);
    y = imfilter(y,fspecial('average',[1 11]),'replicate');
    fidx = find(y == imdilate(y,strel('disk',20)));
    yclip = y(fidx(1):fidx(2));
    xclip = x(fidx(1):fidx(2));
    [ym,midx] = min(yclip);
    thresh = xclip(midx);
    
    MASK = hI(:,:,2) > level & hI(:,:,1) > .04 & hI(:,:,1) < .2 & hI(:,:,3) < .85; 
    MASK = hI(:,:,1) > .19 & hI(:,:,1) < .22;
    MASK = hI(:,:,2) > .18; % OLD
    MASK = hI(:,:,2) > thresh;
    %{
    R = regionprops(MASK,'Area','PixelIdxList');
    [mA midx] = max([R.Area]);
    MASK = zeros(size(MASK));
    MASK(R(midx).PixelIdxList) = 1;
    MASK = imclose(MASK,strel('disk',11,0));
    MASK = imfill(MASK,'holes');
    %}
    tmp = imclearborder(MASK);
    MASK = MASK - tmp;
    %MASK = imfill(MASK,'holes');
    MASK = bwareaopen(MASK,50);
    % fill in only the largest obj
end