%% load fft
dataPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/earData/output/';
% dig for images
FilePath = dataPath;
FileList = {};
FileExt = {'mat'};
verbose = 1;
[mFileList] = gdig(FilePath,FileList,FileExt,verbose);
%{
for e = 1:numel(mFileList)
    load(mFileList{e},'FT')
end
%}

%% data loader
% look for csv files in this path
dataPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/earData/output/';
% dig for csv files
FilePath = dataPath;
FileList = {};
FileExt = {'csv'};
verbose = 1;
[FileList] = gdig(FilePath,FileList,FileExt,verbose);
% init vars
KernelData = [];
EarH = [];
EarW = [];
dataID = {};
matID = {};
imageFile ={};
% for each csv file - read
for e = 1:numel(FileList)
    % read csv file
    D = csvread(FileList{e});
    try 
        % reshape data
        D = reshape(D,[4 3])';
        % cat kernel data
        KernelData = [KernelData D(:,end)];
        % height and width
        EarH = [EarH D(:,2)];
        EarW = [EarW D(:,1)];
        [pth nm ext] = fileparts(FileList{e});
        % data ID name of file
        dataID{end+1} = nm;
        % name of corresponding matlab file
        matID{end+1} = mFileList{e};
        % name of tif
        imageFile{end+1} = [dataPath nm '_result.tif'];
    catch ME
        ME
    end
    e
    numel(FileList)
end
%%
sD = sort(KernelData(:));
for e = 1:10        
    [i j] = find(KernelData==sD(e));
    close all
    I = imread(imageFile{j});
    imshow(I,[])
    waitforbuttonpress
end
%% backup kernel data
KD_BK = KernelData;
%% read the handmeasurements
[D T] = xlsread('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/LengthData_hand.xls');
%% search for data and pair hand measurements
handM = [];
autoM = [];
ID = [];
FL = {};
cif = {};
mif = {};
for e = 1:size(D,1)
    uT = [];
    IDX = num2str(D(e,1));
    % look through each dataID
    for i = 1:numel(dataID)
        fidx = strfind(dataID{i},IDX);
        if ~isempty(fidx)            
            try                         
                uT = [uT;KernelData(:,i)'];
                tmp = imageFile{i};                
                tmpM = matID{i};
            catch ME
                ME
            end
        end
    end
    
    uT = nanmean(uT,1);
    if ~isempty(uT)
        autoM = [autoM;[D(e,1) uT/1200*25.4]];
        handM = [handM;[D(e,1) D(e,4:3:end)/10]];
        cif{end+1} = tmp;
        mif{end+1} = tmpM;
        ID = [ID;str2num(IDX)];
    end
    e
    %{
    if size(autoM,1) ~= size(handM,1)
        break
    end
    %}
end
rmidx = any(isnan(autoM),2) | any(isnan(handM),2);
autoM(rmidx,:) = [];
handM(rmidx,:) = [];
cif(rmidx) = [];
mif(rmidx) = [];
ID(rmidx) = [];
%%
close all
hD = handM(:,2:end);
aD = autoM(:,2:end);
hD = hD(:);
aD = aD(:);
rmidx = hD > 8 | aD < 3;
aD(rmidx) = [];
hD(rmidx) = [];
corr(hD(:),aD(:))
plot(hD(:),aD(:),'.')
%%
cob = 1;
window = 1;
SIDX = 3;
fidx = find(any(autoM < 3,2));
load(mif{fidx(SIDX)},'FT','KernelLength')
I = imread(cif{fidx(SIDX)});
close all
imshow(I,[]);
figure;plot(FT.G{1}{1});
gsig = FT.G{cob}{window};
lsig = FT.L{cob}{window};
h = fspecial('average',[5 1]);
gsig = imfilter(gsig,h);
lsig = imfilter(lsig,h);        
fTG = findT(gsig,size(FT.G{1}{1},1));
fTL = findT(lsig,size(FT.L{1}{1},1));
fT = mean([fTG fTL]);
%%
close all
DI = autoM(:,2) - handM(:,2);
[J fidx] = sort(abs(DI));
for e = 1:10
    I = imread(cif{fidx(end-(e-1))});
    imshow(I,[]);
    waitforbuttonpress
end
%%
DIS = 5;
plot(autoM(fidx(1:end-DIS),2),handM(fidx(1:end-DIS),2),'.')
corr(autoM(fidx(1:end-DIS),2),handM(fidx(1:end-DIS),2))
%% load the longest window
FTD = [];
for e = 1:numel(mFileList)
    load(mFileList{e},'FT')
    cobs = numel(FT.L);
    for cob = 1:cobs
        FTD = [FTD FT.L{cob}{end}];
    end
    e
end
%% 
[S C U E L ERR LAM] = PCA_FIT_FULL(FTD',1);
