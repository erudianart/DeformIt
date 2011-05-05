%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file DeformIt.m
% @author Preet S. Jassi (sorta...)
% @date May 5 2011
% @description the brains for deforming a bunch of images..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%
% @param string filetype the type of 3d file to read, e.g. analyze
% @param string file - the filename
% @param string segmentation - the segmentation name or empty string
% @param string nObs the number of images you want to generate
% @param string WarpedImage 1 if the image is to be deformed and 0 if the image is not to be deformed (warped)
% @param string cp the number of control points per axis of the image if you do not want to manually specify the control points
% @param string RandomMorph 1 if you want the deformation to be Random instead of Vibrational / Variational
% @param string RandomRange integer between [0,1] for the range of the random vectors where 1 is half the distance between control points
% @param string alpha1 weight of vibrational vs variational when calculating the displacement vectors in the range [0,1]
% @param string t number of variational modes used in describing the deformation or the fractional variance if less than one, value between [0, nObs^2]
% @param string Ansio 1 if you want ansio scaling 
% @param string Noise 1 if you want to add noise to the image
% @param string NonUniform 1 if you want non uniformity intensities added to simulate the imhomogenity found in magentic resonance images
% @param string ncp the number of control points for the non uniformity
% @param string NonUniformStrength the strength of the non uniformity [0,1]
% @method DeformIt
% @return void
%%
function DeformIt(filetype, file, segmentation, nObs, WarpedImage, cp, RandomMorph, RandomRange, alpha1, t, Ansio, Noise, NonUniform, ncp, NonUniformStrength) 

    %%convert parameters to numbers
    nObs = str2num(nObs);
    WarpedImage = str2num(WarpedImage);
    cp = str2num(cp); %num of control points (along x = along y = along z) grid of cp*cp*cp
    RandomMorph = str2num(RandomMorph);
    RandomRange = str2num(RandomRange);
    alpha1 = str2num(alpha1);
    t = str2num(t);
    Ansio = str2num(Ansio); %scaling
    
    Noise = str2num(Noise);
    
    NonUniform = str2num(NonUniform);
    ncp = str2num(ncp);
    NonUniformStrength = str2num(NonUniformStrength);




    sz=10;%sqaure size in checkerboard
    mg=.05;%margin boundary

    
    %%read images
    if strcmp(filetype,'analyze')
        [Im,hdr] = anread(file);
        Im = double(Im);
    else
        Im = double(read_mhd(strcat(file,'.mhd')));
    end
    
    fnamecopy = file;
    fpath = strtok(fnamecopy,'/'); 
    
    if (~(strcmp(segmentation,'0')))    
        if strcmp(filetype,'analyze')
            [Iseg,shdr] = anread(segmentation);
            Iseg = double(Iseg);
        else
            Iseg = double(read_mhd(strcat(segmentation,'.mhd')));
        end    
    end
    
    
    
    %get images sizes   
    Imax=max(Im(:));
    iWarpRange=NonUniformStrength*Imax;

    imsz = size(Im,1);
    imszx = size(Im,1);
    imszy = size(Im,2);
    imszz = size(Im,3);

    %% Generating the observations 
    %  spatial transformation (change in control point locations)
    %  and corresponsing warped images


    if WarpedImage
        %Get control points
        [Frx,Fry,Frz]=GetControlPoints(imszx, imszy, imszz, cp, RandomMorph, Ansio);
        [Lx,Ly,Lz]=GetLandmarks(fpath);
        
        SaveControlPoints(fpath, Frx, Fry, Frz);
        
        if (~(RandomMorph))

            %vibrational deform, get change vectors
             OrgShape = [Frx,Fry,Frz];
             [dx_mat,dy_mat,dz_mat] = ShapeGeneration(OrgShape,nObs+1,alpha1,t); 

        end

    end
    
    if NonUniform
        %create arrays imIx and imIy from cp vectors from 1 to imsz
        [imIx,imIy,imIz]=meshgrid(linspace(1,imszx,ncp),linspace(1,imszy,ncp),linspace(1,imszz,ncp));
    
        %create arrays imx imy from 1 to imsz
        [imx,imy,imz]=meshgrid(1:imszx,1:imszy,1:imszz);
    end


    


    for k=1:nObs,


        if NonUniform
            
            di = iWarpRange*(rand(size(imIx),size(imIy),size(imIz))-0.5);
            
            %add  additional intensity values to the warped
            %images to mimic the non-uniformity seen in MR machines (google/images inhomogeneity  MRI)

            [intensityWarp] = interp3(imIx,imIy,imIz,di,imx,imy,imz,'cubic');    
        end


       if WarpedImage 
           
           if RandomMorph 

                dx = RandomRange*(2*imszx*mg*rand(size(Frx))-imszx*mg); %create change in x %% need to change this
                dy = RandomRange*(2*imszy*mg*rand(size(Fry))-imszy*mg); %random change in y
                dz = RandomRange*(2*imszz*mg*rand(size(Frz))-imszz*mg); %random change in z

           else


                % issue with this, had to change (:,k) to (:,k+1) because the
                % first one is for "testing"
                dx = dx_mat(:,k+1);
                dy = dy_mat(:,k+1);
                dz = dz_mat(:,k+1);

                if Ansio

                    dx = dx*(imszx/max([imszx, imszy, imszz]));
                    dy = dy*(imszy/max([imszx, imszy, imszz]));
                    dz = dz*(imszz/max([imszx, imszy, imszz]));

                end

           end

            dx=dx(:)';    dy=dy(:)';	dz=dz(:)'; 

            SaveGeneratedChanges(fpath,dx,dy,dz,k);
            DeformLandmarks(fpath,Lx,Ly,Lz,Frx,Fry,Frz,dx,dy,dz,cp,k)
            
            %How much deformed by
            Tox=-1*(dx);  Toy=-1*(dy);  Toz=-1*(dz);
            Tox = Tox+Frx;
            Toy = Toy+Fry;
            Toz = Toz+Frz;

            temp = 1;
            
            for q=1:size(Frx,2),
               if temp
                if Frx(1,q) > 0 
                   CTRL_DISP = [Frx(1,q)]; 
                else 
                   CTRL_DISP = [1.0];
                end
                temp = 0;
               else
                if Frx(1,q) > 0 
                   CTRL_DISP = [CTRL_DISP Frx(1,q)];  
                else 
                   CTRL_DISP = [CTRL_DISP 1.0];
                end
               end
               
               if Fry(1,q) > 0 
                   CTRL_DISP = [CTRL_DISP Fry(1,q)];  
               else 
                   CTRL_DISP = [CTRL_DISP 1.0];
               end
               
               if Frz(1,q) > 0 
                   CTRL_DISP = [CTRL_DISP Frz(1,q)];  
               else 
                   CTRL_DISP = [CTRL_DISP 1.0];
               end
               
               if Tox(1,q) > 0
                   if Tox(1,q) <= imszx
                        CTRL_DISP = [CTRL_DISP Tox(1,q)];  
                   else
                        CTRL_DISP = [CTRL_DISP imszx*(1-mg)]; 
                   end
               else 
                   CTRL_DISP = [CTRL_DISP 1.0];
               end
               
               if Toy(1,q) > 0 
                   if Toy(1,q) <= imszy
                        CTRL_DISP = [CTRL_DISP Toy(1,q)];  
                   else
                        CTRL_DISP = [CTRL_DISP imszy*(1-mg)]; 
                   end
               else 
                   CTRL_DISP = [CTRL_DISP 1.0];
               end
               
               if Toz(1,q) > 0 
                   if Toz(1,q) <= imszz
                        CTRL_DISP = [CTRL_DISP Toz(1,q)];  
                   else
                        CTRL_DISP = [CTRL_DISP imszz*(1-mg)]; 
                   end
               else 
                   CTRL_DISP = [CTRL_DISP 1.0];
               end
            end
            
            
            %deform image
            DeformedIm = matitk('rtps',[],Im,Im,CTRL_DISP);
            
            %deform segmentation
            if (~(strcmp(segmentation,'0')))
                DeformedIseg = matitk('rtps',[],Iseg,Iseg,CTRL_DISP);
            end
            
            
        else
            DeformedIm = Im;
            
            if (~(strcmp(segmentation,'0')))
                DeformedIseg = Iseg;
            end 
            
        end

        % add noise
        if Noise
            %uniform (speckle) needs variance
            DeformedIm = DeformedIm + rand(imszx,imszy,imszz);
            
            %normally distributed / gaussian
            %DeformedIm = DeformedIm + normrnd(M,V,imszx,imszy,imszz);
            
            %poisson
            %DeformedIm = DeformedIm + possrnd(L,imszx,imszy,imszz);
            
            %salt and pepper
            %determine number of pixels to alter
            %determine pick a random location
            %decide if black or white, change image to black or
            %white...
            
        end

        %add non uniformity
        if NonUniform
           iWarp=DeformedIm+intensityWarp;
        else
            iWarp = DeformedIm;
        end

        
        %save image
        if strcmp(filetype,'analyze')
            ahdr.vsize = hdr.vsize;
            anwrite(strcat(file,'_d_',int2str(k)),iWarp,ahdr);
        else
            save_deformed_mhd(file, strcat(file,'_d_',int2str(k)), iWarp);
        end
        
        %save segmentation
        if (~(strcmp(segmentation,'0')))
            
            if strcmp(filetype,'analyze')
                ashdr.vsize = shdr.vsize;
                anwrite(strcat(segmentation,'_s_',int2str(k)),DeformedIseg,ashdr);
            else
                save_deformed_mhd(segmentation, strcat(segmentation,'_s_',int2str(k)), DeformedIseg);
            end
        end
        

    end

end
