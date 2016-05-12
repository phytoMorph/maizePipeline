function [] = scanAndAnalyzeMaizeSeedling(user)
    analysisType = 'seedlings';
    % get file list
    [FileList] = ScanAndIssueNewFilesOniRods(user,analysisType);
    % geneate the dag
    tmpFileLocation = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeSeedling/tmpSubmitFiles/';
    dag = epfod();    
    dag.setFunctionName('singleSeedlingImage');
    dag.setOutputLocation(['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/seedlingData/']);
    dag.setTempFilesLocation(tmpFileLocation);
    numJobs = numel(FileList);
    % add jobs to dag for each image - create and add job to dag
    for e = 1:numJobs        
        % create job
        job = cJob();
        job.addFile('/mnt/spaldingdata/nate/dcraw');
        job.requirements.memory = {'=' '8000'};
        job.setTempFilesLocation(tmpFileLocation);
        job.setFunctionName('singleSeedlingImage');    
        job.setNumberofArgs(7);        
        job.setArgument([FileList{e}],1);
        job.setArgument('50',2);
        job.setArgument('5',3);
        job.setArgument('100',4);
        job.setArgument('100',5);
        job.setArgument('4',6);
        job.setArgument('./output/',7);
        % add job to dag
        dag.addJob(job);
        job.generate_submitFilesForDag();
    end
    if numJobs ~= 0
        % submit dag
        dag.submitDag(50,50);
    end
end

%{  
    scanAndAnalyzeMaizeSeedling('hirsc213');
    singleSeedlingImage(FileList{end},50,5,100,100,4,'./junk/');
%}