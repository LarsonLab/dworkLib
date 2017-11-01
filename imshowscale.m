
function imshowscale( img, scale, varargin )
  % imshowscale( img, scale [, method, 'range', range, 'border', border ] )
  % displays figure to the screen where size of image is scaled by scale
  %
  % Inputs:
  % img - 2D array representing the grayscale image or 3D array
  %       representing the color image (third dimension has size 3)
  %
  % Optional Inputs:
  % scale - factor to scale the size of the image for display
  % method - when scaling method, interpolation method to use
  %   default is 'nearest'
  %   any method accepted by imresize is accepted for this parameter
  % range - two element array specifying the display range of intensities
  %   If range is [], sets equal to [min(img(:)) max(img(:))]
  %     This is the default.
  %   If range is 'nice', uses imshownice to display image
  % border - border to put around the image in the figure window
  %   either 'noBorder' or a value in pixels  (default is 10)
  %
  % Written by Nicholas - Copyright 2016
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  defaultMethod = 'nearest';
  defaultRange = [];
  defaultBorder = 10;
  p = inputParser;
  p.addOptional( 'method', defaultMethod );
  p.addParameter( 'range', defaultRange );
  p.addParameter( 'border', defaultBorder );
  p.parse( varargin{:} );
  method = p.Results.method;
  range = p.Results.range;
  border = p.Results.border;

  if strcmp( 'nice', range )
    imshownice( img, scale, method );
  elseif range == 0
    if ismatrix( img )
      imshow( imresize( img, scale, method ), range );
    elseif ndims(img) == 3
      imshow( imColorResize( img, scale, method ), range );
    else
      error('wrong number of dimensions');
    end
  else
    if ismatrix( img )
      imshow( imresize( img, scale, method ), range );
    elseif ndims(img) == 3
      imshow( imColorResize( img, scale, method ), range );
    else
      error('wrong number of dimensions');
    end
  end
  
  if ischar( class(border) ) && strcmp(border,'none')
    displayBorder = 0;
  elseif border < 0
    error('border must be great than or equal to 0.');
  else
    displayBorder = border;
  end
  ca = gca;
  beforeAxesUnits = ca.Units;
  set(ca,'units','pixels');
  x = get(ca,'position');
  cf = gcf;
  beforeFigUnits = cf.Units;
  set(cf,'units','pixels');
  y = get(cf,'position');
  set(cf,'position',[y(1) y(2) x(3)+2*displayBorder x(4)+2*displayBorder] );
    % set the position of the figure to the length and width of the axes
  %set(ca,'units','normalized','position',[0 0 1 1]);
  set(ca,'position',[displayBorder displayBorder x(3) x(4)]);
  % Now restore units to previously used values
  set(ca,'units',beforeAxesUnits);
  set(cf,'units',beforeFigUnits);
end
