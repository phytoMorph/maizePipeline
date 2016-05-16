function [S A] = measureStack_ver2(Stack,BOX,mainBOX,numtoMeasure,numCOLS,disp)
    
    % create figures for display
    h1 = figure;
    h2 = figure;
    
    % get the centers of the kernels
    C = getCenters_ver2(Stack{1},mainBOX);
    
    % call to manual crop if centers are not found
    if isempty(C) | mod(size(C,1),numCOLS) ~= 0
        I = imread(Stack{1});
        [I mainBOX] = imcrop(I);
        C = getCenters(Stack{1},mainBOX);
    end
    
    if numtoMeasure < 0
        numtoMeasure = numel(Stack);
    end
    
    %C = fliplr(C);
    % loop over the centers
    parfor e = 1:size(C,1)
        try
           tS = [];
           boundary = {};
           for img = 1:numtoMeasure
                I = getKernelImage(Stack{img},C(e,:),BOX);
                [boundary{img} currentArea] = getKernelArea(I,10^4);
                tS(img) = currentArea;
                if disp
                    figure(h1);
                    imshow(I,[])
                    hold on
                    plot(boundary{img}(:,2),boundary{img}(:,1),'r');
                    figure(h2);
                    plot(calcPercentSwelling(tS));
                end
                fprintf(['Done with kernel:' num2str(e) ':image:' num2str(img) '\n']);
           end
           
           A{e} = tS;
           fprintf(['Done with kernel:' num2str(e) '\n']);
        catch ME
            fprintf(['Error on kernel:' num2str(e) '\n']);
            A{e} = zeros(1,numel(Stack));
        end
    end
    A = cell2mat(A');
    for e = 1:size(A,1)
        S(e,:) = calcPercentSwelling(A(e,:),3);
    end
    close all;
end

%{
    
%}