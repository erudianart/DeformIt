%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file GetLandmarks.m
% @author Preet S. Jassi
% @date October 2nd 2008
% @description get landmarks to interpolate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Lx,Ly] = GetLandmarks(fpath)

    try
        
        
        load(strcat(fpath,'/landmarks.txt'));
        Lx = double(landmarks(:,1));
        Ly = double(landmarks(:,2));
        
    catch
        
        Lx = [];
        Ly = [];

    end

end