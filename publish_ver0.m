%%
fileName = '/home/nate/Downloads/imageJ_10kh_072814.csv';
[D,T] = readtext(fileName);
H = D(1,:);
D(1,:) = [];

%%
FilePath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/return/earData/output/';
FileList = {};
FileExt = {'mat'};
verbose = 1;
FileList = gdig(FilePath,FileList,FileExt,verbose);
%% 
nm = {};
for e = 1:numel(FileList)
    [pth,nm{e},ext] = fileparts(FileList{e});
end
%% search
DATA = [];
hDATA = [];
HW = [];
DN ={};
NMW2 = {};
for e = 1:size(D,1)
    toSearch = strcmp(D{e,1},nm);
    if any(toSearch)
        fidx = find(toSearch);
        A = load(FileList{fidx});
        toM = mean(A.KernelLength,2);
    
        if size(toM,1) == 3
            DN{end+1} = D{e,1};
            DATA = [DATA toM];
            hDATA = [hDATA mean(cell2mat(reshape(D(e,2:1:end),[4 3])),1)'];
            [pth NMW2{end+1} ext] = fileparts(FileList{fidx});
            for k = 1:3
                tmp = [max(A.S.widthProfile(k,:)) A.BB{k}(4) ]
                HW = [HW ; tmp];
                
            end
        end
    end
    e
end
%%
close all
corr(DATA(:),hDATA(:)/10)
plot(DATA(:),hDATA(:)/10,'.')
numel(DATA)
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/earKernelLength.csv',25.4/1200*[DATA(:) hDATA(:)/10])
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

WS = [];
for i = 1:numel(IMFileList)
    [pth,NMW{i},ext] = fileparts(IMFileList{i});    
    [c r V] = impixel(I{i});
    dr = diff(r,1,1);
    dc = diff(c,1,1);
    dl = dr.^2 + dc.^2;
    dl = dl.^.5;
    dl = dl(1:2:end);
    WS = [WS;reshape(dl,[3 2])];
end
%%
WSBK = WS;
%%

[inter,idx1] = setdiff(NMW,NMW2);
WS(7:9,:) = [];
NMW(idx1) = [];
%% 
close all
corr(HW(:,1),WS(:,1))
plot(HW(:,1),WS(:,1),'.')
figure;
plot(HW(:,2),WS(:,2),'.')
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/earWidth.csv',25.4/1200*[HW(:,1) WS(:,1)])
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/earImages/measurements/earLength.csv',25.4/1200*[HW(:,2) WS(:,2)])
