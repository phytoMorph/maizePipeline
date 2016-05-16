classdef cJob < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this is a list of constants that are needed to generate the
    % condor scripts
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private) % for shell file
       % lines for mainX.sh
       mainline0 = '#!/bin/sh';
       mainline01 = 'uname -m';
       
       % unzip the mcr
       mainline1 = 'unzip -q v#MCRARG_VERSION#.zip';
       % set the mrc cache root to location which we can write to
       mainline2 = 'export MCR_CACHE_ROOT=$PWD/mcr_cache';
       mainline21 = 'mkdir -p $MCR_CACHE_ROOT';
       
       % unset the display - not sure if i need this
       mainline3 = 'unset DISPLAY';
       
       % untar the icommands if i want them
       mainline4 = 'tar xvfj icommands.x86_64.tar.bz2 -C $PWD';
       % add the icommands to the path
       mainline5 = 'export PATH=$PATH:$PWD/icommands/';
       % add the pwd to the path for other commands like dcraw
       mainlineN0 = 'export PATH=$PATH:$PWD/';
       % add the environment var for icommands
       mainline6 = 'export irodsEnvFile=$PWD/.irodsEnv';
       % add the environment var for icommands
       mainline9 = 'export irodsAuthFileName=$PWD/.irodsA';
       
       % add the command to run and point to MCR
       mainline7 = './run_#function#.sh "MATLAB_Compiler_Runtime/v#MCRARG_VERSION#/"';
       
       % tar the results
       %mainline8 = 'tar zcvf #outputTAR#.tar output';
       mainline8 = 'tar cvf #outputTAR#.tar output';
       
       % remove the squid and pack-in files
       mainline10 = 'rm #rmfile#';
       
       % squid location
       squidURL = 'http://proxy.chtc.wisc.edu/SQUID/ndmiller/';       
       
       % flock command
       flockCommand = '+WantFlocking = true';
       
       % osg command
       osgCommand = '+WantGlideIn = true';
       
       % input delimter
       delimiter = '**';
       
       % default remote save location
       outLocation = './output';
       
       MCR_version = 'v717';
    end
    
    properties (Access = private)% for submitfile
        % re universe
        universe = 'vanilla';
        
        % re transfer
        should_transfer_files = 'YES';
        when_to_transfer_output = 'ON_EXIT';        
    end
    
     properties (Constant)
        deployed_ouput_vars_location = 'inMemVarsOut';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this is a list of varaibles that need to be "filled out"
    % to generate the condor submit files
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % requirements needed for condor matching to machine
        requirements;
        % unique time stamp needed for creating mat file
        uniqueTimeRandStamp;
        %
        jobFunction;
        jobNargin;
        jobNargout;
        jobArguments;
        xferFileList;
        xferFileList_squid;
        toFlock = 0;
        toOsg = 0;
        
        tmpFileLocation = '/mnt/spaldingdata/nate/inMemCondor/';
        matFileName;
        fullMatLocation;
        outMatFileLocation;
    end
    
    methods
    
        % constructor
        function [obj] = cJob()
            % generate a unique key for handling the mat file
            obj.uniqueTimeRandStamp = strrep([num2str(now) num2str(rand(1,1))],'.','');
            obj.matFileName = [obj.uniqueTimeRandStamp '.mat'];
            obj.initDefaultRequirements();
            obj.initDefaultTransferList();
        end
        
        % set the to flock variable 
        function [] = setFlock(obj,value)
            obj.toFlock = value;
        end
        
        % set the OSG variable
        function [] = setOSG(obj,value)
            obj.toOsg = value;
        end
        
        function [] = initDefaultRequirements(obj)
            obj.requirements.('disk') = {'=' '3000000'};
            obj.requirements.('memory') = {'=' '4000'};
            obj.requirements.('cpus') = {'=' '1'};
        end
        
        function [] = setTempFilesLocation(obj,tmpFileLocation)
            obj.tmpFileLocation = tmpFileLocation;
        end
        
        function [] = initDefaultTransferList(obj)
            % attach any default files
            % listed below are the mcr and icommands attached via the squid
            % server
            obj.addSquidFile('v717.zip');
            obj.addSquidFile('icommands.x86_64.tar.bz2');
            %obj.addSquidFile('dcraw');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % change the MCR from the default version
        % note that the MCR must be on the squid server
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = changeMCRfile(obj,mcrFileName)
            obj.xferFileList_squid{1} =  [mcrFileName '.zip'];
            obj.MCR_version = mcrFileName;
            %{
            [p,n,ex] = fileparts(obj.xferFileList{1});
            obj.xferFileList{1} = [p mcrFileName];
        %}
        end
        
        
        function [] = setFunctionName(obj,functionName)
            obj.jobFunction = functionName;
            obj.addFile(obj.jobFunction);
            obj.addFile(['run_' obj.jobFunction '.sh']);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % call if the vars are loaded from memory
        % therefore the mat file will be generated
        % and the function will be called
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = setAsMemoryJob(obj,uniqueDAGKey,func)
            % set the job function
            obj.setFunctionName(func);
            % construct the eval location
            uniqueEvalDirectory = cFlow.generateUniqueCompileLocation(func,uniqueDAGKey);
            % construct the full location for the mat file
            matFileLocation = obj.generateVariableFileLocation(uniqueEvalDirectory);
            % construct output file
            out_matFileLocation = strrep(matFileLocation,'functionInputs','functionOutputs');
            % set output file location
            obj.outMatFileLocation = out_matFileLocation;
            % add the input file
            obj.addFile(matFileLocation);
            % set in memory mat file location
            obj.fullMatLocation = matFileLocation;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % argument implementations
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = setNumberofArgs(obj,jobNargin)
            obj.jobNargin = jobNargin;
        end
        
        function [] = setNumberofOArgs(obj,jobNargout)
            obj.jobNargout = jobNargout;
        end
        
        function [] = setArgument(obj,argument,number)
            obj.jobArguments{number} = argument;
        end
        
        function [arg] = getArgument(obj,number)
            arg = obj.jobArguments{number};
        end
        
        function [] = setArg(obj,argument,number)
            matLoc = obj.fullMatLocation;
            inputString = generateInput(argument,number,matLoc,obj.delimiter);
            obj.jobArguments{number} = inputString;
        end
        
        function [arg] = getArg(obj,number)
            arg = obj.jobArguments{number};
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % generate the mat file which will contain the input variables
        % actions:  make the directory for the dag
        %           make the functionInputs directory
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [matLoc] = generateVariableFileLocation(obj,launchDirectory)
            inputsDirectory = [launchDirectory 'functionInputs' filesep];
            CMD = ['mkdir -p ' inputsDirectory];
            system(CMD);
            matLoc =  [inputsDirectory obj.matFileName];
        end
        
        function [] = localExecute(obj)
            varargout = {};
            matFile = obj.fullMatLocation();
            if isdeployed
                [~,matFile] = fileparts(matFile); 
            end
            func = str2func(obj.jobFunction);
            inputString = '(';
            for input = 1:obj.jobNargin
                tmp = obj.jobArguments{input};
                load(matFile,tmp);
                inputString = [inputString tmp ','];
            end
            inputString(end) = ')';
            CMD = ['[OUT{1:obj.jobNargout}] = ' obj.jobFunction inputString ';'];
            eval(CMD);
            if isdeployed
                mkdir('./output/');
                matFile = ['./output/' matFile '.mat']
                fprintf('hello');
                for e = 1:numel(OUT)
                    varName = ['out' num2str(e)];
                    CMD = [varName '=OUT{e}'];
                    eval(CMD);
                    if exist(matFile)
                        save(matFile,varName,'-append');
                    else
                        save(matFile,varName);
                    end
                end
            else
                for e = 1:numel(OUT)
                    varName = ['out' num2str(e)];
                    CMD = [varName '=OUT{e};'];
                    eval(CMD);
                    if exist(obj.outMatFileLocation)
                        save(obj.outMatFileLocation,varName,'-append');
                    else
                        save(obj.outMatFileLocation,varName);
                    end
                    varargout{e} = [obj.outMatFileLocation '@' varName];
                end
            end
           
        end
        
        function [] = addFile(obj,file)
            obj.xferFileList{end+1} = file;
        end
        
        function [] = addSquidFile(obj,file)
            obj.xferFileList_squid{end+1} = file;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % generate functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % generate submit file to call shell command
        function [] = generate_submitFile(obj,oFilePath,asVar)
            fileID = fopen([oFilePath obj.generate_submitName] ,'w');
            
            % setup for universe
            fprintf(fileID,'%s\n',['universe = ' obj.universe]);
            
            % setup for executable
            fprintf(fileID,'%s\n',['executable = ' obj.generate_exeName]);
            
            % setup for transferfiles
            fprintf(fileID,'%s\n',['should_transfer_files = ' obj.should_transfer_files]);
            fprintf(fileID,'%s\n',['when_to_transfer_output = ' obj.when_to_transfer_output]);
            
            % setup for xfer files
            obj.renderFileTransferList(fileID,asVar);
            
            % setup for requirements
            obj.renderRequirements(fileID);
            
            % setup for arguments
            obj.renderArguments(fileID,asVar);
            
            % setup for logging
            obj.renderLogFiles(fileID);
          
            % setup for spalding nodes
            fprintf(fileID,'%s\n','+AccountingGroup = "spalding"');
            fprintf(fileID,'%s\n','priority = 9');
            fprintf(fileID,'%s\n','+Group = "spalding"');
            
            % render flock and osg commands if needed
            obj.renderFlockandOsg(fileID);
            
            % setup for queue
            fprintf(fileID,'%s\n','queue');
            
            % close file
            fclose(fileID);
        end
        % generate shell command for compiled code
        function [] = generate_shellCommand(obj,MCR_VER,icommands,oFilePath)
            fileID = fopen([oFilePath obj.generate_exeName],'w');
            
            % setup for shell script            
            fprintf(fileID,'%s\n',obj.mainline0);
            
            % setup reporting out information on machine which is computing           
            fprintf(fileID,'%s\n','echo "nodeArchType:"');
            fprintf(fileID,'%s\n',obj.mainline01);
            fprintf(fileID,'%s\n','echo "nodeIP:"');
            fprintf(fileID,'%s\n','dig +short myip.opendns.com @resolver1.opendns.com');          
            % render squid files
            obj.renderSquidXfer(fileID);
            
            % setup for MCR
            fprintf(fileID,'%s\n',strrep(obj.mainline1,'#MCRARG_VERSION#',MCR_VER));
            fprintf(fileID,'%s\n',obj.mainline2);
            fprintf(fileID,'%s\n',obj.mainline21);
            fprintf(fileID,'%s\n',obj.mainline3);
            
            % setup for icommands
            if icommands
                fprintf(fileID,'%s\n',obj.mainline4);
                fprintf(fileID,'%s\n',obj.mainline5);
                fprintf(fileID,'%s\n',obj.mainlineN0);
                fprintf(fileID,'%s\n',obj.mainline6);
                fprintf(fileID,'%s\n',obj.mainline9);
            end
            
            % setup for main function call
            mainCMD = strrep(obj.mainline7,'#function#',obj.jobFunction);
            mainCMD = strrep(mainCMD,'#MCRARG_VERSION#',MCR_VER);            
            for i = 1:obj.jobNargin
                argVAL = ['""${' num2str(i) '}""'];
                mainCMD = [mainCMD ' ' argVAL];
            end            
            fprintf(fileID,'%s\n',mainCMD);
            
            % setup for tar output            
            fprintf(fileID,'%s\n',strrep(obj.mainline8,'#outputTAR#',['${' num2str(obj.jobNargin+1) '}']));
            
            % add remove file for squid file list
            for e = 1:numel(obj.xferFileList_squid)
                [p,n,ext] = fileparts(obj.xferFileList_squid{e});
                fprintf(fileID,'%s\n',strrep(obj.mainline10,'#rmfile#',[n ext]));
            end
            
            % add remove file for squid file list
            for e = 1:numel(obj.xferFileList)
                [p,n,ext] = fileparts(obj.xferFileList{e});
                fprintf(fileID,'%s\n',strrep(obj.mainline10,'#rmfile#',[n ext]));
            end
            
            
            fprintf(fileID,'%s\n',strrep(obj.mainline10,'#rmfile#','.irodsA'));
            fprintf(fileID,'%s\n',strrep(obj.mainline10,'#rmfile#','.irodsEnv'));
            fprintf(fileID,'%s\n',strrep(obj.mainline10,'#rmfile#','-r output'));
            
            
            
            
            % close File
            fclose(fileID);
        end
        % generate submit package
        function [] = generate_submitFilesForDag(obj,oFilePath)
            if nargin == 1
                oFilePath = obj.tmpFileLocation;
            end
            obj.generate_submitFile(oFilePath,1);
            obj.generate_shellCommand(obj.MCR_version(2:end),1,oFilePath);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % helper functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % generate exe name
        function [exeName] = generate_exeName(obj)
            exeName = ['main_' obj.jobFunction '.sh'];
        end
        % gererate submit name
        function [submitName] = generate_submitName(obj)
            submitName = [obj.jobFunction '.submit'];
        end
        % generate file list
        function [xferList] = getTransferFileList(obj)
            xferList = '';
            for e = 1:numel(obj.xferFileList)
                tmp = [obj.xferFileList{e} ','];
                xferList = [xferList tmp];
            end
            xferList(end) = [];
        end
    end
    
    methods (Access = private)
        
        function [] = renderRequirements(obj,fileID)
            % old style
            %{
            req = 'requirements = ';
            flds = fieldnames(obj.requirements);
            for e = 1:numel(flds)
                tmp = ['(' flds{e} obj.requirements.(flds{e}){1} obj.requirements.(flds{e}){2} ') && '];
                req = [req tmp];
            end
            req(end-2:end) = [];
            fprintf(fileID,'%s\n',req);
            %}
            
            % new style
            flds = fieldnames(obj.requirements);
            for e = 1:numel(flds)
                tmp = ['request_' flds{e} obj.requirements.(flds{e}){1} obj.requirements.(flds{e}){2}];
                fprintf(fileID,'%s\n',tmp);
            end
        end

        function [] = renderArguments(obj,fileID,asVar)
            arg = 'arguments = "';
            for e = 1:(obj.jobNargin+1)
                if asVar
                    tmp = ['$(argNumber' num2str(e) ')'];
                else
                    tmp = [obj.jobArguments{e}];
                end
                arg = [arg '''' tmp '''' ' '];
            end
            arg(end) = [];
            arg = [arg '"'];
            fprintf(fileID,'%s\n',arg);
        end
        
        function [] = renderFileTransferList(obj,fileID,asVar)
            xferList = 'transfer_input_files = ';
            fileList = obj.getTransferFileList();
            if asVar
                fileList = '$(FileTransferList)';
            end
            xferList = [xferList fileList];
            fprintf(fileID,'%s\n',xferList);
        end        
        
        function [] = renderLogFiles(obj,fileID)
            outLOG = ['output = logs/stdout/maizeEar.output$(argNumber' num2str(obj.jobNargin+1) ')'];
            fprintf(fileID,'%s\n',outLOG);
            outERR = ['error = logs/stderr/maizeEar.output$(argNumber' num2str(obj.jobNargin+1) ')'];
            fprintf(fileID,'%s\n',outERR);
        end
        
        function [] = renderSquidXfer(obj,fileID)
            baseLine = 'curl -H "Pragma:" --retry 30 --retry-delay 6 -o ';
            for e = 1:numel(obj.xferFileList_squid)
                curlLine = [baseLine obj.xferFileList_squid{e} ' ' obj.squidURL obj.xferFileList_squid{e}];
                fprintf(fileID,'%s\n',curlLine);
            end
        end
        
        function [] = renderFlockandOsg(obj,fileID)
            if obj.toFlock
                fprintf(fileID,'%s\n',obj.flockCommand);
            end
            if obj.toOsg
                fprintf(fileID,'%s\n',obj.osgCommand);
            end
        end
    end
    
    methods (Static)
        
        function [func] = getFunctionWrapper(func)
            cJob.compileFunction(func);
            func = @(varargin)cJob.callFunction(func,varargin(:));
        end
        
        function [varargout] = callFunction(func,varargin)
            tmpJob = cJob();
            tmpJob.setAsMemoryJob();
            job.setTempFilesLocation(tmpFileLocation);
            job.setFunctionName(func);    
            for e = 1:numel(varargin)
                tmpJob.setArg(varargin{e},e);
            end
            
        end
    end
end

%{
    func = cJob.getFunctionWrapper('testCondorFunction');
%}