%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @file FEM_parameters.m
% @author Preet S. Jassi (sorta...)
% @date July, 31th 2008
% @provides Phi and Delta to the FEM, experimentation with augmentation
% matrix Q
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Phi, Delta] = FEM_parameters(x)

L = length(x)/2; % Number of Landmarks
X = x(1:L);
Y = x(L+1:2*L);



% Calculating the elements of Matrix K
A=zeros(L,L);   B=zeros(L,L);
C=zeros(L,L);   D=zeros(L,L);

for(i = 1 : L)
    for(j = 1 : L)
        if (i == j)
            A(i,j) = 1;
            D(i,j) = 1;
            C(i,j) = 0;
                       
        else
            A(i,j) = (X(i)-X(j))^2 / ((X(i)-X(j))^2 + (Y(i)-Y(j))^2);
            D(i,j) = (Y(i)-Y(j))^2 / ((X(i)-X(j))^2 + (Y(i)-Y(j))^2); %should be D?
            C(i,j) = (X(i)-X(j))*(Y(i)-Y(j)) / ((X(i)-X(j))^2 + (Y(i)-Y(j))^2);
            

        end
        
    end
end

B = C';
K = [A,B;C,D];


[Phi,Omega] = eig(K);
Delta = inv(Omega);

