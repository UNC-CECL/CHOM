function [E,M,X,A,F,Tfinal] = model_initialize;

T                 = 400;            % total time

% owner agent
mWTP              = [1000 2000];    % base willingness to pay distribution bounds
mtau_o            = [0.10 0.30];    % income tax bracket (0 to 0.37)
mrp               = [-0.16 -0.155]; % base risk premium distribution - random distribution of shifts to base risk premium (could be correlated with other distributions)
m                 = 2000;           % investor-only fees of renting the property (just investors)

% nourishment
bta               = 0.2;         % beach width beta ~ alpha * (beachwidth) ^ beta
alph              = 20000;       % beach width alpha ~ alpha * (beachwidth) ^ beta
amort             = 5;           % nourishment loan repayment schedule (amortization period) yrs
nourish_plan_horizon = 10;       % nourishment commitment length (commits to several nourshments over 10 yrs)
expectation_horizon  = 30;       % length of time homeowners consider flow of values 
Ddepth            = 10;          % nourishment depth meters
lLength           = 3000;        % alongshore length of nourishment project
sandcost          = 20;          % unit cost of sand $/m^3
fixedcost_beach   = 1e6;         % fixed cost of nourishment
fixedcost_dune    = 5e5;         % fixed cost of dune building
tax_ratio         = 1;

% agents/ user cost
n                 = 1000;        % number of agents
delta             = 0.06;        % interest rate (same for investor and owner)
gam               = 0.01;        % depreciation rate on housing capital (same for investor and owner)
HV                = 10000;       % annualized value of housing services (same for investor and owner)

rp_I              = zeros(1);    % average risk premium real estate (same for investor and owner)
rp_o              = zeros(n,1);  % average risk premium real estate (same for investor and owner)
rp_dune           = 0.18;
rp_storm          = 0;

epsilon           = 1;              % additional bid for investor
tau_prop          = 0.01*ones(T,1); % base property tax rate (same for investor and owner)
tau_c             = 0.2;            % corporate tax rate (just investors) -- U.S. federal rate (could add 2.5% for NC)
param             = 3;              % choose 1 for uncorrelated wtp and tau_o, 2 for correlated
[tau_o,WTP_base,rp_base] = agent_distribution(mWTP,mtau_o,mrp,n,param); % generate agent variables

g_I               = 0.03;
g_o               = 0.03;
% g_o(1:n/2,:)      = 0.03;
% g_o(n/2+1:end,:)  = 0.03;

horizon           = 50;            % discounting time horizon (50 yrs) for nourishment benefits-cost
Tfinal            = T-horizon;       %
x0                = 100;           % initial beach width of a community (m)
erosion_rate      = [];            % perceived erosion rate
theta_er          = 0.5;

price             = zeros(T,1);
rent              = zeros(T,1);
mkt               = zeros(T,1);
bw                = zeros(T,1);
bw_halftime       = zeros(T,2); 
t_halftime        = zeros(T,2);
price(1)          = 9e5;
rent(1)           = 10000;
mkt(1)            = 0.5;
bw(1)             = x0;

% some other stuff related to agent population equation
P_e                  = 1.3e6*ones(T,1); % external economic forcing 
a                    = 0.0001;

% Community Composition
share_oceanfront = 0.25; % Share of oceanfront properties in the community, increments of 0.01
share_owner      = 0.4;  % Share of owner-occupied propertie s in the community, increments of 0.01

% property col(1) denotes oceanfront =1
%          col(2) denotes owner occupied = 1
property            = ones(n,2);
rdraw               = randperm(n,n);               % random shuffle properties
rassign             = rdraw(1:round((1-mkt(1))*n)); % randomly assign resident owners to property locations
property(rassign,1) = 1;
rdraw               = randperm(n,n);               % random shuffle properties
rassign             = rdraw(1:round((1-mkt(1))*n)); % randomly assign resident owners to property locations
property(rassign,2) = 1; % mkt(t) is the fraction of

dunebens             = zeros(T,1);
duneheight_max       = 7;

H                    = 1000;
er                   = zeros(T,1);      
Ebw                  = zeros(T,1);
beach_plan           = 11+zeros(T,1);
h_dune               = zeros(T,1);   
h_dune(1)            = 7;

tax_param  = {'fieldNames','horizon','x0','amort','nourish_plan_horizon','expectation_horizon','share_oceanfront','share_owner'};
E          = v2struct(tax_param);
econ_param = {'fieldNames','tax_ratio','delta','gam','HV','m','rp_base','rp_dune','rp_storm','g_o',...
                'g_I','rp_I','rp_o','epsilon','tau_c','n','tau_o','WTP_base','bta','alph','horizon','T',...
                'erosion_rate','Ddepth','sandcost','lLength','fixedcost_beach','fixedcost_dune','P_e','duneheight_max','H'};
M          = v2struct(econ_param);
model_vars = {'fieldNames','price','rent','mkt','bw','property','tau_prop','dunebens','n','h_dune','er','beach_plan','bw_halftime','t_halftime'};
X          = v2struct(model_vars);
agent_dist = {'fieldnames','mWTP','mtau_o','mrp','a','theta_er'};
A          = v2struct(agent_dist);


% recent - 
X.n        = zeros(T,1); % from agent pop, may change 
X.n(1)     = n;
% some environmental forcing 
F.ER                   = linspace(1,3,Tfinal); %+randn(1,Tfinal);
F.lam_storm            = 3;
F.storms               = poissrnd(F.lam_storm, Tfinal,1);
% also throw these into X
X.nourishtime          = zeros(T,1);        
X.newplan              = zeros(T,1);
X.builddunetime        = zeros(T,1);
X.er(1)=2;





















