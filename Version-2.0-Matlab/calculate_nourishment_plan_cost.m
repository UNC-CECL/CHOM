function [BPC,MMT]=calculate_nourishment_plan_cost(ACOM,M,MMT,X_NOF,X_OF)

t        = M.time;
t_horiz  = MMT.nourish_plan_horizon;
I_OF     = ACOM.I_OF;
I_own    = ACOM.I_own;
Llength               = MMT.lLength;
sandcost              = MMT.sandcost;
Ddepth                = MMT.Ddepth;
fixedcost             = MMT.fixedcost_beach;
nourish_plan_horizon  = MMT.nourish_plan_horizon; % nourish proposal length (10 yrs)
delta                 = MMT.delta_disc;

if MMT.nourishtime(t+1,1)==1 & MMT.nourishtime(t+1,2)==0
    MMT.nourishtime(t+1:end,1)=0;
end

for time=1:t_horiz
    weight(time)=1/(1+MMT.delta_disc)^time;
end
weight=weight/sum(weight);


for nourishment_interval = 1:MMT.nourish_plan_horizon+1
    
    i = nourishment_interval;
    [bw,nourish_xshore,nourish_yr,mbw] = evaluate_nourishment_future_beach_width(ACOM,M,MMT,i);
    BPC.bw(i,:)        = bw(t+1:t+t_horiz)';
    BPC.mbw(i)         = sum(bw(t+1:t+t_horiz).*weight(:));
    
    nourish_yr = nourish_yr - t;
    pay_years = find(nourish_yr <= MMT.pay_years_ahead);
    nourish_yr         = nourish_yr(pay_years) ;
    nourish_xshore     = nourish_xshore(pay_years);
    
    fcost              = fixedcost.*ones(length(nourish_yr),1)./((1+delta).^nourish_yr(:));
    namount            = nourish_xshore*Llength*(M.barr_elev+0.5*Ddepth)*sandcost;
    varcost            = namount./((1+delta).^nourish_yr);
    
    if i ~= MMT.nourish_plan_horizon+1
        BPC.cost(i)        = (1 - MMT.nourish_subsidy)*( sum(fcost) + sum(varcost) );
    else
        BPC.cost(i) = 0;
    end
    
    BPC.tc_peryear(i) = BPC.cost(i)*delta*(1+delta)^MMT.amort/((1+delta)^MMT.amort-1);
    
    MMT.savefcost(i,t)=sum(fcost);
    MMT.savevcost(i,t)=sum(varcost);
    
end


for nourishment_interval = 1:MMT.nourish_plan_horizon+1
    
    i = nourishment_interval;
    
    if BPC.tc_peryear(i)<0
        BPC.tc_peryear(i)=0; % newly 6/8 added
    end
    % get base tax rate
    BPC.tau_add(i) = (MMT.amort)*BPC.tc_peryear(i)/sum(MMT.taxratio_OF*I_OF.*X_OF.price(t-1) + (1-I_OF)*X_NOF.price(t-1));
    
    BPC.tax_burden(:,i) = (MMT.amort)*(BPC.tau_add(i)*(1-I_OF)*X_NOF.price(t-1) + ...
        MMT.taxratio_OF*BPC.tau_add(i)*I_OF.*X_OF.price(t-1));
    
end





