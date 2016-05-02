function [T ret] = measureImage(fsI,toMeasure,downsample,dR,CHUNK)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                measureImage.m is main function to handle cob analysis. It takes all input variables 
                for its dependent functions. This function returns final result including image with 
                bounding box and color circle. (Inputs are relative to 1200dpi)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                siteProcess.m, myBlock0.m, findT.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                fsI:            The image, period to be measured.
                toMeasure:      Errode such that the fft window samples only ear image.
                downsample:     The number of down sample grid sites.
                dR:             Set the current window size
                CHUNK:          The number of chunk for input for FFT in myBlock0.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    %%%%%%%%%%%%%%%%%%%%%%%
    % init return vars    
    T = NaN;   
    ret = NaN;
    %%%%%%%%%%%%%%%%%%%%%%% 
    try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set display to false
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % create sample sites for fft application
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [g1 g2] = ndgrid(1:downsample:size(toMeasure,1),1:downsample:size(toMeasure,2));
        idx = sub2ind(size(toMeasure),g1(:),g2(:));
        idx = find(toMeasure(idx) == 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % perform fft block process at sitesret{k} = func(B);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tm = clock;        
        sites = [g1(idx) g2(idx)];
        ret = siteProcess(sites,[dR 1],@(block)myBlock0(block),fsI,CHUNK);
        ret = cell2mat(ret);
        ret = mean(ret,2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % analysis of the average fft over the windows
        % look at the first half of the period fft signal 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ufT = ret(1:dR);
        % filter the first half of the signal
        h = fspecial('average',[5 1]);
        ufT = imfilter(ufT,h);
        % find period via first peak finding
        [T f] = findT(ufT,2*dR+1);
        fprintf(['e-time for find fft @ ' num2str(etime(clock,tm)) '\n']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % display
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        if disp
            imshow(sI,[]);
            hold on
            CS = 1:size(fsI,1);
            plot(100*cos(CS*T^-1*2*pi) + 100,CS,'r');
            title(num2str(T));
            hold off
            drawnow
        end
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:measureImage.m******\n']);
    end
end

 %{

        %{
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % create checker board to sample over
        tm = clock;
        [g1 g2] = ndgrid(1:size(toMeasure,1),1:size(toMeasure,2));
        g1 = mod(g1,downsample) == 0;
        g2 = mod(g2,downsample) == 0;
        G = g1 .* g2;
        fprintf(['e-time for checkboard @ ' num2str(etime(clock,tm)) '\n'])
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % mask checker board with toMeasure mask
        tm = clock;
        [ri ci] = find(toMeasure.*G);
        fprintf(['e-time for find checkboard @ ' num2str(etime(clock,tm)) '\n'])
        %}



        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % iterate over the checker board 
        % perform fft
        tm = clock;
        UQ = unique(ri);        
        N = 2*dR+1;
        window_ufT = zeros(N,numel(UQ));
        for u = 1:numel(UQ)
            % find the ri-th row
            fidx = find(ri == UQ(u));
            % find the corresponding column point
            CI = ci(fidx);
            SIG = fsI(ri(fidx(1))-dR:ri(fidx(1))+dR,CI(1):CI(end));            
            % subtract off the mean
            uSIG = mean(SIG,1);
            SIG = bsxfun(@minus,SIG,uSIG);
            % perform fft along 1 dim
            fT = fft(SIG,[],1);
            % get the mean of the fft signal along the 2nd dim
            window_ufT(:,u) = mean(abs(fT),2);
        end
        fprintf(['e-time for find fft @ ' num2str(etime(clock,tm)) '\n']);
        %}
        
        
        
        %{
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % analysis of the average fft over the windows
        % look at the first half of the period fft signal
        tm = clock;        
        ufT = window_ufT(1:round(size(window_ufT,1)/2),:);
        % filter the first half of the signal
        h = fspecial('average',[5 1]);
        ufT = imfilter(ufT,h);
        % take the average over all the windows
        uK = mean(ufT,2);
        fprintf(['e-time for find fft @ ' num2str(etime(clock,tm)) '\n']);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % get the peak frequency
        tm = clock;
        [T f] = findT(uK,N);        
        fprintf(['e-time for find peak-frequency @ ' num2str(etime(clock,tm)) '\n']);
        %}