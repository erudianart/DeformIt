%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file DeformIt.m
% @author Preet S. Jassi
% @date May 5th 2011
% @description Deform 2D images and their corresponsing ground truth segmentations for segmentation validation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% @param string file - the filename
% @param string segmentation - the segmentation name or empty string
% @param string nObs the number of images you want to generate
% @param string WarpedImage 1 if the image is to be deformed and 0 if the image is not to be deformed (warped)
% @param string cp the number of control points per axis of the image if you do not want to manually specify the control points
% @param string RandomMorph 1 if you want the deformation to be Random instead of Vibrational / Variational
% @param string RandomRange integer between [0,1] for the range of the random vectors where 1 is half the distance between control points
% @param string alpha1 weight of vibrational vs variational when calculating the displacement vectors in the range [0,1]
% @param string t number of variational modes used in describing the deformation or the fractional variance if less than one, value between [0, nObs^2]
% @param string Noise 1 if you want to add noise to the image
% @param string NoiseType gaussian, poisson, salt & pepper, speckle
% @param string NM the mean of the noise for guassian noise
% @param string NV the variance for guassian and speckle
% @param string ND density for salt and pepper
% @param string NonUniform 1 if you want non uniformity intensities added to simulate the imhomogenity found in magentic resonance images
% @param string ncp the number of control points for the non uniformity
% @param string NonUniformStrength the strength of the non uniformity [0,1]
% @method DeformIt
% @return void
%%
function DeformIt(file, segmentation, nObs, WarpedImage, cp, RandomMorph, RandomRange, alpha1, t, Noise, NoiseType, NM,NV,ND,NonUniform, ncp, NonUniformStrength)

nObs = str2num(nObs);

WarpedImage = str2num(WarpedImage);
cp = str2num(cp);
RandomMorph = str2num(RandomMorph);
RandomRange = str2num(RandomRange);
alpha1 = str2num(alpha1);
t = str2num(t);

Noise = str2num(Noise);
NM = str2num(NM);
NV = str2num(NV);
ND = str2num(ND);

NonUniform = str2num(NonUniform);
ncp = str2num(ncp);
NonUniformStrength = str2num(NonUniformStrength);


%% initialization
sz=10; %sqaure size in checkerboard
mg=.05; %margin boundary


fileinfo = imfinfo(file);
ext = fileinfo(1).Format;
fname = fileinfo(1).Filename;
fnamecopy = fname;
fpath = strtok(fnamecopy,'/'); 

Im=double(imread(file));

if size(Im,3) > 1
    Im = mean(Im,3);
end

Imax=max(Im(:));
iWarpRange=NonUniformStrength*Imax;

imsz = size(Im,1);
imszx = size(Im,1);
imszy = size(Im,2);


if (~(strcmp(segmentation,'0')))    
    Iseg=double(imread(segmentation));
    seginfo = imfinfo(segmentation);
    segext = seginfo(1).Format;
    segfname = seginfo(1).Filename;
end



%% Generating the observations 
%  spatial transformation (change in control point locations)
%  and corresponsing warped images

    
if (WarpedImage)
    
    [Frx,Fry]=GetControlPoints(imszx, imszy, cp);
    [Lx,Ly]=GetLandmarks(fpath);
    
    SaveControlPoints(fpath,Frx,Fry);
   
    if (~(RandomMorph))

        %vibrational
        OrgShape = [Frx,Fry];
        [dx_mat,dy_mat] = ShapeGeneration(OrgShape,nObs+1,alpha1,t); %naive but whatever lets get this working        
    
    end
end    
   

if (NonUniform)
    
    %create arrays imIx and imIy from cp vectors from 1 to imsz
    [imIx,imIy]=meshgrid(linspace(1,imszx,ncp),linspace(1,imszy,ncp));

    %create arrays imx imy from 1 to imsz
    [imx,imy]=meshgrid(1:imszx,1:imszy);

end





for k=1:nObs,
    
    
        
    if NonUniform
        di=iWarpRange*(rand(size(imIx))-0.5);
        %add  additional intensity values to the warped
        %images to mimic the non-uniformity seen in MR machines (google/images inhomogeneity  MRI)
        [intensityWarp] = interp2(imIx,imIy,di,imx,imy,'cubic');
        intensityWarp = intensityWarp';
    end
    
    
   if WarpedImage
       
       if RandomMorph 


            dx=RandomRange*imszx*mg*(2*rand(size(Frx))-1); %create change in x
            dy=RandomRange*imszy*mg*(2*rand(size(Fry))-1); %random change in y

             dx=dx';    
             dy=dy';	 

       else


            % issue with this, had to change (:,k) to (:,k+1) because the
            % first one is for "testing"
            dx = dx_mat(:,k+1);
            dy = dy_mat(:,k+1);


       end

        SaveGeneratedChanges(fpath,dx,dy,k);
        DeformLandmarks(fpath,Lx,Ly,Frx,Fry,dx,dy,cp,k)
        
        %How much deformed by
        Tox=-1*(dx);  Toy=-1*(dy); 



        %deform image - add noise
        [DeformedIm, X, Y] = DeformImage(Im,Frx,Fry,Tox,Toy,'nearest');
        
                %deform segmentation, do not add noise
        if (~(strcmp(segmentation,'0')))
            if WarpedImage
                DeformedSeg=DeformImage(Iseg,Frx,Fry,Tox,Toy,'nearest');
            else
                DeformedSeg = Iseg;
            end
        end
        
    else
        DeformedIm = Im;
    end

    % add noise
    if Noise
        
        ScaledDIM = DeformedIm - min(DeformedIm(:));
        ScaledDIM = uint8(ScaledDIM*(255/max(ScaledDIM(:))));
        
        switch(NoiseType)
            case('gaussian')
                %gaussian nose
                DeformedIm = double(imnoise(ScaledDIM,'gaussian',NM,NV));
            case('poisson')
                DeformedIm = double(imnoise(ScaledDIM,'poisson'));
            case('salt & pepper')
                DeformedIm = double(imnoise(ScaledDIM,'salt & pepper',ND));
            case('speckle')
                DeformedIm = double(imnoise(ScaledDIM,'speckle',NV));
        end
    end

                   
    if NonUniform
        iWarp=DeformedIm+intensityWarp;
    else
        iWarp = DeformedIm;
    end
    
    %
    %
    % GOTTA SCALE IMAGE!!!!
    iWarp = iWarp - min(iWarp(:));
    iWarp = iWarp*(255/max(iWarp(:)));
    
    %save the file
    switch lower(ext)
        case {'tif','tiff'}
            imwrite(uint8(iWarp),strcat(fname,'_d_',int2str(k),'.',ext),'tif');
        case 'bmp'
            imwrite(uint8(iWarp),strcat(fname,'_d_',int2str(k),'.',ext),'bmp')
        case 'gif'
            imwrite(uint8(iWarp),strcat(fname,'_d_',int2str(k),'.',ext),'gif')
        case {'jpg','jpeg'}
            imwrite(uint8(iWarp),strcat(fname,'_d_',int2str(k),'.',ext),'jpg')
        case 'png'
            imwrite(uint8(iWarp),strcat(fname,'_d_',int2str(k),'.',ext),'png')            
    end
    
    %write the segmentation
    if (~(strcmp(segmentation,'0')) && WarpedImage)

        
        %scale segmentation
        DeformedSeg = DeformedSeg - min(DeformedSeg(:));
        DeformedSeg = DeformedSeg*(255/max(DeformedSeg(:)));
        
        switch lower(segext)
            case {'tif','tiff'}
                imwrite(uint8(DeformedSeg),strcat(segfname,'_s_',int2str(k),'.',ext),'tif');
            case 'bmp'
                imwrite(uint8(DeformedSeg),strcat(segfname,'_s_',int2str(k),'.',ext),'bmp')
            case 'gif'
                imwrite(uint8(DeformedSeg),strcat(segfname,'_s_',int2str(k),'.',ext),'gif')
            case {'jpg','jpeg'}
                imwrite(uint8(DeformedSeg),strcat(segfname,'_s_',int2str(k),'.',ext),'jpg')
            case 'png'
                imwrite(uint8(DeformedSeg),strcat(segfname,'_s_',int2str(k),'.',ext),'png')            
        end
        
    end
    

end


end
