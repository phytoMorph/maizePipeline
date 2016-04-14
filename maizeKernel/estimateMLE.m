function [MLE sMLE] = estimateMLE_BULK(toMeasure,dB,B,H,ni,edgeType,fS,E,U,S,sm)
    MLE = [];    
    %parfor r = 1:numel(toMeasure)
    r=1
        tic
        tmp = circshift(dB,[toMeasure(r) 0]);
        uR = measureSingleContourParametersForMLE_BULK(tmp,B,E,U,S,sm);
        MLE = lookUpLOG(H,uR);
        toc
    %end
    
    
    MLE = interp1(linspace(0,1,size(MLE,1)),MLE,linspace(0,1,ni),'linear');
    h = fspecial('gaussian',[2*fS 1],fS);    
    h = h / sum(h);
    MLE = imfilter(MLE,h,edgeType);
    
    sMLE = sum(MLE,2);
    %sMLE = interp1(linspace(0,1,size(sMLE,1)),sMLE,linspace(0,1,ni),'linear');
    
    
    
end