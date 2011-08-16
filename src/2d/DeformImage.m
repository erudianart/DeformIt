%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file GenerateDeformedAndSegmentedImages.m
% @author Preet S. Jassi (sorta...)
% @date July, 31th 2008
% @returns interpolated image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DeformedIm, X, Y] = DeformImage(Im,Frx,Fry,Tox,Toy,type)
%  [x y x y x y x y x y] 
[XX,YY] = meshgrid(1:size(Im,2), 1:size(Im,1));

if (Frx == Tox' & Fry == Toy')
    DeformedIm = Im;
    X = XX;
    Y = YY;
    return
end


Rows = Frx;
Columns = Fry;
XDeformations = Tox;
YDeformations = Toy;

% Fit spline for the X Deformation
X = FitSpline(XX, Rows, Columns, XDeformations);

% Fit spline for the Y Deformation
Y = FitSpline(YY, Rows, Columns, YDeformations);

%noise types




% Resample Image.
DeformedIm = InterpolateImage2(X, Y, Im, type, XX, YY); 
% return