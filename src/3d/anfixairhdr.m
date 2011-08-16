function anfixairhdr(srcstub, deststub)
% Transfer scaling information from one Analyze header to another
%
% anfixairhdr(srcstub, deststub)
%
% Copy the calibrated intensity scaling from the header of srcstub
% to the header of deststub. Fixes absence of calibrated scaling in AIR 
% resliced data.
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : City of Hope, Duarte CA
% DATES : 02/28/2001 From scratch
%         08/28/2001 Rename from MEPSI_FixAIRHdr for general use
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

% Read the source header
srchdr = anreadhdr(srcstub);

% Read the destination header
desthdr = anreadhdr(deststub);

% Copy the calibrated scaling from source to destination
desthdr.cal = srchdr.cal;

% Resave the destination header
anwritehdr(deststub, desthdr);