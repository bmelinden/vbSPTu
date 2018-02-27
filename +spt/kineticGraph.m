% spt.kineticGraph(A,dA,D,dD,AijMin,nd,nde)
% Use the digraph matlab function to visualize the kinetic model, based on
% A     : transition matrix
% dA    : std.err of A (optional)
% D     : diffusion constants (one for each row in A)
% dD    : std. err. off D (optional)
% AijMin: transition threshold; A-elements < AijMin are not shown. 
%         Default 1e-6
% nd    : number of digits to display for A,D-values   (default 3)
% nde   : number of digits to display for dA,dD-values (default 2)
%
% The graph is plotted in the currently active plot figure, which is
% cleared first.

function kineticGraph(A,dA,D,dD,AijMin,nd,nde)

% parameters and default values
if(~exist('AijMin','var') || isempty(AijMin))
    AijMin=1e-6;
end
if(~exist('nd','var') || isempty(nd))
    nd=3;
end
if(~exist('nde','var') || isempty(nde))
    nde=2;
end

if(~exist('dD','var'))
    dD=[];
end
if(~exist('dA','var'))
    dA=[];
end

% plot the graph
A0=A-diag(diag(A)); % transition matrix, off-diagonal part
A0(A0<AijMin)=0;
G=digraph(A0);
LW=G.Edges.Weight;

% reduce number of significant digits in transition weights and diffusion
% constants
hold off
GP=plot(G,'linewidth',10*LW/max(LW),'edgelabel',LW,...
    'nodelabel',D);
title('diffusive states and transition probabilities')
% improve some lables
N=size(A0,1);
nd =3; % number of digits in the labels
nde=2; % number of digits in std. errors
for k=1:N
    if(~isempty(dD))
        GP.NodeLabel{k}=['D' int2str(k) '=' num2str(D(k),nd) '+-' num2str(dD(k),nde)];
    else
        GP.NodeLabel{k}=['D' int2str(k) '=' num2str(D(k),nd)];
    end
end

ne=0;
for r=1:N
    for c=1:N
        if(A0(r,c)>0) % then a node exists
            ne=ne+1;
            if(~isempty(dA))
                GP.EdgeLabel{ne}=[num2str(A0(r,c),nd) '+-' num2str(dA(r,c),nde)];
            else
                GP.EdgeLabel{ne}=num2str(A0(r,c),nd);
            end
            
        end
    end
end
axis off
