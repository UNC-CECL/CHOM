function [M,MMT,ACOM] = model_initialize(n)
T                    = 550;              % total time

% params to set
bta_NOF              = 0.1;              % 
bta_OF               = 0.2;              % 
share_OF             = 0.25;             % Share of oceanfront properties in the community, increments of 0.01
taxratio_OF          = 4;                % 
theta_er             = 0.5;              % erosion rate update param 
lam_storm            = 1/20;             %
sandcost             = 10;               % unit cost of sand $/m^3 
fixedcost_beach      = 4e6;              % fixed cost of nourishment 
fixedcost_dune       = 1e6;              % fixed cost of dune building 
nourish_subsidy      = 12e6;
P_e_OF               = 6e5*ones(T,1);   % external economic forcing
P_e_NOF              = 4e5*ones(T,1);   % external economic forcing
% P_e_OF               = linspace(2e5,10e5,T)';
% P_e_NOF              = linspace(10e5,2e5,T)';

% keep fixed
amort                = 5;                % nourishment loan repayment schedule (amortization period) yrs
nourish_plan_horizon = 10;               % nourishment commitment length (commits  several nourshments over 10 yrs)
Ddepth               = 10;               % nourishment depth meters
lLength              = 2000;             % alongshore length of nourishment project 
horizon              = 50;               % discounting time horizon (50 yrs) for nourishment benefits-cost
Tfinal               = T-horizon;        % 
x0                   = 100;              % nourish beach width community 
delta_disc           = 0.06;                              % discount rate

n_NOF                = round(n*(1-share_OF));               
n_OF                 = round(n*(share_OF));  
n_agent_total        = n;
dunebens             = zeros(T,1);                        % dune benefits for storing
h0                   = 4;                                 % nourish dune height
Ebw                  = zeros(T,1);                        % expected beach width store
Edh                  = zeros(T,1);                        % expected dune height store
barr_elev            = 1;                                 % barrier elevation above mean sea level
beach_plan           = 11+zeros(T,1);                     % 
h_dune               = zeros(T,1);                        % 
h_dune(1)            = h0;                                %                
bw                   = zeros(T,1);                        % 
bw(1)                = x0;                                % 
E_ER                 = zeros(T,1);                        % expected erosion rate 
nourishtime          = zeros(T,1);                        % 
newplan              = zeros(T,1);                        % 
builddunetime        = zeros(T,1);                        % 
expectation_horizon  = 30;                                % length of time homeowners consider flow of values

% storms               = poissrnd(lam_storm,T,1);           %
storms=zeros(T,1);
storms(21:20:end)=1;
ER                   = 4*ones(T,1) ;                      % + randn(Tfinal,1);
% ER(101:200)          = linspace(4,7,100);
% ER(201:end)          = 7;
msl                  = zeros(T-horizon,1);
% msl(101:200)         = linspace(0,0.95,100);            % mean sea level (meters)
% msl(201:end)         = 0.95;

I_OF  = zeros(n_agent_total,1);  % boolean indicator for oceanfront
I_own = zeros(n_agent_total,1);  % boolean indicator for owners
I_OF(n_NOF+1:end)       = 1;

model_param      = {'fieldNames','ER','horizon','lam_storm','P_e_OF','P_e_NOF','storms','Tfinal','T','barr_elev','msl'};
M                = v2struct(model_param);
management_param = {'fieldNames','amort','beach_plan','bta_NOF','bta_OF','builddunetime',...
                        'bw','Ddepth','dunebens','fixedcost_beach','fixedcost_dune','h0',...
                        'h_dune','lLength','nourishtime','newplan','nourish_plan_horizon','sandcost','x0','expectation_horizon','delta_disc',...
                        'taxratio_OF','nourish_subsidy'};
MMT              = v2struct(management_param);
agent_common     = {'fieldNames','Ebw','Edh','E_ER','n_NOF','n_OF','share_OF','theta_er','n_agent_total','I_OF','I_own'};
ACOM             = v2struct(agent_common);


