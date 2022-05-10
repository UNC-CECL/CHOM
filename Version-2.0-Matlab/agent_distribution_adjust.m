function [A,X,SV] = agent_distribution_adjust(ACOM,A,X,M,SV,OF,MMT);
% OF = 1 ;
% X  = X_OF;
% A=A_OF;

beta_x  = A.beta_x;
t       = M.time;
price   = X.price;
P_e     = X.P_e;

cutoff1 = 0.2;
cutoff2 = 0.8;

if beta_x < cutoff1 & beta_x >= 0
    switching_speed = beta_x*(A.adjust_beta_x)/cutoff1; % this is the speed of the willingness to pay fluxes, arbitrage component 
end
if beta_x > cutoff2 & beta_x <= 1
    switching_speed = -(A.adjust_beta_x/cutoff1)*beta_x+A.adjust_beta_x/cutoff1;
end
if beta_x>=cutoff1 & beta_x<=cutoff2
    switching_speed=A.adjust_beta_x;
end

% change in outside market price will increase willingness to pay distribution bounds
dP_e    = (X.P_e(t)-X.P_e(t-1))/X.P_e(t-1);
    
if dP_e > 0 
    A.range_WTP_base(2) = dP_e * A.range_WTP_base(2) +A.range_WTP_base(2);
    A.range_WTP_alph(2) = dP_e *A.range_WTP_alph(2) +A.range_WTP_alph(2);
end

W         = 1./(1+ A.agent_flux_sensitivity_param*(price(t)-P_e(t)).^2);
beta_x    = beta_x + W*switching_speed*(price(t) - P_e(t)) +(1-W)* switching_speed*(P_e(t) - price(t));
if beta_x>1     % newly added 4/28
    beta_x=1;
end
if beta_x < 0  % newly added 4/28
    beta_x=0;
end

[tau_o,WTP_base,rp_base,WTP_alph] = agent_distribution(A.rcov,A.range_WTP_base,A.range_WTP_alph,A.range_tau_o,A.range_rp_base,beta_x,size(X.rp_o,1),A.distribution_peakiness); % generate agent variables


X.WTP_base   = WTP_base;
X.WTP_alph   = WTP_alph;
X.tau_o      = tau_o;
    
X.rp_base    = rp_base;
[X]          = calculate_risk_premium(A,M,X,MMT,OF);
A.beta_x     = beta_x;

