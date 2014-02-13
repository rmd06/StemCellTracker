function repl = imreplace(image, subimage, coords)
%
% repl = imreplace(image, subimage, coords)
%
% description: 
%    replaces a subimage in image at coordinates coords
%
% input: 
%    image     original image
%    subimage  replacement sub image
%    coords    h,w,l lower left corner
%
% output:
%    repl      image in which subimage is replaced
%
% See also: imextract, imfind

isize = size(image);
ssize = size(subimage);

if length(coords) ~= ndims(image) || length(coords) ~= ndims(subimage)
   error('imreplace: inconsistent image dimensions!')
end

ssize + coords - 1

if any(ssize + coords - 1 > isize)
   error('imreplace: subimage to large!')
end

repl = image;
idx = arrayfun(@(i,j)(i:j), coords , coords + ssize-1, 'UniformOutput', false);
repl(idx{:}) = subimage;

end




