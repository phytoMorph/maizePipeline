function [I] = getCobMask_ver1(I,defaultAreaPix,fracDpi,colRange1,colRange2,fill)
        %{
            getCobMask turns image into black and white base upon background color information,
            removes small objects(dusts) and operates closing.
        %}
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get gray and filter
        I = rgb2hsv_fast(I,'single','H');
        I = I < colRange1/360 | I > colRange2/360;
        I = imclearborder(I);        
        I = imfill(I,'holes');
        %%Remove small objects. In this case less than 1000000 pixels (works for 1200dpi)
        areaRemove = round(defaultAreaPix/fracDpi);
        I = bwareaopen(I,areaRemove);
        %%Check what these value mean
        I = imopen(I,strel('disk',fill));
        I = bwareaopen(I,areaRemove);
end