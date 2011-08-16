function [sz, hdr] = anreadslice(filestub,z)
% Read an XY slice, given Z, from a 3D ANALYZE dataset
%
% [sz, hdr] = anreadslice(filestub,z)
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
% DATES : 03/12/2004 JMT Adapt from anread.m (JMT)
%         06/10/2005 JMT Correct offset bug (z-1 not z)
%         01/23/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
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

fname = 'anreadslice';

% Defaults
sz = [];
hdr = [];

if nargin < 1
  fprintf('USAGE: [sz, hdr] = anreadslice(filestub,z)\n');
  return
end

% Read the ANALYZE header
[hdr, status] = anreadhdr(filestub);
if status < 0
  fprintf('%s: Problem loading header\n', fname);
  return
end

if z > hdr.dim(3) || z < 1
  fprintf('%s: z must be in range 1 to %d\n', fname, hdr.dim(3));
  return
end

% Create appropriate filenames
anaimgfile = [filestub '.img'];

% Open image data stream
fd = fopen(anaimgfile, 'r', hdr.endian);
if fd < 0
  fprintf('%s: Could not open %s to read\n', fname, anaimgfile);
  return;
end

% Calculate offset to start of slice in stream
xysize = prod(hdr.dim(1:2));
offset = xysize * (z-1);

% Read unsigned integer data with correct bitdepth
switch hdr.datatype
case 2
  bytedepth = 1;
  typestr = 'uint8';
case 4
  bytedepth = 2;
  typestr = 'uint16';
case 8
  bytedepth = 4;
  typestr = 'uint32';
case 16
  bytedepth = 4;
  typestr = 'float';
case 64
  bytedepth = 8;
  typestr = 'double';
end

% Skip to the start of the slice
fseek(fd,offset * bytedepth,'bof');

% Read the slice
sz = fread(fd, xysize, typestr);

% Close the data file
fclose(fd);

if size(sz) ~= xysize
  fprintf('%s: Slice size does not match size in header\n', fname);
  sz = [];
  return;
end

switch hdr.datatype
  
  case {2,4,8}

    % Catch zero calibration limits - replace with voxel value limits
    if hdr.cal(1) == 0.0 && hdr.cal(2) == 0.0
      hdr.cal = hdr.vox;
    end

    % Map voxel values from unsigned integer range to calibrated range
    sz = (sz - hdr.vox(2)) / (hdr.vox(1) - hdr.vox(2)) * (hdr.cal(1) - hdr.cal(2)) + hdr.cal(2);
    
  otherwise    
  
    % No rescale
    
end

% Reshape the data
sz = reshape(sz, hdr.dim(1), hdr.dim(2));