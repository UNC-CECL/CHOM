%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%         Coastal Home Ownership Model CHOM         %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd C:\Users\Zack\Dropbox\coastal_housing\coastal_housing\8_April_2021\model_ver1

clear all; close all; format compact;
rand('state',2); randn('state',2);
t1 = 2; % use as plot start time

n                   = 2500;                                           % total number of agents
[M,MMT,ACOM]        = model_initialize(n);                            % initialize
[A_NOF,X_NOF]       = agent_initialize(M.T,ACOM.n_NOF,MMT.bta_NOF);   % initialize
[A_OF,X_OF]         = agent_initialize(M.T,ACOM.n_OF,MMT.bta_OF);      
SV_NOF              = [];
SV_OF               = [];
t2                  = 150;

nourishment_off     = 0;

for t = 2 : t2
    t
    
    % update market share = number of renters, 1-mkt = number renters
    n1                       = round(ACOM.n_NOF*(1-X_NOF.mkt(t-1)));                    
    n2                       = round(ACOM.n_OF*(1-X_OF.mkt(t-1)));
    
    ACOM.I_own               = 0*ACOM.I_own;    
    rand_ownNOF = randi([1 ACOM.n_NOF],n1,1);
    rand_ownOF  = randi([ACOM.n_NOF+1 ACOM.n_NOF+ACOM.n_OF],n2,1);
    ACOM.I_own(rand_ownNOF) = 1;
    ACOM.I_own(rand_ownOF) = 1;
    
    M.time                   = t;                                         
    [MMT,ACOM]               = evolve_environment(ACOM,M,MMT);  
    [ACOM]                   = calculate_expected_dune_height(ACOM,M,MMT);
    [X_NOF]                  = calculate_risk_premium(ACOM,A_NOF,M,X_NOF,MMT);
    [X_OF]                   = calculate_risk_premium(ACOM,A_OF,M,X_OF,MMT);
    [BPC]                    = calculate_nourishment_plan_cost(ACOM,M,MMT,X_NOF,X_OF);
    [BPB,BPC]                = calculate_nourishment_plan_ben(A_NOF,A_OF,ACOM,BPC,M,MMT,X_NOF,X_OF);
    [A_NOF,A_OF,MMT]         = evaluate_nourishment_plans(A_NOF,A_OF,ACOM,BPB,BPC,M,MMT,X_NOF,X_OF,nourishment_off);
    [ACOM,X_NOF,X_OF]        = calculate_expected_beach_width(ACOM,M,MMT,X_NOF,X_OF);
  
    if t>5
        [A_NOF,A_OF,MMT]     = calculate_evaluate_dunes(ACOM,M,MMT,X_NOF,X_OF,A_NOF,A_OF); 
        [X_NOF,SV_NOF]       = expected_capital_gains(ACOM,A_NOF,M,MMT,X_NOF,0,SV_NOF,M.P_e_NOF,ACOM.n_NOF);
        [X_OF,SV_OF]         = expected_capital_gains(ACOM,A_OF,M,MMT,X_OF,1,SV_OF,M.P_e_OF,ACOM.n_OF);
    end
    
    [X_NOF]                  = calculate_user_cost(M,X_NOF,X_NOF.WTP{t},A_NOF.tau_prop(t));         
    [X_OF]                   = calculate_user_cost(M,X_OF,X_OF.WTP{t},A_OF.tau_prop(t));           
    [A_NOF,X_NOF,SV_NOF]     = agent_distribution_adjust(ACOM,A_NOF,X_NOF,M,SV_NOF,0,MMT);
    [A_OF,X_OF,SV_OF]        = agent_distribution_adjust(ACOM,A_OF,X_OF,M,SV_OF,1,MMT);
    
    save_dynamic_var;   % save stuff for analysis
      
end

print_figures

