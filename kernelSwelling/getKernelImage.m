function [I] = getKernelImage(fileName,center,BOX)
    info = imfinfo(fileName);
    COL = round([max(1,center(2)-BOX(1)) min(center(2)+BOX(2),info(1).Width)]);
    ROW = round([max(1,center(1)-BOX(3)) min(center(1)+BOX(4),info(1).Height)]);
    I = imread(fileName,'PixelRegion',{ROW COL});
end