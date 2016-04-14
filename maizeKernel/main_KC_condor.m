function [] = main_KC_condor(varargin)

    % look for files at file path
    FilePath = varargin{1};
    FileList = {};
    FileExt = {'tif','TIF'};
    verbose = 0;
    [FileList] = gdig(FilePath,FileList,FileExt,verbose);

    %  output path
    oPath = varargin{2};
    
    
    AREA = [];
    IMG = {};
    c = 1;
    clear R;

    
    for e = 1:numel(FileList)
        
        KC = [];
        % get the file parts
        [pth nm ext] = fileparts(FileList{e});
        % read in the image
        I = imread(FileList{e});
        % convert to grayscale if needed
        if size(I,3) == 3
            G = rgb2gray(I);
        else
            G = I;
        end
        
        % get the threshold level
        level = graythresh(G);
        B = double(G)/255 > level;
        %B = double(G)/255 < level;
        %B = double(G)/255 < level - .25*level;
        
        B = bwareaopen(B,5000);
        B = imfill(B,'holes');
        R{e} = regionprops(B,'Area','MajorAxis','MinorAxis','Image','Centroid','Orientation');
        AREA = [R{e}.Area];
        
        sr = [];
        for k = 1:numel(AREA)
            RAT = round(AREA.*AREA(k).^-1);
            sr(k) = sum(RAT==1);    
        end

        for k = 1:numel(R{e})
            rIMG = imrotate(R{e}(k).Image,R{e}(k).Orientation);
            H(k) = max(sum(rIMG,1));
        end

        MO = mode(sr);
        fidx = (sr == MO);
        uA = mean(AREA(fidx));
        sel = round(AREA.*uA^-1);
        KC(1) = sum(sel);
        
        
        close all
        imshow(I);
        hold on
        MAJOR = [];
        MINOR = [];
        for k = 1:numel(sel)
            if sel(k) == 1;
                VEC = H(k)*[sin(R{e}(k).Orientation*pi/180),cos(R{e}(k).Orientation*pi/180)];                
                nVEC = [-VEC(2) VEC(1)];
                
                nX = linspace(R{e}(k).Centroid(1)-nVEC(1),R{e}(k).Centroid(1)+nVEC(1),2*H(k));
                nY = linspace(R{e}(k).Centroid(2)-nVEC(2),R{e}(k).Centroid(2)+nVEC(2),2*H(k));
                nLP = ba_interp2(double(B),nX,nY);
                nLPf = imfill(~logical(nLP>.5),[1 round(numel(nLP)/2)]);
                nfidx = find(nLP.*nLPf>.5);

                X = linspace(R{e}(k).Centroid(1)-VEC(1),R{e}(k).Centroid(1)+VEC(1),2*H(k));
                Y = linspace(R{e}(k).Centroid(2)-VEC(2),R{e}(k).Centroid(2)+VEC(2),2*H(k));
                LP = ba_interp2(double(B),X,Y);
                LPf = imfill(~logical(LP>.5),[1 round(numel(LP)/2)]);
                fidx = find(LP.*LPf>.5);

                plot(nX(nfidx),nY(nfidx),'r');
                plot(X(fidx),Y(fidx),'b');


                MAJOR = [MAJOR numel(nfidx)-1];
                MINOR = [MINOR numel(fidx)-1];
            end

            text(R{e}(k).Centroid(1),R{e}(k).Centroid(2),[num2str(sel(k))],'Color','m');

        end
        title(num2str(KC));
        drawnow
        csvwrite([oPath nm '-indiv.csv'],[MAJOR' MINOR']);
        csvwrite([oPath nm '.csv'],[mean(MAJOR) std(MAJOR) mean(MINOR) std(MINOR) KC]);
        saveas(gca,[oPath nm ext]);
    end
end
%{
FilePath = '/mnt/scratch2/maizeData/kernelOnly/unordered/';
oPath = '/mnt/scratch2/maizeData/return/seedCount/';

FilePath ='/mnt/spaldingdata/nate/Nick Haase/Xia_Scans/Xia_seeds/';
oPath = '/mnt/spaldingdata/nate/communications/nickHaase/output_kernelCount0/';

FilePath ='/mnt/spaldingdata/nate/mirror_images/maizeData/kernelData/unordered/';
oPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/return/kernelData/output/';
mkdir(oPath);
main_KC(FilePath,oPath);

FilePath ='/mnt/spaldingdata/nate/mirror_images/maizeData/kernelData/unordered/';
oPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/return/kernelData/output/';
mkdir(oPath);
main_KC(FilePath,oPath);

FilePath = '/mnt/spaldingdata/nate/mirror_images/Teo/';
oPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/return/kernelData/output/';
mkdir(oPath);
main_KC_condor(FilePath,oPath);

%}
%{
%%
UQ = unique(sel);
for u = 1:numel(UQ)
    fidx = find(sel==UQ(u));
    for f = 1:numel(fidx)
        imshow(IMG{fidx(f)})
        title(num2str(UQ(u)))
        drawnow        
    end
end
%}