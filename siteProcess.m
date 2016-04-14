function [ret] = siteProcess(sites,blockSize,func,image)
    %{
    for e = 1:size(sites,1)
        block = image((sites(e,1)-blockSize(1)):(sites(e,1)+blockSize(1)),(sites(e,2)-blockSize(2)):(sites(e,2)+blockSize(2)));
        ret{e} = func(block);
    end
    %}
    
    B = zeros(2*blockSize(1)+1,size(sites,1));
    for e = 1:size(sites,1)
        block = image((sites(e,1)-blockSize(1)):(sites(e,1)+blockSize(1)),(sites(e,2)-blockSize(2)):(sites(e,2)+blockSize(2)));
        B(:,e) = block(:,2);
    end
    ret{1} = func(B);
end