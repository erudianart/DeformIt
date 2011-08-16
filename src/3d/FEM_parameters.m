function [Phi, Delta] = FEM_parameters(x);

L = length(x)/3; % Number of Landmarks
X = x(1:L);
Y = x(L+1:2*L);
Z = x(2*L+1:3*L);

% Calculating the elements of Matrix K
%%A=zeros(L,L);   B=zeros(L,L);
%%C=zeros(L,L);   D=zeros(L,L);

Kxx=zeros(L,L); Kxy=zeros(L,L); Kxz=zeros(L,L);
Kyx=zeros(L,L); Kyy=zeros(L,L); Kyz=zeros(L,L);
Kzx=zeros(L,L); Kzy=zeros(L,L); Kzz=zeros(L,L);


%% kxxij = dxij^2/dij^2, 
%% kyyij = dyij^2/dij^2, 
%% kzzij = dzij^2/dij^2
%% kxyij = (dxij)(dyij)/dij^2j, 
%% kxzij = (dxij)(dyij)/dij^2, 
%% kyzij = (dyij)(dzij)/dij^2
%%
%%
%% where dxij = xi-xj
%% dij^2 = dxij^2 + dyij^2 + dzij^2


for(i = 1 : L)
    for(j = 1 : L)
        if (i == j)
            Kxx(i,j) = 1;
            Kyy(i,j) = 1;
            Kzz(i,j) = 1;
            Kxy(i,j) = 0;
            Kxz(i,j) = 0;
            Kyz(i,j) = 0;
        else

            dxij = X(i)-X(j);
            dyij = Y(i)-Y(j);
            dzij = Z(i)-Z(j);
            
            dijSquared = ((dxij)^2) + ((dyij)^2) + ((dzij)^2);
            
            
            Kxx(i,j) = (dxij)^2 / dijSquared;
            Kyy(i,j) = (dyij)^2 / dijSquared;
            Kzz(i,j) = (dzij)^2 / dijSquared;
            Kxy(i,j) = (dxij)*(dyij) / dijSquared;
            Kxz(i,j) = (dxij)*(dzij) / dijSquared;
            Kyz(i,j) = (dyij)*(dzij) / dijSquared;
        end
    end
end


Kyx = Kxy';
Kzx = Kxz';
Kzy = Kyz';

K = [Kxx,Kyx,Kzx;Kxy,Kyy,Kzy;Kxz,Kyz,Kzz];

[Phi,Omega] = eig(K);
Delta = inv(Omega);