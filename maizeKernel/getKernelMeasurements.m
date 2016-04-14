function [M] = getKernelMeasurements(B,contours)        
    for k = 1:numel(contours)
        M(k) = measureSingleContourParameters(contours{k},B);
    end    
end