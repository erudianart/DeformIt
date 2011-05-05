%% Here we generate M-1 shapes using the Combined-Model of FEM and PDM.
%%function [dx,dy] = ShapeGeneration(OrgShape,M,alpha1,t);
function [dx,dy,dz] = ShapeGeneration(OrgShape,M,alpha1,t);

x(:,1) = OrgShape;
L = length(x(:,1))/3;


for m=1:M
   
    if m == 1
        x_hat = x;
    else
        x_hat = sum(x')'/m;
    end
    
    
    PDM_sum = zeros(3*L,3*L);
    FEM_sum = 0;
    
    for i=1:m
        
        PDM_sum = PDM_sum + ((x(:,i)-x_hat)*(x(:,i)-x_hat)');
       
        [PHI,DELTA] = FEM_parameters(x(:,i));
        FEM_sum = FEM_sum + (PHI*DELTA*PHI');      
        
    end
    
    if m == 1
        PDM = zeros(3*L,3*L);
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
Z = x((2*L)+1:3*L,:);

for i = 1 : M
    dx(:,i) = X(:,i) - X(:,1);
    dy(:,i) = Y(:,i) - Y(:,1);
    dz(:,i) = Z(:,i) - Z(:,1);
end






% 
% 
% 
% 
% 
% % Initialization
% x(:,1) = OrgShape;
% %%L = length(x(:,1))/2;
% L = length(x(:,1))/3;
% m = 1;
% G = 0;
% 
% % Generating M shapes
% while m < M
%     
%     % Calculating PDM term of covariance matrix Sc
%     
%     if (m == 1)
%         x_hat = x;
%         %%Sc_PDM = zeros(2*L,2*L);
%         Sc_PDM = zeros(3*L,3*L);
%     else
%         x_hat = sum(x')'/m;
%         %%S = zeros(2*L,2*L);
%         S = zeros(3*L,3*L);
%         for (i = 1 : m)
%             S = S + (x(:,i)-x_hat) * (x(:,i)-x_hat)';
%         end
%         Sc_PDM = S/(m-1);
%     end
%     
%     for (q = 1 : m)
%         % Calculating FEM term of Sc
%         [Phi_new, Delta_new] = FEM_parameters(x(:,q));
%         G = G + Phi_new * Delta_new * Phi_new';
%     end
%     Sc_FEM = (alpha1/m) * (G/m);
%     G = 0;
%     
%     % Calculating the Combined-Method covariance matrix
%     Sc = Sc_PDM + Sc_FEM;
%     
%     % Generating new shape using PCA
%     [COEFF, latent] = pcacov(Sc);
%     P = COEFF(:,1:t);
%     b = 2*sqrt(latent(1:t)) .* (2*rand(t,1)-ones(t,1));
%     x_new = x_hat + P*b;
%     x = [x,x_new];
%     m = m + 1;
% end
% out = x;
% 
% X = x(1:L,:);  
% Y = x(L+1:2*L,:);
% Z = x((2*L)+1:3*L,:);
% 
% for i = 1 : M
%     dx(:,i) = X(:,i) - X(:,1);
%     dy(:,i) = Y(:,i) - Y(:,1);
%     dz(:,i) = Z(:,i) - Z(:,1);
% end
