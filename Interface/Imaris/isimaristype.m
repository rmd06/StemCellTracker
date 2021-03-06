function b = isimaristype(varargin)
%
% b = isimaristype(object, type)
%
% description:
%   checks if object is of a certain type
% 
% input:
%   object   any surpass scene object
%   type     one of:
%               'Cells'
%               'ClippingPlane'
%               'DataSet'
%               'Filaments'
%               'Frame'
%               'LightSource'
%               'MeasurementPoints'
%               'Spots'
%               'Surfaces'
%               'SurpassCamera'
%               'Volume'
% 
% output:
%   b           1 if the object is of the type specified, 0 otherwise
%
% See also: imariscast

[imaris, varargin, nargin] = imarisvarargin(varargin);

%imaris
%varargin

if nargin ~= 2
    error('isimaristype: 2 input parameters expected.');
end

type = imaristype(imaris, varargin{1});

b = strcmp(type, varargin{2});

end
