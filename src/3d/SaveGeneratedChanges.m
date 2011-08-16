function SaveGeneratedChanges(fpath,dx,dy,dz,k);

    A = [dx,dy,dz];
    fid = fopen(strcat(fpath,'/changevectors',int2str(k),'.txt'),'a');
    
    for i=1:length(dx)
        fprintf(fid,'%6.4f  %6.4f  %6.4f\r\n',dx(i),dy(i),dz(i));
    end

    fprintf(fid,'\r\n');
    fclose(fid);
    
end