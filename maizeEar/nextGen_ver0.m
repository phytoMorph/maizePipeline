file = '/mnt/spaldingdata/nate/mirror_images/maizeData/nhaase/earData/9-10-14/Scan1-140910-0142.tif';
I = imread(file);
%%
H = rgb2hsv_fast(I,'','H','single');
%%
fI = stdfilt(H,getnhood(strel('disk',21,0)));
%fI = imfilter(hI,h,'replicate');
%fI = imfilter(yellowImage,h);
level = graythresh(fI);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% get binary, close, fill holes, remove small objects
%B = im2bw(fI,level);
B = fI < level;
B = imclose(B,strel('disk',31));
B = imfill(B,'holes');
B = bwareaopen(B,1000000);
B = imclearborder(B);
%% 
close all
n = 100:110;
locs = find(any(B,1));
sig = sum(B,1);
[J baseN] = max(sig);
n = baseN-10:baseN+10;
strip = I(:,(n),:);
labels = zeros(size(strip,1),size(I,2));
sam = squeeze(mean(strip,2));
stripMask = B(:,((n)));
stripMask = imfill(stripMask,'holes');
stripMask = any(stripMask,2);
sam = bsxfun(@times,double(sam),double(stripMask));
rmidx = all(sam==0,2);
kpidx = find(any(sam~=0,2));
sam(rmidx,:) = [];
plot(sam)
win = 11;
F = im2col(sam,[win 3],'sliding');
[S C U E L ERR LAM] = PCA_FIT_FULL_T(F,3);
kidx = kmeans(C',4);
kpidx(1:((win-1)/2)) = [];
kpidx(end-(win-1)/2+1:end) = [];

for m = 1:300
    labels(kpidx,(n(1)+m)) = kidx;
end

CL = {'r' 'g' 'b' 'y'};
out = double(I)/255;
for k = 1:4
    out = flattenMaskOverlay(out,labels==k,.5,CL{k});
end
imshow(out,[]);
mean(n)



%%
space_node_start = hmm_node('spaceStart');
kernel_node = hmm_node('kernel');
space_node = hmm_node('spaceEnd');

space_to_space = heavisideTransitionFunction(5,@(x,y)lt(x,y));
space_to_kernel = heavisideTransitionFunction(5,@(x,y)ge(x,y));



kernel_to_kernel = constantTransitionFunction(.1);
kernel_to_space = constantTransitionFunction(.9);

kernel_node.attachNode(kernel_node,kernel_to_kernel);
kernel_node.attachNode(space_node,kernel_to_space);

% attach distributions for patches
tipD = myProb(tip_mean_patch,tip_cov_patch);
tip_node.attachDistribution(tipD,1);
rootD = myProb(root_mean_patch,root_cov_patch);
root_node_lower.attachDistribution(rootD,1);
root_node_upper.attachDistribution(rootD,1);
transD = myProb(trans_mean_patch,trans_cov_patch);
t1_node.attachDistribution(transD,1);
t2_node.attachDistribution(transD,1);
kernelD = myProb(kernel_mean_patch,kernel_cov_patch);
kernel_node.attachDistribution(kernelD,1);
kernel_node_end.attachDistribution(kernelD,1);
% attach distributions for cordinates
tipD_cord = myProb(tip_mean_cord,tip_cov_cord);
tip_node.attachDistribution(tipD_cord,2);
rootD_cord = myProb(root_mean_cord,root_cov_cord);
root_node_lower.attachDistribution(rootD_cord,2);
root_node_upper.attachDistribution(rootD_cord,2);
transD_cord = myProb(trans_mean_cord,trans_cov_cord);
t1_node.attachDistribution(transD_cord,2);
t2_node.attachDistribution(transD_cord,2);
kernelD_cord = myProb(kernel_mean_cord,kernel_cov_cord);
kernel_node.attachDistribution(kernelD_cord,2);
kernel_node_end.attachDistribution(kernelD_cord,2);
% create hmm
hmm = my_hmm();
hmm.addNode(kernel_node);
hmm.addNode(t1_node);
hmm.addNode(root_node_upper);
hmm.addNode(tip_node);
hmm.addNode(root_node_lower);
hmm.addNode(t2_node);
hmm.addNode(kernel_node_end);
hmm.dn = [1 1];