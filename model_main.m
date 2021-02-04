%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%         Coastal Home Ownership Model CHOM         %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd C:\Users\Zack\Dropbox\ECONCOAST\model_2_2_2021\'New folder'\
clear all; close all; format compact;
rand('state',1); randn('state',1);
t1 = 5; % use as plot start time

[E,M,X,A,F,Tfinal]   = model_initialize;                          

for t = 2 : Tfinal; t
    
    X.time = t;                                                   % store current time to pass into functions
    [X]    = evolve_environment(F,X,A,E,M);                       % evolve, erode, build dunes, storms, calculate erosion rates
    [X]    = calculate_expected_dune_height(X);                   % update agent dune height expectations then
    [M]    = calculate_risk_premium(A,M,X);                       % update agent risk premium
    [BP]   = evaluate_nourishment_plan(E,M,X);                    % build menu of nourishment interval options - costs, benefits, property taxes, and
    [BP,X] = choose_nourishment_plan(E,M,X,BP);                   % evaluate nourishment menu - and if choosing to nourish (i.e. nourishtime(t+1)=1), then update prop taxes
    [X]    = calculate_expected_beach_width(X,M);                 % update agent willingness to pay function
    [X]    = evaluate_choose_dune_plan(E,M,X,A);                  % evaluate building a dune (cost, benefits, taxes), and if yes then builddunetime(t+1)=1 and update prop taxes
    [X]    = calculate_user_cost(M,X,X.WTP(:,t),X.tau_prop(t+1)); % real estate market calculation - determine current price, rent, and investor market share
    % [M,X] = agent_func(M,X);                                    % working on - evolve agent pool
    % []    = property_tracking(M,X);                             % working on - space
    save_dynamic_var;                                             % save stuff for analysis

    % debug 
    if X.newplan(t)==1 & isinf(X.planbenefit_beach(t))==1
        disp('debug')
        return
    end
end

print_figures

