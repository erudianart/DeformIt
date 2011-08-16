%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file DeformLandmarks.m
% @author Preet S. Jassi
% @date October 2nd 2008
% @description interpolate new locations of landmarks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DeformLandmarks(fpath,Lx,Ly,Frx,Fry,dx,dy,cp,k)

    if (~isempty(Lx))
        
        % Convert to meshgrid format
        FFrx = zeros(cp,cp);
        FFry = zeros(cp,cp);
        Dx = zeros(cp,cp);
        Dy = zeros(cp,cp);

        count = 1;
        for i=1:cp
            for j=1:cp
                FFrx(j,i) = Frx(count);
                FFry(j,i) = Fry(count);
                Dx(j,i) = dx(count);
                Dy(j,i) = dy(count);
                count = count+1;
            end
        end

        %interpolate and save new landmarks
        fid = fopen(strcat(fpath,'/deformedlandmarks',int2str(k),'.txt'),'a');

        for k=1:length(Lx)
            x = Lx(k) - interp2(FFrx, FFry, Dx, Lx(k), Ly(k), 'linear');
            y = Ly(k) - interp2(FFrx, FFry, Dy, Lx(k), Ly(k), 'linear');
            fprintf(fid,'%6.4f  %6.4f\r\n',x,y);
        end

        fprintf(fid,'\r\n');
        fclose(fid);

    end
end