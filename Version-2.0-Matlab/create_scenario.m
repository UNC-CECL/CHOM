function [M,X]=create_scenario(X,M,run_option,row)

ER_bw    = zeros(M.T,1);
ERbw1    = run_option.beach_ER(1);
ERbw2    = run_option.beach_ER(2);

ER_d     = zeros(M.T,1);
ERd1     = run_option.dune_ER(1);
ERd2     = run_option.dune_ER(2);

msl      = zeros(M.T,1);
msl1     = run_option.sea_level(1);
msl2     = run_option.sea_level(2);

P_e      = zeros(M.T,1);
POF1     = run_option.outside_market_OF(1);
POF2     = run_option.outside_market_OF(2);
PNOF1    = run_option.outside_market_NOF(1);
PNOF2    = run_option.outside_market_NOF(2);

if run_option.name == 'init'
    
    ER_bw          = ERbw1 + zeros(M.T,1);
    msl            = msl1+zeros(M.T,1);
    
    if strcmp(row,'front')
        P_e  = POF1*ones(M.T,1);   % new 5/9   % external economic forcing
    else
        P_e  = PNOF1*ones(M.T,1);   % new 5/9   % external economic forcing
    end
    
end

if run_option.name == 'main'
    t1                = run_option.environ_changepts(1);
    t2                = run_option.environ_changepts(2);
    ER_bw(1 :t1)      = ERbw1;
    ER_bw(t1+1 :t2)   = linspace(ERbw1,ERbw2,t2-t1);
    ER_bw(t2 +1 :end) = ERbw2;
    ER_d(1 :t1)       = ERd1;
    ER_d(t1+1 :t2)    = linspace(ERd1,ERd2,t2-t1);
    ER_d(t2 +1 :end)  = ERd2;
    msl(1 :t1)        = msl1;
    msl(t1+1 :t2)     = linspace(msl1,msl2,t2-t1);
    msl(t2 :end)      = msl2;
    
    t1          = run_option.outside_mkt_changepts(1);
    t2          = run_option.outside_mkt_changepts(2);
    if strcmp(row,'front')
        P_e(1 :t1)      = POF1;
        P_e(t1+1 :t2)   = linspace(POF1,POF2,t2-t1);
        P_e(t2 +1 :end) = POF2;
    else
        P_e(1 :t1)      = PNOF1;
        P_e(t1+1 :t2)   = linspace(PNOF1,PNOF2,t2-t1);
        P_e(t2 +1 :end) = PNOF2;
    end
end

M.ER_bw = ER_bw;%+0.25*randn(size(ER_bw));
M.ER_d  = ER_d;
M.msl   = msl;
X.P_e   = P_e;
