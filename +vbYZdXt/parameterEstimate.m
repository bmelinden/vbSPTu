function P=parameterEstimate(W,varargin)
% P=parameterEstimate(W)
% varational parameter averages 
% p0        : initial state probability
% A         : transition matrix
% lambda    : step length variance
% D         : diffusion coefficient
% pOcc      : occupancy
% dwellSteps: mean dwell time [timesteps]
% dwellTime : mean dwell time [time]
% optional input: 
%       parameterEstimate(W,dt,'stateRMS',v) computes the average RMS
%       error for every state, by combining the localization variance v
%       with the estimated state occupancy. The result is written to the
%       field RMSerr.


k=0;
rmsEstimate=false;
while(k<nargin-2)
    k=k+1;
    if(strcmpi(varargin{k},'stateRMS'))
        k=k+1;
        datV=varargin{k};
        rmsEstimate=true;
    else
        error(['Argument ' varargin{k} ' not recognized.'])
    end
end


% initial state probability
P.p0=rowNormalize(W.P.wPi);
% state change probabilities, <ln(a)>, <ln(1-a)>
wa0=sum(W.P.wa,2);
a  =rowNormalize(W.P.wa);
a=a(:,1);
% conditional jump probabilities, <lnB>, with zeros on the diagonal
B  = rowNormalize(W.P.wB);
P.A=diag(1-a)+(a*ones(1,W.numStates)-diag(a))+B; % <A>

% step length variance
P.lambda =W.P.c./(W.P.n-1); % <1/lambda>
P.D=P.lambda/2/W.timestep;

% dwell time and occupancy
P.pOcc=rowNormalize(sum(W.S.pst,1));
P.dwellSteps=1./a;
P.dwellTime=P.dwellSteps*W.timestep;

if(rmsEstimate)
   P.RMSerr=zeros(1,W.numStates);
   ind=isfinite(datV(:,1));
   for k=1:W.numStates
      P.RMSerr(k)= sqrt(sum(mean(datV(ind,:),2).*W.S.pst(ind,k))/sum(W.S.pst(ind,k)));
   end   
end

