function [B] = createBlocks(image,mask,dR,downsample)

 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % create checker board to sample over
        tm = clock;
        [g1 g2] = ndgrid(1:size(image,1),1:size(image,2));
        g1 = mod(g1,downsample) == 0;
        g2 = mod(g2,downsample) == 0;
        G = g1 .* g2;
        fprintf(['e-time for checkboard @ ' num2str(etime(clock,tm)) '\n'])
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % mask checker board with toMeasure mask
        tm = clock;
        [ri ci] = find(mask.*G);
        fprintf(['e-time for find checkboard @ ' num2str(etime(clock,tm)) '\n'])
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % perform fft block process at sites
        tm = clock;       
        sites = [ri ci];
        B = siteProcess(sites,[dR 1],@(block)myBlock1(block),image);
        B = cell2mat(B);            
        
        

end