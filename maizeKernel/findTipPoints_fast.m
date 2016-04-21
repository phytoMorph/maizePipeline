function [tdB] = findTipPoints_fast(dB,B,I)
    tdB = dB;
    %%take this out
    SEGSIZE = 601;
    [E,U] = generateCurveSegments(dB,SEGSIZE,10);
    
    for k = 1:numel(dB)
    %parfor k = 1:numel(dB)
        fprintf(['starting creating measure tensor for:' num2str(k) ':' num2str(numel(dB)) '\n']);
        tm = clock;
        M{k} = measureSingleContourMetrics_fast(dB{k},B,E,U,SEGSIZE,10);
        fprintf(['ending creating measure tensor for:' num2str(k) ':' num2str(numel(dB)) ' in' num2str(etime(clock,tm)) '\n']);
    end
    
    
    for rep = 1:3
        tM = [];
        %{
        parfor e = 1:numel(tdB)
            uR = measureSingleContourParametersForMLE(tdB{e},B,E,U,SEGSIZE,10);
            M(e,:) = uR;parfor e = 1:numel(dB)
            e
            numel(tdB)
        end
        %}
        %The following error occurred converting from struct to double:Error using double Conversion to double from struct is not possible.
        for k = 1:numel(dB)
            %tM(k,:) = M{k}(1,:);
            tmp = struct2array(M{k});
            tM(k,:) = tmp(1,:);
        end
        
        
        H = {};
        for e = 1:size(tM,2)
            H{e} = getColumnDistribution(tM(:,e));
        end



        %imshow(I,[]);
        %hold on
        %if disp
        %    %imshow(I,[]);
        %    imshow(I);
        %    hold on;
        %end
        for e = 1:numel(dB)
            MLE = lookUpLOG(H,M{e});
            MLE = sum(MLE,2);
            [J,nidx] = max(MLE);
            toShift = nidx-1;
            shiftAmount(rep,e) = toShift;
            %{
              if disp
                plot(tdB{e}(:,2),tdB{e}(:,1),'r');
                hold on
                plot(tdB{e}(1,2),tdB{e}(1,1),'c*');
                plot(tdB{e}(nidx,2),tdB{e}(nidx,1),'b*');
                drawnow
            end
            %}
            %tdB{e} = circshift(tdB{e},[toShift 0]);
            %M{e} = circshift(M{e},[toShift 0]);
            
        end
    end
        %{
            %{
            SKIP = 2;        
            tic
            toMeasure = 0:SKIP:(size(tdB{e},1)-1);
           ,toDisplay [MLE sMLE] = estimateMLE(toMeasure,tdB{e},B,H,size(tdB{e},1),'circular',1,E,U,SEGSIZE,10);
            %}
            %[J,nidx] = max(sMLE);
            %{
            WINDOW = 15;
            toMeasure2 = (nidx - WINDOW):(nidx+WINDOW);        
            [iMLE siMLE] = estimateMLE(toMeasure2,tdB{e},B,H,numel(toMeasure2),'replicate',5,E,U,SEGSIZE,10);
            [J,nidx1] = max(siMLE);
            nidx2 = nidx1 + toMeasure2(1);

            %}

            %nidx2 = nidx2 - 1;


            %toShift(e) = nidx2;
            toShift(e) = nidx-1;
            tmp = circshift(tdB{e},[toShift(e) 0]);
            %{
            plot(tdB{e}(:,2),tdB{e}(:,1),'r')
            hold on
            plot(tdB{e}(1,2),tdB{e}(1,1),'b*');
            plot(dB{e}(1,2),dB{e}(1,1),'c*');
            plot(tmp(1,2),tmp(1,1),'yo');
            hold on
            drawnow
            %}
            toc
        end
        %}
        %{
        for e = 1:numel(tdB)
            tdB{e} = circshift(tdB{e},[toShift(e) 0]);
        end
        %}
        %{
        figure;imshow(I,[]);hold on
        for e = 1:numel(tdB)
            plot(tdB{e}(:,2),tdB{e}(:,1),'b')
            title(num2str(e));
            drawnow
            pause(.5);
        end
        %}
    %end
end

%{

for e = 1:numel(dB)
    imshow(I,[]);
hold on
    plot(dB{e}(:,2),dB{e}(:,1),'r')
hold off
    title(num2str(e))
drawnow
pause(.3)
end
%}