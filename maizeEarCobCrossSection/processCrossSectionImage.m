function [] = processCrossSectionImage(fileName,oPath)
    try
        % 
        [pth,nm,ext] = fileparts(fileName);
        %
        I = single(imread(fileName))/255;
        G = rgb2gray(I);
        M = G > graythresh(G);
        M = bwareaopen(M,10000);
        M = imclose(M,strel('disk',110));
        R = regionprops(M,'BoundingBox','Centroid','PixelIdxList');
        %
        for e = 1:numel(R)
            fprintf(['Starting Analysis' num2str(e) ':' num2str(numel(R)) '\n']);
            Mtmp = zeros(size(M));
            Mtmp(R(e).PixelIdxList) = 1;
            tmpB = R(e).BoundingBox - [150 150 -300 -300];
            tmpI = imcrop(I,tmpB);
            [MAX(e) MIN(e) rowN(e)] = processCrossSection(double(tmpI),0);
            fprintf(['Ending Analysis' num2str(e) ':' num2str(numel(R)) '\n']);
        end
        % 
        image(I);
        hold on
        vP = 1.3;
        axis off
        axis equal
        TH = linspace(-pi,pi,2000);
        LineWidth = 1;
        for e = 1:numel(R)
            fprintf(['Starting Display' num2str(e) ':' num2str(numel(R)) '\n']);
            SIG = 50*cos(TH*rowN(e));
            Ro = .5*(MIN(e)+MAX(e));
            xl = (Ro+SIG).*cos(TH) + R(e).Centroid(1);
            yl = (Ro+SIG).*sin(TH) + R(e).Centroid(2);
            plot(xl,yl,'r','LineWidth',LineWidth);

            xl = MAX(e).*cos(TH) + R(e).Centroid(1);
            yl = MAX(e).*sin(TH) + R(e).Centroid(2);
            plot(xl,yl,'b','LineWidth',LineWidth);

            xl = MIN(e).*cos(TH) + R(e).Centroid(1);
            yl = MIN(e).*sin(TH) + R(e).Centroid(2);
            plot(xl,yl,'b','LineWidth',LineWidth);
            TI = ['Kernel Row Number:' num2str(rowN(e)) '**' 'Kernel Depth:' num2str(MAX(e) - MIN(e)) '**' 'Kernel Width:' num2str(MAX(e)/rowN(e))];
            title(TI);
            %{
            text(R(e).Centroid(1)-100,R(e).Centroid(2),['Kernel Row Number:' num2str(rowN(e))],'Background','w');
            text(R(e).Centroid(1)-100,R(e).Centroid(2)+150,['Kernel Depth:' num2str(MAX(e) - MIN(e))],'Background','w');
            text(R(e).Centroid(1)-100,R(e).Centroid(2)+300,['Kernel Width:' num2str(MAX(e)/rowN(e))],'Background','w');
            %}
            vMIN = R(e).Centroid - vP*MAX(e);
            vMAX = R(e).Centroid + vP*MAX(e);
            axis([vMIN(1) vMAX(1) vMIN(2) vMAX(2)]);
            drawnow
            saveas(gca,[oPath nm '--subNumber--' num2str(e) '.tif']);
            fprintf(['Ending Display' num2str(e) ':' num2str(numel(R)) '\n']);
        end
        close all
    catch ME
        
    end
end

%{    
    FilePath = '/mnt/spaldingdata/nate/mirror_images/maizeData/garf0012/crosssectionData/';
    FileList = {};
    FileExt = {'tif'};
    FileList = gdig(FilePath,FileList,FileExt,1);
    oPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/garf0012/return/crossSectionData/output/';
    parfor e = 1:numel(FileList)
        processCrossSectionImage(FileList{e},oPath);
    end
%}