%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file DeformLandmarks.m
% @author Preet S. Jassi
% @date October 3 2008
% @description interpolate new locations of landmarks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DeformLandmarks(fpath,Lx,Ly,Lz,Frx,Fry,Frz,dx,dy,dz,cp,indx)

    if (~isempty(Lx))
        
        % Convert to meshgrid format
        FFrx = zeros(cp,cp,cp);
        FFry = zeros(cp,cp,cp);
        FFrz = zeros(cp,cp,cp);
        Dx = zeros(cp,cp,cp);
        Dy = zeros(cp,cp,cp);
        Dz = zeros(cp,cp,cp);
        
        count = 1;
        for i=1:cp
            for j=1:cp
                for k=1:cp;
                    FFrx(k,j,i) = Frx(count);
                    FFry(k,j,i) = Fry(count);
                    FFrz(k,j,i) = Frz(count);
                    Dx(k,j,i) = dx(count);
                    Dy(k,j,i) = dy(count);
                    Dz(k,j,i) = dz(count);
                    count = count+1;
                end
            end
        end

        %interpolate and save new landmarks
        fid = fopen(strcat(fpath,'/deformedlandmarks',int2str(indx),'.txt'),'a');

        for m=1:length(Lx)
            x = Lx(m) - interp3(FFrx, FFry, FFrz, Dx, Lx(m), Ly(m), Lz(m), 'linear');
            y = Ly(m) - interp3(FFrx, FFry, FFrz, Dy, Lx(m), Ly(m), Lz(m), 'linear');
            z = Lz(m) - interp3(FFrx, FFry, FFrz, Dz, Lx(m), Ly(m), Lz(m), 'linear');
            fprintf(fid,'%6.4f  %6.4f  %6.4f\r\n',x,y,z);
        end

        fprintf(fid,'\r\n');
        fclose(fid);

    end
end