function [s, hdr] = anread(filestub)
% Read a 3D ANALYZE 7.5 dataset
%
% [s, hdr] = anread(filestub)
%
% The header structure contains the following elements:
% .dim   = dimension vector for s (eg [256 256 128])
% .vsize = voxel size vector for s (eg [0.5 0.5 0.2])
% .cal   = calibrated intensity range of s (eg [max min] = [1 0])
% .vox   = voxel intensity range of s (eg [max min] = [255 0]);
% .datatype = ANALYZE datatype enum (eg 4 = int16)
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : City of Hope, Duarte CA
% DATES : 01/24/2001 JMT From scratch (see Mayo Clinic ANALYZE format page)
%         10/04/2004 JMT Add trap for zero voxel limits
%         01/23/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of AnUtils.
%
% AnUtils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% AnUtils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with AnUtils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

fname = 'anread';

% Defaults
s = [];
hdr = [];

if nargin < 1
  fprintf('USAGE: [s, hdr] = anread(filestub)\n');
  return
end

% Read the ANALYZE header
[hdr, status] = anreadhdr(filestub);

if status < 0
  fprintf('%s: Problem loading header\n', fname);
  return
end

% Create appropriate filenames
anaimgfile = [filestub '.img'];

% Load image data
fd = fopen(anaimgfile, 'r', hdr.endian);
if fd < 0
  fprintf('%s: Could not open %s to read\n', fname, anaimgfile);
  return;
end

% Read unsigned integer data with correct bitdepth
switch hdr.datatype
  case 2
    s = fread(fd, Inf, 'uint8');
  case 4
    s = fread(fd, Inf, 'uint16');
  case 8
    s = fread(fd, Inf, 'uint32');
  case 16
    s = fread(fd, Inf, 'float');
  case 64
    s = fread(fd, Inf, 'double');
end

% Close the data file
fclose(fd);

if prod(hdr.dim) ~= size(s)
  fprintf('%s: Data size does not match size in header\n', fname);
  s = [];
  return;
end

switch hdr.datatype
  
  case {2,4,8}

    % Catch zero voxel limits
    if hdr.vox(1) == 0 && hdr.vox(2) == 0.0
      hdr.vox = [1 0];
    end
    
    % Catch zero calibration limits - replace with voxel value limits
    if hdr.cal(1) == 0.0 && hdr.cal(2) == 0.0
      hdr.cal = hdr.vox;
    end

    % Map voxel values from unsigned integer range to calibrated range
    s = (s - hdr.vox(2)) / (hdr.vox(1) - hdr.vox(2)) * (hdr.cal(1) - hdr.cal(2)) + hdr.cal(2);
    
  otherwise    
  
    % No rescale
    
end

% Reshape the data
s = reshape(s, hdr.dim(1), hdr.dim(2), hdr.dim(3));