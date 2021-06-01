function [BPC]=calculate_nourishment_plan_cost(ACOM,M,MMT,X_NOF,X_OF)

t     = M.time;
I_OF  = ACOM.I_OF;
I_own = ACOM.I_own;

% these for variables will probably come from physical model
Llength               = MMT.lLength;
sandcost              = MMT.sandcost;
Ddepth                = MMT.Ddepth;
fixedcost             = MMT.fixedcost_beach;
nourish_plan_horizon  = MMT.nourish_plan_horizon; % nourish proposal length (10 yrs)
expectation_horizon   = MMT.expectation_horizon;  % might rename
delta                 = MMT.delta_disc;

% loop over all nourishment plans (indexed as the nourishment interval
for nourishment_interval = 1:10
    
    i = nourishment_interval;                                                               % i = nourishment interval(nourish every i years)
    
    [bw,nourish_xshore,nourish_yr,mbw] = evaluate_nourishment_future_beach_width(ACOM,M,MMT,i);
    
    fcost              = fixedcost.*ones(length(nourish_yr),1)./((1+delta).^nourish_yr(:));
    namount            = nourish_xshore*Ddepth*Llength*sandcost;
    varcost            = namount./((1+delta).^nourish_yr);
    maxplan            = find(nourish_yr>11);  % how many years to consider costs over?
    maxplan            = maxplan(1)-1;
    BPC.cost(i)        = sum(fcost(1:maxplan))+sum(varcost(1:maxplan))-MMT.nourish_subsidy;
    
    if t>30
        bw_future = [MMT.bw(1:t); bw]; % consists of past beach width plus future expected nourishments
        ind = 1;
        for t2 = t+1:t+expectation_horizon
            Ebw_future(ind) = mean(bw_future(t2-29:t2)); % projection of expected beach width over next 30 years
            ind = ind+1;
        end
        BPC.bw(i,:) = Ebw_future(:);
    else
        bw_future = [MMT.bw(1:t); bw]; % consists of past beach width plus future expected nourishments
        ind = 1;
        for t2 = t+1:t+expectation_horizon
            Ebw_future(ind) = mean(bw_future(t2-(t-1):t2));
            ind = ind+1;
        end
        BPC.bw(i,:) = Ebw_future(:);
    end
    
    BPC.tc_peryear(i) = BPC.cost(i)*delta*(1+delta)^MMT.amort/((1+delta)^MMT.amort-1);   % loan amortization
    
end

for nourishment_interval = 1:10
    i = nourishment_interval;
    
    % get base tax rate
    BPC.tau_add(i) = (MMT.amort)*BPC.tc_peryear(i)/sum(MMT.taxratio_OF*I_OF.*X_OF.price(t-1) + (1-I_OF)*X_NOF.price(t-1));
    
    % total tax burden
    BPC.tax_burden(:,i) = (MMT.amort)*(BPC.tau_add(i)*(1-I_OF)*X_NOF.price(t-1) + ...
        MMT.taxratio_OF*BPC.tau_add(i)*I_OF.*X_OF.price(t-1));
    
end