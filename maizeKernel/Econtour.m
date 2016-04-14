function [dB] = Econtour(dB,B,I)

    tdB = dB;
    SEGSIZE = 601;
    [E,U] = generateCurveSegments(dB,SEGSIZE,10);
    
    for Y = 1:3
        M = [];
        
        parfor e = 1:numel(tdB)
            uR = measureSingleContourParametersForMLE(tdB{e},B,E,U,SEGSIZE,10);
            M(e,:) = uR;
            e
            numel(tdB)
        end
        
        
        H = {};
        for e = 1:size(M,2)
            H{e} = getColumnDistribution(M(:,e));
        end



        %imshow(I,[]);
        %hold on
        for e = 1:numel(tdB)
            SKIP = 2;        
            tic
            toMeasure = 0:SKIP:(size(tdB{e},1)-1);
            [MLE sMLE] = estimateMLE(toMeasure,tdB{e},B,H,size(tdB{e},1),'circular',1,E,U,SEGSIZE,10);
            [J,nidx] = max(sMLE);
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

        for e = 1:numel(tdB)
            tdB{e} = circshift(tdB{e},[toShift(e) 0]);
        end
        %{
        figure;imshow(I,[]);hold on
        for e = 1:numel(tdB)
            plot(tdB{e}(:,2),tdB{e}(:,1),'b')
            title(num2str(e));
            drawnow
            pause(.5);
        end
        %}
    end
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