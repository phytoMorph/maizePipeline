function [ret] = myBlock2(block)
    % subtract off the mean
    uBlock = mean(block,1);
    block = bsxfun(@minus,block,uBlock);
    % perform fft along 1 dim
    fT = fft(block,[],1);
    % get the mean of the fft signal along the 2nd dim
    ret = mean(abs(fT),2);
end