function [BB PS] = maizeCob_forcondor(I,numberOfCobs)
        % declare vars
        PS.widthProfile = [];
        % get cob mask
        [B] = getCobMask_ver1(I);
        %B = imclose(B,strel('disk',101,0));
        %for e = 1:size(I,3)
        %mI(:,:,e) = I(:,:,e).*B;
        %end
        R = regionprops(B,'PixelIdxList','PixelList','Area','Image','BoundingBox');
        numberOfCobs = min(numberOfCobs,numel(R));
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % iterate over the cobs    
        for e = 1:numberOfCobs            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % get bounding box and the image
            BB{e} = R(e).BoundingBox;
            % get the binary mask
            subI = R(e).Image;
            % crop the color image for obtaining the cob color
            tmpI = imcrop(I,floor((R(e).BoundingBox)));            
            % make strip image for cob color
            tmpM = zeros(size(subI));
            tH = R(e).BoundingBox(4)/3;            
            tStr = round(+tH);
            tStp = round(2*tH);
            tmpM(tStr:tStp,:) = 1;
            % fill in the middle third
           
            
            tmpM = tmpM.*subI;
            PixelIdxList = find(tmpM);
            for k = 1:size(I,3)
                tmpP = tmpI(:,:,k);
                tmpC(k) = mean(tmpP(PixelIdxList));
            end
            RGB(e,:) = tmpC;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % get width profile
            WIDTH = sum(subI,2);
            fidx = find(WIDTH ~= 0);
            uW = mean(WIDTH(fidx));
            PS.average_WIDTH(e) = uW;
            PS.widthProfile = [PS.widthProfile ;interp1(1:numel(WIDTH),WIDTH,linspace(1,numel(WIDTH),1000))];
        end
        PS.RGB = RGB;
end
