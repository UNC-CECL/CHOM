% function [A_NOF,A_OF,A_OF_msd,MMT]=calculate_evaluate_dunes(ACOM,M,MMT,X_NOF,X_OF,X_OF_msd,A_NOF,A_OF,A_OF_msd);
function [A_NOF,A_OF,MMT]=calculate_evaluate_dunes(ACOM,M,MMT,X_NOF,X_OF,A_NOF,A_OF);

t                        = M.time;

% I_msd=ACOM.I_msd;
I_OF=ACOM.I_OF;
I_own=ACOM.I_own;

% everything from here \/
deltadune = MMT.h0 - MMT.h_dune(t);

Llength                  = MMT.lLength;
sandcost                 = MMT.sandcost;
width                    = 4;
sandvolume               = Llength*width*deltadune;
% to here /\ should be dealt with when coupling

fixedcost                = MMT.fixedcost_dune;
var_cost                 = sandvolume*sandcost + fixedcost;
tc_peryear               = var_cost*MMT.delta_disc*(1+MMT.delta_disc)^MMT.amort/((1+MMT.delta_disc)^MMT.amort-1); % loan amortization

tau_add = (MMT.amort)*tc_peryear/sum(MMT.taxratio_OF*I_OF.*X_OF.price(t-1) + (1-I_OF)*X_NOF.price(t-1));

tax_burden = (MMT.amort)*(tau_add*(1-I_OF)*X_NOF.price(t-1) + MMT.taxratio_OF*tau_add*I_OF.*X_OF.price(t-1));

SV = [];
X_NOF_nodune      = X_NOF;
X_OF_nodune       = X_OF;
ACOM_nodune       = ACOM;
[X_NOF_nodune]    = calculate_risk_premium(ACOM_nodune,A_NOF,M,X_NOF_nodune,MMT);
[X_OF_nodune]     = calculate_risk_premium(ACOM_nodune,A_OF,M,X_OF_nodune,MMT);

[X_NOF_nodune]    = calculate_user_cost(M,X_NOF_nodune,X_NOF_nodune.WTP{t},A_NOF.tau_prop(t));  % real estate market calculation - determine current price, rent, and investor market share
[X_OF_nodune]     = calculate_user_cost(M,X_OF_nodune,X_OF_nodune.WTP{t},A_OF.tau_prop(t));     % real estate market calculation - determine current price, rent, and investor market share

X_NOF_dune       = X_NOF;
X_OF_dune        = X_OF;
ACOM_dune        = ACOM;
ACOM_dune.Edh(t) = MMT.h0;
[X_NOF_dune]     = calculate_risk_premium(ACOM_dune,A_NOF,M,X_NOF_dune,MMT);
[X_OF_dune]      = calculate_risk_premium(ACOM_dune,A_OF,M,X_OF_dune,MMT);

[X_NOF_dune]     = calculate_user_cost(M,X_NOF_dune,X_NOF_dune.WTP{t},A_NOF.tau_prop(t)+tau_add);  % real estate market calculation - determine current price, rent, and investor market share
[X_OF_dune]      = calculate_user_cost(M,X_OF_dune,X_OF_dune.WTP{t},A_OF.tau_prop(t)+MMT.taxratio_OF*tau_add);     % real estate market calculation - determine current price, rent, and investor market share

dune_plan(1,1)   = X_NOF_dune.price(t);
dune_plan(2,1)   = X_OF_dune.price(t);
dune_plan(1,2)   = X_NOF_nodune.price(t);
dune_plan(2,2)   = X_OF_nodune.price(t);

price_list=zeros(ACOM.n_agent_total,2);
price_list(1:ACOM.n_NOF,1)=dune_plan(1,1);
price_list(ACOM.n_NOF+1:ACOM.n_NOF+ACOM.n_OF,1)=dune_plan(2,1);
price_list(1:ACOM.n_NOF,2)=dune_plan(1,2);
price_list(ACOM.n_NOF+1:ACOM.n_NOF+ACOM.n_OF,2)=dune_plan(2,2);

for i = 1:ACOM.n_agent_total
    if I_own(i) == 1 & MMT.nourishtime(t+1) == 1
        price_increase = price_list(i,1) - price_list(i,2);
        if tax_burden(i) < price_increase
            vote(i) = 1;
        else
            vote(i) = 0;
        end
    else
        vote(i) = 0;
    end
end

if sum(vote/ACOM.n_agent_total)>0.5
    MMT.builddunetime(t+1) = 1;
    A_NOF.tau_prop(t+1:t+MMT.amort)    = A_NOF.tau_prop(t+1:t+MMT.amort)+tau_add;
    A_OF.tau_prop(t+1:t+MMT.amort)     = A_OF.tau_prop(t+1:t+MMT.amort)+MMT.taxratio_OF*tau_add;
end




