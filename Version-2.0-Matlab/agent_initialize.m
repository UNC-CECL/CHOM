%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A,X,SV] = agent_initialize(T,n,run_option,row)

% owner agent distributions 
if strcmp(row,'front')==1 
    bta            = 0.25;        % hedonic scaling parameter for willingness_to_pay(agentj)*beach_width^(BTA)
    range_WTP_base = [21000 38000];  % bounds on base willingness to pay agent distribution
    range_WTP_alph = [9000 12000];      % bounds on ALPHA(j)*beach_width - component of willingness to pay distribution
    range_tau_o    = [0.10 0.37];    % income tax bracket (0 to 0.37)
    range_rp_base  = [0.8 1.2];    % base risk premium distribution - random distribution of shifts to base risk premium
    distribution_peakiness = 150;
    beta_x         = 0.45;            % [0 to 1] - 0 starts income and WTP distributions at lowest values, 1 at highest
else
    bta             = 0.15;
    range_WTP_base  = [21000 38000];
    range_WTP_alph  = [9000 12000];
    range_tau_o     = [0.10 0.37];
    range_rp_base   = [0.8 1.2];
    distribution_peakiness = 150;
    beta_x          = 0.45; 
end

% if strcmp(row,'front')==1 
%     bta            = 0.25;        % hedonic scaling parameter for willingness_to_pay(agentj)*beach_width^(BTA)
%     range_WTP_base = [23500 40000];  % bounds on base willingness to pay agent distribution
%     range_WTP_alph = [9000 12000];      % bounds on ALPHA(j)*beach_width - component of willingness to pay distribution
%     range_tau_o    = [0.1 0.5];    % income tax bracket (0 to 0.37)
%     range_rp_base  = [0.5 1.5];    % base risk premium distribution - random distribution of shifts to base risk premium
%     distribution_peakiness = 150;
%     beta_x         = 0.45;            % [0 to 1] - 0 starts income and WTP distributions at lowest values, 1 at highest
% else
%     bta             = 0.15;
%     range_WTP_base  = [23500 40000];
%     range_WTP_alph  = [9000 12000];
%     range_tau_o     = [0.1 0.5];
%     range_rp_base   = [0.5 1.5];
%     distribution_peakiness = 150;
%     beta_x          = 0.45; 
% end

rcov                = 0.9; % covariance on income and willingness to pay distributions   
[tau_o,WTP_base,rp_base,WTP_alph] = agent_distribution(... % generate wtp/income/risk prem distributions
    rcov,range_WTP_base,range_WTP_alph,range_tau_o,range_rp_base,beta_x,n,distribution_peakiness); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% user cost parameters
delta             = 0.06;             % interest rate (same for investor and owner)
gam               = 0.01;             % depreciation rate on housing capital (same for investor and owner)
epsilon           = 1;                % additional bid for investor
tau_prop          = 0.01*ones(T+5,1); % base property tax rate (same for investor and owner)
tau_c             = 0.22;              % corporate tax rate (just investors) -- U.S. federal rate (could add 2.5% for NC)
m                 = 2000;             % additional investor-only fees of renting the property (just investors)

rp_I     = zeros(1);                  % average risk premium real estate (same for investor and owner)
rp_o     = zeros(n,1);                % average risk premium real estate (same for investor and owner)
g_I      = zeros(1);
g_o      = zeros(n,1);
price    = zeros(T,1);
rent     = zeros(T,1);
mkt      = zeros(T,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% agent flux parameters 
adjust_beta_x                 = 1e-7; 
agent_flux_sensitivity_param  = 1e-8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model_vars = {'fieldNames','bta','delta','epsilon','gam','g_o','g_I','m',...
    'mkt','n','price','rent','rp_base','rp_I',...
    'rp_o','tau_c','tau_o','WTP_base','WTP_alph'};
X          = v2struct(model_vars);

agent_dist = {'fieldnames','rcov','range_WTP_base','range_WTP_alph','distribution_peakiness','range_tau_o',...
    'range_rp_base','tau_prop','beta_x','agent_flux_sensitivity_param','adjust_beta_x'};
A          = v2struct(agent_dist);

SV = [];


