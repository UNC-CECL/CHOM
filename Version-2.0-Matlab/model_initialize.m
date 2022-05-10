function [M,MMT,ACOM] = model_initialize(run_option)
T                     = run_option.time; % total time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

taxratio_OF           = 3;     % Tax ratio of oceanfront to non-oceanfront communities, e.g. == 2,
theta_er              = .5;    % erosion rate update param
sandcost              = 5;     %5; %2; %1; %5; %10;               % unit cost of sand $/m^3
fixedcost_beach       = 1e6;   %1e6; %1e5; % 2e6; 8e6 for high    % fixed cost of nourishment
fixedcost_dune        = 1e5;   %1e6; %1e5;                        % fixed cost of dune building

if isfield(run_option,'subsidy')
    nourish_subsidy       = run_option.subsidy;   % percent of total costs covered
else
    nourish_subsidy=0.9;
end

% 0.9125 if federally sponsored, (65% fed, 75% remaining cost NC = 91.25% total subsidy)
% 0.30 if non-federally sponsored
% see page XII-24 of NC Beach and Inlet management plan, final report
% https://files.nc.gov/ncdeq/Coastal%20Management/documents/PDF/BIMP/BIMP%20Section%20XII%20-%20Funding%20Prioritization%20Formatted.pdf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% either define the number of agents explicity by n and share_OF, or
%%% implicitly by defining the barrier geometry and average house footprint size
%%% define explicitly
% n                    = 2000;   % total number of agents
% share_OF             = 0.50;   % Share of oceanfront properties in the community, increments of 0.01

% nags head estimate - 600 to 800 ocean front homes out of 4884
% oceanfront share somewhere around 12 to 16 percent

% %%% define implicitly
% lLength                = 20000;  % alongshore length of nourishment project
% house_footprint_width  = 30;
% average_interior_width = 250;
% house_footprint_depth  = 50;
% number_rows            = floor(average_interior_width / house_footprint_depth);
% house_units_per_row    = floor(lLength / house_footprint_width);
% n_oceanfront           = house_units_per_row
% n_nonoceanfront        = number_rows*house_units_per_row
% n                      = n_oceanfront + n_nonoceanfront;
% share_OF               = n_oceanfront/n;
lLength                = 9000;  % alongshore length of nourishment project
n_oceanfront           = 500;
n_nonoceanfront        = 2000;
n                      = n_oceanfront + n_nonoceanfront;
share_OF               = n_oceanfront/n;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
amort                = 5;                % nourishment loan repayment schedule (amortization period) yrs
nourish_plan_horizon = 30;               % nourishment commitment length (commits  several nourshments over 10 yrs)
Ddepth               = 20;               % toe depth
horizon              = [];               % discounting time horizon (50 yrs) for nourishment benefits-cost
Tfinal               = T-horizon;        %
x0                   = 70;               % nourish beach width community
delta_disc           = 0.06;             % discount rate
pay_years_ahead      = 10;
barr_elev            = 1;                % barrier elevation above mean sea level
h0                   = 4;                % nourish dune height
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_NOF                = round(n*(1-share_OF));   % number of nonoceanfront agents/units
n_OF                 = round(n*(share_OF));     % number of nonoceanfront agents/units
n_agent_total        = n;                       % total number of agents
dunebens             = zeros(T,1);              % dune benefits for storing
Ebw                  = zeros(T,1);              % expected beach width store
beach_plan           = (nourish_plan_horizon+1)+zeros(T,1);           %
h_dune               = zeros(T,1);              %
E_ER                 = zeros(T,1);              % expected erosion rate
bw                   = zeros(T,1);              %
nourishtime          = zeros(T+nourish_plan_horizon+1, 2); %
newplan              = zeros(T+1,1);              %
builddunetime        = zeros(T+1,1);              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_dune(1)            = run_option.dune_t0;        %
bw(1)                = run_option.beach_t0;       %
Ebw(1)               = run_option.beach_t0;       %
E_ER(1)              = run_option.beach_ER(1);
I_OF                 = zeros(n_agent_total,1);    % index of agents that are front row
I_own                = zeros(n_agent_total,1);    % index of agents who own (back and front rows combined)
I_own(1:round(0.5*n_NOF)) = 1;
I_own(n_NOF+1:n_NOF+1+round(0.5*n_OF)) = 1;
I_OF(n_NOF+1:end) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model_param      = {'fieldNames','horizon','Tfinal','T','barr_elev'};
M                = v2struct(model_param);
management_param = {'fieldNames','amort','beach_plan','builddunetime',...
    'bw','Ddepth','dunebens','fixedcost_beach','fixedcost_dune','h0',...
    'h_dune','lLength','nourishtime','newplan','nourish_plan_horizon','sandcost','x0','pay_years_ahead','delta_disc',...
    'taxratio_OF','nourish_subsidy'};
MMT              = v2struct(management_param);
agent_common     = {'fieldNames','Ebw','E_ER','n_NOF','n_OF','share_OF','theta_er','n_agent_total','I_OF','I_own'};
ACOM             = v2struct(agent_common);


