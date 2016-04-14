function [] = scanAndAnalyzeMaizeKernels(user)
    analysisType = 'kernels';    
    % get file list
    [FileList] = ScanAndIssueNewFilesOniRods(user,analysisType);
    % generate dag
    tmpFileLocation = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeKernel/tmpSubmitFiles/';
    dag = epfod();
    dag.setFunctionName('singleKernelImage');
    dag.setOutputLocation(['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/kernelData/']);
    dag.setTempFilesLocation(tmpFileLocation);
    % add jobs to dag for each image - create and add job to dag
    numJobs = numel(FileList);
    for e = 1:numJobs
        [pth,nm,ex] = fileparts(FileList{e});
        % create job
        job = cJob();
        job.requirements.memory = {'=' '16000'};
        job.setTempFilesLocation(tmpFileLocation);
        job.setFunctionName('singleKernelImage');    
        job.setNumberofArgs(4);
        job.setArgument(FileList{e},1);        
        job.setArgument('./output/',2); 
        job.setArgument('1',3);
        job.setArgument('1',4); 
        % add job to dag
        dag.addJob(job);
        job.generate_submitFilesForDag();
    end
    if numJobs ~= 0
        % submit dag
        dag.submitDag(50,50);
    end
    %{
        singleKernelImage(FileList{4},'./output/',1,1);
    %}
end

%{   
    scanAndAnalyzeMaizeKernels('nhaase');
%}