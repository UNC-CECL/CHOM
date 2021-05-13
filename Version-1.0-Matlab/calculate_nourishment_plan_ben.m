function [BPB,BPC]=calculate_nourishment_plan_ben(A_NOF,A_OF,ACOM,BPC,M,MMT,X_NOF,X_OF)

t=M.time;

for nourishment_interval = 1:10
    i                  = nourishment_interval;
    BPC.mbw(i)         = mean(BPC.bw(i,:));
    WTP_plan_NOF       = X_NOF.WTP_base+X_NOF.WTP_alph*BPC.mbw(i)^MMT.bta_NOF;
    WTP_plan_OF        = X_OF.WTP_base+X_OF.WTP_alph*BPC.mbw(i)^MMT.bta_OF;
    tauprop_NOF        = A_NOF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(i);
    [X_NOF]            = calculate_user_cost(M,X_NOF,WTP_plan_NOF,tauprop_NOF(1));
    tauprop_OF         = A_OF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(i)*MMT.taxratio_OF;
    [X_OF]             = calculate_user_cost(M,X_OF,WTP_plan_OF,tauprop_OF(1));
    BPB.prop_plan(1,i) = X_NOF.price(t);
    BPB.prop_plan(2,i) = X_OF.price(t);
end

mbw_noplan = MMT.bw(t)-ACOM.E_ER(t):-ACOM.E_ER(t):MMT.bw(t)-ACOM.E_ER(t)*MMT.expectation_horizon;
mbw_noplan(mbw_noplan<1)=1;
mbw_noplan = mean(mbw_noplan);

WTP_plan_NOF        =  X_NOF.WTP_base+X_NOF.WTP_alph *mbw_noplan ^MMT.bta_NOF;
WTP_plan_OF         =  X_OF.WTP_base+X_OF.WTP_alph *mbw_noplan ^MMT.bta_OF;

[X_NOF]             = calculate_user_cost(M,X_NOF,WTP_plan_NOF,A_NOF.tau_prop(t+1));
[X_OF]              = calculate_user_cost(M,X_OF,WTP_plan_OF,A_OF.tau_prop(t+1));
BPB.prop_plan(1,11) = X_NOF.price(t);
BPB.prop_plan(2,11) = X_OF.price(t);


price_list=zeros(ACOM.n_agent_total,11);
for ii=1:11
    price_list(1:ACOM.n_NOF,ii)=BPB.prop_plan(1,ii);
    price_list(ACOM.n_NOF+1:ACOM.n_NOF+ACOM.n_OF,ii)=BPB.prop_plan(2,ii);
end
BPB.price_list=price_list;
