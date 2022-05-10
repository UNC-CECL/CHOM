function [tau_o,WTP_base,rp_base,WTP_alph]=agent_distribution(rcov,range_WTP_base,range_WTP_alph,range_tau_o,range_rp_base,beta_x,n,distribution_peakiness)

% % for debug
% beta_x   = A_OF.beta_x;
% range_tau_o    = A_OF.range_tau_o
% range_WTP_base = A_OF.range_WTP_base
% range_WTP_alph = A_OF.range_WTP_alph
% range_rp_base  = A_OF.range_rp_base


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% method 1
%%%%%%%%%%%%%%%%%%%%%%%%%%

beta_min = .01;

bline2   = -(distribution_peakiness-beta_min)*beta_x+distribution_peakiness;
bline1   =  (distribution_peakiness-beta_min)*beta_x+beta_min;

% covariances 
r12 = rcov;
r13 = rcov;
r14 = rcov;
r23 = rcov;
r24 = rcov;
r34 = rcov;

Rho =  [1 r12 r13 r14;
        r12 1 r23 r24;
        r13 r23 1 r34;
        r14 r24 r34 1];
    
U = copularnd('Gaussian',Rho,n);
X = [betainv(U(:,1),bline1,bline2) betainv(U(:,2),bline1,bline2) betainv(U(:,3),bline1,bline2) betainv(U(:,4),bline1,bline2)];
% X = [betainv(U(:,1),bline1,bline2) betainv(U(:,2),bline1,bline2) betainv(U(:,3),bline1,bline2) betainv(U(:,4),2,2)];

tau_o    = X(:,1);
WTP_base = X(:,2);
WTP_alph = X(:,3);
rp_base  = 1-X(:,4); % rp is currently fixed and while correlated with WTP/tau_inc, does not adjust with the outside market

% rescale to property intervals
tau_o=tau_o*(range_tau_o(2)-range_tau_o(1));
tau_o=tau_o+range_tau_o(1);

WTP_base=WTP_base*(range_WTP_base(2)-range_WTP_base(1));
WTP_base=WTP_base+range_WTP_base(1);

WTP_alph=WTP_alph*(range_WTP_alph(2)-range_WTP_alph(1));
WTP_alph=WTP_alph+range_WTP_alph(1);

rp_base=rp_base*(range_rp_base(2)-range_rp_base(1));
rp_base=rp_base+range_rp_base(1);

% beta distribution max/min parameter values 
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% method 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% beta_min = .01;
% 
% bline2   = -(distribution_peakiness-beta_min)*beta_x+distribution_peakiness;
% bline1   =  (distribution_peakiness-beta_min)*beta_x+beta_min;
% 
% % covariances 
% r12 = rcov;
% r13 = rcov;
% r14 = rcov;
% r23 = rcov;
% r24 = rcov;
% r34 = rcov;
% 
% Rho =  [1 r12 r13 r14;
%         r12 1 r23 r24;
%         r13 r23 1 r34;
%         r14 r24 r34 1];
% U = copularnd('Gaussian',Rho,n);
% X = [betainv(U(:,1),bline1,bline2) betainv(U(:,2),bline1,bline2) betainv(U(:,3),bline1,bline2) betainv(U(:,4),bline1,bline2)];
% % X = [betainv(U(:,1),bline1,bline2) betainv(U(:,2),bline1,bline2) betainv(U(:,3),bline1,bline2) betainv(U(:,4),2,2)];
% 
% tau_o    = X(:,1);
% WTP_base = X(:,2);
% WTP_alph = X(:,3);
% rp_base  = 1-X(:,4); % rp is currently fixed and while correlated with WTP/tau_inc, does not adjust with the outside market

% % rescale to property intervals
% tau_o=tau_o*(range_tau_o(2)-range_tau_o(1));
% tau_o=tau_o+range_tau_o(1);
% 
% WTP_base=WTP_base*(range_WTP_base(2)-range_WTP_base(1));
% WTP_base=WTP_base+range_WTP_base(1);
% 
% WTP_alph=WTP_alph*(range_WTP_alph(2)-range_WTP_alph(1));
% WTP_alph=WTP_alph+range_WTP_alph(1);
% 
% rp_base=rp_base*(range_rp_base(2)-range_rp_base(1));
% rp_base=rp_base+range_rp_base(1);



% %%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% method 3
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% beta_min = .01;
% 
% bline2   = -(distribution_peakiness-beta_min)*beta_x+distribution_peakiness;
% bline1   =  (distribution_peakiness-beta_min)*beta_x+beta_min;
% 
% % covariances 
% r12 = rcov;
% r13 = rcov;
% r14 = rcov;
% r23 = rcov;
% r24 = rcov;
% r34 = rcov;
% 
% Rho =  [1 r12 r13 r14;
%         r12 1 r23 r24;
%         r13 r23 1 r34;
%         r14 r24 r34 1];
% U = copularnd('Gaussian',Rho,n);
% X = [betainv(U(:,1),bline1,bline2) betainv(U(:,2),bline1,bline2) betainv(U(:,3),bline1,bline2) betainv(U(:,4),bline1,bline2)];
% % X = [betainv(U(:,1),bline1,bline2) betainv(U(:,2),bline1,bline2) betainv(U(:,3),bline1,bline2) betainv(U(:,4),2,2)];
% 
% tau_o    = X(:,1);
% WTP_alph = X(:,3);
% rp_base  = 1-X(:,4); % rp is currently fixed and while correlated with WTP/tau_inc, does not adjust with the outside market
% 
% % rescale to property intervals
% tau_o=tau_o*(range_tau_o(2)-range_tau_o(1));
% tau_o=tau_o+range_tau_o(1);
% 
% WTP_alph=WTP_alph*(range_WTP_alph(2)-range_WTP_alph(1));
% WTP_alph=WTP_alph+range_WTP_alph(1);
% 
% rp_base=rp_base*(range_rp_base(2)-range_rp_base(1));
% rp_base=rp_base+range_rp_base(1);
% 
% a1 = [1000 20000];
% b1 = [9 10];
% 
% a=a1(1)+(a1(2)-a1(1))*rand(size(tau_o));
% b=b1(1)+(b1(2)-b1(1))*rand(size(tau_o));
% 
% WTP_base = (a.*exp(b.*tau_o))*(1/3);















% tbrack=[.10 .12 .22 .24 .32 .35 .37]
% income = [10000 20000; 20000 80000; 80000 171000; 171000 326000; 326000 414000; 414000 622000; 620000 1000000]
% plot(tbrack,income(:,1)); hold on; plot(tbrack,income(:,2))

% close all
% % plot(tbrack',mean(income,2))
% % hold on
% % f=fit(tbrack',mean(income,2),'exp1')
% 
% tau_o=linspace(0.1,0.37,600);
% a1 = [1000 20000];
% b1 = [9 10];
% 
% a=a1(1)+(a1(2)-a1(1))*rand(size(tau_o));
% b=b1(1)+(b1(2)-b1(1))*rand(size(tau_o));
% 
% WTP_base =(a.*exp(b.*tau_o))/3;
% 
% min(WTP_base)
% max(WTP_base)
% 
% plot(tau_o,WTP_base,'k.')
% hold on
% plot( tbrack',mean(income,2)/2,'linewidth',3)
% plot( tbrack',mean(income,2)/4,'linewidth',3)
% 
% 
% 
