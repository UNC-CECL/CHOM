function [tau_o,WTP_base,rp_base,WTP_alph]=agent_distribution(rcov,range_WTP_base,range_WTP_alph,range_tau_o,range_rp_base,beta_x,n)

% beta distribution max/min parameter values
beta_max = 10.5;
beta_min = 2;

bline2   = -(beta_max-beta_min)*beta_x+beta_max;
bline1   =  (beta_max-beta_min)*beta_x+beta_min;

% bline2   = -beta_x+(beta_max+beta_min);
% bline1   =  beta_x;
% covariances 
r12 = rcov;
r13 = rcov;
r14 = rcov;
r23 = 0.9;
r24 = rcov;
r34 = rcov;

Rho =  [1 r12 r13 r14;
        r12 1 r23 r24;
        r13 r23 1 r34;
        r14 r24 r34 1];
U = copularnd('Gaussian',Rho,n);
X = [betainv(U(:,1),bline1,bline2) betainv(U(:,2),bline1,bline2) betainv(U(:,3),bline1,bline2) betainv(U(:,4),bline1,bline2)];

tau_o    = X(:,1);
WTP_base = X(:,2);
WTP_alph = X(:,3);
rp_base  = X(:,4);

% rescale to property intervals
tau_o=tau_o*(range_tau_o(2)-range_tau_o(1));
tau_o=tau_o+range_tau_o(1);

WTP_base=WTP_base*(range_WTP_base(2)-range_WTP_base(1));
WTP_base=WTP_base+range_WTP_base(1);

WTP_alph=WTP_alph*(range_WTP_alph(2)-range_WTP_alph(1));
WTP_alph=WTP_alph+range_WTP_alph(1);

rp_base=rp_base*(range_rp_base(2)-range_rp_base(1));
rp_base=rp_base+range_rp_base(1);
