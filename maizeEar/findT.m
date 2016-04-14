function [T f Tchoices SNIP] = findT(sig,N,varargin)
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