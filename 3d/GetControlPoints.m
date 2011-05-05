%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file GetControlPoints.m
% @author Preet S. Jassi
% @modified October 3 2008
% @description get control points for deformation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Frx,Fry,Frz] = GetControlPoints(imszx, imszy, imszz, cp, RandomMorph, Ansio);


        
    %margin
    mg = 0.05;

    if (~(RandomMorph))

        if (~(Ansio))

          %we are not scaling so we create a cube of control points
          %somewhere randomly in the image

           mindim = min([imszx, imszy, imszz]);

           startx = floor(rand()*(imszx - mindim));
           starty = floor(rand()*(imszy - mindim));
           startz = floor(rand()*(imszz - mindim));

           [Frx,Fry,Frz] = meshgrid(linspace(startx,(1-mg)*(startx+mindim),cp),linspace(starty,(1-mg)*(starty+mindim),cp),linspace(startz,(1-mg)*(startz+mindim),cp));

        else 

          %create a space, linearly distributed
          [Frx,Fry,Frz]=meshgrid(linspace(imszx*mg,(1-mg)*imszx,cp),linspace(imszy*mg,(1-mg)*imszy,cp),linspace(imszz*mg,(1-mg)*imszz,cp));  

        end

    else

        %create it - linearly distributed
        [Frx,Fry,Frz]=meshgrid(linspace(imszx*mg,(1-mg)*imszx,cp),linspace(imszy*mg,(1-mg)*imszy,cp),linspace(imszz*mg,(1-mg)*imszz,cp));

    end

    %transpose them I guess..
    Frx=Frx(:)';    Fry=Fry(:)'; Frz=Frz(:)';
   

end