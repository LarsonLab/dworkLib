
function labelImgPts( pts, varargin )
  % labelImgFeatures( pts [, scale] )
  % This function puts the index of the point onto the image
  % It assumes that the image is already displayed and the figure
  %   is set to the current figure.
  % pts - an Nx2 array where the first column is the x location
  %   and the second column is the y location
  % scale (optional) - scales the points to display correctly on a scaled
  %   image.  Its default value is 1.
  %
  % Written by Nicholas Dwork (c) 2015

  defaultScale = 1.0;
  p = inputParser;
  p.addOptional('scale',defaultScale);
  p.parse( varargin{:} );
  scale = p.Results.scale;

  scaledPts = round( pts * scale );

  [nPts,~] = size(scaledPts);
  for i=1:nPts
    th = text( scaledPts(i,1), scaledPts(i,2), num2str(i), ...
      'FontSize', 30);
  end

end

