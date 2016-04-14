function [] = scanAndAnalyzeMaizeCobs(user)
    analysisType = 'cobs';
    % get file list
    [FileList] = ScanAndIssueNewFilesOniRods(user,analysisType);   
    % geneate the dag 
    tmpFileLocation = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeCob/tmpSubmitFiles/';
    dag = epfod();
    dag.setFunctionName('singleCobImage');
    dag.setOutputLocation(['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/cobData/']);
    dag.setTempFilesLocation(tmpFileLocation);
    numJobs = numel(FileList);
    % add jobs to dag for each image - create and add job to dag
    for e = 1:numJobs
        [pth,nm,ex] = fileparts(FileList{e});
        % create job
        job = cJob();
        job.requirements.memory = {'=' '8000'};
        job.setTempFilesLocation(tmpFileLocation);
        job.setFunctionName('singleCobImage');    
        job.setNumberofArgs(5);        
        job.setArgument([FileList{e}],1);        
        job.setArgument('3',2);
        job.setArgument('./output/',3);
        job.setArgument('1',4);
        job.setArgument('1',5);
        % add job to dag
        dag.addJob(job);
        job.generate_submitFilesForDag();
    end
    % submit dag
    dag.submitDag(50,50);
    %{
    % run single image local
    singleCobImage(FileList{3},3,'./output/',0);
    %}
end

%{
    scanAndAnalyzeMaizeCobs('gxe');
%}