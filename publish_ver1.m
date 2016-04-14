% scan for ear images
eFilePath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/earData/';
eFileList = {};
FileExt = {'tif'};
verbose = 1;
eFileList = gdig(eFilePath,eFileList,FileExt,verbose);
% scan for cob images
cFilePath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/cobData/';
cFileList = {};
FileExt = {'tif'};
verbose = 1;
cFileList = gdig(cFilePath,cFileList,FileExt,verbose);
% scan for kernel images
kFilePath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/kernelData/';
kFileList = {};
FileExt = {'tif'};
verbose = 1;
kFileList = gdig(kFilePath,kFileList,FileExt,verbose);
%% scan for mat files for ear data
mFilePath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/earData/output/';
mFileList = {};
FileExt = {'mat'};
verbose = 1;
mFileList = gdig(mFilePath,mFileList,FileExt,verbose);
%% get the file names for the ear mat files
nm = {};
for e = 1:numel(mFileList)
    [pth,nm{e},ext] = fileparts(mFileList{e});
end
%% scan for mat files for cob data
mcFilePath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/cobData/output/';
mcFilePath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/Results_cobData_mat/';
mcFileList = {};
FileExt = {'mat'};
verbose = 1;
mcFileList = gdig(mcFilePath,mcFileList,FileExt,verbose);
%% get the file names for the cob mat files
cnm = {};
for e = 1:numel(mcFileList)
    [pth,cnm{e},ext] = fileparts(mcFileList{e});
end
%% find the return images for the top 20 odds
searchPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/earData/output/';
oPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/Results_earData/';
mkdir(oPath)
X = 20;
for e = 1:2:2*X
    [jp,jn,je] = fileparts(eFileList{e}(1:end-4));
    fileName = [searchPath jn '_result.tif'];
    if exist(fileName)
        sourceName = fileName;
        targetName = [oPath jn '_result.tif'];
        fprintf([sourceName '-->' targetName '\n'])
        CMD = ['cp -a ' sourceName ' ' targetName];
        system(CMD,'-echo');
        CMD
    end
end
%% find the return images for the top 20 odds
searchPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/earData/output/';
oPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/Results_earData/';
mkdir(oPath)
X = 20;
for e = 1:2:2*X
    [jp,jn,je] = fileparts(eFileList{e}(1:end-4));
    fileName = [searchPath jn '_result.tif'];
    if exist(fileName)
        sourceName = fileName;
        targetName = [oPath jn '_result.tif'];
        fprintf([sourceName '-->' targetName '\n'])
        CMD = ['cp -a ' sourceName ' ' targetName];
        system(CMD,'-echo');
        CMD
    end
end
%% find the return mat files for the top 20 odds ears
searchPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/earData/output/';
oPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/data/matFiles/Results_earData_mat/';
mkdir(oPath)
X = 20;
for e = 1:2:2*X
    [tp,tnm,te] = fileparts(eFileList{e});
    toSearch = strcmp(tnm,nm);
    if any(toSearch)
        % find and load the matlab file
        fidx = find(toSearch);
        sourceName = mFileList{fidx};
        [j1,jn,je] = fileparts(sourceName);        
        targetName = [oPath jn je];
        fprintf([sourceName '-->' targetName '\n'])
        CMD = ['cp -a ' sourceName ' ' targetName]
        system(CMD,'-echo');
        CMD
    end
end
%% short cut for re-extracting the fft peaks
inPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/data/matFiles/Results_earData_mat/';
tmpFileList = {};
FileExt = {'mat'};
verbose = 1;
tmpFileList = gdig(inPath,tmpFileList,FileExt,verbose);
tmpT = [];
for m = 1:numel(tmpFileList)
    A = load(tmpFileList{m});
    for ear = 1:3
        for u = 1:numel(A.RAD)
            tmpT(m,ear,u,1) = findT(A.FT.G{ear}{u},A.RAD(u));
            tmpT(m,ear,u,2) = findT(A.FT.L{ear}{u},A.RAD(u));
        end
    end
end
tmpT = mean(mean(tmpT,4),3);
tmpT = tmpT';
%% load the mat file for the fft
A = load('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/data/matFiles/Results_earData_mat/Scan1-150122-0001.mat');
sig = A.FT.G{1}{end};
dR = A.RAD(end);
ufT = sig(1:dR);
% filter the first half of the signal
h = fspecial('average',[5 1]);
ufT = imfilter(ufT,h);                
N = 2*dR+1;
[Period freq] = findT(ufT,2*dR+1);
Tline = N./((1:numel(ufT))-1)';
oPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/data/fft.csv';
csvwrite([oPath],[.0211^-1*Tline.^-1 ufT]);
%% match the top X images with the mat file for the ear images
X = 20;
E_algoDATA_kernel = [];
E_algoDATA_hw = [];
full_E_imageName = {};

eFileName = {};
emFileName = {};
for e = 1:2:2*X
    [tp,tnm,te] = fileparts(eFileList{e});
    toSearch = strcmp(tnm,nm);
    if any(toSearch)        
        % find and load the matlab file
        fidx = find(toSearch);
        A = load(mFileList{fidx});
        toM = mean(A.KernelLength,2);
        % if there are three
        if size(toM,1) == 3
            full_E_imageName{end+1} = eFileList{e};
            eFileName{end+1} = tnm;
            E_algoDATA_kernel = [E_algoDATA_kernel;toM];            
            [pth emFileName{end+1} ext] = fileparts(mFileList{fidx});
            for k = 1:3
                tmp = [max(A.S.widthProfile(k,:)) A.BB{k}(4)];
                E_algoDATA_hw = [E_algoDATA_hw ; tmp];
            end
        else
            tnm
        end
    end
end
%% match the top X images with the mat file for the cob images
X = 20;
C_algoDATA_hw = [];
full_C_imageName = {};
SIGSTACK = [];
cFileName = {};
cmFileName = {};
for e = 1:2:2*X
    [tp,tnm,te] = fileparts(cFileList{e});
    toSearch = strcmp(tnm,cnm);
    if any(toSearch)        
        % find and load the matlab file
        fidx = find(toSearch);
        A = load(mcFileList{fidx});        
        % if there are three
        if numel(A.BB) == 3
            full_C_imageName{end+1} = cFileList{e};
            cFileName{end+1} = tnm;            
            [pth cmFileName{end+1} ext] = fileparts(mcFileList{fidx});
            for k = 1:3
                sig = A.S.widthProfile(k,:);
                SIGSTACK = [SIGSTACK;sig];
                sig = imfilter(sig,fspecial('average',[1 101]),'replicate');
                tmp = [max(sig) A.BB{k}(4)];
                C_algoDATA_hw = [C_algoDATA_hw ; tmp];
            end
        else
            tnm
        end
    end
end
%% load images for clicks along width and height for ears
I = {};
for n = 1:numel(full_E_imageName)
    I{n} = imread(full_E_imageName{n});
    n
end
%% hand measure the width and height for ears
%E_handDATA_hw = [];
for i = 1:numel(full_E_imageName)
    
    [pth,sane_check_measure1_name{i},ext] = fileparts(full_E_imageName{i});    
    imshow(I{i});
    title(num2str(i));
    [c r V] = impixel();
    
    dr = diff(r,1,1);
    dc = diff(c,1,1);
    dl_Ear = dr.^2 + dc.^2;
    dl_Ear = dl_Ear.^.5;
    dl_Ear = dl_Ear(1:2:end);
    E_handDATA_hw = [E_handDATA_hw;reshape(dl_Ear,[3 2])];
end
%% save ear measurements
close all
corr(E_algoDATA_hw(:,1),E_handDATA_hw(:,1))
plot(E_algoDATA_hw(:,1),E_handDATA_hw(:,1),'.')
figure;
corr(E_algoDATA_hw(:,2),E_handDATA_hw(:,2))
plot(E_algoDATA_hw(:,2),E_handDATA_hw(:,2),'.')
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/earWidth.csv',25.4/1200*[E_algoDATA_hw(:,1) E_handDATA_hw(:,1)])
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/earLength.csv',25.4/1200*[E_algoDATA_hw(:,2) E_handDATA_hw(:,2)])
%% load images for clicks along width and height for cobs
I = {};
for n = 1:numel(full_C_imageName)
    I{n} = imread(full_C_imageName{n});
    n
end
%% hand measure the width and height for cobs
C_handDATA_hw = [];
for i = 1:numel(full_C_imageName)
    
    [pth,sane_check_measure2_name{i},ext] = fileparts(full_C_imageName{i});    
    imshow(I{i});
    title(num2str(i));
    [c r V] = impixel();
    
    dr = diff(r,1,1);
    dc = diff(c,1,1);
    dl_Cob = dr.^2 + dc.^2;
    dl_Cob = dl_Cob.^.5;
    dl_Cob = dl_Cob(1:2:end);
    C_handDATA_hw = [C_handDATA_hw;reshape(dl_Cob,[3 2])];
end
%% save cob measurements
close all
corr(C_algoDATA_hw(:,1),C_handDATA_hw(:,1))
p = polyfit(C_algoDATA_hw(:,1),C_handDATA_hw(:,1),1);
plot(C_algoDATA_hw(:,1),C_handDATA_hw(:,1),'.');

figure;
corr(C_algoDATA_hw(:,2),C_handDATA_hw(:,2));
plot(C_algoDATA_hw(:,2),C_handDATA_hw(:,2),'.')
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/cobWidth.csv',25.4/1200*[C_algoDATA_hw(:,1) C_handDATA_hw(:,1)])
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/cobLength.csv',25.4/1200*[C_algoDATA_hw(:,2) C_handDATA_hw(:,2)])
%% look for outliers in cob data
here=1
[J midx] = max(abs(C_algoDATA_hw(:,1) - C_handDATA_hw(:,1)));
C_algoDATA_hw(midx,1)
C_handDATA_hw(midx,1)


oPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/Results_cobData/';
searchPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/cobData/output/';
A = load([searchPath cmFileName{midx/3} '.mat'])
toLook = 5;
sig = A.S.widthProfile(3,:);
figure;plot(sig)
max(sig)
[pth,nm,ext] = fileparts(full_C_imageName{5});
outName = [oPath nm '_result.tif'];
figure;
I = imread(outName);
%close all
imshow(I,[])
%I = imread(full_C_imageName{5});
%[c v V] = impixel(I);
%% run through the image for the paper
oPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/MasterData_forMar2214/Results_cobData_mat/';
for e = 1:numel(full_C_imageName)
    singleCobImage(full_C_imageName{e},3,oPath,1,1);
end

%% for kernels
fileName = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/10KH_NJHforNathan_050115.csv';
[D,T] = readtext(fileName);
D(1,:) = [];
%% search for kernel data
KERNEL_AUTO_DATA = [];
KERNEL_HAND_DATA = [];
KERNEL_NAME_CHECK1={};
KERNEL_NAME_CHECK2 = {};
KERNEL_CHECK_NAME_FULL = {}; 
for e = 1:size(D,1)
    tmpT2 = [];
    toSearch = strcmp(D{e,1},nm);
    if any(toSearch)
        fidx = find(toSearch);
        A = load(mFileList{fidx});        
        
        for ear = 1:3
            sigT = [];
            for u = 1:numel(A.RAD)
               
                ufT = A.FT.G{ear}{u}(1:A.RAD(u));                
                h = fspecial('average',[8 1]);
                ufT = imfilter(ufT,h);                
                [tmpT2(ear,u,1),j1 j2,SIG] = findT(ufT,2*A.RAD(u)+1);
                %sigT(1,:) = ufT;
                sigT(1,u,:) = SIG;
                %{
                %%
                plot(ufT(1:100));
                drawnow
                pause(.3)
                %}
                
                ufT = A.FT.L{ear}{u}(1:A.RAD(u));
                h = fspecial('average',[8 1]);
                ufT = imfilter(ufT,h);
                [tmpT2(ear,u,2),j1 j2,SIG] = findT(ufT,2*A.RAD(u)+1);
                sigT(2,u,:) = SIG;
                
                
                
                ufT = .5*(A.FT.L{ear}{u}(1:A.RAD(u)) + A.FT.G{ear}{u}(1:A.RAD(u)));
                h = fspecial('average',[8 1]);
                ufT = imfilter(ufT,h);
                [tmpT2(ear,u,3),j1 j2,SIG] = findT(ufT,2*A.RAD(u)+1);
                sigT(3,u,:) = SIG;
               
                drawnow
                
                %{
                %%
                plot(ufT(1:100));
                drawnow
                pause(.3)
                %}
                
                
            end
            sigT = mean(squeeze(mean(sigT,2)),1);
            
            [J,midx] = max(sigT);
            J = linspace(0,.025,1000);
            toM(ear) = J(midx).^-1;
            %plot(sigT')
            %drawnow
        end
        %toM = mean(A.KernelLength,2);
        %toM = mean(mean(tmpT2,3),2);
        %toM = mean(tmpT2(:,:,1),2);
        KERNEL_AUTO_DATA = [KERNEL_AUTO_DATA toM];
        if size(toM,1) == 3
            KERNEL_NAME_CHECK1{end+1} = D{e,1};            
            tmpH = reshape(cell2mat(D(e,2:end)),[4 3]);
            KERNEL_HAND_DATA = [KERNEL_HAND_DATA mean(tmpH,1)'];
            [pth KERNEL_NAME_CHECK2{end+1} ext] = fileparts(mFileList{fidx});            
            KERNEL_CHECK_NAME_FULL{end+1} = mFileList{fidx};
        end
    end
    e
end
corr(KERNEL_HAND_DATA(:),KERNEL_AUTO_DATA(:))
%% try with shortcut and new findT
corr(tmpT(:),KERNEL_HAND_DATA(:))
%% look at opt error in kernels
close all
kERR = abs(KERNEL_AUTO_DATA - KERNEL_HAND_DATA/10);
%kERR = -(KERNEL_AUTO_DATA - KERNEL_HAND_DATA/10);
[mE,midx] = max(max(kERR));
[~,mIDX] = max(kERR(:));
fileName = strrep(KERNEL_CHECK_NAME_FULL{midx},'.mat','_result.tif');
Ie = imread(fileName);
imshow(Ie,[]);
figure
plot(KERNEL_AUTO_DATA(:),KERNEL_HAND_DATA(:)/10,'.')
hold on
plot(KERNEL_AUTO_DATA(mIDX),KERNEL_HAND_DATA(mIDX)/10,'ro')
[b,bint,r,rint,stats] = regress(KERNEL_HAND_DATA(:),KERNEL_AUTO_DATA(:));
%% try my own hand measurements for outlier
close all
I = imread(eFileList{2*midx-1});

%%
imshow(I,[]);
[c r V] = impixel();
dR = diff(r);dR = mean(dR(1:2:end));
%%
close all
toSearch = strcmp(D{midx,1},nm);
fidx = find(toSearch);
A = load(mFileList{fidx});        
cobM = 2;
P1 = A.BB{cobM}(1:2);
D1 = A.BB{cobM}(3:4)/2;
D1(2) = A.BB{cobM}(4);
P1(1) = P1(1) + D1(1);
P2 = P1;
P2(2) = P2(2) + D1(2);


J1 = linspace(P1(1),P2(1),1000);
J2 = linspace(P1(2),P2(2),1000);
TH = KERNEL_HAND_DATA(mIDX);
toM = KERNEL_AUTO_DATA(mIDX);
FUN = 100*cos(2*pi/(TH/10)*J2);
FUN2 = 100*cos(2*pi/toM*J2);
FUN3 = 100*cos(2*pi/dR*J2);


imshow(I,[])
hold on
plot(J1,J2)
plot(FUN+J1+100,J2,'r')
plot(FUN2+J1-100,J2,'g')
plot(FUN3+J1-200,J2,'b')
plot(P1(1),P1(2),'g*')
plot(P2(1),P2(2),'g*')





%% write kernel data
close all
corr(KERNEL_AUTO_DATA(:),KERNEL_HAND_DATA(:)/10)
plot(KERNEL_AUTO_DATA(:),KERNEL_HAND_DATA(:)/10,'.')
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/earKernelLength.csv',25.4/1200*[KERNEL_AUTO_DATA(:) KERNEL_HAND_DATA(:)/10])
hold on
plot(linspace(180,240,2),linspace(180,240,2),'r')













%% HAND MEASURE THE WIDTH
inPath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/';
IMFileList = {};
FileExt = {'tif'};
verbose = 1;
IMFileList = gdig(inPath,IMFileList,FileExt,verbose);
I = {};
for i = 1:numel(IMFileList)
    I{i} =  imread(IMFileList{i});
end
%%

%%
WSBK = WS;
%%

[inter,idx1] = setdiff(NMW,NMW2);
WS(7:9,:) = [];
NMW(idx1) = [];
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the fft data from the first trial
%%
% scan for the iamges and measure parameters for model
FilePath = '/mnt/spaldingdata/nate/communications/papers/maizeEarScan/data/imageFiles/rawImages/earData/1-22-15/';
FileList = {};
FileExt = {'tif'};
verbose = 1;
FileList = gdig(FilePath,FileList,FileExt,verbose);
I = {};
parfor e = 1:numel(FileList)
    I{e} = rgb2gray(imread(FileList{e}));
    e
end
%% measure model parameters 1) gray scale kernel values
V = [];
for e = 1:20%numel(FileList)    
    [x y v] = impixel(I{e});
    V = [V;v];
end
%% measure gap
%% measure model parameters 1) gray scale kernel values
gap = [];
for e = 1:20%numel(FileList)    
    for g = 1:5
        J = imcrop(I{e});
        [x y v] = impixel(J);
        gap = [gap (diff(x).^2 + diff(y).^2).^.5];
    end
end
%% fit weibull distribution to gaps
parmhat = wblfit(gap);
%% dark gap values
dV = [];
for e = 1:20%numel(FileList)    
    [x y v] = impixel(I{e});
    dV = [dV;v];
end
%% get shape of kernel
C = [];
for e = 1:20
    for i = 1:5
        [x y V] = impixel(I{e});
        c = improfile(I{e},x,y);
        C = [C interp1(linspace(0,1,numel(c)),c,linspace(0,1,100))];
    end
end