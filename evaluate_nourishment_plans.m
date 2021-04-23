function [A_NOF,A_OF,MMT]=evaluate_nourishment_plans(A_NOF,A_OF,ACOM,BPB,BPC,M,MMT,X_NOF,X_OF,nourishment_off)

t     = M.time;
I_OF  = ACOM.I_OF;
I_own = ACOM.I_own;

nourish_schedule = MMT.nourishtime(t+1:t+MMT.nourish_plan_horizon)'; 
nourish_schedule = repmat(nourish_schedule,[11 1]);

for j=1:10
    nindx                     = 1:j:MMT.nourish_plan_horizon;
    nourish_schedule(j,nindx) = nourish_schedule(j,nindx)+1;
    num_scheduling_conflicts  = numel(find(nourish_schedule(j,:)>1));
    if num_scheduling_conflicts>0
        schedule_conflict(j) = 1;
    else
        schedule_conflict(j) = 0;
    end
    
    % can't schedule such that back to back nourishments are planned
    catch_back2back_nourishplans = nourish_schedule(j,1:end-1)+nourish_schedule(j,2:end);
    if numel(find(catch_back2back_nourishplans==2))>0
        schedule_conflict(j) = 1;
    end
    
    catch_back2back_nourishplans = nourish_schedule(j,1:end-2)+nourish_schedule(j,2:end-1)+nourish_schedule(j,3:end);
    if numel(find(catch_back2back_nourishplans>1))>0
        schedule_conflict(j) = 1;
    end
    
    if t>5
        if sum(MMT.nourishtime(t-2:t))>0
            schedule_conflict(j)=1;
        end
    end
end

for j = 1:10
    for i = 1:ACOM.n_agent_total
        if I_own(i) == 1 & schedule_conflict(j) == 0
            price_increase = BPB.price_list(i,j) - BPB.price_list(i,11);
            if BPC.tax_burden(i,j) < price_increase
                vote(i,j) = 1;
            else
                vote(i,j) = 0;
            end
        else
            vote(i,j) = 0;
        end
    end
end

tally_vote         = sum(vote)/sum(I_own);
tally_vote([1 10]) = NaN;
voter_choice       = find(tally_vote>0.5);

if MMT.nourishtime(t)==1
    voter_choice=[];
end

% if nourishment is happening in current time step,
% then a new nourishment plan cannot be adopted
if nourishment_off==1
    voter_choice=[];
end

if numel(voter_choice) == 0
    MMT.newplan(t+1)  = 0;
    MMT.current_plan  = 11;
end

if numel(voter_choice) == 1
    MMT.newplan(t+1) = 1;
    MMT.current_plan  = voter_choice;
    MMT.nourishtime(t+1:t+MMT.nourish_plan_horizon)=nourish_schedule(voter_choice,:);
    A_NOF.tau_prop(t+1:t+MMT.amort) = A_NOF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(voter_choice);
    A_OF.tau_prop(t+1:t+MMT.amort)  = A_OF.tau_prop(t+1:t+MMT.amort)+MMT.taxratio_OF*BPC.tau_add(voter_choice);
end

if numel(voter_choice) > 1 & voter_choice~=11
    voter_choice=voter_choice(end);
    %     voter_choice=voter_choice(1);
    MMT.newplan(t+1) = 1;
    MMT.current_plan  = voter_choice;
    MMT.nourishtime(t+1:t+MMT.nourish_plan_horizon)=nourish_schedule(voter_choice,:);
    A_NOF.tau_prop(t+1:t+MMT.amort)    = A_NOF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(voter_choice);
    A_OF.tau_prop(t+1:t+MMT.amort)     = A_OF.tau_prop(t+1:t+MMT.amort)+MMT.taxratio_OF*BPC.tau_add(voter_choice);
end


% for plotting - get netben for each group

    MMT.netben(t,1)   =  max(BPB.price_list(1,:));
    MMT.netben(t,2)   =  max(BPB.price_list(ACOM.n_NOF+1,:));

