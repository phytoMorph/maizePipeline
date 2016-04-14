function [yi] = lookUpLOG(H,m)
    for e = 1:numel(H)
        yi(:,e) = interp1(H{e}.xi,H{e}.f,m(:,e),'cubic',eps);
    end
    yi = log(yi);
    %yi(isinf(yi)) = 0;
end