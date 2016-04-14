function [FileList] = scanForMaizeImagesOnIrods(user,type)
    pathToScan = '/home/nate/iplant/';
    CMD = ['mountIrods.sh /iplant/home/' user '/maizeData/'];
    [o,r] = system(CMD);
    switch type
        case 'ears'
            pathToScan = [pathToScan 'earData/'];                        
            FileList = {};
            FileExt = {'tiff','TIF','tif'};
            verbose = 1;
            FileList = gdig(pathToScan,FileList,FileExt,verbose);
        case 'cobs'
            pathToScan = [pathToScan 'cobData/'];                        
            FileList = {};
            FileExt = {'tiff','TIF','tif'};
            verbose = 1;
            FileList = gdig(pathToScan,FileList,FileExt,verbose);
            
        case 'kernels'
    end
    
    
end