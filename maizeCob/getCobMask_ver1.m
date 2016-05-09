function [Mask_out] = getCobMask_ver1(I,defaultAreaPix,colRange1,colRange2,fill)
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
        Mask_out = rgb2hsv_fast(I,'single','H');
        Mask_out = Mask_out < colRange1/360 | Mask_out > colRange2/360;
        % take this out and retry on May,4 2016
        
        %{
        %Mask_out = imclearborder(Mask_out);
        for e = 1:4
            Mask_out(:,1) = 0;
            Mask_out = imrotate(Mask_out,90);
        end
        %}
        Mask_out = imfill(Mask_out,'holes');
        Mask_out = bwareaopen(Mask_out,defaultAreaPix);
        Mask_out = imopen(Mask_out,strel('disk',fill));
        Mask_out = bwareaopen(Mask_out,defaultAreaPix);
end