%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Test ImageSourceAligned Class %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% align
clc
ist.align('overlap.max')
%%% Test ImageSourceAligned Class %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%', 120,  'overlap.min', 80, 'shift.max', 30)

%% traditional alignment

imgs = reshape(tl, [4,4]);
imgs = cellfunc(@mat2gray, imgs);
shifts = alignImages(imgs, 'overlap.max', 120, 'overlap.min', 80, 'shift.max', 30);
figure(2); clf;
plotAlignedImages(imgs, shifts)

%% traditional pairwise alignment
clc
ip = ist.ialignment.ipairs

shifts = alignImages(imgs, 'pairs', ip, 'overlap.max', 120, 'overlap.min', 80, 'shift.max', 30);
var2char(shifts)
figure(2); clf;
plotAlignedImages(imgs, shifts)



%%

figure(3); clf;
ist.plotAlignedImages


%%

var2char(ist.imageShifts)

%% stiching

clc
ist.align('overlap.max', 120,  'overlap.min', 80, 'shift.max', 30)

img = ist.stitch('method', 'Mean');

figure(4)
implot(img);


%% get the full data
ist.clearCache()

%%
ist.icache = 1;
img = ist.data;


figure(4)
implot(img);


%%

sh= ist.imageShifts;
tiles= ist.tiles;

st = stitchImages(tiles(2:3), sh(2:3), 'method', 'Mean');
figure(1); clf
implot(st)






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ImageSourceTiled

clear all
clear classes
close all
clc

initialize
bfinitialize

texpr = tagexpr('./Test/Images/hESCells_Tiling/*.tif', 'tagnames', {'tile'});
is = ImageSourceTagged(texpr);
is.setTagRange('tile', {37,38,33,34});

ist = ImageSourceTiled(is, 'tileshape', [2,2], 'tileformat', 'uv');


%%
imgs = ist.tiles;
size(imgs)

figure(1); clf;
implottiling(imgs)


%%
tic
ist.align('overlap.max', 120,  'overlap.min', 80, 'shift.max', 20)
toc

%%
figure(1); clf
ist.plotAlignedImages


%%
st = ist.stitch('method', 'Hugin');

figure(2); clf
implot(st)

%% nice












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ImageSourceTiled

clear all
clear classes
close all
clc

initialize
bfinitialize

texpr = tagexpr('./Test/Images/hESCells_Tiling/*.tif', 'tagnames', {'tile'})
is = ImageSourceTagged(texpr);

ist = ImageSourceTiled(is, 'tileshape', [4,4], 'tileformat', 'uy');


%%

tl = ist.tiles;
size(tl)

figure(1); clf;
implottiling(tl)


%%

tic
ist.align('overlap.max', 120,  'overlap.min', 80, 'shift.max', 20)
toc

%%
figure(1); clf
ist.plotAlignedImages


%%

img = ist.stitch('method', 'Mean');

figure(2); clf
implot(img);



%%


imgr = imresize(img, 0.5);
size(imgr)

imgrf = gaussianFilter(imgr, 20);
imgro = imclose(imgrf, strel('disk', 20));



figure(4); clf;
implottiling(cellfunc(@mat2gray, {imgr; imgrf; imgro}));


%%

figure(1); clf
hist(mat2gray(imgro(:)), 256)

%%
imgm = mat2gray(imgro) > 0.1;
implottiling(cellfunc(@mat2gray, {imgr; imgrf; imgro; imgm}));


%%

[centers, radii, metric] = imfindcircles(imgro,  [200 400], 'Sensitivity', 0.97, 'Method', 'TwoStage')

figure(6); clf
%implot(imgro);

imshow(mat2gray(imgro))
viscircles(centers,radii);

[~, id] = max(metric);

id = metric > 0.15
viscircles(centers(id,:), radii(id), 'EdgeColor', 'b')


%% aryehs approach:
% find peaks method to detect possible nucelar positions  -> alpha vol to detec colony -> works well -> go for it now, need to do it anyway

% methods to find circles ???




imgd = mat2gray(imgr);

imgf = medianFilter(imgd, 5);
imgf = mat2gray(imgf);

imgp =imextendedmax(imgf, 0.01);


figure(11); clf; 
implottiling({255 * imgd; 255 * imgf; imoverlay(imgd, imgp)})


%%
[p,q] = find(imgp);

X= [p,q];

clf
 alphavol(X,20,1);


