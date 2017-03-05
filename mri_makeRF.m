
function R = mri_makeRF( alpha, phi )
  % R = mri_makeRF( alpha, phi )
  % determine the tip-angle rotation matrix applied to (Mx,My,Mz)
  %
  % Inputs:
  % alpha - the tip angle in radians
  % phi - the phase of the RF pulse in radians
  %
  % Outputs:
  % the 3x3 rotation matrix
  %
  % Written by Nicholas Dwork - Copyright 2016
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  if nargin < 2, phi=0; end;

  calpha = cos(alpha);
  salpha = sin(alpha);
  cphi = cos(phi);  cphiSq = cphi*cphi;
  sphi = sin(phi);  sphiSq = sphi*sphi;

  R = [ ...
    cphiSq + sphiSq*calpha, cphi*sphi*(1-calpha), -sphi*salpha; ...
    cphi*sphi*(1-calpha), sphiSq+cphiSq*calpha, cphi*salpha; ...
    sphi*salpha, -salpha*cphi, calpha; ...
  ];

end
