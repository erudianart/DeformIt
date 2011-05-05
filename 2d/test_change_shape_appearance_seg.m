%% to do
% make it work for non square images



%% clean up
close all;clear all



%% initialization
file = 'O1451U10X.tif';
sz=10;%sqaure size in checkerboard
cp=6;%num of control points (along x = along y) grid of cp*cp
mg=.05;%margin boundary
%Im=checkerboard(sz);

fileinfo = imfinfo(file);
ext = fileinfo(1).Format;
fname = fileinfo(1).Filename;

Im=double(imread(file));


Iseg=double(imread('O1451U10X_12042006.tif'));
Im=Im(70:149,85:164); %not sure why we are slicing this..
Iseg=Iseg(70:149,85:164); %same with this
%%%% add landmarks and see where they move to
%%%% add noise

Imax=max(Im(:));
iWarpRange=0.5*Imax;
imsz=size(Im,1);
nObs=1;%number of hi-D observations. includes an extra one for testing

%% Generating the observations 
%  spatial transformation (change in control point locations)
%  and corresponsing warped images


%%% preload
% load warps_xforms
if 0
 load cc_warps_xforms.mat 
%%% or generate
else
    warps=[];
    xforms=[];
    iwarps=[];
    segs=[];
    %create arrays Frx and Fry of cp number of vectors from mg*imgz to
    %(1-mg)*imgz
    [Frx,Fry]=meshgrid(linspace(imsz*mg,(1-mg)*imsz,cp),linspace(imsz*mg,(1-mg)*imsz,cp));
    %create arrays imIx and imIy from cp vectors from 1 to imsz
    [imIx,imIy]=meshgrid(linspace(1,imsz,cp),linspace(1,imsz,cp));
    %create arrays imx imy from 1 to imsz
    [imx,imy]=meshgrid(1:imsz,1:imsz);
    
    for k=1:nObs,
        di=iWarpRange*(rand(size(imIx))-0.5);
        %add  additional intensity values to the warped
        %images to mimic the non-uniformity seen in MR machines (google/images inhomogeneity  MRI)
        [intensityWarp] = interp2(imIx,imIy,di,imx,imy,'cubuc');

        dx=2*imsz*mg*rand(size(Frx))-imsz*mg; %create change in x
        dy=2*imsz*mg*rand(size(Fry))-imsz*mg; %random change in y
                
        %transpose them I guess..
        Frx=Frx(:)';    Fry=Fry(:)';
        dx=dx(:)';    dy=dy(:)';

        %create blank matricies
        Fr=zeros(1,length(Frx)*2);
        To=zeros(1,length(Frx)*2);
        dcp=zeros(1,length(Frx)*2);

        %not sure what the hell this does
        %start at 1
        %step by 2
        %to end
        Fr(1:2:end)=Frx;    Fr(2:2:end)=Fry;
        dcp(1:2:end)=dx;    dcp(2:2:end)=dy;
        To(1:2:end)=Frx;    To(2:2:end)=Fry;

        To=To+dcp;
        
        %deform image - add noise
        [DeformedIm, X, Y] = DeformImage(Im, Fr,To,'gaussian');
        
        %deform segmentation, do not add noise
        DeformedSeg=DeformImage(Iseg, Fr,To,'');
        iWarp=DeformedIm+intensityWarp;
        
        if 1 %plotting
            clf
            subplot(321);imagesc(Im);colormap gray;axis image;title('orig img + from/to ctrl pts')
            hold on; plot(Fr(2:2:end),Fr(1:2:end),'y.');
            hold on; plot(To(2:2:end),To(1:2:end),'g.');
            subplot(322);imagesc(DeformedIm);colormap gray;axis image;title('sp. warped img + from/to')
            hold on; plot(Fr(2:2:end),Fr(1:2:end),'y.');
            hold on; plot(To(2:2:end),To(1:2:end),'g.');
            hold off
            subplot(323);imagesc(intensityWarp);colormap gray;axis image;title('intensity change')
            subplot(324);imagesc(iWarp);colormap gray;axis image;title('sp and int. warped img')
            subplot(325);imagesc(Iseg);colormap gray;axis image;title('segmentation')
            subplot(326);imagesc(DeformedSeg);colormap gray;axis image;title('warped segmentation')
            drawnow
            pause
        end

        
        %save the file
        switch lower(ext)
            case {'tif','tiff'}
                imwrite(uint8(DeformedIm),STRCAT(fname,'_d_',int2str(k),'.',ext),'tif');
            case 'bmp'
                imwrite(uint8(DeformedIm),STRCAT(fname,'_d_',int2str(k),'.',ext),'bmp')
            case 'gif'
                imwrite(uint8(DeformedIm),STRCAT(fname,'_d_',int2str(k),'.',ext),'gif')
            case {'jpg','jpeg'}
                imwrite(uint8(DeformedIm),STRCAT(fname,'_d_',int2str(k),'.',ext),'jpg')
            case 'png'
                imwrite(uint8(DeformedIm),STRCAT(fname,'_d_',int2str(k),'.',ext),'png')
            
        end
        
        %a=[1 2;3 4] , a=a(:), reshape(a,[2 2])
        warps=[warps,DeformedIm(:)];
        xforms=[xforms,dcp'];
        iwarps=[iwarps,di(:)]; %intensity warp
        segs=[segs;DeformedSeg(:)];
    end

    %replace NaNs by zeros
    warps(isnan(warps))=0;
    %save cc_warps_xforms.mat warps xforms
end
