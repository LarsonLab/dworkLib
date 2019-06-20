
function recon = csReconFISTA( samples, lambda, varargin )
  % recon = csReconFISTA2( samples, lambda [, 'polish', polish ] )
  % This routine minimizes 0.5 * || Ax - b ||_2^2 + lambda || W x ||_1
  %   where A is sampleMask * Fourier Transform * real part, and
  %   W is the Haar wavelet transform.
  %
  % Inputs:
  % samples - a 2D array that is zero wherever a sample wasn't acquired
  % lambda - regularization parameter
  %
  % Written by Nicholas Dwork - Copyright 2017
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular purpose.

  p = inputParser;
  p.addParameter( 'debug', false, @(x) isnumeric(x) || islogical(x) );
  p.addParameter( 'nIter', [], @ispositive );
  p.addParameter( 'polish', false, @(x) isnumeric(x) || islogical(x) );
  p.addParameter( 'printEvery', 1, @ispositive );
  p.addParameter( 'verbose', false, @(x) isnumeric(x) || islogical(x) );
  p.addParameter( 'waveletType', 'Haar', @(x) true );
  p.parse( varargin{:} );
  debug = p.Results.debug;
  nIter = p.Results.nIter;
  polish = p.Results.polish;
  printEvery = p.Results.printEvery;
  waveletType = p.Results.waveletType;
  verbose = p.Results.verbose;

  if numel( nIter ) == 0
    if debug == true
      nIter = 30;
    else
      nIter = 100;
    end
  end

  M = ( samples ~= 0 );
  nSamples = numel( samples );  % Note that A is square

  % A = M F Re , A' = Re * F' * M
  % A' * A = Re * F' * M * F * Re
  % gGrad = A'*A*x - A'*b;

  function out = F( x )
    Fx = 1/sqrt(nSamples) .* fftshift( fft2( x(:,:,1) + 1i * x(:,:,2) ) );
    out = cat( 3, real(Fx), imag(Fx) );
  end

  function out = Fadj( y )
    Fadjy = sqrt(nSamples) * ifft2( ifftshift( y(:,:,1) + 1i * y(:,:,2) ) );
    out = cat( 3, real(Fadjy), imag(Fadjy) );
  end

  M2 = cat( 3, M, M );

  function out = A( x )
    Fx = F( cat( 3, x, zeros(size(x)) ) );
    out = M2 .* Fx;
  end

  function out = Aadj( y )
    tmp = Fadj( M2 .* y );
    out = tmp(:,:,1);
  end

  %csReconFISTA_checkAdjoints( samples, @F, @Fadj, @A, @Aadj )

  b = cat( 3, real(samples), imag(samples) );
  function out = g( x )
    Ax = A( x );
    diff = Ax(:) - b(:);
    out = 0.5 * norm( diff, 2 ).^2;
  end

  Aadjb = Aadj(b);
  gGrad = @(x) Aadj( A(x) ) - Aadjb;

  split = zeros(4);  split(1,1) = 1;
  %split = [1 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0;];
  %split = [ 1 0; 0 0; ];

  if strcmp( waveletType, 'Deaubechies' )
    W = @(x) wtDeaubechies2( x, split );
    WT = @(y) iwtDeaubechies2( y, split );

  elseif strcmp( waveletType, 'Haar' )
    W = @(x) wtHaar2( x, split );
    WT = @(y) iwtHaar2( y, split );

  else
    error( 'Unrecognized wavelet type' );
  end

  proxth = @(x,t) WT( softThresh( W(x), t*lambda ) );
    % The proximal operator of || W x ||_1 was determined using
    % Vandenberghe's notes from EE 236C; slide 8-8 of "The proximal mapping"

  function out = h( x )
    Wx = W(x);
    out = sum( abs( Wx(:) ) );
  end

  x0 = real( ifft2( ifftshift( samples ) ) );
    % Could possibly make this better with inverse gridding

  t = 1;
  if debug
    %[recon,oValues] = fista( x0, @g, gGrad, proxth, 'h', @h, 'verbose', verbose );   %#ok<ASGLU>
    [recon,oValues] = fista_wLS( x0, @g, gGrad, proxth, 'h', @h, ...
      't0', t, 'N', nIter, 'verbose', true, 'printEvery', printEvery );                                                                     %#ok<ASGLU>
  else
    %recon = fista( x0, @g, gGrad, proxth );   %#ok<UNRCH>
    recon = fista_wLS( x0, @g, gGrad, proxth, 't0', t, 'N', nIter, ...
      'verbose', verbose, 'printEvery', printEvery );
  end

  if polish
    maskW = softThresh( W(recon), t*lambda ) ~= 0;
    proxth = @(x,t) WT( maskW .* W(x) );
    if debug
      [recon,oValues2] = fista_wLS( recon, @g, gGrad, proxth, 'h', @h, ...
        'N', nIter, 't0', t, 'verbose', verbose, 'printEvery', printEvery );   %#ok<ASGLU>
    else
      recon = fista_wLS( recon, @g, gGrad, proxth, 'h', @h, 'N', nIter, 't0', t, ...
        'verbose', verbose, 'printEvery', printEvery );
    end
  end
end


function csReconFISTA_checkAdjoints( samples, F, Fadj, A, Aadj )
  % Check to make sure that Fadj is the adjoint of F
  x1 = rand( [size(samples) 2] );
  y1 = rand( [size(samples) 2] );
  Fx = F(x1);
  Fadjy = Fadj(y1);
  Fxy = dotP( Fx, y1 );
  xFadjy = dotP( x1, Fadjy );
  if abs( Fxy - xFadjy ) > 1d-7
    error('FT is not the transpose of F');
  end

  % Test to make sure that Aadj is the adjoint of A
  x2 = rand( size(samples) );
  y2 = rand( [size(samples) 2] );
  Ax = A(x2);
  Aadjy = Aadj(y2);
  Axy = dotP( Ax, y2 );
  xAadjy = dotP( x2, Aadjy );
  if abs( Axy - xAadjy ) > 1d-7
    error('Aadj is not the adjoing of A');
  end
end

