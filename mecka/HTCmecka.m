function [] = HTmecka(user,algorithm)
    %{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    About:      
                HTmecka.m is create jobs for condor to run Maize Ear Cob Kernel Analysis. A user is 
                to choose one of three algorithm to use and provide user for condor.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dependency: 
                mecka.m, ScanAndIssueNewFilesOniRods.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Variable Definition:
                user:           The user name for condor. (?)
                algorithm:      The argorithm to use. 'c' for singleCobImage.m, 'e' for singleEarImage.m, and 'k' for singleKernelImage.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    tmpFileLocation = '/mnt/scratch1/maizePipeline/mecka/tmpSubmitFiles/';
    remoteOutputLocation = ['/iplant/home/' user '/#plantType#/return/#tissueType#/output/'];
    remoteOutputLocation = strrep(remoteOutputLocation,'#plantType#','maizeData');
    switch algorithm
        case 'c'
            analysisType = 'cobs';
            memREQ = '4000';
            algorithmFlag = 'c';
            numberOfObjects = '3';
            imageRES = '1200';
            localOutputLocation = ['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/cobData/'];
            remoteOutputLocation = strrep(remoteOutputLocation,'#tissueType#','cobData');
        case 'e'
            analysisType = 'ears';
            memREQ = '4000';
            algorithmFlag = 'e';
            numberOfObjects = '3';
            imageRES = '1200';
            localOutputLocation = ['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/earData/'];
            remoteOutputLocation = strrep(remoteOutputLocation,'#tissueType#','earData');
        case 'k'
            analysisType = 'kernels';
            memREQ = '4000';
            algorithmFlag = 'k';
            numberOfObjects = [];
            imageRES = '1200';
            localOutputLocation = ['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/kernelData/'];
            remoteOutputLocation = strrep(remoteOutputLocation,'#tissueType#','kernelData');
    end
    CMD = ['imkdir -p ' remoteOutputLocation];
    system(CMD);
    
    % get file list
    [FileList] = ScanAndIssueNewFilesOniRods(user,analysisType);
    numJobs = numel(FileList);
    
    func = cFlow('mecka');
    for e = 1:numJobs
        func(algorithmFlag,FileList{e},numberOfObjects,'./output/',remoteOutputLocation,1,1,imageRES,1);
    end
    func.submitDag(50,50);
    
    
end

%{
    HTCmecka('gxe','c');
    HTCmecka('gxe','e');
    HTCmecka('gxe','k');
%}