function [A_NOF,A_OF,MMT]=calculate_evaluate_dunes(ACOM,M,MMT,X_NOF,X_OF,A_NOF,A_OF);

t                        = M.time;

I_OF  = ACOM.I_OF;  % used for voting on plan
I_own = ACOM.I_own;

% everything from here \/
deltadune         = MMT.h0 - MMT.h_dune(t);
Llength           = MMT.lLength;
sandcost          = MMT.sandcost;
dune_depth        = 25;
sandvolume        = Llength*dune_depth*deltadune;
% to here /\ should be dealt with when coupling

fixedcost         = MMT.fixedcost_dune;
var_cost          = sandvolume*sandcost;
cost              = (1-MMT.nourish_subsidy) * (fixedcost + var_cost);
tc_peryear        = cost * MMT.delta_disc*(1+MMT.delta_disc)^MMT.amort/((1+MMT.delta_disc)^MMT.amort-1); % loan amortization

tau_add           = (MMT.amort)*tc_peryear/sum(MMT.taxratio_OF*I_OF.*X_OF.price(t-1) + (1-I_OF)*X_NOF.price(t-1));
tax_burden        = (MMT.amort)*(tau_add*(1-I_OF)*X_NOF.price(t-1) + MMT.taxratio_OF*tau_add*I_OF.*X_OF.price(t-1));

% create copies of system state to keep separate
X_OF_nodune       = X_OF;
X_OF_dune         = X_OF;
X_NOF_nodune      = X_NOF;
X_NOF_dune        = X_NOF;
MMT_nodune        = MMT;
MMT_dune          = MMT;
MMT_dune.h_dune(t)= MMT.h0;

% no dune case, calculate risk premium, feed into user cost
[X_NOF_nodune]    = calculate_risk_premium(A_NOF,M,X_NOF_nodune,MMT_nodune,0);
[X_NOF_nodune]    = calculate_user_cost(M,X_NOF_nodune,X_NOF.WTP{t},A_NOF.tau_prop(t)); 

[X_OF_nodune]     = calculate_risk_premium(A_OF,M,X_OF_nodune,MMT_nodune,1);
[X_OF_nodune]     = calculate_user_cost(M,X_OF_nodune,X_OF.WTP{t},A_OF.tau_prop(t));     

% with dunes built case, calculate risk premium, feed into user cost
[X_NOF_dune]       = calculate_risk_premium(A_NOF,M,X_NOF_dune,MMT_dune,0);
[X_NOF_dune]       = calculate_user_cost(M,X_NOF_dune,X_NOF_dune.WTP{t},A_NOF.tau_prop(t)+tau_add);  

[X_OF_dune]        = calculate_risk_premium(A_OF,M,X_OF_dune,MMT_dune,1);
[X_OF_dune]        = calculate_user_cost(M,X_OF_dune,X_OF_dune.WTP{t},A_OF.tau_prop(t)+MMT.taxratio_OF*tau_add);    

NOF_index                 = [1 : ACOM.n_NOF];
OF_index                  = [ACOM.n_NOF+1 : ACOM.n_NOF+ACOM.n_OF];
price_increase(NOF_index) = X_NOF_dune.price(t) - X_NOF_nodune.price(t);
price_increase(OF_index)  = X_OF_dune.price(t) - X_OF_nodune.price(t);

for i = 1:ACOM.n_agent_total
    if I_own(i) == 1
        if price_increase(i) - tax_burden(i) > 0 
            vote(i) = 1;
        else
            vote(i) = 0;
        end
    else
        vote(i) = 0;
    end
end

if sum(vote)/sum(I_own)>0.5 & MMT.nourishtime(t+1) == 1 % changed 6/8 
% if sum(vote/ACOM.n_agent_total)>0.5 & MMT.nourishtime(t+1) == 1
    MMT.builddunetime(t+1)          = 1;
    A_NOF.tau_prop(t+1:t+MMT.amort) = A_NOF.tau_prop(t+1:t+MMT.amort)+tau_add;
    A_OF.tau_prop(t+1:t+MMT.amort)  = A_OF.tau_prop(t+1:t+MMT.amort)+MMT.taxratio_OF*tau_add;
end

% % % for debug 
% sprintf('pct. owner share = %f',round(100*sum(I_own)/ACOM.n_agent_total,1))
% sprintf('pct. price increase > tax burden = %f',round(100*length(find(price_increase-tax_burden>0))/ACOM.n_agent_total,1))
% sprintf('pct. vote yes = %f',round(100*sum(vote)/ACOM.n_agent_total,1))
% sprintf('nourish = %d, builddune = %d',MMT.nourishtime(t+1),MMT.builddunetime(t+1))
% pause
