function [A_NOF,A_OF,MMT,ACOM,X_NOF,X_OF]=evaluate_nourishment_plans(A_NOF,A_OF,ACOM,BPB,BPC,M,MMT,X_NOF,X_OF,run_option)

% run_option = run_option_init;
% run_option = run_option_main;

t            = M.time;
I_OF         = ACOM.I_OF;
I_own        = ACOM.I_own;
I_own_repmat = repmat(I_own,[1 MMT.nourish_plan_horizon]);    % new change -
t_horiz      = MMT.nourish_plan_horizon;

schedule_conflict = zeros(MMT.nourish_plan_horizon,1);

if sum(MMT.nourishtime(t:end,2)) > 0
    schedule_conflict(:)=1;
end

schedule_conflict(1) = 1;
% schedule_conflict(15:30) = 1;  % alert alert

last_payed_nourish = find(MMT.nourishtime(:,2)==1,1,'last');
first_unpaid_nourish = find(MMT.nourishtime(:,1)==1 & MMT.nourishtime(:,2)==0,1,'first');

for j=1:MMT.nourish_plan_horizon
    if t >= last_payed_nourish & t < first_unpaid_nourish - 1
        allowed_interval = t - last_payed_nourish + 2;
        if j > allowed_interval
            schedule_conflict(j) = 1;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:MMT.nourish_plan_horizon
    price_increase(:,j) = BPB.price_list(:,j) - (BPB.prop_plan(2,end)*I_OF + BPB.prop_plan(1,end)*(1-I_OF));
end

net_benefits = price_increase ;
% net_benefits = price_increase - BPC.tax_burden(:,1:MMT.nourish_plan_horizon);
net_benefits(:,[1]) = -1;

net_ben_OF = net_benefits(end,1:MMT.nourish_plan_horizon);
net_ben_NOF = net_benefits(1,1:MMT.nourish_plan_horizon);

MMT.nbof(:,t)=net_ben_OF(:);
MMT.nbnof(:,t)=net_ben_NOF(:);


if sum(I_own)/ACOM.n_agent_total < 0.1
    I_own=ones(size(I_own));
end

for j = 2:MMT.nourish_plan_horizon
    for i = 1:ACOM.n_agent_total
        if I_own(i) == 1 & schedule_conflict(j) == 0
            if net_benefits(i,j) > 0
                vote(i,j) = 1;
            else
                vote(i,j) = 0;
            end
        else
            vote(i,j) = 0;
        end
    end
end

tally_vote        = sum(vote)./sum(I_own);
voter_choice      = find(tally_vote>0.5);

% % choose the plan if there are multiple choices
if numel(voter_choice) > 1
    not_choice = ones(MMT.nourish_plan_horizon,1);
    not_choice(voter_choice)=0;
    summed_ben = sum(net_benefits);
    summed_ben(not_choice==1)=NaN;
    [~,voter_choice]=max(summed_ben);
    
end

% 
% % choose the plan if there are multiple choices
% if numel(voter_choice) > 1
%     net_ben_nof = net_benefits(1,:);
%     net_ben_of  = net_benefits(X_NOF.n+1,:);
%     num_nof=sum(I_own(1:ACOM.n_NOF));
%     num_of=sum(I_own(ACOM.n_NOF+1:end));
%     total_ben_nof = num_nof*net_ben_nof;
%     total_ben_of = num_of*net_ben_of;
%     if max(total_ben_nof) > max(total_ben_of)
%         [~,voter_choice] = max(total_ben_nof);
%     else
%         [~,voter_choice] = max(total_ben_of);
%     end
%     if max(total_ben_nof) == max(total_ben_of)
%         disp('evaluate plan max = max problem')
%         pause
%     end
% end

if numel(voter_choice)==1 & ~run_option.nourish_off
    MMT.newplan(t+1)              = 1;
    MMT.current_plan              = voter_choice;
    MMT.nourishtime(t+1:end,1)    = 0;
    nourish_yr                    = t+1:voter_choice:t+t_horiz;
    MMT.nourishtime(nourish_yr,1) = 1;
    paid                          = find(nourish_yr - t < MMT.pay_years_ahead);
    MMT.nourishtime(nourish_yr(paid),2) = 1;
    A_NOF.tau_prop(t+1:t+MMT.amort)     = A_NOF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(voter_choice);
    A_OF.tau_prop(t+1:t+MMT.amort)      = A_OF.tau_prop(t+1:t+MMT.amort)+MMT.taxratio_OF*BPC.tau_add(voter_choice);
else
    voter_choice = MMT.nourish_plan_horizon+1;
    MMT.newplan(t+1)  = 0;
    MMT.current_plan = MMT.nourish_plan_horizon+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the official expected beach width
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for time=1:t_horiz
    weight(time)=1/(1+MMT.delta_disc)^time;
end
weight=weight/sum(weight);
MMT.current_choice(t) = voter_choice;
bw                    = zeros(M.T + MMT.nourish_plan_horizon,1);
bw(1:t)               = MMT.bw(1:t);

for time = t+1:t+t_horiz
    bw(time) = bw(time-1) - ACOM.E_ER(t);
    if MMT.nourishtime(time,1) == 1
        bw(time) = MMT.x0;
    end
end
bw(bw<1)               = 1;
ACOM.Ebw(t)            = sum(bw(t+1:t+t_horiz).*weight(:));
MMT.bw_projection(:,t) = bw(t+1:t+t_horiz);
if run_option.nourish_off
    ACOM.Ebw(t) = MMT.bw(t);
end

X_NOF.WTP{t} = X_NOF.WTP_base+X_NOF.WTP_alph.*ACOM.Ebw(t)^X_NOF.bta; % expected willingness to pay
X_OF.WTP{t}  = X_OF.WTP_base+X_OF.WTP_alph.*ACOM.Ebw(t)^X_OF.bta; % expected willingness to pay


if ~run_option.nourish_off & run_option.name == 'main' & t>2
    
    if voter_choice<MMT.nourish_plan_horizon+1
    MMT.netbenNOF_total(t)         = net_benefits(1,voter_choice);
    MMT.netbenNOF_priceincrease(t) = price_increase(1,voter_choice);
    MMT.netbenNOF_taxburden(t)     = BPC.tax_burden(1,voter_choice);
    MMT.netbenOF_total(t)          = net_benefits(ACOM.n_NOF+1,voter_choice);
    MMT.netbenOF_priceincrease(t)  = price_increase(ACOM.n_NOF+1,voter_choice);
    MMT.netbenOF_taxburden(t)      = BPC.tax_burden(ACOM.n_NOF+1,voter_choice);
    else
    MMT.netbenNOF_total(t)         = NaN;
    MMT.netbenNOF_priceincrease(t) = NaN;
    MMT.netbenNOF_taxburden(t)     = NaN;
    MMT.netbenOF_total(t)          = NaN;
    MMT.netbenOF_priceincrease(t)  = NaN;
    MMT.netbenOF_taxburden(t)      = NaN;
    end
end















% for j=1:MMT.nourish_plan_horizon
%     if t < BPC.last_payed_nourish
%         schedule_conflict(j) = 1;
%     end
%     if MMT.nourishtime(t) == 1 | MMT.nourishtime(t-1)==1
%         schedule_conflict(j) = 1;
%     end
%     for i=1:MMT.nourish_plan_horizon
%         if nourish_schedule(j,i) == 1 & nourish_schedule(j,i+1)==1
%             schedule_conflict(j)=1;
%         else if nourish_schedule(j,i)>1
%                 schedule_conflict(j)=1;
%             end
%         end
%     end
% end
% if t<=10
%     for j=1:MMT.nourish_plan_horizon
%         price_increase(:,j) = BPB.price_list(:,j) - (mean(X_OF.price(1:t-1))*I_OF +mean(X_NOF.price(1:t-1))*(1-I_OF));
%     end
% else
%     for j=1:MMT.nourish_plan_horizon
%         price_increase(:,j) = BPB.price_list(:,j) - (mean(X_OF.price(t-10:t-1))*I_OF +mean(X_NOF.price(t-10:t-1))*(1-I_OF));
%     end
% end

%
% if numel(voter_choice) > 1
%
%     net_ben_nof = net_benefits(1,:);
%     net_ben_of  = net_benefits(X_NOF.n+1,:);
%
%     net_ben_of(net_ben_of<0) = -Inf;
%     net_ben_nof(net_ben_nof<0) = -Inf;
%
%     [net_ben_of_sorted, i_of] = sort(net_ben_of,'descend');
%     [net_ben_nof_sorted, i_nof] = sort(net_ben_nof,'descend');
%     num_pos_nof = length(find(net_ben_nof > 0));
%     num_pos_of = length(find(net_ben_of > 0));
%
%     flag=0;
%     if num_pos_nof > 0 & num_pos_of > 0
%         ii=1;
%         while flag == 0
%             c=intersect(i_of(1:ii),i_nof(1:ii));
%             if numel(c)>1
%                 c=c(1);
%             end
%             if numel(c)>0 & schedule_conflict(c)==0
%                 voter_choice=c;
%                 flag=1;
%             else
%                 ii=ii+1;
%                 if ii == MMT.nourish_plan_horizon + 1
%                     flag=1;
%                     voter_choice=voter_choice(1);
%                 end
%             end
%         end
%     else if num_pos_nof == 0 & num_pos_of > 0
%             voter_choice = i_of(1);
%
%         else if num_pos_of == 0 & num_pos_nof > 0
%                 voter_choice = i_nof(1);
%             end
%         end
%     end
%
%
%     if BPC.tau_add(voter_choice)<0
%         disp('negative tax problem')
%         pause
%     end
%
%
%
% end

% if numel(voter_choice) > 1
%
%     cost_nof = BPC.tax_burden(1,1:MMT.nourish_plan_horizon);
%     cost_of  = BPC.tax_burden(X_NOF.n+1,1:MMT.nourish_plan_horizon);
%
%     cost_of(cost_of<0) = Inf;
%     cost_nof(cost_nof<0) = Inf;
%
%
%
%     [cost_of_sorted, i_of] = sort(cost_of,'ascend');
%     [cost_nof_sorted, i_nof] = sort(cost_nof,'ascend');
%     num_pos_nof = length(find(cost_nof > 0));
%     num_pos_of = length(find(cost_of > 0));
%
%     flag=0;
%     if num_pos_nof > 0 & num_pos_of > 0
%         ii=1;
%         while flag == 0
%             c=intersect(i_of(1:ii),i_nof(1:ii));
%             if numel(c)>1
%                 c=c(1);
%             end
%             if numel(c)>0 & schedule_conflict(c)==0
%                 voter_choice=c;
%                 flag=1;
%             else
%                 ii=ii+1;
%                 if ii== MMT.nourish_plan_horizon + 1
%                     flag=1;
%                     voter_choice=NaN;
%                 end
%             end
%         end
%     else if num_pos_nof == 0 & num_pos_of > 0
%             voter_choice = i_of(1);
%         else if num_pos_of == 0 & num_pos_nof > 0
%                 voter_choice = i_nof(1);
%             end
%         end
%     end
%
%     if BPC.tau_add(voter_choice)<0
%         disp('negative tax problem')
%         pause
%     end
%
%     MMT.newplan(t+1)              = 1;
%     MMT.current_plan              = voter_choice;
%     MMT.nourishtime(t+1:end,1)    = 0;
%     nourish_yr                    = t+1:voter_choice:t+t_horiz;
%     MMT.nourishtime(nourish_yr,1) = 1;
%     paid                          = find(nourish_yr - t < MMT.pay_years_ahead);
%     MMT.nourishtime(nourish_yr(paid),2) = 1;
%     A_NOF.tau_prop(t+1:t+MMT.amort)     = A_NOF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(voter_choice);
%     A_OF.tau_prop(t+1:t+MMT.amort)      = A_OF.tau_prop(t+1:t+MMT.amort)+MMT.taxratio_OF*BPC.tau_add(voter_choice);
% end







