%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file 3d.m
% @author Preet S. Jassi
% @date August 15th 2011
% @description an example 3d image deformation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the parameters for DeformIt to be used
% detailed description of the parameters and their ranges is in the 
% DeformIt.m file in the /src/3d/ directory
% NOTE: this file needs to be copied into the source directory to work

filetype = 'analyze';
file = 'analyze';
segmentation = '0';
nObs = '10';
WarpedImage = '1';
cp = '6';
RandomMorph = '1';
RandomRange = '0.5';
alpha1 = '0';
t = '0';
Ansio = '1';
Noise = '1';
NonUniform = '1';
ncp = '6';
NonUniformStrength = '0.5';

% deform the image and the ground thruth segmentation
% note that these files need to be copied into the source folder in order for it to work
DeformIt(filetype, file, segmentation, nObs, WarpedImage, cp, RandomMorph, RandomRange, alpha1, t, Ansio, Noise, NonUniform, ncp, NonUniformStrength); 
