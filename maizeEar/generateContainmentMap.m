



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