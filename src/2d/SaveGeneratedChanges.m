%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file SaveGeneratedChanges.m
% @author Preet S. Jassi (sorta...)
% @date August 1st, 2008
% @saves change vectors to a text file..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SaveGeneratedChanges(fpath,dx,dy,k)

    fid = fopen(strcat(fpath,'/changevectors',int2str(k),'.txt'),'a');
    
    for i=1:length(dx)
        fprintf(fid,'%6.4f  %6.4f\r\n',dx(i),dy(i));
    end

    fprintf(fid,'\r\n');
    fclose(fid);
    
end