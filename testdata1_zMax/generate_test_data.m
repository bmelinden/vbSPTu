% implement mle model search and cross-validation as a function taking a
% list of models as input

if(~exist('uSPThmm_setup','file'))
    addpath ../
    uSPThmm_setup
end
clear
%% model and parameters
savefile='data.mat';

% localization model
sig0=135; % nm PSF width in focus
L2z=300;  % quadratic PSF width doubling length
a=80; % px length
b2=1; % bg photons/pixel
Nph=250;
dt=5e-3;
tE=1.5e-3;
FaDsigZ=@(dz,D)(sqrt((sig0*(1+(dz/L2z).^2)).^2+a^2/12+1/3*D*tE)); % PSF width incl. px correction and blur widening
varXY=@(dz,D)( 2/Nph*FaDsigZ(dz,D).^2.*(16/9+8*pi*b2*FaDsigZ(dz,D)/Nph/a^2));

% kinetic model
% parameters
p0=ones(3,1)/3;
pE=0; %trajectories really are exp-distributed
D=[0.1 6 3]*1e6; % 
tDw=[1/20+1/20 1/6.7 1/8.6]
A0=1-1./(tDw/dt);
A=diag(A0)+[0 10*dt 0;0 0 6.7*dt;8.6*dt 0 0]; % transition matrix for 3-state tRNA cycle

tau   =tE/dt/2;
Rcoeff=tE/dt/6;
pM=0.01;     % fraction of missing data

% add localization errors afterwards 
RMSmean=0;%[1 1 1]*1e-6
RMSstd=0;%[1 1 1]*1E-6;

% amount of data
Ttrj=25;
Tmin=5;
Ntrj=50;
dim=2;
T=Tmin+round(-(Ttrj-Tmin)*log(rand(1,Ntrj))); % exp-distributed trajectory lengths >= 5
%% SPT trajectories within fixed z interval
[x,v,s,y,z]=spt.diffusiveHMM_blur_detach(p0,A,pE,D*dt,tE/dt,RMSmean,RMSstd,3,T,numel(T),pM);
% invert around z=+-400
zMax=350;
Dss=[0 D]';
dE=0.05; % RMSD estimation error (uniform)
for n=1:numel(x)
   x{n}(:,3)= x{n}(:,3)-zMax+2*rand*zMax;
   zk=x{n}(:,3);
   ii= find(abs(zk)>zMax,1);
   while(~isempty(find(abs(zk)>zMax,1)))
      if(zk(ii)>zMax)
          zk(ii:end)=zMax-(zk(ii:end)-zMax);
      elseif(zk(ii)<-zMax)
          zk(ii:end)=-zMax+(-zMax-zk(ii:end));       
      end
      ii= find(abs(zk)>zMax,1);
   end   
   Dk=Dss(s{n}+1);
   vk=varXY(zk,Dk);
   v{n}=vk*ones(1,dim);
   x{n}=x{n}(:,1:dim)+sqrt(v{n}).*randn(size(v{n})); % add actual errors
   ve{n}=v{n}.*(1+dE*(-1+2*rand(size(v{n})))).^2;    % RMS error estimate with 5% error
end
disp('z errors complete')
%% plot RMS histogram
mim=struct;mim.s=s;
X0=spt.preprocess(x,v,2,mim,5,false,inf);
clear mim
figure(1)
clf
hist(sqrt(X0.v(:,1)))
% create ground truth state probability array
pst=zeros(size(X0.misc.s,1),3);
for n=1:3
   pst(X0.misc.s==n,n)=1; 
end
clear X0

% save data

disp(['saving to ' savefile  ' ...'])
save(savefile,'D','A','p0','dt','tE','Rcoeff','tau','x','v','ve','s','pst','y','z')
disp('... done')
