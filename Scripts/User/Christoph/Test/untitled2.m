
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Segmentation of a Tiled Colony %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean Start

clear all %#ok<CLSCR>
clear classes %#ok<CLSCR>
close all
clc

initialize
bfinitialize

initializeParallelProcessing(4) % number of processors


%% Plotting

verbose = true;     % switch to turn on figure generation
figure_offset = 0;  % offset for figure numbering / use to compare results etc..


%% Load Images and Stitch 
%
%  result: img the image to analyze

% autodetect the tag expression for the images:
tagexp = tagExpression('/home/ckirst/Desktop/fred/2.tif_Files/*.tif', 'tagnames', {'S','C'})

%%
% generate image source for tagged images
clc
is = ImageSourceFiles(tagexp);

%is.setDataFormat('XY');
is.setReshape('S', 'UV', [42,56]);
is.setCellFormat('Uv');
is.setCaching(true);

is.setRange('U', 1:5, 'V', 1:5);

is.printInfo

%% Preview 

if verbose
   figure(1); clf
   is.plotPreviewStiched('overlap', 120, 'scale', 0.05, 'lines', false);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Alignment

% create 
clc
algn = Alignment(is, 'UV');
algn.printInfo


%% Background Intensity for Overlap Quality of Tiles

img1 = algn.sourceData(2);
nbins = 350;
th = thresholdFirstMin(img1, 'nbins', nbins, 'delta', 1/10000 * numel(img1))

if verbose
   figure(3); clf
   hist(img1(:), nbins)
end

%% Quality of Overlap between neighbouring Tiles 

% parameter: see overlapQuality
algn.calculateOverlapQuality('threshold.max', th, 'overlap.max', 120);

hist(algn.overlapQuality, 256)


%% Align components
clc
clear subalgn
subalgn = algn.connectedComponents('threshold.quality', -eps);
nsubalgn = length(subalgn);
fprintf('Alignment: found %g connected components\n', nsubalgn);

if verbose  
   var2char({subalgn.anodes})
end


%%
for s = 1:nsubalgn
   fprintf('\n\nAligning component: %g / %g\n', s, nsubalgn)
   subalgn(s).align('alignment', 'Correlation', 'overlap.max', 100, 'overlap.min', 4, 'shift.max', 140);
   if verbose && s < 20 %%&& subalgn(s).nNodes < 75
      subalgn(s).printInfo 
      figure(100+s); clf
      
      subalgn(s).plotPreviewStiched('scale', 0.05)
   end
end

%% Align Components
clc
subalgn.alignPositions;

% merge to single alignment

algnAll = subalgn.merge;
algnAll.printInfo

%%
if verbose
   figure(5); clf
   algnAll.plotPreviewStiched
end



%% Colony Detection 

% detect by resampling and closing
scale = algnAll.source.previewScale;
roi = detectROIsByClosing(algnAll, 'scale', scale, 'threshold', 1.5 * th, 'strel', 1, 'radius', 50, 'dilate', 100, 'check', true)


%% Colony 

colonies = Colony(algnAll, roi);
ncolonies = length(colonies);

figure(1); clf
colonies.plotPreview


%% Visualize

if verbose
   figure(10); clf
   for c = 1:min(ncolonies, 20)
      figure(10);
      img = colonies(c).data;
      imsubplot(5,4,c)
      if numel(img) > 0
         implot(img)
      end
   end
end


%% Save

colony = colonies(3);

% make sure to clear cache before saving
colony.clearCache();
save('./Test/Data/Colonies/colony.mat', 'colony')


%%

load('./Test/Data/Colonies/colony.mat', 'colony')



%% Cut to ROI 

img = colony.data;

if verbose
   figure(4+figure_offset); clf;
   implot(img)
end

imgraw = mat2gray(double(img));

%% Preprocessing 1 (optional)
%
% result: imgpre  image of intensity values in [0,1]
%
% note: this step strongly depends on the image quality / distractors etc
%       try to remove as much noise as possible while preserving edges

imgpre = imgraw;
background = [];

% remove strong intensity variations (possibly iterate) 
for i = 1:1
   imgpre = log(imgpre+eps);
   imgpre(imgpre < -10) = 0;
   imgpre = mat2gray(imgpre);
end

% reduce range
%imgpre = imclip(imgpre, 0.1, 0.9);
%imgpre = mat2gray(imgpre);

% sharpen
%imgpre = imsharpen(imgpre, 'Radius', 4, 'Amount', 0.8, 'Threshold', 0);
%imgpre = imclip(imgpre,0,1);

% histrogram equalization
%imgpre = histeq(imgpre, 512);

% remove trend in illumination via morphological opening
%background = imopen(imgraw,strel('disk',60));
%imgpre = imgpre - background;
%imgpre = imclip(imgpre,0);

% morphologival operations
%imgpre = imopen(imgpre, strel('disk', 5));

if verbose 
   figure(5 + figure_offset); clf; colormap jet
   set(gcf, 'Name', ['Preprocess 1']);
   
   if ~isempty(background)
      implottiling({imgraw; background; imgpre}, {'imgraw', 'background', 'imgpre'}) 
   else
      implottiling({imgraw; imgpre}, {'imgraw','imgpre'}) 
   end
end

%% Preprocessing 2 (option)
% result: imgpre2    image of intensity values in [0,1]
%
% note: this step strongly depends on the image quality / distractors etc
%       try to remove as much noise as possible while preserving edges

imgpre2 = imgpre;

% appy addiitonal filters 
% gaussian filter
%param.ksize = [5, 5];    % size of the filter kernel (q x p box)
%param.sigma = []         % std of gaussian [] = param.filter.ksize / 2 / sqrt(2 * log(2)); 
%imgpre2 = filterGaussian(imgpre2, param.ksize, param.sigma);

% mean shift filter - edge preserving 
%param.ksize = [3 3];              % size of the filter kernel (q x p box)
%param.intensity_width = 0.1;  % max deviaiton of intensity values to include in mean
%param.iterations = 1;         % number of iterating the filtering 
%imgpre2 = filterMeanShift(imgpre2, param.ksize, param.intensity_width, param.iterations);

% median filter - edge preserving
%ksize = [3, 3];               % size of the filter kernel (q x p box) 
%imgpre2 = filterMedian(imgpre2, ksize);

% bilateral filter - edge preserving
%param.ksize = 3;              % size of the filter kernel (h x w box) 
%param.sigma_space = [];       % std of gaussian in space  [] = param.filter.ksize / 2 / sqrt(2 * log(2));
%param.sigma_intensity = [];   % std fo gaussian in intensity [] = 1.1 * std(img(:));
%imgpre2 = filterBilateral(imgpre2, param.ksize, param.sigma_space, param.sigma_intensity);

% function filter
%param.ksize = [5, 5];                    % size of the filter kernel (h x w box) 
%param.function = @(x)(max(x,[],2)); ;    % function acting on array that for each pixel (1st dim) contains its neighbourhood in 2nd dim
%                                         % should return a vector of the new pixel values
%imgpre2 = filterFunction(imgpre2, param.filter.ksize, param.filter.function);

% thresholding and clipping
imgpre2 = imclip(mat2gray(imgpre2), 0.6, 0.9);
imgpre2 = mat2gray(imgpre2);

% gradient
imggrad = mat2gray(imgradient(imgpre));
imggrad = mat2gray(imclip(imggrad, 0.1, 0.6));
imgpre2 = imgpre2 - imggrad;
imgpre2(imgpre2 < 0) = 0;


% others: see ./Filtering folder or type filter


if verbose
   figure(6 + figure_offset)
   set(gcf, 'Name', ['Preprocess:']);
   implottiling({imgraw; imgpre2; imggrad},{'imgraw', 'imgpre2'});
end


%% Thresholding / Masking
%
% result: - imgmask    binary mask that specifies region of interest, get mask correct here
%         - imgth      thresholded image with removed background
%
% note: see thresholding.m script for more info

% determine threshold using the histogram on logarithmic intensities

imgvalslog = log2(img(:)+eps);
imgvalslog(imgvalslog < -15) = -15; % bound lower values
imgvalslog(imgvalslog > 0) = 0;     % bound upper values

param.threshold.MoG = 0.5;          % probability of a pixel belonging to foreground
                                    % decrease to decrease the fitted threshold                        
%thlog = 2^thresholdMixtureOfGaussians(imgvalslog, param.threshold.MoG);  % this usually takes long


% direct thresholding methods (with optional prefiltering)

%param.ksize = 3;
%imgf = filterMedian(img, param.ksize);
imgf = img;

thotsu = thresholdOtsu(imgf);
thentropy = thresholdEntropy(imgf);
thmentropy = thresholdMutualEntropy(imgf);
thmog = thresholdMixtureOfGaussians(imgf, 0.5);


% thresholding using local maxima statistics

imgvalsmax = img(imregionalmax(img));
%imgvalsmax = img(imextendedmax(img, 0.01));
imgvalslogmax = log2(imgvalsmax);
param.threshold.MoG = 0.5;   
thmax = 2^thresholdMixtureOfGaussians(imgvalslogmax, param.threshold.MoG);

% select a threshold and create mask and thresholded image
th = thmax;

imgth = img;
imgth(imgth < th) = 0;
imgmask = imgth > 0;

% remove small fragments and small isolated minima with imopen
imgmask = imopen(imgmask, strel('disk', 4));    % larger disk size removes larger fragments
% close
%imgmask = imclose(imgmask, strel('disk', 2));  % larger disksize closes more
% dilate
%imgmask = imdilate(imgmask, strel('disk', 2)); % increase mask region 
% erode
%imgmask = imerode(imgmask, strel('disk', 2));  % decreasde mask region
% fill holes
%imgmask = imfill(imgmask,'holes');


if verbose

   prt = '\n\nthresholds:\n===========\n';
   thnames = {'thlog', 'thmog', 'thotsu', 'thentropy', 'thmentropy', 'thmax'};
   thdescription = {'MoG on log(img) = %7.5f', 'MoG(img)        = %7.5f', 'Otsu(img)       = %7.5f',... 
                    'Entropy on hist = %7.5f', 'Mutual entropy  = %7.5f', 'MoG on local max= %7.5f'};
   for t = 1:length(thnames)
      if exist(thnames{t}, 'var')
         prt = [prt '\n' sprintf(thdescription{t}, eval(thnames{t}))]; %#ok<AGROW>
       end
   end
   prt = [prt '\n-------------------------\n'];
   prt = [prt sprintf('threshold       = %7.5f', th)];
   fprintf([prt '\n']);


   figure(10 + figure_offset)
   set(gcf, 'Name', ['Thresholding: ' is.ifilename])
   implottiling({imgth; imoverlay(img, imgmask)});
   
   figure(11 + figure_offset)
   set(gcf, 'Name', ['Thresholding Histograms: ' is.ifilename])   
   
   subplot(2,4,1);
   hist(imgraw(:), 256);
   title('raw intensities')
   subplot(2,4,5);
   plot(sort(imgraw(:))) % x-axis is effectively number of pixels <= ordinate in following plots
      
   if exist('imgvalslog', 'var')
      subplot(2,4,2);
      hist(imgvalslog, 256);
      title('log intensities');
      subplot(2,4,6);
      plot(sort(imgvalslog(:)))
   end
   if exist('imgvalsmax', 'var')
      subplot(2,4,3);
      hist(imgvalsmax, 256);
      title('local max intensities');
      subplot(2,4,7);
      plot(sort(imgvalsmax(:)))
   end
   if exist('imgvalslogmax', 'var')
      subplot(2,4,4);
      hist(imgvalslogmax, 256);
      title('local log max intensities');
      subplot(2,4,8);
      plot(sort(imgvalslogmax(:)))
   end
   
end   



%% Seeding
%
% result: - imgmax     binary image indicating seeds for segmentation
%
% note: Ideally have one seed per nucleus

%%% optional pre filtering, alternatively use imgpre, imgpre2

%imgf = imgraw;

% gaussian smoothing
%imgf = filterGaussian(imgf,3,10);

% median filter / if note cumpted above or different parameter set
%imgf = filterMedian(imgf, 3);

% mean shift 
%imgf = filterMeanShift(imgf, 3, 0.1);

imgf = imgpre2;

%%% center enhancing filter to detect seeds

% Laplacian of Gaussians (LoG) - more robust / use on inverse image !
%param.ksize = [15, 15];       % size of the filter = diameter of nuclei
%param.sigma = [];           % std of gaussian ([] = ksize / 4 / sqrt(2 * log(2)))
%imgf = filterLoG(max(imgf(:)) - imgf, param.ksize, param.filter.sigma);

% disk filter (consists of inner disk and optional outer ring to enhanve edges
%param.ksize = 12;            % size of filer h or [h, w]
%param.ring_width = 2;        % width fo ring (disk radius is determined by outer radius - ringh_width)
%param.disk_weight = 1;       % weight on inner disk
%param.ring_weight = -1;      % weight on outer ring
%imgf = filterDisk(imgf, param.ksize, param.ring_width, param.disk_weight, param.ring_weight);

% Difference of Gaussians (DoG) - similar to LoG but less robust
%param.ksize = [15, 15];      % size of the filter
%param.sigma_in = [];         % std of inner Gaussian ([] = 1/1.5 * sigma_out)
%param.sigma_out = [];        % std of outer negative Gaussian ([] = ksize / 2 / sqrt(2 log(2)) )
%imgf = filterDoG(imgf, param.ksize,  param.sigma_in,  param.sigma_out);

% sphere filter
param.ksize = 10 * [1, 1];
ker = fspecial2('sphere', param.ksize);
%ker = fspecial2('disk',  param.ksize, 1, 1, -.2);
imgf = filterLinear(imgf, ker);


% normalize
imgf = mat2gray(imgf);

%%% Maxima detection

% h-max detection (only local maxima with height > hmax are considered as maxima
param.hmax = 0.001;  %0.02;
imgmax = imextendedmax(mat2gray(imgf), param.hmax);

%local max
%imgmax = imregionalmax(imgf);

% constrain to maxima within mask
imgmax = immask(imgmax, imgmask);

% Combine nearby points
imgmax = imdilate(imgmax, strel('disk', 2));
% fill holes - combination of nearby points can lead to holes
imgmax = imfill(imgmax,'holes');
% shrink to single points - extended maxima usually give better segmentation results
% imgmax = bwmorph(imgmax,'shrink',inf);           

% plot the results.
if verbose  
   figure(20 + figure_offset)
   set(gcf, 'Name', ['Seeding: ' is.ifilename])
   implottiling({imoverlay(imgraw, imgmax); imoverlay(imgpre2, imgmax); imoverlay(imgf, imgmax)});
end

%% Postprocess Seeds by Joining (optional)
%
% result: - imgjoin     binary image indicating seeds for segmentation
%
% note: Ideally have one seed per nucleus

imgf = imgth;

imglab = bwlabeln(imgmax);

imggrd = mat2gray(imgradient(imgf));

param = setParameter('threshold.min',        0.05, ...  % if profile comes below this absolute intensity objects are different
                     'threshold.max',        inf,...    % if profile is always above this threshold, objects are joined
                     'threshold.change'    , 1, ...     % maximal rel change in intensitiy above objects are assumed to be different
                     'threshold.gradient'  , 1, ...     % maximal absolute gradient change above objects are assumed to be different, only if gradient image is supplied
                     'cutoff.distance'     , 20, ...    % maximal distance between labels (= 20)
                     'averaging.ksize'     , 2, ...     % ksize to calculate reference mean intensity (=3)
                     'addline'             , true);     % add a line between joined label (true)

%[imgjoin, pairs, joins] = joinSeedsByRays(imglab, imgf, param);
[imgjoin, pairs, joins] = joinSeedsByRays(imglab, imgf,  imggrd, param);


if verbose 
   figure(30 + figure_offset); clf
   
   ax(1) = imsubplot(2,1,1);
   implot(imoverlay(imgf, imglab));
   plotSeedPairs(imglab, pairs);
   plotSeedPairs(imglab, joins, 'g');

   ax(2) =imsubplot(2,1,2);
   %figure(13)
   colormap jet
   %implot(imcolorize(imgjoin))
   implot(imoverlaylabel(imgf, imgjoin, true));
   
   linkaxes(ax, 'xy');
end



%% Segmentation by WaterShed
%
% result: - imgseg     segmented image, all pixels of a single segment have a unique number
%
% note: Ideally the segments should cover and separate the visible nuclei

% optional fitlering if alternative use of  imgpre, imgpre2 fails

%imgf = filterMedian(img,3);
%dilating the maxima can improve segmentation

imgmaxws = imdilate(imgjoin, strel('disk', 0));
%imgmaxws = imgmax;

imgf = imgpre;

% watershed
imgmin = imimposemin(max(imgf(:)) - imgf, imgmaxws);
imgws = watershed(imgmin);
imgseg = immask(imgws, imgmask);

% watershed on image + gradient
imgmaxws = imdilate(imgjoin, strel('disk', 0));
imggrad = mat2gray(imgradient(imgpre2));
imgf = imgf - 0.5 * imggrad;
imgf(imgf <0) = 0;
imgf = mat2gray(imgf);

rm = imimposemin(max(imgf(:)) - imgf, imgmaxws);
ws = watershed(rm);
imgsegg = immask(ws , imgmask);


figure(20)
implottiling({imcolorize(imgseg), imcolorize(imgsegg); imoverlaylabel(img, imgseg), imoverlaylabel(img, imgsegg)}, {'watershed on image', 'watershed image gradient'; 'overlay', 'overlay'});


%%
figure(21)
implottiling({imoverlaylabel(mat2gray(img), imgseg, false); imoverlaylabel(img, imgseg, true)}, {'watershed', 'watershed on img overlaid on img'})



%% Watershed Segmentation on Image + Gradient 
%
% result: - imgseg     segmented image, all pixels of a single segment have a unique number
%
% note: a different approach to the above matlab cell

% optional fitlering if alternative use of  imgpre, imgpre2 fails


%imgf = img;

if false
   
imgf = filterMedian(img,3);

imgfgrad = imgradient(img);
mi = max(imgf(:));
mg = max(imgfgrad(:));
imgmix = imsubtract(imgf, 1.0 * (mi/mg) * imgfgrad);

imgmin = imimposemin(max(imgmix(:)) - imgmix, imdilate(imgmax, strel('disk',0)));
imgmin(imgmin < 0) = 0;
imgws = watershed(imgmin);
imgseg = double(imgws) .* double(imgmask);

figure(30); clf
implottiling({imoverlay(imgf, imgmax), imgfgrad;
              imgmix, mat2gray(imgmin); imcolorize(imgws), imoverlaylabel(img, imgws)})
           
end



%% Segmentation by Propagation
%
% result: - imgseg     segmented image, all pixels of a single segment have a unique number
%
% note: a different approach to the above matlab cell


% mixture of image / gradient can improve result
%imgmedgrad = imgradient(imgmed);
%mi = max(imgmed(:));
%mg = max(imgmedgrad(:));
%imgprop = imadd(imgmed, 5.0 * mi / mg * imgmedgrad);

if false

imgprop = imgf;

imgmaxlabel = bwlabel(imgmax);

param.propagation.lambda = 0.2; % weight between pixel intensity (lambda = 0) changes and spatial distance (lambda = 1)
param.propagation.ksize = 1;    % box width for calculating intensity differences
param.propagation.cutoff.distance = Inf;

[imgproplabel, dist] = segmentByPropagation(imgprop, imgmaxlabel, imgmask, param.propagation.lambda, param.propagation.ksize);
imgproplabel(dist>param.propagation.cutoff.distance) = 0;



figure(40)
ax(1) = imsubplot(3,1,1);
imshow(imoverlay(imgprop, imgmax))
ax(2) = imsubplot(3,1,2);
%imshow(imcolorize(imgproplabel))
imshow(double(imcolorize(imgproplabel)) .* gray2rgb(img))

distinf0 = dist;
distinf0(dist==Inf) = 0;
ax(3) = imsubplot(3,1,3);
%imshow(imgmask)
imshow(mat2gray(distinf0))

% trick to make all axes scale together.
linkaxes(ax, 'xy')

%figure(41)
%imshow([imgmedgrad, imgprop])

end


%% Postprocess Segmentation and alternative diagnositcs
%
% result: - imgpost  cleaned up segmentation removing small areas etc..
%         - stats    some statistics calculated on the way
%
% note: if this step is ignored stats can be an empty struct

param = setParameter('volume.min',    50,...     % minimal volume to keep (0)
                     'volume.max',    inf,...    % maximal volume to keep (Inf)
                     'intensity.min', -inf, ...  % minimal mean intensity to keep (-Inf)
                     'intensity.max', inf, ...   % maximal mean intensity to keep (Inf)
                     'boundaries',    false, ... % clear objects on x,y boundaries (false)
                     'fillholes',     true,...   % fill holes in each z slice after processing segments (true)
                     'relabel',       true);    % relabel from 1:nlabelnew (true)

[imgpost, stats] = postProcessSegments(imgseg, param);

if verbose
   
   figure(41 + figure_offset)
   colormap jet
   implottiling({imcolorize(imgpost); imoverlaylabel(img, imgpost, true)})
end



%% Create Objects and Frame form Labeled Image

param = setParameter('time' ,  0, ...   % time for objects (0)
                     'rescale',1, ...   % rescale coordinates r by this factor ([1, 1(, 1)])
                     'method', 'none'); % how to calcualte the intensity in Object, a string of any function, 'none' = dont calcualte ('median')

objs = label2DataObjects(imgpost, img, stats, param);

frame = Frame('objects', objs, 't', 0);



%% Measure  

stats = imstatistics(imgpost,  stats, {'Centroid', 'SurfacePixelIdxList', 'MedianIntensity'}, img)


%% Add to Data Objects

objs.setChannelData('dapi', [stats.('MedianIntensity')])
objs.dataFields

%%

if verbose
   figure(42 + figure_offset); clf
   set(gcf, 'Name', ['DAPI: ' is.ifilename])
   hist([objs.dapi])
   title('DAPI')
end



