function [] = checkNcompile(mexaName)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                checkNcompile.m checks existance of .mexa64 file and if it
                does not then compile and create .mexa64.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                cwtK_closed_imfilter.m, circshift.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                dB:      The information is needed. 
                B:
                I:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    try
        [pth nm ext] = fileparts(mexaName);
        mexaName = ['/mnt/snapper/Lee/gitHub_maizepipeline/maizePipeline/helperFunctions/' nm '/' mexaName];
        if exist(mexaName, 'file')
            % File exists.  Do stuff....
            %cd(cur);
        else
          % File does not exist.
          %cd('/mnt/snapper/Lee/gitHub_maizepipeline/maizePipeline/helperFunctions/ba_interp');
          mex -O ba_interp2.cpp;
          %cd(cur);
        end
    catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:checkNcompile.m******\n']); 
    end
end