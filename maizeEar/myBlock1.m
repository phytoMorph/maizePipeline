function [ret] = myBlock1(block)
    ret = mean(block,2);
    ret = ret - mean(ret);
end