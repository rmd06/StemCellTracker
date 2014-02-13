function surface = bwpixelsurface(bw)
%
% surface = bwpixelsurface(bw)
%
% description: 
%    returns pixel on the surface of the bw objects
%    this is pixel with city-block distance 1 from the exterior
%
% input:
%    bw       the bw image
%
% output:
%    surface  surface pixels fo the bw region
%
% See also: impixelsurface, imsurface

%surface = bwdist(~bw, 'chessboard') == 1;
surface = bwdist(~bw, 'cityblock') == 1;

% alternative
%surface = imfilter(double(bw), ker); % imfilter uses 0 for padding by default
%surface(surface <= conn -2) = 0;
%surface(surface > 0) = 1;

end