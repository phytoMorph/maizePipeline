function [M] = connectPlant(M)
    mM = M - imclearborder(M);
    pM = M - mM;
    [d idx] = bwdist(mM);
    R = regionprops(logical(pM),'PixelIdxList');
    for e = 1:numel(R)
        dd = [];
        for p = 1:numel(R(e).PixelIdxList)
            dd(p) = d(R(e).PixelIdxList(p));
            map(p) = idx(R(e).PixelIdxList(p));
        end
        [J,midx] = min(dd);
        [str(1) str(2)] = ind2sub(size(M),map(midx));
        [stp(1) stp(2)] = ind2sub(size(M),R(e).PixelIdxList(midx));
        DIS = dd(midx);
        X = round(linspace(str(1),stp(1),ceil(DIS)));
        Y = round(linspace(str(2),stp(2),ceil(DIS)));
        IDX = sub2ind(size(M),X,Y);
        M(IDX) = 1;
    end
end