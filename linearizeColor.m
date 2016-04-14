%% look for data
FilePath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/cobData/output/'
FileList = {};
FileExt = {'csv'};
verbose = 0;
[FileList] = gdig(FilePath,FileList,FileExt,verbose);
%% read decoder files
d1 = readtext('/home/nate/Downloads/Full2013_2014CobKernelDecoder_052815_njh.csv');
d1(2:2:end,:) = [];
d2 = readtext('/home/nate/Downloads/2013_2014_fullMap_Observations.csv');
d2(2:2:end,:) = [];
d2 = d2(2:end,[2 7]);
d1 = d1(2:end,[1 5 6 7]);
cnt = 1;
CL = [2 3];
d1_1 = {};
for c = 1:2
    for e = 1:size(d1,1)
        d1_1{cnt,1} = d1{e,CL(c)};
        d1_1{cnt,2} = d1{e,1};
        d1_1{cnt,3} = d1{e,4};
        cnt = cnt + 1;
    end
end
%% read the widiv population list
[P1,POP,K] = xlsread('/home/nate/Downloads/WiDiv population.xlsx');
for e = 1:numel(POP)
    POP{e} = rmSpecialChar(POP{e});
end
%% find rgb
rm = [];
for e = 1:numel(FileList)
    if isempty(strfind(FileList{e},'RGB'))
       rm = [rm e]; 
    end
end
FileList(rm) = [];
numel(FileList)
%% load data
RGB = [];
sRGB = [];
EV = [];
for e = 1:numel(FileList)
    tmp = csvread(FileList{e});
    RGB = [RGB;mean(tmp,1)];
    sRGB = [sRGB;std(tmp,1)];
    %EV =[EV;e*ones(size(tmp,1),1)];
    EV =[EV;e*ones(1,1)];
    e
    numel(FileList)
end

%% plot
close all
plot3(RGB(:,1),RGB(:,2),RGB(:,3),'.')
%% fit line
close all
[S C U E L ERR LAM] = PCA_FIT_FULL(RGB,1);
plot3(RGB(:,1),RGB(:,2),RGB(:,3),'.');
hold on
quiver3(U(1),U(2),U(3),E(1),E(2),E(3),.5);
quiver3(U(1),U(2),U(3),-E(1),-E(2),-E(3),.5);
%% guassian mix model
options = statset('Display','iter');
clusterNum = 2;
obj = gmdistribution.fit(RGB,clusterNum,'Options',options);
close all
figure;hold on
kidx = cluster(obj,RGB);
mag = .2;
for e = 1:clusterNum
    [eV eL]= eigs(obj.Sigma(:,:,e));
    for i = 1:3
        %quiver3(obj.mu(e,1),obj.mu(e,2),obj.mu(e,3),mag*obj.Sigma(1,i,e),mag*obj.Sigma(2,i,e),mag*obj.Sigma(3,i,e));
        quiver3(obj.mu(e,1),obj.mu(e,2),obj.mu(e,3),mag*eV(1,i),mag*eV(2,i),mag*eV(3,i),0);
    end
end
CL = {'r.','b.','g.'};
for e = 1:clusterNum 
    plot3(RGB(kidx==e,1),RGB(kidx==e,2),RGB(kidx==e,3),CL{e},'MarkerSize',3);
end
%% remove low prob data points
%% backup data
RGB_BK = RGB;
%% restore from backu
RGB = RGB_BK;
%%
toRM = 300;
PR = pdf(obj,RGB);
[J,sidx] = sort(PR);
sRGB(sidx(1:toRM),:) = [];
RGB(sidx(1:toRM),:) = [];
EV(sidx(1:toRM)) = [];
kidx(sidx(1:toRM)) = [];
%% PCA on clusters
clear S C U E L ERR LAM
for e = 1:clusterNum    
    [S{e} C{e} U{e} E{e} L{e} ERR{e} LAM{e}] = PCA_FIT_FULL(RGB(kidx==e,:),3);
end
%% give global space and align vectors
close all
figure
hold on
CL = {'r.','b.','g.'};
for e = 1:clusterNum 
    plot3(RGB(kidx==e,1),RGB(kidx==e,2),RGB(kidx==e,3),CL{e},'MarkerSize',3);
end

[gS gC gU gE gL gERR gLAM] = PCA_FIT_FULL(RGB,1);
quiver3(gU(1),gU(2),gU(3),gE(1),gE(2),gE(3),'k');
for e = 1:clusterNum
    if gE'*E{e}(:,1) < 0
        E{e}(:,1) = -E{e}(:,1);
    end
    
    for d = 1:1%size(E{e},2)
        quiver3(U{e}(1),U{e}(2),U{e}(3),E{e}(1,d),E{e}(2,d),E{e}(3,d));
    end
end
%% obtain the pcs scores for each cluster
nScores = [];
for e = 1:clusterNum
    tidx = kidx==e;
    tmp = RGB(tidx,:);
    v = PCA_REPROJ(tmp,E{e},U{e});
    nScores(tidx,:) = v;
end
toExport = [kidx nScores sRGB RGB gS];
%% build for export
UQn = unique(EV);
cnt = 1;
EXP = {};
P = 0;
for e = 1:numel(UQn)
    tmp = UQn(e);
    fidx = find(EV==tmp);
    P = P + numel(fidx);
    for f = 1:numel(fidx)
        [pth,nm,ext] = fileparts(FileList{EV(fidx(f))});
        EXP{cnt,1} = nm;
        for n = 1:size(toExport,2)
            EXP{cnt,1+n} = toExport(fidx(f),n);
        end
        cnt = cnt + 1;
    end
end
%cell2csv('/mnt/scratch1/phytoM/tmp/Mona.csv',EXP);
%% remove tag 
for e = 1:size(EXP,1)
    EXP{e,1} = EXP{e,1}(1:end-7);
end
%% get geno type
[J,idx1,idx2] = intersect(d1_1(:,1),EXP(:,1));
pln = d1_1(idx1,2);
[J,i1,i2] = intersect(pln,d2(:,1));
subE = EXP(idx2(i1),:);
G = d2(i2,2);
subE = [subE,G];
for e = 1:numel(G)
    if isnumeric(G{e})
        G{e} = num2str(G{e});
    end
    G{e} = rmSpecialChar(G{e});
end
genoTypeColor = [];
genoTypeColor2 = [];
sPOPRGB = [];
genoTypePOP = {};
DF = [];
for e = 1:numel(POP)
    fidx = find(strcmp(G(:,1),POP{e}));
    if numel(fidx) >= 1
        
    end
    K = cell2mat(subE(fidx,end-3:end-1));
    genoTypeColor = [genoTypeColor;mean(K,1)];
    
    K2 = cell2mat(subE(fidx,end-3-3:end-1-3));
    DF = [DF;numel(K2)];
    genoTypeColor2 = [genoTypeColor2;mean(K2,1)];
    
    K3 = cell2mat(subE(fidx,end-3-3-3:end-1-3-3));
    sPOPRGB = [sPOPRGB;mean(K3,1)];
    if ~isempty(K)
        genoTypePOP{end+1} = POP{e};
    end
end
%[J,idx1,idx2] = intersect(G,POP);
%% find max and min along global HERE FOR PAPER
close all
[V1,mIDX] = max(genoTypeColor(:,1));
[V1,MIDX] = min(genoTypeColor(:,1));
LT = cat(3,ones(300,300)*genoTypeColor(mIDX,1),ones(300,300)*genoTypeColor(mIDX,2),ones(300,300)*genoTypeColor(mIDX,3)); 
genoTypePOP{mIDX}
genoTypeColor(mIDX,:)
sPOPRGB(mIDX,:)
DR = cat(3,ones(300,300)*genoTypeColor(MIDX,1),ones(300,300)*genoTypeColor(MIDX,2),ones(300,300)*genoTypeColor(MIDX,3)); 
genoTypePOP{MIDX}
genoTypeColor(MIDX,:)
sPOPRGB(MIDX,:)
imshow([LT,DR],[]);
%% look at images for strange between
EXP(idx2(i1(fidx)),:)

f1 = [pth filesep subE{fidx(1),1} '_result.tif'];
I1 = imread(f1);
f2 = [pth filesep subE{fidx(2),1} '_result.tif'];
I2 = imread(f2);

%%
V = PCA_REPROJ(RGB,gE,gU);
[~,midx] = min(V);
[~,Midx] = max(V);
Eidx = EV(Midx);
eidx = EV(midx);
FileList(Eidx)
FileList(eidx)
ERidx = find(EV == Eidx);
eRidx = find(EV == eidx);
MRGB = mean(RGB(ERidx,:))
SRGB = std(RGB(ERidx,:))
eRGB = mean(RGB(eRidx,:))
sRGB = std(RGB(eRidx,:))
FileList(EV(Eidx))
FileList(EV(eidx))
%%  sim on clusters not equal
MM = [];
for e = 1:clusterNum
    toSim = 1;
    uC = mean(C{e},1);
    %lC = linspace(min(C{e}(:,toSim)),max(C{e}(:,toSim)),5);
    
    tM = [];
    for s = 1:numel(lC{e})
        tmp = uC;
        tmp(toSim) = lC{e}(s);
        M = PCA_BKPROJ(tmp,E{e},U{e});
        R = M(1)*ones(200,200);
        G = M(2)*ones(200,200);
        B = M(3)*ones(200,200);
        P = cat(3,R,G,B);
        imshow(P,[]);
        title(num2str(e))
        tM = [tM P];
        drawnow
        pause(.1);
    end
    %waitforbuttonpress
    MM = [MM;tM];
    
end
figure;
imshow(MM);
%% normalize clusters
close all
figure;
hold on;
MAG = 2;
CL = {'r' 'b'};
for e = 1:2
    [f{e} xi{e}] = ksdensity(C{e}(:,1));
    plot(xi{e},f{e},CL{e})
    sd = LAM{e}(1).^.5;
    lC{e} = linspace(-MAG*sd,MAG*sd,5);
end
%% model bi-normal 
clusterNum = 2;
toClus = 2;
sub_obj = gmdistribution.fit(C{toClus}(:,1),clusterNum,'Options',options);

sub_kidx = cluster(sub_obj,C{toClus}(:,1));
sCL = {'g' 'k'};
for e = 1:2
    %[f xi] = ksdensity(C{toClus}(sub_kidx==e,1));
    %plot(xi,f,sCL{e})
    Y{e} = normpdf(xi{toClus},sub_obj.mu(e,1),sub_obj.Sigma(1,:,e).^.5);
    plot(xi{toClus},Y{e},sCL{e})
    
end
tot = Y{1} + Y{2};
tot = bindVec(tot)*max(f{toClus});
plot(xi{toClus},tot,'c')










%% sim the data
close all
L = linspace(min(C),max(C),50);
M = PCA_BKPROJ(L',E,U);
for e = 1:size(M,1)
    R = M(e,1)*ones(200,200);
    G = M(e,2)*ones(200,200);
    B = M(e,3)*ones(200,200);
    P = cat(3,R,G,B);
    imshow(P,[])
    drawnow
    pause(.25);
end
%% histogram
close all
ksdensity(C)
%% break into groups and qqplot each group
kidx = kmeans(C,2);
%tmp = bindVec(C);
%level = graythresh(tmp);
%kidx = double(tmp < level) + 1;
for u = 1:2
    fidx = find(kidx==u);
    figure;
    qqplot(C(fidx));
end
figure;
qqplot(C);
figure;
CL = {'r.' 'b.'};
for u = 1:2
    fidx = find(kidx==u);
    plot3(RGB(fidx,1),RGB(fidx,2),RGB(fidx,3),CL{u});
    hold all;
end
%%
%% look at patches  and compare to sim
close all
for e = 1:size(RGB,1)
    R = RGB(e,1)*ones(200,200);
    G = RGB(e,2)*ones(200,200);
    B = RGB(e,3)*ones(200,200);
    Rs = S(e,1)*ones(200,200);
    Gs = S(e,2)*ones(200,200);
    Bs = S(e,3)*ones(200,200);
    P = cat(3,R,G,B);
    Ps = cat(3,Rs,Gs,Bs);
    P = [P Ps];
    imshow(P,[])
    drawnow
    pause(.25)
end
%% show values
close all
V = [-.4 -.3 -.2 -.05 .1 .2]';
M = PCA_BKPROJ(V,E,U);
MP = [];
for e = 1:size(M,1)
    R = M(e,1)*ones(200,200);
    G = M(e,2)*ones(200,200);
    B = M(e,3)*ones(200,200);
    P = cat(3,R,G,B);
    MP = [MP P];
    imshow(P,[])
    drawnow
end
imshow(MP,[])
%% show model
close all
V = [-.4 -.3 -.2]';
M = PCA_BKPROJ(V,E,U);
MP = [];
for e = 1:size(M,1)
    R = M(e,1)*ones(200,200);
    G = M(e,2)*ones(200,200);
    B = M(e,3)*ones(200,200);
    P = cat(3,R,G,B);
    MP = [MP P];
    imshow(P,[])
    drawnow
end
imshow(MP,[]);
V = [-.05 .1 .2]';
M = PCA_BKPROJ(V,E,U);
MP1 = [];
for e = 1:size(M,1)
    R = M(e,1)*ones(200,200);
    G = M(e,2)*ones(200,200);
    B = M(e,3)*ones(200,200);
    P = cat(3,R,G,B);
    MP1 = [MP1 P];
    imshow(P,[])
    drawnow
end
MM = [MP;MP1];
imshow(MM,[])
