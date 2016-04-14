function [FileList] = ScanAndIssueNewFilesOniRods(user,tissueType,plantType,fileExt)
    if nargin == 2
        plantType = 'maize';
        fileExt = {'tif','TIF','tiff','nef'};
    end
    % scan a fuse mounted directory for maize data
    [FileList] = scanForImagesOnIrods(user,plantType,tissueType,fileExt);
    
    % remove the processed files
    [FileList] = removeProcessedFiles(FileList,user,tissueType,plantType);
    
    % change the local file name to irods file name and issue tickets
    baseString = ['/iplant/home/' user '/$plantTypeData/'];
    baseString = strrep(baseString,'$plantType',plantType);
    [FileList] = fuse2irods2(FileList,'/home/nate/iplant/',baseString);
    
    % issue bulk shared tickets
    [FileList] = issueBulkTicket(FileList);
end