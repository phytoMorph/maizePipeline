f = '/iplant/home/garf0012/maizeData/crosssectionData/W22_003.tif';
f = '~/Downloads/MN02-151002-cross-0003.tif';
I = imread(f);
%%
G = double(rgb2gray(I))/255;
M = G > graythresh(G);
M = bwareaopen(M,10000);
M = imclose(M,strel('disk',110));
imshow(M,[]);
%%
dB = bwboundaries(M);
imshow(I,[]);
hold on
for e = 1:numel(dB)
    plot(dB{e}(:,2),dB{e}(:,1),'r');
end
%%
G = imcrop(G);
%%
close all
f = '~/Downloads/MN02-151002-cross-0003.tif';
f = '~/Downloads/MN02-151002-cross-0034.tif';
I = imread(f);
I = imcrop(I);
%
close all
G = double(rgb2gray(I))/255;
M = G > graythresh(G);
M = bwareaopen(M,10000);
M = imclose(M,strel('disk',110));
R = regionprops(M,'Centroid');
imshow(M,[]);
%
OUTER = 1200;
close all
[n1 n2] = ndgrid(linspace(-pi,pi,2000),linspace(0,OUTER,OUTER));
X = n2.*cos(n1);
Y = n2.*sin(n1);
X = X + R(1).Centroid(1);
Y = Y + R(1).Centroid(2);
h1 = figure;
imshow(I,[]);
hold on
for e = 1:50:size(X,2)
    plot(X(:,e),Y(:,e));
end

S = ba_interp2(G,X,Y);
OS = S;
S = imfilter(S,fspecial('disk',21),'replicate');
[d1 d2] = gradient(S);



RING = sum(abs(d1),1);
[p,idx] = find(RING == imdilate(RING,strel('disk',51)));
val = RING(idx);
[J,sidx] = sort(val,'descend');
idx = idx(sidx(1:2));
idx = sort(idx);
MAX = idx(2);
MIN = idx(1);


sig = bindVec(sum(abs(d2)));
thresh = graythresh(sig);
sig = sig > thresh;
fidx = find(sig);
MAX = fidx(end);
MIN = fidx(1);


plot(X(:,MIN),Y(:,MIN),'r','LineWidth',3);
plot(X(:,MAX),Y(:,MAX),'y','LineWidth',3);

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
figure;
plot(sum(abs(d1)),'r');
hold on
plot(sum(abs(d2)),'g');
F = OS(:,MIN:MAX);
%[d1 F] = gradient(F);
%gz = F > 0;
sig = mean(F,2);
sig = sig - mean(sig);
F = mean(abs(fft(sig,[],1)),2);
%figure;
%plot(F);
[J,idx] = max(F);
%freq = (idx-1)/(size(F,1));
%T = 1/freq;
T = idx-1;
figure(h1);
rowCount = T;
title(num2str(rowCount));
TH = linspace(-pi,pi,2000);
SIG = 50*cos(TH*T);
Ro = .5*(MIN+MAX);

xl = (Ro+SIG).*cos(TH) + R(1).Centroid(1);
yl = (Ro+SIG).*sin(TH) + R(1).Centroid(2);
plot(xl,yl,'r','LineWidth',3)
%%
close all
G = double(rgb2gray(I))/255;
M = G > graythresh(G);
M = bwareaopen(M,10000);
M = imclose(M,strel('disk',110));
STRIPG = 5;
imshow(I,[])
F = [];
S = [];
SNIP = 50;
for loop = 1:80
   
    dB = bwboundaries(M);
    hold all
    
    for e = 1%1:numel(dB)
        plot(dB{e}(:,2),dB{e}(:,1));
        drawnow
        % sample along boundary
        sam = ba_interp2(G,dB{e}(:,2),dB{e}(:,1));
        % interp1 1000
        L = size(dB{e},1);
        sam = interp1(linspace(1,L,L),sam,linspace(1,L,5000));
        sam = imfilter(sam,fspecial('average',[1 100]),'replicate');
        S(loop,:) = sam;
        sam = sam - mean(sam);
        f = fft(sam);
        f = [f(1:SNIP) f(end-SNIP+1:end)];
        f = fftshift(f);
        
        F(loop,:) = abs(f);
    end
    loop
     M = imerode(M,strel('disk',STRIPG));
end
%%
close all
G = double(rgb2gray(I))/255;
M = G > graythresh(G);
M = bwareaopen(M,10000);
M = imclose(M,strel('disk',110));
