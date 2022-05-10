function [X,SV]=calculate_user_cost(M,X,WTP_new,tau_prop,SV)
% A=A_NOF;
% X=X_NOF;
% WTP=X_NOF.WTP{t};
% tau_prop=A_NOF.tau_prop(t);
% [X_NOF]            = calculate_user_cost(M,X_NOF,WTP_plan_NOF,tauprop_NOF(1));
% X_NOF=X_NOF_base;
% 
% WTP_new=X_NOF.WTP{t};
% tau_prop=A_NOF.tau_prop(t);
% X=X_NOF;
% A=A_NOF;

v2struct(X)
v2struct(M)
WTP=WTP_new;

% Initialize R and P
R         = [];                                                  % rental value
P_o       = [];                                                  % owner bid function
P_i       = [];                                                  % investor bid function
vacancies = []; % initialize vacancies

R   = WTP ;
P_o = R(:)./((delta+tau_prop).*(1-tau_o(:))+ gam + rp_o(:) - g_o(:)) ; % with expected capital gains g_o
% X.Ouc(:,M.time)  = ((delta+tau_prop).*(1-tau_o(:))+ gam + rp_o(:) - g_o(:));

% Investor bids and market share
owner_info                             = [P_o R];
[owner_info,index]                     = sortrows(owner_info,1);
X.index_sorted_agents_by_po{M.time}    = index;

% loop over investor owning properties 
for i = 1:n
    P_bid = owner_info(i,1)+epsilon;
    R_i   = (P_bid)*((delta+tau_prop)*(1-tau_c)+ gam + rp_I - g_I + m); % with expected capital gains g_I
    
    if R_i <0
        R_i = 1;
    end
    
    vacant = zeros(i,1);
    for j = 1:i
        if R_i>owner_info(j,2) %  check for vacancy
            vacant(j) = 1;
        end
    end
    vacancies(i)      = sum(vacant);
    rent_store(i)     = R_i;
    P_invest_store(i) = P_bid;
end

results = [vacancies' rent_store' P_invest_store'];

vac_check        = 0;
ii               = 1;
% P_equ            = min(results,3)-epsilon;
P_equ            = min(results(:,3))-epsilon;

R_equ            = 0;
mkt_share_invest = 0;

while vac_check < 1
    R_equ            = results(ii,2);
    P_equ            = results(ii,3);
    vac_check        = results(ii,1);
    mkt_share_invest = ii/n;
    
    if ii == n
        vac_check = 1;
    else
        ii = ii+1;
    end
end    
    
X.Ouc1(:,M.time) = R(:);
X.Ouc2(:,M.time) = rent_store(:);

X.price(M.time) = P_equ;           
X.P_o(:,M.time) = owner_info(:,1);
X.rent(M.time)  = R_equ;            %rental mkt equilibrium annual rent
X.mkt(M.time)   = mkt_share_invest; %investor market share

% % get index of all agents who are renters (agent bid price P_o < P_equ)
find_renter = find(P_o<P_equ);
find_owner  = find(P_o>P_equ);

% mean(rp_o(index(find_renter)))
% mean(rp_o(index(find_owner)))

X.rp_renter{M.time}  = rp_base(find_renter); % get mean risk premium of 
X.rp_owner{M.time}   = rp_base(find_owner);

SV.tau_incO{M.time}       = tau_o(find_owner);
SV.tau_incR{M.time}       = tau_o(find_renter);

SV.riskO{M.time}       = rp_o(find_owner);
SV.riskR{M.time}       = rp_o(find_renter);

% rpN.avg     = mean(rp_o);
% 
% P_bid           = P_bid-epsilon;
% owner_info(:,3) = index;
