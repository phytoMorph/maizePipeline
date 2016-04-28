function [I] = getCobMask_ver1(I,defaultAreaPix,colRange1,colRange2,fill)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                getCobMask_ver1.m turns image into black and white base upon background color information, 
                removes small objects(dusts) and operates closing.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                rgb2hsv_fast.m, imclearborder.m, imfill.m, bwareaopen.m, imopen.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                I:       An image to be analyzed in a matrix.
                defaultAreaPix: The default pixel to be considered noise relative to 1200 dpi.
                colRange1:      The color range for back ground to be removed in getcobMask.
                colRange2:      The color range for back ground to be removed in getcobMask.
                fill:           The radius of disk for Kernel of an image close operation.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get gray and filter
        I = rgb2hsv_fast(I,'single','H');
        I = I < colRange1/360 | I > colRange2/360;
        I = imclearborder(I);        
        I = imfill(I,'holes');
        %%Remove small objects. In this case less than 1000000 pixels (works for 1200dpi)
        %%now fracDpi handles defaultAreaPix outside of the func
        I = bwareaopen(I,defaultAreaPix);
        %%Check what these value mean
        I = imopen(I,strel('disk',fill));
        I = bwareaopen(I,defaultAreaPix);
end