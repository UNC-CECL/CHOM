function [X]=evaluate_choose_dune_plan(E,M,X,A);

t                        = X.time;

% everything from here \/
deltadune                = M.duneheight_max-X.h_dune(t);
Llength                  = M.n*15;                 
sandcost                 = M.sandcost;            
width                    = 4;
sandvolume               = Llength*width*deltadune;   
% to here /\ should be dealt with when coupling

fixedcost                = M.fixedcost_dune;
var_cost                 = sandvolume*sandcost + fixedcost;
tc_peryear               = var_cost*M.delta*(1+M.delta)^E.amort/((1+M.delta)^E.amort-1); % loan amortization
tau_t                    = tc_peryear/(M.n*M.tax_ratio*X.price(t-1));
tax_burden               = tau_t*X.property(:,1)*X.price(t-1)+tau_t*(1-X.property(:,1))*X.price(t-1);

X_no_dune                = X;                                         % X_no_dune is the world where dunes are not built in the next time step
[M_no_dune]              = calculate_risk_premium(A,M,X_no_dune);     % M_no_dune is also in this world 
[X_no_dune]              = calculate_user_cost(M_no_dune,X,X.WTP(:,t),X_no_dune.tau_prop(t+1)); % determine the price in this no dune world 
                             
X_build_dune                     = X;                                        % X_build_dune is a world where dunes are built at t+1
X_build_dune.tau_prop(1:E.amort) = X_build_dune.tau_prop(1:E.amort)+tau_t;   % a world where property taxes are increased 
X_build_dune.mdh(t)              = M.duneheight_max;                         % the dunes are high
[M_build_dune]                   = calculate_risk_premium(A,M,X_build_dune); % and the risk premia lower              
[X_build_dune]                   = calculate_user_cost(M_build_dune,X_build_dune,X_build_dune.WTP(:,t),X_build_dune.tau_prop(t+1)); % get the price in the world with dunes
 
% only build dunes if you are already nourishing 
if X.nourishtime(t+1) == 1 
    % only build dunes if the price increase is greater than the tax burden on a per house basis
    if X_build_dune.price(t) - X_no_dune.price(t) > tax_burden(1)*E.amort 
        X.builddunetime(t+1) = 1;                                     % schedule the dune building
        X.tau_prop(t+1:t+E.amort) = X_build_dune.tau_prop(1:E.amort); % add cost to build to property taxes
    end
end

X.dunebens(t) = (X_build_dune.price(t) - X_no_dune.price(t)) - tax_burden(1)*E.amort; % grab the benefit-cost of building dune 
