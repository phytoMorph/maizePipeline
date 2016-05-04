function [E,U] = generateCurveSegments(dB,S,sm)
    Nsegs = [];
    cnt = 1;
    for e = 1:numel(dB)
        % generate the normal and tangent space for the curve
        E = getNormalsAndTangent(dB{e}',sm);        
        % generate curve segments
        segs = genS(dB{e}',S,E);        
        Nsegs = [Nsegs squeeze(segs(:,2,:))];
        e;
    end
    
     %{
    
        h1 = figure;
        h2 = figure;
        for e = 1:size(segs,3)    
            figure(h1)
            plot(dB{1}(:,1),dB{1}(:,2),'r');
            hold on    
            plot(dB{1}(e,1),dB{1}(e,2),'b*');
            hold off
            
            figure(h2)
            plot(segs(:,1,e),segs(:,2,e))
            axis equal
            drawnow
            pause(.1)
    
        end
    
        for f = 1:size(segs,3)
                U = segs((S-1)/2,:,f);
                plot(segs(:,1,f),segs(:,2,f),'b')
                hold on
                quiver(U(1),U(2),E(2,2),E(2,1),10,'k')
                quiver(U(1),U(2),E(1,2),E(1,1),10,'g')
                drawnow
        end
    %}
  
    [SIM C U E L ERR LAM] = PCA_FIT_FULL(Nsegs',2);
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
