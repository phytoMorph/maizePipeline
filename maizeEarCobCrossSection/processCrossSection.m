function [MAX MIN rowNumber] = processCrossSection(I,disp)
    DS = 50;
    samplePER = 1.5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % make gray, mask and simple process mask
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    G = rgb2gray(I);
    M = G > graythresh(G);
    M = bwareaopen(M,10000);
    M = imclose(M,strel('disk',110));
    R = regionprops(M,'Centroid');
    
    
    % crop the objects at PER greater than diameter 
    OUTER = samplePER*max(sum(M,2))/2;
    % make circular sample disk
    [n1 n2] = ndgrid(linspace(-pi,pi,2000),linspace(0,OUTER,OUTER));
    X = n2.*cos(n1);
    Y = n2.*sin(n1);
    X = X + R(1).Centroid(1);
    Y = Y + R(1).Centroid(2);
    % if display - show the sample rings downsampled by DS
    if disp
        h1 = figure;
        imshow(I,[]);
        hold on
        for e = 1:DS:size(X,2)
            plot(X(:,e),Y(:,e));
        end
    end
    % sample gray in disk hood
    S = ba_interp2(G,X,Y);
    % smooth and gradient
    smoothedS = imfilter(S,fspecial('disk',21),'replicate');
    [d1 d2] = gradient(smoothedS);
    sig = bindVec(sum(abs(d2)));
    thresh = graythresh(sig);
    sig = sig > thresh;
    fidx = find(sig);
    MAX = fidx(end);
    MIN = fidx(1);

    if disp
        plot(X(:,MIN),Y(:,MIN),'r','LineWidth',3);
        plot(X(:,MAX),Y(:,MAX),'y','LineWidth',3);
    end

%{
figure;
imshow(S,[]);
figure;
imshow(abs(d1),[])
figure;
imshow(abs(d2),[])
figure;
plot(sum(S,1))
figure;
plot(sum(abs(d2)));
%}
%{
figure;
plot(sum(abs(d1)),'r');
hold on
plot(sum(abs(d2)),'g');
    
    
    [g1 g2] = gradient(F);
%}

    PER = .8;
    WID = .5*(MAX-MIN);
    CEN = round(.5*(MIN+MAX));
    WID = round(PER*WID);
    VEC = CEN + (-WID:WID);
    F = S(:,VEC);
    
    [g1 g2] = gradient(F);
    gZ = g2 > 0;
    sig = (gZ.*g2);
    sig = bsxfun(@minus,sig,mean(sig,1));
    sig1 = mean(abs(fft(sig)),2);
    
    gZ = g2 < 0;
    sig = (gZ.*g2);
    sig = bsxfun(@minus,sig,mean(sig,1));
    sig2 = mean(abs(fft(sig)),2);
    
    F = mean([sig1,sig2],2);
    %sig(1:6) = 0;
    %{
    sig = mean(F,2);
    sig = sig - mean(sig);
    F = mean(abs(fft(sig,[],1)),2);
    %}
    F(1:6) = 0;
    %figure;
    %plot(F);
    [J,idx] = max(F(1:end/2));
    T = idx-1;
    rowNumber = T;
    if disp
        figure(h1);
        rowCount = T;
        title(num2str(rowCount));
        TH = linspace(-pi,pi,2000);
        SIG = 50*cos(TH*T);
        Ro = .5*(MIN+MAX);
        xl = (Ro+SIG).*cos(TH) + R(1).Centroid(1);
        yl = (Ro+SIG).*sin(TH) + R(1).Centroid(2);
        plot(xl,yl,'r','LineWidth',3);
    end
end