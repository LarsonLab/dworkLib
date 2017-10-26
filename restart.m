
function restart( varargin )
  % restart
  % closes all windows, clears variables, and clears the command window
  %
  % Written by Nicholas Dwork - Copyright 2017
  %
  % This software is offered under the GNU General Public License 3.0.  It
  % is offered without any warranty expressed or implied, including the
  % implied warranties of merchantability or fitness for a particular
  % purpose.

  type = [];
  if nargin > 0, type = varargin{1}; end;

  if strcmp( type, 'all' ), clear all; end;

  close all;
  clear;
  clc;
end
