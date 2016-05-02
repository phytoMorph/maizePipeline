function [T ufT BB PS MT sM] = measureKernelLength(I,numberCobs,RAD,gridSites,defaultAreaPix,fill,CHUNK)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                measureKernelLength.m is main function to handle cob analysis. It takes all input variables 
                for its dependent functions. This function returns final result including image with 
                bounding box and color circle. (Inputs are relative to 1200dpi)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                rgb2hsv_fast.m, measureImage.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                I:              The blue header remvoed image to be analyzed.
                numberCobs:     Number of cobs that are expected to be analyzed. 
                RAD:            The value for window size.
                gridSites:      The number of down sample grid sites.
                defaultAreaPix: The default pixel to be considered noise relative to 1200 dpi.
                fill:           The radius of disk for Kernel of an image close operation.
                CHUNK:          The number of chunk for input for FFT in myBlock0.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    %%%%%%%%%%%%%%%%%%%%%%%
    % init return vars    
    ufT = 0;
    PS = [];
    PS.widthProfile = [];
    sM = {};
    %%%%%%%%%%%%%%%%%%%%%%%
    try        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get hsv slice, filter and mask
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['starting mask creation. \n']);
        %h = fspecial('gaussian',[31 31],11);
        %I = imfilter(I,h);
        fI = rgb2hsv_fast(I,'single','V');
        level = graythresh(fI);
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get binary, close, fill holes, remove small objects
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        B = fI > level;
        B = imopen(B,strel('disk',fill));
        B = imclose(B,strel('disk',fill));
        B = imfill(B,'holes');
        B = bwareaopen(B,defaultAreaPix);
        B = imclearborder(B);
        R = regionprops(B,'PixelIdxList','PixelList','Area','Image','BoundingBox');
        fprintf(['ending mask creation. \n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % iterate over the cobs        
        for e = 1:numberCobs
            fprintf(['starting with ear ' num2str(e) ':' num2str(numberCobs) '\n']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get bounding box - color
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BB{e} = R(e).BoundingBox;
            subI = R(e).Image;
            grayImage = single(imcrop(I,R(e).BoundingBox))/255;
            grayImage = rgb2gray(grayImage);
            fprintf(['Operating on sub image of size: [' num2str(size(grayImage)) ']:[' num2str(size(I)) ']\n']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get width profile
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            WIDTH = sum(subI,2);
            fidx = find(WIDTH ~= 0);
            uW = mean(WIDTH(fidx));
            PS.average_WIDTH(e) = uW;
            % store width profile
            PS.widthProfile = [PS.widthProfile ;interp1(1:numel(WIDTH),WIDTH,linspace(1,numel(WIDTH),1000))];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Display
            % process the grayscale image, take gradient, look at pos and neg
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            h = fspecial('average',41);            
            grayImage = imfilter(grayImage,h);
            % look at gradient of grayscale image - could be yellow
            [~,grayImage] = gradient(grayImage);
            % smooth cols gradient
            grayImage = imfilter(single(grayImage),fspecial('gaussian',[41 41],11));
            % find the beginning and ending of kernels - pos and neg
            gMSK = grayImage > 0;
            lMSK = grayImage < 0;
            % strip the image border to zero
            subI(1,:) = 0;
            subI(:,end) = 0;
            subI(end,:) = 0;
            % init vars to measuure image
            tG = {};
            tL = {};
            parfor r = 1:numel(RAD)
                fprintf(['starting with fft window ' num2str(r) ':' num2str(numel(RAD)) '\n']);
                % set the current window size
                dR = RAD(r);
                % errode such that the fft window samples only ear image
                toMeasure = imerode(subI,strel('rectangle',[2*dR+1 20]));
                % call to measure kernel period of the rising edge
                [Tg tG{r}] = measureImage(gMSK.*grayImage,toMeasure,gridSites,dR,CHUNK);
                % call to measure the kernel period of the falling edge
                [Tl tL{r}] = measureImage(lMSK.*grayImage,toMeasure,gridSites,dR,CHUNK);
                % stack results together
                MT(r,:,e) = [Tg Tl];
                % average of rising and falling edge period
                T(e,r) = nanmean([Tg Tl]);                
                fprintf(['ending with fft window ' num2str(r) ':' num2str(numel(RAD)) '\n']);
            end
            fprintf(['ending with ear ' num2str(e) ':' num2str(numberCobs) '\n']);
            ufT.G{e} = tG;
            ufT.L{e} = tL;
        end
    catch ME
        getReport(ME);
        fprintf(['******error in:measureKernelLength.m******\n']);
    end
end


%{

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get hsv slice, filter and mask
        h = fspecial('gaussian',[31 31],11);
        %yellowImage = rgb2gray(I);
        % line changed to value rather than Hue on Mar 22, 2016
        %hI = rgb2hsv_fast(I,'single','H');
        fI = rgb2hsv_fast(I,'single','V');
        %hI = hI(:,:,1);
        %fI = entropyfilt(hI,getnhood(strel('disk',21,0)));
        %fI = stdfilt(hI,getnhood(strel('disk',21,0)));
        %fI = imfilter(hI,h,'replicate');
        %fI = imfilter(yellowImage,h);
        level = graythresh(fI);
   


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % non-fill example
    fileName = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/earData/3-19-14/Scan-140319-0210.tif';
    I = imread(fileName);
    measureKernelLength_forcondor(I,3)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % fill example
    fileName = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/earData/3-19-14/Scan-140319-0176.tif';
    I = imread(fileName);
    RAD = 1200:100:1600;
    [T ufT BB PS MT sM] = measureKernelLength_forcondor(I,3,RAD);
    
    for e = 1:numel(sM)
        for i = 1:numel(sM{e}.height)
            HT{e}(i) = mean(sM{e}.height{i});
        end
    end

    G = rgb2gray(I);
    G = double(G);
    G_mod = imdilate(G,strel('disk',81));
    G_mod = imreconstruct(imcomplement(G_mod),imcomplement(G));
    G_mod = imcomplement(G_mod);
    G_modE = imerode(G_mod,strel('disk',81));
    G_mod = imreconstruct((G_modE),(G_mod));
    rm = imregionalmax(G_mod);
    D = bwdist(rm);
    DL = watershed(D);

    [d1 d2] = gradient(double(G));
    dI = (d1.^2 + d2.^2).^.5;
    dI_mod = imimposemin(dI,rm | DL == 0);
    L = watershed(dI_mod);
    Lrgb = label2rgb(L,'jet','w','shuffle');
    imshow(Lrgb,[]);
    R = regionprops(L,'BoundingBox');
    for e = 1:numel(R)
        H(e) = R(e).BoundingBox(4);
    end
    %G_mod = imcomplement(G_mod);




    for EAR = 1:3
        figure;

        RAD = 1200:25:1600;
        for e = 1:numel(RAD)            
            dR = RAD(e);
            SIGL = 2*dR+1;
            aft = .5*(ufT.G{EAR}{e}+ufT.L{EAR}{e});
            [mT(e,EAR,1) mf(e,EAR,1)] = findT(ufT.G{EAR}{e},SIGL);
            [mT(e,EAR,2) mf(e,EAR,2)] = findT(ufT.L{EAR}{e},SIGL);
            [mT(e,EAR,3) mf(e,EAR,3)] = findT(aft,SIGL);

            plot((1:numel(ufT.G{EAR}{e}))/SIGL,ufT.G{EAR}{e},'b');
            hold on
            plot((1:numel(ufT.G{EAR}{e}))/SIGL,ufT.L{EAR}{e},'r');
            plot((1:numel(ufT.G{EAR}{e}))/SIGL,aft,'k');
            
            xlim([0 .05])
            
        end
    end



    EAR = 3
    for e = 1:numel(RAD) 
        dR = RAD(e);
        N = 2*dR+1;
        plot(((1:numel(ufT.G{EAR}{e}))-1)/N,ufT.G{EAR}{e},'r');xlim([0 .03]);
    end

    
    figure;


    EAR = 2;
    uT1 = mean(mean(mT(:,EAR,:),1),3)
    uf1 = mean(mean(mf(:,EAR,:),1),3).^-1
    uT2 = mean(mT(:,EAR,3))
    uf2 = mean(mf(:,EAR,3)).^-1
    


    uT = nanmean(T,2)
    %h = image(I);
    imshow(I,[]);
    hold on
    % make rectangle around the cob and plot the cosine
    % function
    DATA = [];
    for b = 1:numel(BB)
        rectangle('Position',BB{b},'EdgeColor','g','LineWidth',3);
        CS = [1:BB{b}(4)] + BB{b}(2);
        Func = 100*cos(2*pi/uT(b)*CS) + BB{b}(3)/2 + BB{b}(1);
        DATA = [DATA;[BB{b}(3:4) PS.average_WIDTH(b)]];
        plot(Func,CS,'g','LineWidth',3);    
    end
    %% write to disk for paper
    imwrite(I,'/mnt/spaldingdata/nate/communications/papers/maizeEarScan/fullFill.tif');
    
    imshow(I,[]);
    
    
    C = rgb2cmyk(double(I)/255);
    yellowImage = C(:,:,3);
    h = fspecial('average',41);
    fsI = imfilter(yellowImage,h);
    [g1 g2] = gradient(fsI);
    eI = imfilter(double(g2),fspecial('gaussian',[41 41],11));

    raw = yellowImage(:,(7398-30):(7398+30));
    SNIPraw = yellowImage(end/2-500:end/2+500,(7398-300):(7398+300));
    SNIPseg = eI(end/2-500:end/2+500,(7398-30):(7398+30));    
    
    seg = eI(:,(7398-30):(7398+30));
    iseg = yellowImage(:,(7398-500):(7398+500));
    
    seg = mean(seg,2);
    uraw = mean(raw,2);
    SNIPseg = mean(SNIPseg,2);
    gMSK = seg > 0;
    lMSK = seg < 0;
    plot(gMSK.*seg.^2);
    hold on
    plot(lMSK.*seg.^2,'r');
    plot(abs(fft(gMSK.*seg.^2)));
    % make figure for paper
    plotyy(1:numel(uraw),uraw,1:numel(uraw),seg);
    plot(seg)
    plot(SNIPseg)

    imshow(I,[]);
    hold on
    rectangle('Position',[7398-300 size(yellowImage,1)/2-500 600 1000],'EdgeColor','r')


    imshow(SNIPraw,[]);
    hold on
    plot(bindVec(SNIPseg)*100+size(SNIPraw,2)/2,1:numel(SNIPseg),'r');
    plot(bindVec(mean(SNIPraw,2))*100+size(SNIPraw,2)/2,1:numel(SNIPseg),'b');
    [AX,H1,H2] = plotyy(1:numel(SNIPseg),bindVec(mean(SNIPraw,2)),1:numel(SNIPseg),SNIPseg);
    xlim(AX(1),[0 1000]);    
    xlim(AX(2),[0 1000]);
    
    %}