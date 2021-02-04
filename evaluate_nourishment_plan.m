function [BP]=evaluate_nourishment_plan(E,M,X)

t = X.time;

% these for variables will probably come from physical model
Llength               = M.lLength;             
sandcost              = M.sandcost;
Ddepth                = M.Ddepth;
fixedcost             = M.fixedcost_beach;
nourish_plan_horizon  = E.nourish_plan_horizon; % nourish proposal length (10 yrs)
expectation_horizon   = E.expectation_horizon;  % might rename 

% loop over all nourishment plans (indexed as the nourishment interval
for nourishment_interval=1:10 
    
    i = nourishment_interval;                                                               % i = nourishment interval(nourish every i years)
    [Ebw,nourish_xshore,nourish_yr,mbw] = evaluate_nourishment_future_beach_width(i,E,X,M); % returns expected bw(t), and the amount nourished    
    
    fcost              = fixedcost.*ones(length(nourish_yr),1)./((1+M.delta).^nourish_yr(:));
    namount            = nourish_xshore*Ddepth*Llength*sandcost;
    varcost            = namount./((1+M.delta).^nourish_yr);
    maxplan            = find(nourish_yr>10);
    maxplan            = maxplan(1)-1; 
    BP.cost(i)         = sum(fcost(1:maxplan))+sum(varcost(1:maxplan));
    BP.mbw(i)          = mbw;
    tc_peryear         = BP.cost(i)*M.delta*(1+M.delta)^E.amort/((1+M.delta)^E.amort-1);   % loan amortization
    BP.tau_t(i)        = tc_peryear/(M.n*M.tax_ratio*X.price(t-1));
    BP.tax_burden(:,i) = BP.tau_t(i)*X.property(:,1)*X.price(t-1);
    clear nourish_xshore Ebw nourish_yr fcost namount varcost tc_peryear
end

% no nourish case plan = 11
% (no nourish plan placed in spot 11, does not indicate nourish every 11 years)
Ebw                  = X.bw(t):-X.er(t):X.bw(t)-X.er(t)*E.nourish_plan_horizon;
Ebw(Ebw<0)           = 0;
BP.cost(11)          = 0;
BP.mbw(11)           = mean(Ebw);
tc_peryear           = BP.cost(11)*M.delta*(1+M.delta)^E.amort/((1+M.delta)^E.amort-1);   
BP.tau_t(11)         = tc_peryear/(M.n*M.tax_ratio*X.price(t-1));
BP.tax_burden(:,11)  = BP.tau_t(11)*X.property(:,1)*X.price(t-1);

% get the nourishment plan discounted net benefits
for nourishment_interval = 1:11
    
    i                          = nourishment_interval; 
    WTP_plan_i                 = M.WTP_base+M.alph*BP.mbw(i)^M.bta;
    tau_prop_plan              = X.tau_prop(t+1:t+E.nourish_plan_horizon);
    tau_prop_plan(1:E.amort)   = tau_prop_plan(1:E.amort)+BP.tau_t(i);
    [Xplan]                    = calculate_user_cost(M,X,WTP_plan_i,tau_prop_plan(1));
    BP.PropPrice_under_plan(i) = Xplan.price(X.time); 
end

BP.nourish_schedule = X.nourishtime(t+1:t+E.nourish_plan_horizon)'; % comment what this is for
BP.nourish_schedule = repmat(BP.nourish_schedule,[11 1]);




