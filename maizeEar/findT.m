function [T f Tchoices SNIP] = findT(sig,N,varargin)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                findT.m is main function to handle ear analysis. It takes all input variables 
                for its dependent functions. This function returns final result including image with 
                bounding box. (Inputs are relative to 1200dpi)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                bindVec.m, interp1.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                sig:       An image to be analyze in a string that includes path and file name.
                N:            Number of cobs that are expected to be analyzed. 
                varargin:          A path to result of analysis in a string that includes '/'.
                rawImage_scaleFactor:   A desired percentage to resize the image.
                checkBlue_scaleFactor:  A desired percentage to resize the image in checkBlue.
                defaultAreaPix: The default pixel to be considered noise relative to 1200 dpi.
                addcut:         The boarder handle for checkBlue. This is an addition to blue top computed in checkBlue.
                baselineBlue:   The baseline threshold to remove blue header in checkBlue.
                fill:           The radius of disk for Kernel of an image close operation.
                CHUNK:          The number of chunk for input for FFT in myBlock0.
                RAD:            The value for window size.
                toSave:         0 - not to save, 1 - to save.
                toDisplay:      0 - not to save, 1 - to save.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    MAXT = 600; % max kernel length
    if nargin == 3
        MAXT = varargin{1};
    end
    Tline = N./((1:numel(sig))-1)';
    
    T_thresh = Tline < MAXT;
    [localMAX] = nonmaxsuppts(sig,8);
    
    % added for simulation
    %sig = sig.*T_thresh;
    
    nsig = bindVec(sig);
    thresh = graythresh(nsig);
    bidx = (nsig > thresh);
    
    
    fidx = find(localMAX.*bidx.*T_thresh);
    fpeak = sig(fidx);
    [fpeak sidx] = sort(fpeak,'descend');
    
    
    
    f = mean(fidx(sidx(1)));
    % first peak
    f = fidx(1);
    %%
    T = N/(f-1);
    f = T^-1;
    if nargout >= 3
        Tchoices = N.*fidx.^-1;
    end
    if nargout == 4
        SNIP = interp1(Tline.^-1,sig,linspace(0,.025,1000));
    end
end