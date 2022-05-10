function [BPB,BPC]=calculate_nourishment_plan_ben(A_NOF,A_OF,ACOM,BPC,M,MMT,X_NOF,X_OF)

X_OF_base  = X_OF;
X_NOF_base = X_NOF;   % new change
t          = M.time;


for nourishment_interval = 1:MMT.nourish_plan_horizon+1
    X_OF               = X_OF_base;    % new change
    X_NOF              = X_NOF_base;
    i                  = nourishment_interval;
    WTP_plan_NOF       = X_NOF.WTP_base+X_NOF.WTP_alph*BPC.mbw(i)^X_NOF.bta;
    WTP_plan_OF        = X_OF.WTP_base+X_OF.WTP_alph*BPC.mbw(i)^X_OF.bta;
    tauprop_NOF = A_NOF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(i);
%     tauprop_NOF        = A_NOF.tau_prop(t+1:t+MMT.amort);
    [X_NOF]              = calculate_user_cost(M,X_NOF,WTP_plan_NOF,tauprop_NOF(1));
    tauprop_OF       = A_OF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(i)*MMT.taxratio_OF;
%     tauprop_OF         = A_OF.tau_prop(t+1:t+MMT.amort);
    [X_OF]             = calculate_user_cost(M,X_OF,WTP_plan_OF,tauprop_OF(1));
    BPB.prop_plan(1,i) = X_NOF.price(t);
    BPB.prop_plan(2,i) = X_OF.price(t);
end

price_list=zeros(ACOM.n_agent_total,MMT.nourish_plan_horizon+1);
for ii=1:MMT.nourish_plan_horizon+1
    price_list(1:ACOM.n_NOF,ii)=BPB.prop_plan(1,ii);
    price_list(ACOM.n_NOF+1:ACOM.n_NOF+ACOM.n_OF,ii)=BPB.prop_plan(2,ii);
end
BPB.price_list=price_list;


% 
% 
% 
% for i=1:MMT.nourish_plan_horizon+1
%     WTP_plan_NOF(i)       = mean(X_NOF.WTP_base+X_NOF.WTP_alph*(BPC.mbw(i)*3.28)^X_NOF.bta);
%     WTP_plan_OF(i)        = mean(X_OF.WTP_base+X_OF.WTP_alph*(BPC.mbw(i)*3.28)^X_OF.bta);
% end
% 
% close all
% plot(3.28*BPC.mbw,WTP_plan_OF)
% hold on
% plot(3.28*BPC.mbw,WTP_plan_NOF)
