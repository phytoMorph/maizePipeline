function [P] = findKernelsOnEar(I,levels)    
    % get level curves
    I = double(I);
    I = imfilter(I,fspecial('average',51));    
    I = bindVec(I);
    [levelCurve] = getLevelContours(I,levels);
    
    % filter less and greater curves
    kp = [];
    for e = 1:numel(levelCurve)
        kp(e) = all(levelCurve(e).data(:,1) == levelCurve(e).data(:,end)) & levelCurve(e).length > 600 & levelCurve(e).length < 5000;
    end
    levelCurve = levelCurve(find(kp));
    
    
    
    % get enclosing area
    AREA = [];
    for e = 1:numel(levelCurve)
        AREA(e) = polyarea(levelCurve(e).data(1,:)',levelCurve(e).data(2,:)');
    end
    [C,NUM] = modeGrouping(AREA);
    



    % loop over labels
    UQ = unique(C);
    for u = 1:numel(UQ)
        % find the objects for the current label
        fidx = find(C == UQ(u));
        
        % get the area of the objects
        a = AREA(fidx);
        % get the average area
        muA = mean(a);
        % find those that round to one within the limits of the average
        sidx = find(round(a.*muA.^-1) == 1);
        % area of the selected 
        a = a(sidx);
        % temp curve
        tmpC = levelCurve(fidx(sidx));
        
        
        % generate containment map
        CM = generateContainmentMap(tmpC);
        % find the roots of the graph
        roots = find(sum(CM,1)==1);
        
        z = zeros(size(I));
        for e = 1:numel(roots)
            tmp = poly2mask(tmpC(roots(e)).data(1,:),tmpC(roots(e)).data(2,:),size(z,1),size(z,2));
            z = tmp + z;            
        end
        R = regionprops(logical(z),'Eccentricity','Image');
        for e = 1:numel(R)
            P.height{u}(e) = sum(logical(sum(R(e).Image,2)));
            P.width{u}(e) = sum(logical(sum(R(e).Image,1)));
        end
        P.ecc{u} = [R.Eccentricity];
        P.mask{u} = z;
        P.curves{u} = tmpC(roots);
        
        
        %{
        close all   
        imshow(I,[]);hold on;    
        %{
        for e = 1:numel(tmpC)        
            plot(tmpC(e).data(1,:),tmpC(e).data(2,:),'r')        
        end
        %}
        %title([num2str(NUM(fidx(1))) '--' num2str(numel(fidx))]);
        for e =  1:numel(roots)
            plot(tmpC(roots(e)).data(1,:),tmpC(roots(e)).data(2,:),'g');
        end
        drawnow
        %waitforbuttonpress
        %}
        
    end
end






function [CM] = generateContainmentMap(tmpC)
    CM = [];
    for i = 1:numel(tmpC)        
        PTL = [];        
        for j = 1:numel(tmpC)        
            PTL = [PTL;tmpC(j).data(:,1)'];         
        end
        CM(i,:) = inpoly(PTL,tmpC(i).data(:,1:10:end)');        
    end
end