function [Frx,Fry] = GetControlPoints(imszx, imszy, cp)
 
        %margin
        mg = 0.05;
        
        [Frx,Fry]=meshgrid(linspace(imszx*mg,(1-mg)*imszx,cp),linspace(imszy*mg,(1-mg)*imszy,cp));
        
        %transpose them I guess..
        Frx=Frx(:)';    Fry=Fry(:)'; 
   
end