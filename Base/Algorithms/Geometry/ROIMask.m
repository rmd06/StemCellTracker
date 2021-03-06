classdef ROIMask < ROI
   %
   % I binary mask defining the roi
   %
   
   properties
      mask = [];
   end
   
   methods
      function obj = ROIMask(varargin)  % basic constructor
      %
      % Rectangle()
      % Rectangle(center, radii)
      %
         if nargin > 0
            obj.mask = varargin{1};
         end
      end

      function d = dim(obj)
         d = ndims(obj.mask);
      end

      function v = volume(obj)
         v = total(obj.mask);
      end

      function b = boundingBox(obj, varargin)
         [p1, p2] = imboundingBox(obj.mask);
         b = ROIRectangle(p1, p2);
      end

      function p = pixelIdxList(obj)
         p = find(obj.mask);
      end
            
      function n = nPixel(obj)
         n = obj.volume;
      end
      
      function o = overlap(obj, roi) %#ok<STOUT>
         error('%s: overlap with % s not implemented!', class(obj), class(roi));
      end
      

      function ps = pixelSurfaceIdxList(obj)
         ps= impixelsurface(obj.mask);
         ps = find(ps);
      end
      

      function d = extractdDta(obj, d)
         d = immask(d, obj.mask);
      end
      
      function shift(obj, ~)
         error('%s: shift not implemented yet!', class(obj));
      end
       
   end
      
      
  
end
