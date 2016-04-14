function [block] = myReduction0(block)
    block = cell2mat(block);
    block = mean(block,2);
end