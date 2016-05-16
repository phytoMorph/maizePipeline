function [nC] = realignCenters(fileName,C,BOX)
    parfor e = 1:size(C,1)
        I = getKernelImage(fileName,C(e,:),BOX);
        nC(e,:) = getNewCenter(I,10^4);
        nC(e,:) = fliplr(nC(e,:)) + C(e,:);
        fprintf(['Done realigning center ' num2str(e) ':' num2str(size(C,1)) '\n']);
    end
end