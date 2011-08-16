%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file SaveControlPoints.m
% @author Preet S. Jassi (sorta...)
% @date July, 26th 2008
% @saves the original control points.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SaveControlPoints(fpath, Frx, Fry, Frz)

    fid = fopen(strcat(fpath,'/controlpoints.txt'),'a');
    
    for i=1:length(Frx)
        fprintf(fid,'%6.4f  %6.4f  %6.4f\r\n',Frx(i),Fry(i),Frz(i));
    end

    fprintf(fid,'\r\n');
    fclose(fid);
    
end