function [MASK] = getMASK_ver0(I)
    hI = rgb2hsv(double(I)/255);
    %I = I(:,:,2);
    level = graythresh(hI(:,:,2));
    level = max(level,.2);
    
    MASK = hI(:,:,2) > level & hI(:,:,1) > .04 & hI(:,:,1) < .2 & hI(:,:,3) < .85; 
    MASK = hI(:,:,1) > .19 & hI(:,:,1) < .22;
    MASK = hI(:,:,2) > .18;
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
    MASK = imfill(MASK,'holes');
end