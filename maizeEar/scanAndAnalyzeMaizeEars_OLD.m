function [] = scanAndAnalyzeMaizeEars(inPath,user,irodsSwitch)

    % if running local
    if ~irodsSwitch
        % dig for images
        FilePath = strrep(inPath,'#USER#',user);    
        FileList = {};
        FileExt = {'tif','TIF'};
        verbose = 1;
        [FileList] = gdig(FilePath,FileList,FileExt,verbose);
    end
   
    % scan a fuse mounted directory for maize data
    if irodsSwitch
        [FileList] = scanForMaizeImagesOnIrods(user,'ears');
    end
    
    % check to see if data is already analyzed
    resultsPath = ['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/earData/output/'];
    rm = [];
    for e = 1:numel(FileList)
        [pth nm ext] = fileparts(FileList{e});
        oFile = [resultsPath nm '_result' ext];
        rm(e) = exist(oFile);
    end
    rm = logical(rm);
    FileList(rm) = [];
    
    % change the local file name to irods file name and issue tickets
    if irodsSwitch
        [FileList] = fuse2irods2(FileList,'/home/nate/iplant/',['/iplant/home/' user '/maizeData/']);
        [FileList] = issueBulkTicket(FileList);
    end
    
    %%% geneate the dag 
    % generate dag
    tmpFileLocation = '/mnt/scratch1/phytoM/flashProjects/maizeEarCondor/';
    dag = epfod();
    dag.setFunctionName('singleEarImage');
    dag.setOutputLocation(['/mnt/spaldingdata/nate/mirror_images/maizeData/' user '/return/earData/']);
    dag.setTempFilesLocation(tmpFileLocation);
    numJobs = numel(FileList);
    %numJobs = 1;
    for e = 1:numJobs
        % get the file name and path
        [pth,nm,ex] = fileparts(FileList{e});
        % create job
        job = cJob();
        job.setTempFilesLocation(tmpFileLocation);
        job.setFunctionName('singleEarImage');    
        job.setNumberofArgs(5);
        % if local then add to condor file transfer and attach name after
        % condor file transfer
        if ~irodsSwitch
            job.addFile(FileList{e});
            job.setArgument([nm ex],1);
        else
            job.setArgument([FileList{e}],1);
        end
        job.setArgument('3',2);
        job.setArgument('./output/',3);
        job.setArgument('0',4);
        job.setArgument('1',5);
        % add job to dag
        dag.addJob(job);
        job.generate_submitFilesForDag();
    end

    
    
    dag.renderDagFile();
    scpList = dag.generate_scpFileList();
    dirCMD_logs_out = ['ssh -p 50118 nate@128.104.98.118 ''' 'mkdir -p /home/nate/condorFunctions/#directory#/logs/stdout/'''];
    dirCMD_logs_err = ['ssh -p 50118 nate@128.104.98.118 ''' 'mkdir -p /home/nate/condorFunctions/#directory#/logs/stderr/'''];
    dirCMD_output = ['ssh -p 50118 nate@128.104.98.118 ''' 'mkdir -p /home/nate/condorFunctions/#directory#/output/'''];
    [status result] = system(strrep(dirCMD_logs_out,'#directory#',dag.jobFunction));
    [status result] = system(strrep(dirCMD_logs_err,'#directory#',dag.jobFunction));
    [status result] = system(strrep(dirCMD_output,'#directory#',dag.jobFunction));
    dirCMD = ['ssh -p 50118 nate@128.104.98.118 ''' 'mkdir /home/nate/condorFunctions/#directory#/'''];
    [status result] = system(strrep(dirCMD,'#directory#',dag.jobFunction));
    CMD = 'scp -P 50118 #srcfile# nate@128.104.98.118:/home/nate/condorFunctions/#directory#/#desfile#';
    CMD = strrep(CMD,'#directory#',dag.jobFunction);
    for f = 1:numel(scpList)
        [pth nm ext] = fileparts(scpList{f});
        tCMD = strrep(CMD,'#desfile#',[nm ext]);
        tCMD = strrep(tCMD,'#srcfile#',scpList{f});
        [status result] = system(tCMD);
    end

    % submit the job dag
    dagName = dag.generate_dagName();    
    CMD = ['ssh -p 50118 nate@128.104.98.118 ''' 'cd /home/nate/condorFunctions/#directory#/; condor_submit_dag ' dagName ''''];
    CMD = ['ssh -p 50118 nate@128.104.98.118 ''' 'cd /home/nate/condorFunctions/#directory#/; condor_submit_dag -maxidle 50 -maxjobs 50 -maxpost 50 ' dagName ''''];    
    CMD = ['ssh -p 50118 nate@128.104.98.118 ''' 'cd /home/nate/condorFunctions/#directory#/; export _CONDOR_DAGMAN_SUBMIT_DELAY=180; export _CONDOR_DAGMAN_MAX_SUBMITS_PER_INTERVAL=50; condor_submit_dag -maxidle 50 -maxpost 50 ' dagName ''''];    
    CMD = ['ssh -p 50118 nate@128.104.98.118 ''' 'cd /home/nate/condorFunctions/#directory#/; export _CONDOR_DAGMAN_SUBMIT_DELAY=0;condor_submit_dag -maxidle 30 -maxpost 50 ' dagName ''''];    
    
    CMD = strrep(CMD,'#directory#',dag.jobFunction);
    system(CMD,'-echo');
end

%{
    inPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/#USER#/earData/';    
    %scanAndAnalyzeMaizeEars(inPath,'nhaase');
    scanAndAnalyzeMaizeEars(inPath,'gxe');

    % for running single ear and development
    singleEarImage(FileList{140},3,[],0,0);
%}