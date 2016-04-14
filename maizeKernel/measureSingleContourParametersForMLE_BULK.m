function [M] = measureSingleContourParametersForMLE_BULK(contour,B,E,U,S,sm)

    
    % generate the normal and tangent space for the curve
    cE = getNormalsAndTangent(contour',sm);        
    % generate curve segments
    segs = genS(contour',S,cE);
    for e = 1:size(segs,3)
        C(e,:) = PCA_REPROJ(segs(:,2,e)',E,U);
    end

    
    
    

    % get the curvature values for gaussian smoothed contours
    out = cwtK_closed_imfilter(contour,{[5:10]});
    %M.K = [mean(out.K(1,:)) std(out.K(1,:))];
    M.K = [mean(out.K,2) C];

    
    
    
    
    currCentroid = fliplr(mean(contour));
    B = double(B);
    for e = 1:size(contour,1)
        VEC = [fliplr(contour(1,:)) - (currCentroid)];
        VEC = 3*VEC;
        H = norm(VEC);
        VEC_store(e,:) = VEC;
        % create line to sample along both major and minor                        
        nVEC = [-VEC(2) VEC(1)];
        nVEC_store(e,:) = nVEC;
        % make line to sample along
        nX = linspace(currCentroid(1)-nVEC(1),currCentroid(1)+nVEC(1),2*H);
        nY = linspace(currCentroid(2)-nVEC(2),currCentroid(2)+nVEC(2),2*H);

        % sample along the binary image and measure the major axis
        nLP = ba_interp2(double(B),nX,nY);
        nLPf = imfill(~logical(nLP>.5),[1 round(numel(nLP)/2)]);
        nfidx = find(nLP.*nLPf>.5);

        % make line to sample along
        X = linspace(currCentroid(1)-VEC(1),currCentroid(1)+VEC(1),2*H);
        Y = linspace(currCentroid(2)-VEC(2),currCentroid(2)+VEC(2),2*H);                

        % sample along the binary image and measure minor axis
        LP = ba_interp2(B,X,Y);
        LPf = imfill(~logical(LP>.5),[1 round(numel(LP)/2)]);
        fidx = find(LP.*LPf>.5);

        % find the base point and measure K
        baseP = [Y(fidx(1)) X(fidx(1))];
        delta = bsxfun(@minus,contour,baseP);
        delta = sum(delta.*delta,2);
        [~,sidx] = min(delta);
        Cbase(e,:) = PCA_REPROJ(segs(:,2,sidx)',E,U);
        % plot the major and minor axis
        M.MajorLine = [[nX(nfidx(1));nX(nfidx(end))],[nY(nfidx(1));nY(nfidx(end))]];
        M.MinorLine = [[X(fidx(1));X(fidx(end))],[Y(fidx(1));Y(fidx(end))]];
        
        % stack the major and minor axis
        M.MajorLength(e) = numel(nfidx)-1;
        M.MinorLength(e) = numel(fidx)-1;
    end
    M.K = [M.K Cbase];
    
           


    M = [M.MajorLength' M.MinorLength' M.K];
    M = [M(:,1).*M(:,2).^-1 M(:,3:end)];
    
    
    
    
    % get the eth contour and project to the kernels frame
    % of reference
    tmp = interp1(linspace(0,1,size(contour,1)),contour,linspace(0,1,500));
    utmp = mean(tmp,1);
    for e = 1:size(contour,1)

        VEC = VEC_store(e,:)/norm(VEC_store(e,:));
        nVEC = nVEC_store(e,:)/norm(nVEC_store(e,:));
        C = PCA_REPROJ(tmp,[VEC',nVEC']',utmp);
        lZ = C(:,1) < 0;
        gZ = C(:,1) > 0;
        BINS = [min(C(:,2)):max(C(:,2))];
        lf = ksdensity(C(lZ,2),BINS);
        gf = ksdensity(C(gZ,2),BINS);
        lf = lf / sum(lf);
        gf = gf / sum(gf);
        %MM = abs(sum(lf.*BINS) - sum(gf.*BINS));
        SYM(e) = norm(lf-gf);
    end
    M = [M SYM'];
    %MM(3) = MM;
    %{
    sf = gf - lf;
    plot(BINS,lf)
    hold on
    plot(BINS,gf,'r');
    %}
    %M.iContour = C; 
    %M.contour = contour;
end




% generate the normal and tangent space
function [segs] = genS(segment,segmentSize,E)
    halfBlock = (segmentSize-1)/2;    
    sz = size(segment);
    J = [segment';segment';segment'];
    tmp1 = im2col(J(:,1),[segmentSize 1]);
    tmp2 = im2col(J(:,2),[segmentSize 1]);    
    tmp1 = tmp1(:,sz(2)+1-halfBlock:sz(2)+sz(2)-halfBlock);
    tmp2 = tmp2(:,sz(2)+1-halfBlock:sz(2)+sz(2)-halfBlock);
    segs = cat(3,tmp1,tmp2);
    segs = permute(segs,[2 1 3]);
    segs = permute(segs,[2 3 1]);
    for e = 1:size(segs,3)
        sz = size(segs,1);
        U = segs((sz-1)/2,:,e);
        segs(:,:,e) = bsxfun(@minus,segs(:,:,e),U);
        segs(:,:,e) = (E(:,:,e)'*segs(:,:,e)')';
    end
    %{
    for e = 1:size(segs,3)
        plot(segs(:,1,e),segs(:,2,e))
        hold on
    end
    %}
end


% generate the normal and tangent space
function [E] = getNormalsAndTangent(segment,S)
    sz = size(segment);
    J = [segment';segment';segment'];
    % calculate curvature
    d1X1 = cwt(J(:,1),S,'gaus1');
    d1X2 = cwt(J(:,2),S,'gaus1');            
    T = cat(3,d1X1,d1X2);
    L = sum(T.*T,3).^.5;
    T = bsxfun(@times,T,L.^-1);
    N = cat(3,T(:,:,2),-T(:,:,1));
    N = squeeze(N)';
    N = N(:,sz(2)+1:sz(2)+sz(2));
    T = squeeze(T)';
    T = T(:,sz(2)+1:sz(2)+sz(2));
    E = cat(3,permute(T,[2 1]),permute(N,[2 1]));
    E = permute(E,[2 3 1]);
end