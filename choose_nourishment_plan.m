function [BP,X] = choose_nourishment_plan(E,M,X,BP)

t=X.time;

for j = 1:11
    benefit(j)                   = BP.PropPrice_under_plan(j)-BP.PropPrice_under_plan(11);  % increase in house price from nourishment
    ben_min_taxburden(j)         = benefit(j)-BP.tax_burden(1,j)*E.amort;                   % increase (benefit) minus the total tax paid 
    nindx                        = 1:j:E.nourish_plan_horizon;
    BP.nourish_schedule(j,nindx) = BP.nourish_schedule(j,nindx)+1;
    BP.ben_min_taxburden(j)      = ben_min_taxburden(j);                                    % store benefits minus the taxburden
end

for j = 1:11
    if numel(find(BP.nourish_schedule(j,:)==2))>0
        BP.ben_min_taxburden(j) = -Inf;
    end
end

BP.ben_min_taxburden([1 10]) = -Inf;
X.nourishtimeold             = X.nourishtime;                       

if max(BP.ben_min_taxburden)>0 & X.nourishtime(t)+X.nourishtime(t-1)==0
    [~,beach_plan]            = max(BP.ben_min_taxburden);
    BP.beach_plan             = beach_plan;
    X.tau_prop(t+1:t+E.amort) = X.tau_prop(t+1:t+E.amort)+BP.tau_t(BP.beach_plan);
    X.nourishtime(t+1:BP.beach_plan:t+E.nourish_plan_horizon) = 1;
else
    BP.beach_plan = 11;
end

if sum(X.nourishtime) > sum(X.nourishtimeold)         % track when a new nourishment committments are started
    X.newplan(t)      = 1;
    X.beach_plan(t) = BP.beach_plan;
else
    X.beach_plan(t) = X.beach_plan(t-1);
end
