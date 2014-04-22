classdef Frame < handle
%
% Frame is a class that conains data about objects from a single time point
%
% See also: Colony, Cell, TimeSeries

   properties
      t = 0;           % absolute time of frame
      objects  = [];   % segmented objects in image (e.g. array of Object, Cell, classes...)
      
      experiment = []; % reference to Experiment class
      %timeseries = []; % optional reference to the time series this frame belongs to
      file       = []; % image to load specified either by row vector of file tags or direct filename 
   end
   
   methods
      
      function obj = Frame(varargin)
         %
         % Frame()
         % Frame(frame)
         % Frame(...,fieldname, fieldvalue,...)
         %

         if nargin == 1 && isa(varargin{1}, 'Frame') %% copy constructor
            obj = copy(varargin{1});
         else
            for i = 1:2:nargin % constructor from arguments
               if ~ischar(varargin{i})
                  error('%s: invalid constructor input, expects char at position %g',class(obj), i);
               end
               if isprop(obj, lower(varargin{i}))
                  obj.(lower(varargin{i})) = varargin{i+1};
               else
                  warning('%s: unknown property name: %s ', class(obj), lower(varargin{i}))
               end
            end
         end
      end

      function newobj = copy(obj)
      % 
      % f = copy(obj)
      %
      % description:
      %    deep copy of the frame and its objects
      %
         nobjs = length(obj);
         newobj(nobjs) = Frame();
         for k = 1:nobjs
            newobj(k).t          = obj(k).t;
            newobj(k).objects    = obj(k).objects.copy;
            newobj(k).experiment = obj(k).experiment; % shallo copy
            newobj(k).file       = obj(k).file;
            %newobj(k).timeseries = obj(k).timeseries;
         end 
      end
      
      
      function d = dim(obj)
         %
         % d = dim()
         %
         % spatial dimension of object's position
         %
         d = obj(1).objects(1).dim;
      end

      function data = toArray(obj)
      %
      % data = toArray(obj)
      %
      % convert data of all objects to array
      %  
         data = obj.objects.toArray;
      end
           
      function t = time(obj)
      %
      % t = time(obj)
      %
      % output:
      %   t    time of the frame
      %
         if ~isempty(obj.t)
            t = obj.t;
         elseif length(obj) == 1
            t = obj.objects(1).time;
         else
            t = cellfun(@(x) x(1).time, {obj.objects});
         end
      end
      
      
      function xyz = r(obj)
      %
      % xyz = r(obj)
      %
      % output:
      %   xyz    coordinates of the objects in the image as column vectors
      %
         if length(obj) > 1 % for array of images
            xyz = cellfun(@(x) [ x.r ], { obj.objects }, 'UniformOutput', false);
         else               % single image
            xyz = [ obj.objects.r ];
         end   
      end

      function vol = volume(obj)
      %
      % vol = volume(obj)
      %
      % output:
      %   vol    volumes of the objects in the image
      %
         if length(obj) > 1 % for array of images
            vol = cellfun(@(x) [ x.volume ], { obj.objects }, 'UniformOutput', false);
         else               % single image
            vol = [ obj.objects.volume ];
         end   
      end
      
      function i = intensity(obj)
      %
      % i = intensity(obj)
      %
      % output:
      %   i    intensities of the objects in the image
      %
         if length(obj) > 1 % for array of images
            i = cellfun(@(x) [ x.intensity ], { obj.objects }, 'UniformOutput', false);
         else               % single image
            i = [ obj.objects.intensity ];
         end   
      end

      function t = type(obj)
      %
      % t = type(obj)
      %
      % output:
      % t    type data of the objects in the image as column vectors
      %
         if length(obj) > 1 % for array of images
            t = cellfun(@(x) [ x.type ], { obj.objects }, 'UniformOutput', false);
         else               % single image
            t = [ obj.objects.type ];
         end   
      end

      function i = id(obj)
      %
      % i = id(obj)
      %
      % output:
      %   i    coordinates of the objects in the image
      %
         if length(obj) > 1 % for array of images
            i = cellfun(@(x) [ x.id ], { obj.objects }, 'UniformOutput', false);
         else               % single image
            i = [ obj.objects.id ];
         end   
      end
      

      function obj = transformCoordinates(obj, R, T, C)
      %
      % obj = transformCoordinates(obj, R, T, C)
      %
      % applies rotation R, scaling C  and translation T to coordinates of objects r
      %  
         obj.objects = obj.objects.transformCoordinates(R,T,C);
         
      end
      
      
      function img = readImage(obj)
      %
      % img = readData()
      %
      % returns the image data of this frame
      %
         img = obj.experiment.readData(obj.file);    
      end


      % image
      function imglab = labeledImage(obj)
         imglab = obj.objects.labeledImage();
      end

   end
   
end
