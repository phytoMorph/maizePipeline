function [] = scanAndAnalyzeMaizeEars(user)
    analysisType = 'ears';
    % get file list
    [FileList] = ScanAndIssueNewFilesOniRods(user,analysisType);
    % geneate the dag
    tmpFileLocation = '/mnt/scratch1/phytoM/flashProjects/maizePipeline/maizeEar/tmpSubmitFiles/';
    dag = epfod();    
    dag.setFunctionName('singleEarImage');
    dag.setOutputLocation(['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/earData/']);
    dag.setTempFilesLocation(tmpFileLocation);
    numJobs = numel(FileList);
    % add jobs to dag for each image - create and add job to dag
    for e = 1:numJobs        
        % create job
        job = cJob();
        job.requirements.memory = {'=' '4000'};
        job.setTempFilesLocation(tmpFileLocation);
        job.setFunctionName('singleEarImage');    
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
    if numJobs ~= 0
        % submit dag
        dag.submitDag(50,50);
    end
end

%{  
    scanAndAnalyzeMaizeEars('nhaase');
    scanAndAnalyzeMaizeEars('gxe');
    scanAndAnalyzeMaizeEars('garf0012');
%}