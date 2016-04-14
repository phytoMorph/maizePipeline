function [ret] = mySiteFFT(imageFile,varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if output directory is given create the save directory
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin == 2
        output_directory = varargin{1};
        mkdir(output_directory);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % read the image
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    I = double(imread(imageFile))/255;
   
    % setup the windows length
    WINDOWS = 1200:50:1800;
    %WINDOWS = 1200:500:1800;
    
    % loop over the windows
    for win = 1:numel(WINDOWS)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set the window value
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        WIN = WINDOWS(win);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setup the sites generator
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % OP.filter_window_size = size of filter window
        % OP.sigma              = sigma of filter window
        % OP.numberCobs         = number of cobs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        siteOP.filter_window_size = [301 301];
        siteOP.sigma = 91;
        siteOP.numberCobs = 3;
        siteOP.siteSample = 10;
        siteOP.windowSize = 2*WIN+1;
        % function to call to generate the sites
        site_function_generator.func = @(I,OP)mySiteExtract0(I,OP);
        % ops to pass to the site generator
        site_function_generator.OP = siteOP;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % call site(s) process
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        site_function.func = @(block)myBlock0(block);
        site_function.block_size = [WIN 1];
        site_reduce_function = @(block)myReduction0(block);
        tmp_ret = site_process_caller(I,site_function_generator,site_function,site_reduce_function);
        fprintf(['Done with window ' num2str(win) ':' num2str(numel(WINDOWS)) '\n']);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % post process each window to find the peaks T
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for e = 1:numel(tmp_ret)
            %{
            % OLD WAY USED LOTS OF MEM
            % change the cell to mat
            % sig = cell2mat(tmp_ret{e}.data);            
            % mean along all sites
            %sig = mean(sig,2);            
            %}
            sig = tmp_ret{e}.data;
            % store the raw sig
            ret{e,win} = sig;
            % filter the sig
            sig = imfilter(sig,fspecial('average',[5 1]));
            % take the gradient
            sig = sig.*([1:size(sig,1)]-1)';
            % pick out the kernel length via period
            KernelData(e,win) = findT(sig(1:40),size(sig,1));
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % generate the output data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phData = [];
    for e = 1:numel(tmp_ret)
        phData = [phData ; [tmp_ret{e}.auxData.width tmp_ret{e}.auxData.height tmp_ret{e}.auxData.mean_width nanmean(KernelData(e,:))]];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if output directory is given the save data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if nargin == 2
        tic
        fprintf(['Spooling out data to disk: START\n']);
        % get files parts
        [pth nm ext] = fileparts(imageFile);
        
        % save mat file
        save([output_directory filesep nm '_ret.mat'],'ret','KernelData');
        
        % save ear features
        csvwrite([output_directory filesep nm '_phenoTypeData.csv'],reshape(phData',[1 numel(phData)]));
        
        % create feedback image
        h = image(I);
        hold on        
        for b = 1:numel(tmp_ret)
            rectangle('Position',tmp_ret{b}.auxData.BoundingBox,'EdgeColor','r');
            CS = [1:tmp_ret{b}.auxData.BoundingBox(4)] + tmp_ret{b}.auxData.BoundingBox(2);
            Func = 100*cos(2*pi/nanmean(KernelData(b,:))*CS) + tmp_ret{b}.auxData.BoundingBox(3)/2 + tmp_ret{b}.auxData.BoundingBox(1);
            plot(Func,CS,'r');
        end
        imageFile = [output_directory nm '_result.tif' ];
        saveas(h,imageFile);
        
        
        % save width profiles
        for e = 1:numel(tmp_ret)
            outFile = [output_directory filesep nm '_widthProfile_' num2str(e) '.csv'];
            csvwrite(outFile,tmp_ret{e}.auxData.cob_width_profile);
            outFile = [output_directory filesep nm '_earContour_' num2str(e) '.csv'];
            csvwrite(outFile,tmp_ret{e}.auxData.dB);
            plot(tmp_ret{e}.auxData.dB(:,2),tmp_ret{e}.auxData.dB(:,1),'g');
        end
        fprintf(['Spooling out data to disk: END ' num2sr(toc) '\n']);
    end
    
end

%{
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compile_directory = '/mnt/scratch1/phytoM/flashProjects/maizeEarCondor/';
    CMD = ['mcc -d ' compile_directory ' -m -v -R -singleCompThread mySiteFFT.m'];
    eval(CMD);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % condor launch - START
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dig for input images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/earData/';    
    FilePath = inPath;    
    FileList = {};
    FileExt = {'tif','TIF'};
    verbose = 0;
    [FileList] = gdig(FilePath,FileList,FileExt,verbose);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % geneate the dag 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % generate dag
    tmpFileLocation = '/mnt/scratch1/phytoM/flashProjects/maizeEarCondor/';
    dag = epfod();
    dag.setFunctionName('mySiteFFT');
    dateString = strrep(strrep(strrep(datestr(clock, 'yyyy-mm-dd HH:MM:SS'),' ','_'),':','_'),'-','_');
    outputLocation =['/mnt/spaldingdata/nate/mirror_images/maizeData/development/fft_condor/' dateString '/'];
    mkdir(outputLocation);
    dag.setOutputLocation(outputLocation);
    dag.setTempFilesLocation(tmpFileLocation);
    
    numJobs = numel(FileList);
    %numJobs = 5;
    for e = 1:numJobs
        % file into parts
        [pth,nm,ex] = fileparts(FileList{e});
        
        % create job
        job = cJob();
        job.setTempFilesLocation(tmpFileLocation);
        job.setFunctionName('mySiteFFT');    
        job.setNumberofArgs(2);
        job.addFile(FileList{e});
        job.setArgument([nm ex],1);        
        job.setArgument('./output/',2);        
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
    CMD = strrep(CMD,'#directory#',dag.jobFunction);
    system(CMD);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % condor launch - END
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % condor loader -START
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dig for returns
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dataPath = outputLocation;
    inPath = dataPath;
    FilePath = inPath;    
    dFileList = {};
    FileExt = {'mat'};
    verbose = 0;
    [dFileList] = gdig(FilePath,dFileList,FileExt,verbose);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data = {};
    nm = {};
    dataID = {};
    KernelData = [];
    for e = 1:numel(dFileList)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % gather the name of the data and the trial
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [pth nm{e} ext] = fileparts(dFileList{e});
        tr{e} = nm{e}(end-4:end-4);
        dataID{e} = nm{e}(1:end-6);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % load the data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %d = load(dFileList{e},'ret','KernelData');
        %data{e} = d.ret;
        d = load(dFileList{e},'KernelData');
        KernelData(e,:) = mean(d.KernelData,2);
        fprintf(['done with loading ' num2str(e) ':' num2str(numel(dFileList)) '\n']);
        %{
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find T
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1:numel(data{e})
            sig = data{e}{i};
            sig = imfilter(sig,fspecial('average',[5 1]));
            sig = sig.*([1:size(sig,1)]-1)';
            [KernelData(e,i) f] = findT(sig(1:40),size(sig,1));
        end
        %}
    end
    KernelData = KernelData';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % condor loader - END
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % hand measurements compare - START
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% read the handmeasurements
    [D] = xlsread('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/LengthData_hand.xls');
    %% search for data and pair hand measurements
    handM = [];
    autoM = [];
    ID = [];
    tmpSpec = {};
    specData = {};
    for e = 1:size(D,1)
        uT = [];
        tmpSpec = [];
        IDX = num2str(D(e,1));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % look through each dataID
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1:numel(dataID)
            fidx = strfind(dataID{i},IDX);
            if ~isempty(fidx)            
                try                         
                    uT = [uT;KernelData(:,i)'];
                    %tmpSpec{end+1} = data{i};
                catch ME
                    IDX
                    ME
                end
            end
        end

          
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % average together the trials
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        uT = nanmean(uT,1);
        if ~isempty(uT)
            autoM = [autoM;[D(e,1) uT/1200*25.4]];
            handM = [handM;[D(e,1) D(e,4:3:end)/10]];            
            ID = [ID;str2num(IDX)];
            specData{end+1} = tmpSpec;
        else
            IDX
        end                
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove nan
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rmidx = any(isnan(autoM),2) | any(isnan(handM),2);
    autoM(rmidx,:) = [];
    handM(rmidx,:) = [];
    ID(rmidx) = [];
    specData(rmidx) = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get measurements and plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hD = handM(:,2:3);
    aD = autoM(:,2:3);
    aD = aD(:);
    hD = hD(:);
    plot(hD(:),aD(:),'.')
    [J sidx] = sort(abs(aD - hD));
    rm_num = 10;
    hD(sidx(end-rm_num:end)) = [];
    aD(sidx(end-rm_num:end)) = [];
    hold on
    plot(hD(:),aD(:),'r.');
    corr(hD,aD)
    uhD = mean(handM(:,2:end),2);
    uaD = mean(autoM(:,2:end),2);
    [J sidx] = sort(abs(uaD - uhD));
    rm_num = 10;
    uhD(sidx(end-rm_num:end)) = [];
    uaD(sidx(end-rm_num:end)) = [];
    plot(uhD,uaD,'g.')
    corr(uhD,uaD)
    axis([3 8 3 8]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % hand measurements compare - END
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%}



%{

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % model width profile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dig for input csv files
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inPath = outputLocation;    
    FilePath = inPath;    
    FileList = {};
    FileExt = {'csv'};
    verbose = 0;
    [rawFileList] = gdig(FilePath,FileList,FileExt,verbose);
    kp0 = [];
    kp1 = [];
    for e = 1:numel(rawFileList)
        if ~isempty(strfind(rawFileList{e},'widthProfile'))
            kp0 = [kp0 e];
        end
        
        if ~isempty(strfind(rawFileList{e},'phenoTypeData'))
            kp1 = [kp1 e];
        end
    end
    csvFileList = rawFileList(kp0);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load width profiles
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    interpNum = 50;
    WIDTH = zeros(interpNum,numel(csvFileList));
    HEIGHT = [];
    EAR = [];
    NM = {};
    for e = 1:numel(csvFileList)
        [pth nm ext] = fileparts(csvFileList{e});
        d = csvread(csvFileList{e});
        WIDTH(:,e) = interp1(linspace(0,1,numel(d)),d,linspace(0,1,interpNum))';
        LENGTH(e) = numel(d); 
        fidx = strfind(nm,'_');
        EAR(e) = str2num(nm(fidx(end)+1:end));
        NM{e} = nm(1:fidx(1)-1);
        fprintf(['Done with ' num2str(e) ':' num2str(numel(csvFileList)) '\n']);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load kernel, max width, length data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    csvFileList = rawFileList(kp1);
    PH = [];
    for e = 1:numel(csvFileList)
        phFile = csvFileList{e};
        p = csvread(phFile);
        p = reshape(p,[4 3])';
        PH = [PH;p];
        fprintf(['Done with ' num2str(e) ':' num2str(numel(csvFileList)) '\n']);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % model profiles and plot information gain
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    modelPara = 3;
    [wS wC wU wE wL wERR wLAM] = PCA_FIT_FULL(WIDTH',modelPara);
    plot(cumsum(diag(wLAM))/sum(diag(wLAM)));
    waitforbuttonpress

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % view fit and raw data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for e = 1:size(wS,1)
        plot(wS(e,:),'r')
        hold on
        plot(WIDTH(:,e),'b')
        hold off
        drawnow
        pause(.5)
    end
    figure
    plot3(wC(:,1),wC(:,2),wC(:,3),'.')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % parameter sweep
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uC = mean(wC,1);
    ndims = 3;
    CL = {'r' 'b' 'g' 'm' 'c' 'y' 'r' 'b' 'g' 'm' 'c' 'y'}; 
    for d = 1:ndims
        tmpC = uC;
        para = linspace(min(wC(:,d)),max(wC(:,d)),10);
        tmpC = repmat(tmpC,[numel(para) 1]);
        tmpC(:,d) = para';
        model = PCA_BKPROJ(tmpC,wE,wU);
        for e = 1:size(model,1)
            plot(fliplr(model(e,:)),linspace(1,mean(LENGTH),size(model,2)),CL{e});
            hold on
            plot(-fliplr(model(e,:)),linspace(1,mean(LENGTH),size(model,2)),CL{e});
            hold all
        end
        hold off
        axis equal
        waitforbuttonpress
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % look up image
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % look up image
    deltaM = bsxfun(@minus,WIDTH',model(end-3,:));
    deltaM = sum(deltaM.*deltaM,2);
    [~,sidx] = min(deltaM);
    imageFile = [outputLocation '/output/' NM{sidx} '_result.tif'];
    I = imread(imageFile);
    imshow(I,[]);
    title(num2str(EAR(sidx)))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % width with length
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for d =1:5
        plot(wC(:,d),LENGTH,'.');
        waitforbuttonpress
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WIDTH with phenotype
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for d = 1:3
        for p = 1:size(PH,2)
            plot(wC(:,d),PH(:,p),'.');
            title(['dim: ' num2str(d) '-- pheno: ' num2str(p)]);
            waitforbuttonpress
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LENGTH with phenotype
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for p = 1:size(PH,2)
        plot(LENGTH,PH(:,p),'.');
        title(['pheno: ' num2str(p)]);
        waitforbuttonpress
    end

%}


%{

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % local launch
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dig for input images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inPath = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/earData/';    
    FilePath = inPath;    
    FileList = {};
    FileExt = {'tif','TIF'};
    verbose = 0;
    [FileList] = gdig(FilePath,FileList,FileExt,verbose);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % local run(s)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    e = 1;
    ret = mySiteFFT(FileList{e});

%}


