function [] = cFlow_execute(matFile)
    if isdeployed
        [p,matFile,ext] = fileparts(matFile);
    end
    load(matFile,'tmpJob');
    tmpJob.localExecute();
end