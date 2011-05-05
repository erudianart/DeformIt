%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file GenerateDeformedAndSegmentedImages.m
% @author Preet S. Jassi (sorta...)
% @date July, 31th 2008
% @description the brains for deforming a bunch of images..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Here we generate M-1 shapes using the Combined-Model of FEM and PDM.

function [dx,dy] = ShapeGeneration(OrgShape,M,alpha1,t)

x(:,1) = OrgShape;
L = length(x(:,1))/2;


for m=1:M
   
    if m == 1
        x_hat = x;
    else
        x_hat = sum(x')'/m;
    end
    
    
    PDM_sum = zeros(2*L,2*L);
    FEM_sum = 0;
    
    for i=1:m
        
        PDM_sum = PDM_sum + ((x(:,i)-x_hat)*(x(:,i)-x_hat)');
        
        %if we want a value to be zero (X or Y) then we set its 
        %corresponding row in PHI to zero.
        [PHI,DELTA] = FEM_parameters(x(:,i));
        FEM_sum = FEM_sum + (PHI*DELTA*PHI');      
        
    end
    
    if m == 1
        PDM = zeros(2*L,2*L);
    else
        PDM = PDM_sum/(m-1);
    end
    
    FEM = (alpha1/m)*(FEM_sum/m);
    Sc = PDM + FEM;

    [COEFF, latent, explained] = pcacov(Sc);
    
    if t < 1
        higher = find(cumsum(explained)>=t*100);
        t = higher(1);
    end
    
    P = COEFF(:,1:t);
    b = 2*sqrt(latent(1:t)) .* (2*rand(t,1)-ones(t,1));
     
    x_new = x_hat + P*b;
    x = [x,x_new];    
       
end


X = x(1:L,:);  
Y = x(L+1:2*L,:);


for i = 1 : M
    dx(:,i) = X(:,i) - X(:,1);
    dy(:,i) = Y(:,i) - Y(:,1);
end
