function [varargout] = wrap4Cob(mainfun,fileName,noe,oPath,rawImage_scaleFactor,varargin)
    try
% This function takes inputs and compute relative inputs with fraction
% Get resolution of the image frosingleCobImagem its filename
[pth nm ext] = fileparts(fileName);
% Expect same filename format
% i.e. 'MN03-160125-0026-300.tif'
nums = regexp(nm,'-','split');
res = nums(end);
baseRes = 1200;
res = StoN(res);
baseRes = StoN(baseRes);
fracDpi = round(res/baseRes);

[varargout{1:nargout}] = funcToRun(varargin{1}{:});

function [varargout] = runMem(dirToRun,funcToRun,varargin)

        % get working directory
        curWD = pwd;
        % 
        cd(dirToRun)
        % change to working directory of dirToRun
        [varargout{1:nargout}] = funcToRun(varargin{1}{:});
        % change the workig directory back to the orginal



cd(curWD)
    % setup the return function call for the user to use
    funcToRun = [destination mainfun];
    func = @(varargin)runMem(destination,str2func(mainfun),varargin);


catch ME
        close all;
        getReport(ME);
        fprintf(['******error in:wrap4Cob.m******\n']);
end
end

%{
singleCobImage(fileName,noe,oPath,rawImage_scaleFactor,checkBlue_scaleFactor,
defaultAreaPix,fracDpi,rho,addcut,baselineBlue,colRange1,colRange2,fill,
toSave,toDisplay)

singleCobImage(I800,3,oPut,1,.25,1000000,2,300/2,100/2,600,70,166,50,1,1);

wrap4Cob([]@singleCobImage(),fileName,noe,oPath,rawImage_scaleFactor)
%}