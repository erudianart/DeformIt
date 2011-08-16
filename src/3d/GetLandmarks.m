%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file GetLandmarks.m
% @author Preet S. Jassi
% @date October 3 2008
% @description get landmarks to interpolate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Lx,Ly,Lz] = GetLandmarks(fpath)

    try
        
        
        load(strcat(fpath,'/landmarks.txt'));
        Lx = double(landmarks(:,1));
        Ly = double(landmarks(:,2));
        Lz = double(landmarks(:,3));
        
    catch
        
        Lx = [];
        Ly = [];
        Lz = [];

    end

end