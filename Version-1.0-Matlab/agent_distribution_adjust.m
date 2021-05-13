function [A,X,SV] = agent_distribution_adjust(ACOM,A,X,M,SV,OF,MMT);

beta_x = A.beta_x;
a = 2; b = 2;
denom = gamma(a)*gamma(b)/gamma(a+b);

if beta_x<0.05 | beta_x >0.95
    a_dist1 = A.adjust_beta_x*((beta_x^(a-1)*(1-beta_x)^(b-1))/denom);
    a_dist2     = a_dist1;
else
    a_dist1 = A.adjust_beta_x;
    a_dist2 = a_dist1;
end

t           = M.time;
Price       = X.price(t);

if OF==1
    P_e     = M.P_e_OF(t);
else
    P_e     = M.P_e_NOF(t);
end

ddist1       = a_dist1*(Price - P_e);
ddist2       = a_dist2*(P_e - Price);
W            = 1./(1+ A.beta_x_feedbackparam*(Price-P_e).^2);
A.beta_x     = beta_x + ddist1*W + ddist2*(1-W);
SV.ddist1(t) = ddist1;
SV.ddist2(t) = ddist2;
SV.W(t)      = W;

[tau_o,WTP_base,rp_base,WTP_alph] = agent_distribution(A.rcov,A.range_WTP_base,A.range_WTP_alph,A.range_tau_o,A.range_rp_base,A.beta_x,size(X.rp_o,1)); % generate agent variables

[rp_base_sorted,I] = sort(rp_base);
A.I_realist = zeros(length(rp_base),1);
A.I_realist(I(end-round(length(rp_base)*A.frac_realist)+1:end))=1;

X.WTP_base   = WTP_base;
X.WTP_alph   = WTP_alph;
X.tau_o      = tau_o;
X.rp_base    = rp_base;
[X]          = calculate_risk_premium(ACOM,A,M,X,MMT);

[rp_base_sorted,I] = sort(rp_base);
A.I_realist=zeros(length(rp_base),1);
A.I_realist(I(end-round(length(rp_base)*A.frac_realist)+1:end))=1;
 