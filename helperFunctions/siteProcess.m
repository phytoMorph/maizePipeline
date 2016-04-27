function [ret] = siteProcess(sites,blockSize,func,image,CHUNK)
    %{
        siteProcess slices an image into multiple blocks and feeds to
        func, which is myBlock0 in this case.
        Dependency: myBlock0
    %}
    try
        %CHUNK = 10;
        % init start and stop pointers
        str = 1;
        stp = str + CHUNK;
        stp = min(stp,size(sites,1));
        k = 1;
        while stp > str
            tmpCHUNK = stp - str + 1;
            B = zeros(2*blockSize(1)+1,tmpCHUNK,'single');
            cnt = 1;
            for e = str:stp
                block = image((sites(e,1)-blockSize(1)):(sites(e,1)+blockSize(1)),(sites(e,2)-blockSize(2)):(sites(e,2)+blockSize(2)));
                B(:,cnt) = block(:,2);
                cnt = cnt + 1;
            end
            % update start and stop pointers
            str = stp + 1;
            stp = str + CHUNK;
            stp = min(stp,size(sites,1));
            % insert results from func
            ret{k} = func(B);
            k = k + 1;
        end
    catch ME
        fprintf(['******error in:siteProcess.m******\n']);
    end
end