function implot3dsurface(xyz, tri, nrm)
%
% h = implot3dsurfaces(xyz, tri, nrm)
% h = implot3dsurfaces(labeledimage)
%
% description:
%    plots the surfaces obtained with imisosurface
%
% input:
%    xyz            coordinates for each object as cell array
%    tri            triangulation faces of surface as cell array
%    nrm            normals
%    labeledimage   surfaces are infered form the labeled image
%
% See also: imisosurface, isosurface, isonormals, patch


if nargin == 1
   isize = size(xyz);
   [xyz, tri, nrm] = imisosurface(xyz);
else
   isize = [];
end

if ~iscell(xyz)
   xyz = {xyz};
end
if ~iscell(tri)
   tri = {tri};
end

nlabel = length(xyz);
if nlabel ~= length(tri)
   error('implot3dsurface: inconsistent input sizes');
end

if nargin < 3
   nrm = cell(1,nlabel);
else
   if ~iscell(nrm)
      nrm = {nrm};
   end
   if nlabel ~= length(nrm)
      error('implot23surface: inconsistent input sizes');
   end   
end


hold on

cm = colormap;
ncm = length(cm);

for i = 1:nlabel
   
   fv.vertices = xyz{i}(:,[2 1 3
      ]);
   fv.faces = tri{i};
   col = cm(round((i-1)/nlabel * (ncm-1))+1, :); 
   if isempty(nrm{i})
      patch(fv, 'FaceColor', col ,'EdgeColor','none');
   else
      patch(fv, 'FaceColor', col ,'EdgeColor','none', 'VertexNormals', nrm{i}(:,[2 1 3]));
   end

end

daspect([1 1 1]); view(3); axis tight

if ~isempty(isize)
   xlim([0, isize(1)]); ylim([0, isize(2)]); zlim([0, isize(3)])
end

camlight

end



