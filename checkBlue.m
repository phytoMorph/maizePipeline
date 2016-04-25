function [I] = checkBlue(I, checkBlue_scaleFactor,addcut,baselineBlue)
    %{
        checkBlue finds blue header from the raw image and if there is, it
        removes blue header and returns resulted image.
    %}
    try
        fprintf(['starting with check for blue header.\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % hue and saturation
        % make mask
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        sI = imresize(I,checkBlue_scaleFactor);
        h = rgb2hsv_fast(sI,'single','H');
        v = rgb2hsv_fast(sI,'single','V');
        % find blue header from image 
        dI = h > 130/255 & h < 180/255 & v > 50/255;
        dI = sum(dI,2) > size(sI,2)/4;
        % measure blue area
        R = regionprops(dI,'Area');
        A = max([R.Area]);
        % it seems 600 would work down to 300DPI
        % it removes blue header from image if there exists
        if A > baselineBlue*checkBlue_scaleFactor
            fidx = find(dI);
            fidx = max(fidx);
            fidx = fidx *checkBlue_scaleFactor^-1;
            fidx = fidx + addcut;
            I = I(fidx:end,:,:);
        end
        fprintf(['end with check for blue header.\n']);
    catch ME
        fprintf(['******error in check blue******\n']);
    end
end