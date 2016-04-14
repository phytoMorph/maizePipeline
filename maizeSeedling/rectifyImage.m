function [rI] = rectifyImage(I)
    % make gray scale
    G = rgb2gray(I);
    % filter the image
    G = imfilter(G,fspecial('gaussian',[13 13],4),'replicate');
    % find edge
    E = edge(G);
    % find the 90-plumb
    [H,T,R] = hough(E','RhoResolution',0.5,'Theta',linspace(-30,30,100));
    P = houghpeaks(H,1);
    lines = houghlines(E',T,R,P,'FillGap',size(E,1)/3,'MinLength',300);
    xy = [lines(1).point1; lines(1).point2];
    xy = diff(xy,1,1);
    rI = imrotate(I,atan2(xy(1),xy(2))*180/pi,'crop');
    mask = sum(rI,3)==0;
    for e = 1:4
        fidx = find(sum(mask(:,1:end/2),1) > 100);
        rI(:,1:fidx(end),:) = [];
        rI = imrotate(rI,90);
        mask = imrotate(mask,90);
    end
end