function [sites mask] = generate_checker_board(mask,downsample)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create checker board to sample over
    tm = clock;
    [g1 g2] = ndgrid(1:size(mask,1),1:size(mask,2));
    g1 = mod(g1,downsample) == 0;
    g2 = mod(g2,downsample) == 0;
    G = g1 .* g2;
    fprintf(['e-time for checkboard @ ' num2str(etime(clock,tm)) '\n'])

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % mask checker board with toMeasure mask
    tm = clock;
    mask = mask.*G;
    [ri ci] = find(mask);
    sites = [ri ci];
    fprintf(['e-time for find checkboard @ ' num2str(etime(clock,tm)) '\n'])
    
    
    
end