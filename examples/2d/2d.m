%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file 2d.m
% @author Preet S. Jassi
% @date August 15th 2011
% @description Example 2d deformation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% set the parameters for DeformIt to be used
% detailed description of the parameters and their ranges is in the 
% DeformIt.m file in the /src/2d/ directory
% NOTE: this file needs to be copied into the source directory to work

file = 'O1451U10X.tif';
segmentation = 'O1451U10X_12042006.tif';
nObs = '20';
WarpedImage = '1';
cp = '6';
RandomMorph = '0';
RandomRange = '0';
alpha1 = '0.5';
t = '0.8';
Noise = '1';
NoiseType = 'gaussian';
NM = '0';
NV = '0.01';
ND = '0';
NonUniform = '1';
ncp = '6';
NonUniformStrength = '0.5';

% deform the image and the ground thruth segmentation
% note that these files need to be copied into the source folder in order for it to work
DeformIt(file, segmentation, nObs, WarpedImage, cp, RandomMorph, RandomRange, alpha1, t, Noise, NoiseType, NM,NV,ND,NonUniform, ncp, NonUniformStrength);
