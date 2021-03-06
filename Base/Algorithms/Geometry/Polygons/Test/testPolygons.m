%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Test Polygon Package %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

initialize

%% Simple Shape
clc

n = 10;
pol= 3 * [sin(0:(2*pi/n) : (2*pi)); cos(0:(2*pi/n) : (2*pi))];

figure(1); clf
polygonPlot(pol)

%% Dilate / buffering
polb = polygonBuffer(pol, 2);

figure(1); clf; hold on
polygonPlot(polb, 'FaceColor', 'b');
polygonPlot(pol)

%% Simplyfying and Orienting Polygons consistent with Buffering 

pol = {[0,0; 1,0; 0,1]',0.2* [0,0; 0,1; -1,0]'+0.25, [-1,0; 0,0; 0,1]'};
[pols, tree] = polygonSimplify(pol)

figure(1); clf
polygonPlot(pols);

polb = polygonBuffer(pols, 0.04);

figure(2); clf;
polygonPlot(polb);



%% Dilate with hole

% orientation is important -> use polygonSimplify first for even odd 
n = 10;
pol= 3 * [sin(0:(2*pi/n) : (2*pi)); cos(0:(2*pi/n) : (2*pi))];
hol =  0.45 * pol + 1;
pol = {pol, hol};

pols = polygonSimplify(pol);

polb = polygonBuffer(pol, 0.5, 'simplify', false);
polsb = polygonBuffer(pols, 0.5);

figure(4); clf;
subplot(1,2,1);
polygonPlot(polb);
polygonPlot(pol, 'FaceColor', 'none', 'EdgeColor', 'b', 'LineWidth', 2 )
subplot(1,2,2);
polygonPlot(polsb)
polygonPlot(pols, 'FaceColor', 'none', 'EdgeColor', 'b', 'LineWidth', 2 )


%% Execute Operations

n = 10;
pol= 3 * [sin(0:(2*pi/n) : (2*pi)); cos(0:(2*pi/n) : (2*pi))];
pol2 = 0.5 * pol;

pole = polygonExecute(pol, pol2, 'operator', 'Difference')

figure(4); clf;
%patch('Faces', tri.ConnectivityList, 'Vertices', tri.Points, 'FaceColor', 'r', 'EdgeColor', 'r' )
polygonPlot(pole, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'LineWidth', 2 )
polygonPlot(pol, 'FaceColor', 'none', 'EdgeColor', 'b', 'LineWidth', 2 )
polygonPlot(pol2, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 2 )


%% Difference
clc; close all

pol =5* [-1, -1; 1, -1; 0, 1; -1,1]';
polin = 2/5* pol(:,end:-1:1);
polin2 = 1/5 * pol;
polin3 = [-3,-3; -2,-3; -2,-2; -3,-2]' ;
polfull = {pol, polin, polin2, polin3};

figure(1); clf;
polygonPlot(polfull)

polb = polygonDifference(polfull, {[-6, -6; 1, -6; 1, 6]'});

figure(2); clf
polygonPlot(polb)



%% Intersection
clc
pol =5* [-1, -1; 1, -1; 0, 1; -1,1]';
polin = 2/5* pol(:,end:-1:1);
polin2 = 1/5 * pol;
polin3 = [-3,-3; -2,-3; -2,-2; -3,-2]' ;
polfull = {pol, polin, polin2, polin3};

figure(1); clf;
polygonPlot(polfull)

polb = polygonIntersection(polfull, {[-6, -6; 1, -6; 1, 6]'});

figure(2); clf
polygonPlot(polb)


%% Polygon To Bounding Box

bb = polygonToBoundingBox(pol)

figure(7); clf; hold on
polygonPlot(pol)
polygonPlot(bb, 'FaceColor', 'none', 'EdgeColor', 'b')


%% Polygon to Triangulation

clc
tri = polygonToTriangulation(pol)

figure(2); clf; hold on
fill(pol(1,:)',pol(2,:)','r')
triplot(tri);

%% 
clc

hol =  0.3 * pol + 1;
hol2 =  0.3 * pol -1;
pol2 = 0.1 * pol + 1;


tri = polygonToTriangulation({pol, hol, hol2, pol2}, 'all', false);

figure(3); clf; hold on
fill(pol(1,:)',pol(2,:)','r');
fill(hol(1,:)',hol(2,:)','w'); fill(hol2(1,:)', hol2(2,:)', 'w');
fill(pol2(1,:)', pol2(2,:)', 'r'); 
triplot(tri);

figure(4); clf;
%patch('Faces', tri.ConnectivityList, 'Vertices', tri.Points, 'FaceColor', 'r', 'EdgeColor', 'r' )
polygonPlot({pol, hol, hol2, pol2}, 'FaceColor', 'b', 'EdgeColor', 'r', 'LineWidth', 2 )


%% Triangulation To Polygon

polt = polygonFromTriangulation(tri)

figure(5); clf;
polygonPlot(polt, 'FaceColor', 'none', 'EdgeColor', 'k')

%% Polygon Tree

pol =5* [-1, -1; 1, -1; 0, 1; -1,1]';
polin = 2/5* pol(:,end:-1:1);
polin2 = 1/5 * pol;
polin3 = [-3,-3; -2,-3; -2,-2; -3,-2]' -1 ;
polin3 = polin3(:,end:-1:1);
pol4 = [-3,-3; -2,-3; -2,-2; -3,-2]' +6;
polfull = {pol, polin, polin2, polin3, pol4};

[pol, tree] = polygonSimplify(pol)
[polt, tree] = polygonSimplify(polfull)

figure(1); clf;
polygonPlot(pol)

figure(2); clf
polygonPlot(polt)

%% Split Polygons

[ps, ts] = polygonSplit(polfull, 'full', false)

figure(1); clf
col = colorcube(length(ps)+1);
for i = 1:length(ps)
   polygonPlot(ps{i}, 'FaceColor', col(i,:));
end

[ps, ts] = polygonSplit(polfull)

figure(2); clf
col = colorcube(length(ps)+1);
for i = 1:length(ps)
   polygonPlot(ps{i}, 'FaceColor', col(i,:));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Polygon From Image

close all
clc

imglab = syntheticLabeledImage([100,100], 5, 10);


%% check bwboundaries
% imglab(20:50, 60:90) = 1;
% imglab(30:40, 70:80) = 0;
% imglab(33:37, 73:77) = 1;
imglab = zeros(24,14);
imglab(10:20, 5) = 2;
imglab(3:20, 8) = 2;
imglab(5:10, 8:13) = 2;
imglab(6:8, 10) = 0;

figure(3); clf
implot(imglab)

[B, L, N, A] =bwboundaries(imglab)

figure(5); clf
implot(L)

%% Clipper Bug on Buffering single horizontal line on the left
clc
i = 1;

[B, L, N, A] =bwboundaries(imglab == 2);

figure(6); clf
implot(imglab == i)

total(imglab==i)
length(B)

figure(9); clf
imgl = zeros(size(imglab));
for k = 1:length(B)
   imgl(sub2ind(size(imglab), B{k}(:,1), B{k}(:,2))) = k;
end
implot(imgl)

%implot(imglab)

polygonPlot(cellfunc(@(x) x', B)', 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 2)

polb = polygonBuffer(B{2}', 0.5, 'simplify', false, 'end', 2);

polygonPlot(polb{1}, 'FaceColor', 'none', 'EdgeColor', 'b', 'LineWidth', 2)

bb = B{3}';
bb = bb(:,[3:length(bb), 1:2]);
polb = polygonBuffer(bb, 0.50, 'simplify', false, 'join', 'Square', 'end', 2);
%polb = polygonBuffer(polb, -0.25, 'simplify', false);

polygonPlot(polb{1}, 'FaceColor', 'none', 'EdgeColor', 'g', 'LineWidth', 2)

%% bwboundaries on each label

[b,tree] = imlabelbwboundary(imglab)
b{2}
tree{2}

%% Polygon From Labeled Image
clc
[pol, ids, tree] = polygonFromLabeledImage(imglab)

figure(10); clf; hold on
implot(imglab)
col = colorcube(length(pol)+1);
for i = 1:length(pol)
   polygonPlot(pol{i}, 'FaceColor', 'none', 'EdgeColor', col(i,:), 'LineWidth', 3)
end

%%  with splitting
clc
[pol, ids, tree] = polygonFromLabeledImage(imglab, 'split', true)

figure(10); clf; hold on
implot(imglab)
col = colorcube(length(pol)+1);
for i = 1:length(pol)
   polygonPlot(pol{i}, 'FaceColor', 'none', 'EdgeColor', col(i,:), 'LineWidth', 3)
end

%% single pixel / pixel on boundary

img = zeros(10);
%img(3:5, 4) = 1;
%img(4:7, 7) = 2;
img(4,4) = 1;
img(10,10) = 2;

pol = polygonFromLabeledImage(img)
pol{1}{1}

figure(6); clf; hold on
implot(img)
polygonPlot(pol{1}, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 2)
polygonPlot(pol{2}, 'FaceColor', 'none', 'EdgeColor', 'g', 'LineWidth', 2)


%% Polygon From Mask

clc
pol = polygonFromMask(imglab > 0);

figure(10); clf
polygonPlot(pol)


%% Ploygon To Mask

pol = polygonFromMask(imglab);

img = poly2mask(pol{1}(2,:)' -0.5, pol{1}(1,:)' -0.5, size(imglab,1), size(imglab,2));

figure(2); clf; hold on
implot(imglab + img);
polygonPlot(pol, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 2)

%%

pol = polygonFromMask(imglab);

img = polygonToMask(pol, 'size', size(imglab));

figure(2); clf; hold on
implot(img);
polygonPlot(pol, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 2)


%% Polygons To Labeled Image

pol = polygonFromLabeledImage(imglab, 'split', true);

figure(5); clf;
col = colorcube(length(pol)+1);
for i = 1:length(pol)
   polygonPlot(pol{i},'FaceColor', 'none', 'EdgeColor', col(i,:), 'LineWidth', 2);
end

%%

imgt = polygonToLabeledImage(pol, 'size', size(imglab));

figure(6); clf;
implot(imgt)



%% Test bwbountaries tree matix


imglab = zeros(30,30);
imglab(5:25, 5:25) = 1;
imglab(10:20, 10:20) = 0;
imglab(13:17, 13:17) = 1;

figure(8); clf;
implot(imglab)

[b, ~, ~, t] = bwboundaries(imglab)


[pol, ids, tree] = polygonFromLabeledImage(imglab)

pol{1}
tree{1}
