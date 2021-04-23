%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A,X] = agent_initialize(T,n,bta)
% 
% T=M.T
% bta=0.2;

% % owner agent
if bta==2
    range_WTP_base         = [5000 35000];    
    range_WTP_alph         = [5000 35000];    % base willingness to pay distribution bounds
    range_tau_o            = [0.0 0.35];      % income tax bracket (0 to 0.37)
else
    range_WTP_base         = [5000 25000];    %
    range_WTP_alph         = [5000 25000];    % base willingness to pay distribution bounds
    range_tau_o            = [0.0 0.35];
end

if bta==0.2
    range_rp_base           = [-0.03 0.03];   % base risk premium distribution - random distribution of shifts to base risk premium
else
    range_rp_base           = [0 0.03];       
end

m = 0.003;           % additional investor-only fees of renting the property (just investors)

% agents/ user cost
delta             = 0.06;           % interest rate (same for investor and owner)
gam               = 0.01;           % depreciation rate on housing capital (same for investor and owner)
HV                = 1000;           % annualized value of housing services (same for investor and owner)
rp_I              = zeros(1);       % average risk premium real estate (same for investor and owner)
rp_o              = zeros(n,1);     % average risk premium real estate (same for investor and owner)
rp_storm          = 0;
epsilon           = 1;              % additional bid for investor
tau_prop          = 0.01*ones(T,1); % base property tax rate (same for investor and owner)
tau_c             = 0.2;            % corporate tax rate (just investors) -- U.S. federal rate (could add 2.5% for NC)

capgain_feedbackparam = 1e-10;
beta_x_feedbackparam  = 1e-10;
adjust_beta_x         = 5e-8;
risk_to_EnvExptdGains = 0.2;
frac_realist          = .75;
rcov                  = 0.8;
env_risk_immediacy    = 0.2;    % determines how quickly people switch from abitrage to environmental risk in capital gains 
if bta==2
    beta_x = 0.4;
else
    beta_x = 0.4;
end

[tau_o,WTP_base,rp_base,WTP_alph] = agent_distribution(rcov,range_WTP_base,range_WTP_alph,range_tau_o,range_rp_base,beta_x,n); % generate agent variables

[rp_base_sorted,I] = sort(rp_base);
I_realist=zeros(length(rp_base),1);
I_realist(I(end-round(length(rp_base)*frac_realist)+1:end))=1;


g_I               = 0.01;
g_o               = 0.04*randn(n,1);
price             = zeros(T,1);
rent              = zeros(T,1);
mkt               = zeros(T,1);
t_halftime        = zeros(T,2);

if bta>=0.2
    price(1)          = 6e5;
    rent(1)           = 1e5;
else
    price(1) = 4e5;
    rent(1)  = 1e5;
end
mkt(1)            = 0.4;

model_vars = {'fieldNames','bta','delta','epsilon','gam','g_o','g_I','HV','m',...
                'mkt','n','price','rent','rp_base','rp_storm','rp_I',...
                'rp_o','tau_c','tau_o','WTP_base','WTP_alph'};
X          = v2struct(model_vars);

agent_dist = {'fieldnames','rcov','range_WTP_base','range_WTP_alph','range_tau_o','range_rp_base','tau_prop','frac_realist','I_realist','beta_x','beta_x_feedbackparam','adjust_beta_x','capgain_feedbackparam','risk_to_EnvExptdGains','env_risk_immediacy'};
A          = v2struct(agent_dist);






