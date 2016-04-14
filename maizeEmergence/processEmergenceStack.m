function [] = processEmergenceStack(imageStack)

    N = 10;
    [rec] = getRectification(imageStack{1},1,1);
    [circleMatrix MASK] = getCircles(imageStack,rec,N);
    
  
    %displayMaskNumbers(MASK,imageStack{end});
    
    
    para.scales.value = 9;
    para.resize.value = .75;
    BORDER = 50;
    [R] = getBoundingBoxes(MASK);
    for e = 1:numel(R)
        tm = clock;
        tmpBB = R(e).BoundingBox;
        [miniStack miniMask] = diskCrop(imageStack,MASK,tmpBB,BORDER);
        
        [featureStack] = surKurStack(miniStack,miniMask,para);
        
        
        [kidx(e) Z{e}] = extractPointsFromFeatureStack(featureStack,miniMask,miniStack);
        %showAndPlot(miniStack,squeeze(miniStack(:,:,1,:)),miniMask,sK(:,1,e))
        %[kidx(e) L(e,:) bc(e,:) di(e,:)] = findGermFrame_ver0(miniStack,miniMask);
        numel(R)*etime(clock,tm)/12/60
    end
    
    
    %{
    toSNIP = 2;
    [tmpL] = snipSignal(L,toSNIP,7);
    [tmpbc] = snipSignal(bc,toSNIP,7);
    [tmpdi] = snipSignal(di,toSNIP,7);
    
    tmpS = tmpL.*tmpdi;
    [pidx pv] = findSignalPeak(tmpS,20);
    [bk] = getSigalBackground(tmpS,30);
    
    nsig = (pv.*bk.^-1);
    kidx = kmeans(nsig,2);
    
    for e = 1:numel(kidx)
        framesToGet = numel(imageStack);
        [frameCrop] = diskCropAtFrame(imageStack,framesToGet,R(e).BoundingBox);
        imshow(frameCrop,[]);
        title(num2str(kidx(e)))
        waitforbuttonpress
    end
    
    
    
    [bS bC bU bE bL bERR bLAM] = PCA_FIT_FULL(tmpbc,3);
    toProj = tmpS;
    oL = bsxfun(@minus,toProj,mean(toProj,1));
    oL = bsxfun(@plus,oL,bU);
    [hC] = PCA_REPROJ(oL,bE,bU);
    mL = PCA_BKPROJ(hC,bE,bU);
    mL = bsxfun(@minus,mL,bU);
    mL = bsxfun(@plus,mL,mean(toProj,1));
    
    nL = -(toProj - mL);
    
    %{
    for e = 1:numel(R)
        [bc(e,:)] = getBrightnessCurve(mov)
    end
    %}
    
    
    % feed orginal signal
    nL = L;
    tmpbc = bc;
    
    
    % feed tmp signal
    nL = tmpL;
    tmpbc = tmpbc;
    
    % mean by std
    nL = tmpL.*tmpdi;
    
    % percent threshold
    perTHRESH = .3;
    
    %nL = tmpS;
    
    % from curvature
    nL = squeeze(sK(:,1,:))';
    
    kidx = [];
    sL = [];
    for e = 1:size(nL,1)
        %[kidx(e) sL(e,:)] = find_L_threshold(nL(e,:),tmpbc(e,:),perTHRESH,1);
        [kidx(e) sL(e,:)] = find_L_threshold(nL(e,:),[],perTHRESH,1);
    end
    %}
    
    %kidx = pidx;
    %sL = tmpS;
    %OFFSET = 16;
    kidx(kidx~=0) = kidx(kidx~=0) + 0 + OFFSET;
    kidx = round(kidx);
    for e = 1:size(nL,1)
        tmpStack = [];
        v = max(sL(e,:));
        z = zeros(size(sL(e,:)));
        if kidx(e) ~= 0
            z(kidx(e)) = v;
            framesToGet = [(kidx(e)-1) kidx(e) (kidx(e)+1) numel(imageStack)];
            idx = (framesToGet > numel(imageStack));
            framesToGet(idx) = numel(imageStack);
            [frameCrop] = diskCropAtFrame(imageStack,framesToGet,R(e).BoundingBox,BORDER);
            frameCrop(:,:,:,end) = 255*flattenMaskOverlay(double(frameCrop(:,:,:,end))/255, logical(Z{e}),.25,'r');
            for i = 1:size(frameCrop,4)
                tmpStack = cat(2,tmpStack,frameCrop(:,:,:,i));
            end
        else
            framesToGet = [numel(imageStack)];
            [tmpStack] = diskCropAtFrame(imageStack,framesToGet,R(e).BoundingBox,BORDER);
            tmpStack = flattenMaskOverlay(double(tmpStack)/255, logical(Z{e}),.25,'r');
        end
        figure
        plot(sL(e,:),'k');
        hold on
        plot(z,'r')
        figure
        imshow(tmpStack);
        title(num2str(framesToGet));
        waitforbuttonpress
        hold off
        close all
        
    end
    
    
    
    
end

%{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1) scan for images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FilePath = '/home/nate/Downloads/Overhead_Compilation/';
    FilePath = '/home/nate/Downloads/Angle_Compilation/';
    FilePath = '/home/nate/Downloads/emergance/';
    FilePath = '/home/nate/Downloads/20151222_Camera1/';
    FilePath = '/mnt/scratch1/phytoM/flashProjects/workWithGustin/20160106_Camera1/';
    FilePath = '/mnt/scratch1/phytoM/flashProjects/workWithGustin/Checkerboard/';
    FilePath = '/mnt/scratch1/phytoM/flashProjects/workWithGustin/20160115_Camera1/';
    FileList = {};
    FileExt = {'tiff','TIF','tif','JPG','jpg'};
    FileExt = {'tiff'};
    verbose = 1;
    FileList = gdig(FilePath,FileList,FileExt,verbose);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1) checkerboad check
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %checkerBoardChecker(FileList);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2) sort the images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n = {};
    for e = 1:numel(FileList)
        [p n{e} ex] = fileparts(FileList{e});
        n{e} = str2num(n{e});
    end
    [n sidx] = sort(cell2mat(n));
    FileList = FileList(sidx);
    processEmergenceStack(FileList);
%}