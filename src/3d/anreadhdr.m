function [hdr,status] = anreadhdr(filestub)
% Read the header from an ANALYZE 7.5 dataset
%
% [hdr,status] = anreadhdr(filestub)
%
% The header structure contains the following elements:
% .dim   = dimension vector for s (eg [256 256 128])
% .vsize = voxel size vector for s (eg [0.5 0.5 0.2])
% .cal   = calibrated intensity range for s (eg [max min] = [1 0])
% .vox   = voxel intensity range for s (eg [max min] = [255 0])
% .datatype = ANALYZE datatype enum (eg 4 = int16)
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : City of Hope, Duarte CA
% DATES : 02/28/2001 JMT Adapt from anread.m
%         08/17/2004 JMT Add origin support for SPM
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

fname = 'anreadhdr';

% Defaults
status = 0;
hdr.dim = [];
hdr.vsize = [];
hdr.cal = [];

if nargin < 1
  fprintf('USAGE: hdr = anreadhdr(filestub)\n');
  status = -1;
  return
end

% Create appropriate filenames
anahdrfile = [filestub '.hdr'];

%--------------------------------------------------------------
% Test read header to determine endian-ness
%--------------------------------------------------------------

% Open as little endian
fd = fopen(anahdrfile, 'r', 'ieee-le');
if fd < 0
  fprintf('%s: Could not open %s to read\n', fname, anahdrfile);
  status = -2;
  return;
end

% Read header length field - should contain 348 if LE
len = fread(fd,1,'uint32');

if len == 348
  
  % Must be little endian
  hdr.endian = 'ieee-le';
  
else
  
  hdr.endian = 'ieee-be';

  % Repen header as big endian
  fd = fopen(anahdrfile, 'r', 'ieee-be');
  if fd < 0
    fprintf('%s: Could not open %s to read\n', fname, anahdrfile);
    status = -3;
    return
  end

end

% Read matrix dimensions
fseek(fd, 42, 'bof');
hdr.dim = fread(fd, 3, 'uint16')';

% Read data type
fseek(fd, 70, 'bof');
hdr.datatype = fread(fd, 1, 'uint16');

% Read voxel sizes
fseek(fd, 80, 'bof');
hdr.vsize = fread(fd, 3, 'float')';

% Read calibrated intensity range
fseek(fd, 124, 'bof');
calMax = fread(fd, 1, 'float');
calMin = fread(fd, 1, 'float');
hdr.cal = [calMax calMin];

% Read voxel intensity range
fseek(fd, 140, 'bof');
voxMax = fread(fd, 1, 'uint32');
voxMin = fread(fd, 1, 'uint32');
hdr.vox = [voxMax voxMin];

%------------------------------------------------------------------
% Read image history structure
% Starts at offset 148
%------------------------------------------------------------------
fseek(fd, 148, 'bof');
hdr.desc = char(fread(fd, 80, 'char')');
hdr.auxfile = char(fread(fd, 24, 'char')');
hdr.orient = double(fread(fd, 1, 'char')');

% Use SPMs redefinition of the originator field
% to 5 x int16 shorts. First three values are X,Y,Z
% origin location in voxels.
hdr.orig = fread(fd, 5, 'int16');
hdr.orig = hdr.orig(1:3);

hdr.generated = char(fread(fd, 10, 'char')');
hdr.scanno = char(fread(fd, 10, 'char')');
hdr.pid = char(fread(fd, 10, 'char')');
hdr.expdate = char(fread(fd, 10, 'char')');
hdr.exptime = char(fread(fd, 10, 'char')');
hdr.hist_un0 = char(fread(fd, 3, 'char')');
hdr.views = fread(fd, 1, 'int32');
hdr.vols_added = fread(fd, 1, 'int32');
hdr.start_field = fread(fd, 1, 'int32');
hdr.field_skip = fread(fd, 1, 'int32');
hdr.Omin = fread(fd, 1, 'int32');
hdr.Omax = fread(fd, 1, 'int32');
hdr.Smin = fread(fd, 1, 'int32');
hdr.Smax = fread(fd, 1, 'int32');

fclose(fd);

%------------------------------------------------------------------
% ANALYZE .hdr format specification
%
% FROM: http://www.mayo.edu/bir/Analyze_Pages/AnalyzeFileInfo.html
%
% /*    ANALYZETM
%  Header File Format
%  *
%  *
%  *  (c) Copyright, 1986-1995
%  *  Biomedical Imaging Resource
%  *  Mayo Foundation
%  *
%  *
%  *  dbh.h
%  *
%  *
%  *
%  *  databse sub-definitions
%  */
%
%
% struct header_key                       /* header key   */ 
%       {                                /* off + size      */
%       int sizeof_hdr                   /* 0 + 4           */
%       char data_type[10];              /* 4 + 10          */
%       char db_name[18];                /* 14 + 18         */
%       int extents;                     /* 32 + 4          */
%       short int session_error;         /* 36 + 2          */
%       char regular;                    /* 38 + 1          */
%       char hkey_un0;                   /* 39 + 1          */
%       };                               /* total=40 bytes  */
% struct image_dimension 
%       {                                /* off + size      */
%       short int dim[8];                /* 0 + 16          */
%       short int unused8;               /* 16 + 2          */
%       short int unused9;               /* 18 + 2          */
%       short int unused10;              /* 20 + 2          */
%       short int unused11;              /* 22 + 2          */
%       short int unused12;              /* 24 + 2          */
%       short int unused13;              /* 26 + 2          */
%       short int unused14;              /* 28 + 2          */
%       short int datatype;              /* 30 + 2          */
%       short int bitpix;                /* 32 + 2          */
%       short int dim_un0;               /* 34 + 2          */
%       float pixdim[8];                 /* 36 + 32         */
%                       /* 
%                            pixdim[] specifies the voxel dimensitons: 
%                            pixdim[1] - voxel width
%                            pixdim[2] - voxel height
%                            pixdim[3] - interslice distance
%                                ...etc
%                       */
%       float vox_offset;                /* 68 + 4          */
%       float funused1;                  /* 72 + 4          */
%       float funused2;                  /* 76 + 4          */
%       float funused3;                  /* 80 + 4          */
%       float cal_max;                   /* 84 + 4          */
%       float cal_min;                   /* 88 + 4          */
%       float compressed;                /* 92 + 4          */
%       float verified;                  /* 96 + 4          */
%       int glmax,glmin;                 /* 100 + 8         */
%       };                               /* total=108 bytes */
% struct data_history       
%       {                                /* off + size      */
%       char descrip[80];                /* 0 + 80          */
%       char aux_file[24];               /* 80 + 24         */
%       char orient;                     /* 104 + 1         */
%       char originator[10];             /* 105 + 10        */
%       char generated[10];              /* 115 + 10        */
%       char scannum[10];                /* 125 + 10        */
%       char patient_id[10];             /* 135 + 10        */
%       char exp_date[10];               /* 145 + 10        */
%       char exp_time[10];               /* 155 + 10        */
%       char hist_un0[3];                /* 165 + 3         */
%       int views                        /* 168 + 4         */
%       int vols_added;                  /* 172 + 4         */
%       int start_field;                 /* 176 + 4         */
%       int field_skip;                  /* 180 + 4         */
%       int omax, omin;                  /* 184 + 8         */
%       int smax, smin;                  /* 192 + 8         */
%       };
% struct dsr
%      { 
%       struct header_key hk;            /* 0 + 40          */
%       struct image_dimension dime;     /* 40 + 108        */
%       struct data_history hist;        /* 148 + 200       */
%       };                               /* total= 348 bytes*/
%
% /* Acceptable values for datatype */
%
% #define DT_NONE                  0
% #define DT_UNKNOWN               0
% #define DT_BINARY                1
% #define DT_UNSIGNED_CHAR         2
% #define DT_SIGNED_SHORT          4
% #define DT_SIGNED_INT            8
% #define DT_FLOAT                 16
% #define DT_COMPLEX               32
% #define DT_DOUBLE                64
% #define DT_RGB                   128
% #define DT_ALL                   255
%
% typedef struct
%       { 
%        float real;
%        float imag;
%       } COMPLEX;
%
%
% --------------------------------------------------------------------------------
%
% Comments
% The header format is flexible and can be extended for new user-defined data types. The essential structures of the header are the header_key and the image_dimension.
%
% The required elements in the header_key substructure are: 
%
% int sizeof_header      Must indicate the byte size of the header file. 
% int extents              Should be 16384, the image file is created as contiguous with a minimum extent size. 
% char regular              Must be `r' to indicate that all images and volumes are the same size. 
% The image_dimension substructure describes the organization and size of the images. These elements enable the database to reference images by volume and slice number. Explanation of each element follows: 
%
% short int dim[];      /* array of the image dimensions */ 
% dim[0]      Number of dimensions in database; usually 4 
% dim[1]      Image X dimension; number of pixels in an image row 
% dim[2]      Image Y dimension; number of pixel rows in slice 
% dim[3]      Volume Z dimension; number of slices in a volume 
% cdim[4]      Time points, number of volumes in database.
% char vox_units[4]     specifies the spatial units of measure for a voxel 
% char cal_units[4]      specifies the name of the calibration unit 
% short int datatype      /* datatype for this image set */ 
% /*Acceptable values for datatype are*/ 
% #define DT_NONE                        0 
% #define DT_UNKNOWN               0      /*Unknown data type*/ 
% #define DT_BINARY                    1      /*Binary (1 bit per voxel)*/ 
% #define DT_UNSIGNED_CHAR     2      /*Unsigned character (8 bits per voxel)*/ 
% #define DT_SIGNED_SHORT        4      /*Signed short (16 bits per voxel)*/ 
% #define DT_SIGNED_INT             8      /*Signed integer (32 bits per voxel)*/ 
% #define DT_FLOAT                     16     /*Floating point (32 bits per voxel)*/ 
% #define DT_COMPLEX                32     /*Complex (64 bits per voxel; 2 floating point numbers) 
% #define DT_DOUBLE                   64     /*Double precision (64 bits per voxel)*/ 
% #define DT_RGB                         128    /* */
% #define DT_ALL                         255    /* */
%
% short int bitpix;        /* number of bits per pixel; 1, 8, 16, 32, or 64. */ 
% short int dim_un0;   /* unused */ 
% float pixdim[];       Parallel array to dim[], giving real world measurements in mm. and ms. 
% pixdim[1];      voxel width in mm. 
% pixdim[2];      voxel height in mm. 
% pixdim[3];      slice thickness in mm. 
% float vox_offset;      byte offset in the .img file at which voxels start. This value can be 
%                                   negative to specify that the absolute value is applied for every image
%                                   in the file. 
% float calibrated Max, Min    specify the range of calibration values 
% int glmax, glmin;    The maximum and minimum pixel values for the entire database. 
% The data_history substructure is not required, but the orient field is used to indicate individual slice orientation and determines whether the Movie program will attempt to flip the images before displaying a movie sequence.
%
% orient:       slice orientation for this dataset. 
% 0      transverse unflipped 
% 1      coronal unflipped 
% 2      sagittal unflipped 
% 3      transverse flipped 
% 4      coronal flipped 
% 5      sagittal flipped 