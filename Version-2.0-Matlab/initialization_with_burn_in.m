% this is the initialization/burn-in file

[M,MMT,ACOM]            = model_initialize(run_option_init);
[A_NOF,X_NOF,SV_NOF]    = agent_initialize(M.T,ACOM.n_NOF,run_option_init,'back');
[A_OF,X_OF,SV_OF]       = agent_initialize(M.T,ACOM.n_OF,run_option_init,'front');
[~,X_NOF]               = create_scenario(X_NOF,M,run_option_init,'back');
[M,X_OF]                = create_scenario(X_OF,M,run_option_init,'front');

SV_NOF.meanAWTP_alph(1) = mean(X_NOF.WTP_alph);
SV_NOF.meanAWTP_base(1) = mean(X_NOF.WTP_base);
SV_NOF.meanAtauo(1)     = mean(X_NOF.tau_o);
SV_NOF.meanArp(1)       = mean(X_NOF.rp_o);
SV_NOF.tau_inc{1}       = X_NOF.tau_o;
SV_NOF.g_o(1,:)         = X_NOF.g_o;
SV_NOF.g_I(1)           = X_NOF.g_I;
SV_NOF.rp_o(1,:)        = (X_NOF.rp_o);
SV_NOF.rp_I(1)          = (X_NOF.rp_I(1));
SV_NOF.beta_x(1)        = A_NOF.beta_x(1);
SV_OF.meanAWTP_alph(1)  = mean(X_OF.WTP_alph);
SV_OF.meanAWTP_base(1)  = mean(X_OF.WTP_base);
SV_OF.meanAtauo(1)      = mean(X_OF.tau_o);
SV_OF.meanArp(1)        = mean(X_OF.rp_o);
SV_OF.tau_inc{1}        = X_OF.tau_o;
SV_OF.g_o(1,:)          = X_OF.g_o;
SV_OF.g_I(1)            = X_OF.g_I(1);
SV_OF.rp_o(1,:)         = (X_OF.rp_o);
SV_OF.rp_I(1)           = (X_OF.rp_I(1));
SV_OF.beta_x(1)         = A_OF.beta_x(1);
M.time = 1;

BPB=[];
BPC=[];
BPC.last_payed_nourish=2;
BPC.last_plan_start=0;

[bw,nourish_xshore,nourish_yr,mbw] = evaluate_nourishment_future_beach_width(ACOM,M,MMT,MMT.nourish_plan_horizon+1);
ACOM.Ebw(1) = mean(bw(2:end));

MMT.current_plan = MMT.nourish_plan_horizon+1;
BPC.mbw = zeros(MMT.nourish_plan_horizon+1,1);
BPC.mbw(MMT.current_plan) = ACOM.Ebw(1);


for t = 2 : run_option_init.time
    tic
    M.time = t;
    % evolve the environmental variables
    [MMT,ACOM]           = evolve_environment(ACOM,M,MMT,run_option_init);
    
    % calculate the risk premium using expected dune height/other environmetnal vars from previous step
    [X_NOF]              = calculate_risk_premium(A_NOF,M,X_NOF,MMT,0);
    [X_OF]               = calculate_risk_premium(A_OF,M,X_OF,MMT,1);
    
    % calculat the cost of all nourishment options
    [BPC,MMT]             = calculate_nourishment_plan_cost(ACOM,M,MMT,X_NOF,X_OF);
    
    % calculate the benefits of each option
    [BPB,BPC]            = calculate_nourishment_plan_ben(A_NOF,A_OF,ACOM,BPC,M,MMT,X_NOF,X_OF);
    
    % evaluate which is the best nourishment plan, agent voting
    [A_NOF,A_OF,MMT,ACOM,X_NOF,X_OF]     = evaluate_nourishment_plans(A_NOF,A_OF,ACOM,BPB,BPC,M,MMT,X_NOF,X_OF,run_option_init);
    
    % decide if dunes will also be built
    [A_NOF,A_OF,MMT]     = calculate_evaluate_dunes(ACOM,M,MMT,X_NOF,X_OF,A_NOF,A_OF);
    
    % calculate the expected capital gains
    [X_NOF,SV_NOF]       = expected_capital_gains(ACOM,A_NOF,M,MMT,X_NOF,0,SV_NOF,ACOM.n_NOF);
    [X_OF,SV_OF]         = expected_capital_gains(ACOM,A_OF,M,MMT,X_OF,1,SV_OF,ACOM.n_OF);
    
    % determine the price and rent
    [X_NOF]              = calculate_user_cost(M,X_NOF,X_NOF.WTP{t},A_NOF.tau_prop(t));
    [X_OF]               = calculate_user_cost(M,X_OF,X_OF.WTP{t},A_OF.tau_prop(t));
    
    % change agent distributions in response to new price
    [A_NOF,X_NOF,SV_NOF] = agent_distribution_adjust(ACOM,A_NOF,X_NOF,M,SV_NOF,0,MMT);
    [A_OF,X_OF,SV_OF]    = agent_distribution_adjust(ACOM,A_OF,X_OF,M,SV_OF,1,MMT);
    
    % assign agent indicators for homeowners (for voting)
    [ACOM]               = agent_assign_properties(ACOM,X_OF,X_NOF,M);
    % save some of the variables
    save_dynamic_var;
    
    if X_OF.price(t) > 1e7 | X_OF.price(t) < 0 | X_NOF.price(t) > 1e7 | X_NOF.price(t) < 0
        disp('price out of bounds')
        return
    end
    
    if t==2
        X_OF.price(1) = X_OF.price(2);
        X_NOF.price(1) = X_NOF.price(2);
    end
    toc1=toc;
    if t==3
        initialize_time_estimate = toc1*(run_option_init.time-t);
        disp(sprintf('%s seconds until initialization complete...',num2str(round(initialize_time_estimate,2))))
    end
    
    subplot(231)
    plot(MMT.bw(1:t))
    subplot(232)
    plot(X_OF.price(1:t))
    subplot(233)
    plot(SV_OF.beta_x(1:t),'k')
    hold on
    plot(SV_NOF.beta_x(1:t),'k')
    hold off
    ylabel('\beta x')
subplot(234)
    plot(X_OF.mkt(1:t),'k')
    hold on
    plot(X_NOF.mkt(1:t),'k')
    hold off
ylabel('mkt share')
    drawnow
    
subplot(235)    
    hist(X_OF.rp_base)
    xlim([.5 1.5])
    subplot(236)
    hist(X_OF.tau_o)
    xlim([0 0.4])
    
    
end

flag_out = 0 ;

if ~run_option_init.nourish_off
    if sum(MMT.nourishtime)>0
        last_nourish=find(MMT.nourishtime==1);
        last_nourish=last_nourish(end);
        if MMT.bw(end)<20
            disp('initialization no good')
            disp('consider changing nourishment cost parameters')
            disp('paused')
            flag_out = 1;
            
        end
    end
end

% to make sure burn in is grabbing an appropriate range of
% beta_x values - plot beta_x time series and the median of the last N beta_x values
median_betax_of  = median(SV_OF.beta_x(run_option_init.time-29:run_option_init.time));
median_betax_nof = median(SV_NOF.beta_x(run_option_init.time-29:run_option_init.time));
% 
% subplot(221)
% plot([1:run_option_init.time],X_OF.price(1:run_option_init.time),'b')
% hold on
% plot([1:run_option_init.time],X_NOF.price(1:run_option_init.time),'r')
% plot([1:run_option_init.time],X_OF.P_e(1:run_option_init.time),'k','linewidth',1)
% plot([1:run_option_init.time],X_NOF.P_e(1:run_option_init.time),'k','linewidth',1)
% legend('NOF','OF','P_e OF','P_e NOF')
% xlim([1 run_option_init.time]); xlabel('time')
% ylabel('price')
% title('model initialization')
% 
% subplot(223)
% MMT.newplan(MMT.newplan==0)=NaN;
% plot([1:run_option_init.time],MMT.bw(1:run_option_init.time),'k','linewidth',1)
% hold on
% plot([1:run_option_init.time],ACOM.Ebw(1:run_option_init.time),'color',[.5 0 .5],'linewidth',3)
% plot([1:run_option_init.time],102*MMT.newplan(1:run_option_init.time),'rx')
% ylabel('beach width')
% legend('bw_t','E_t[bw]_{t+1}')
% xlim([1 run_option_init.time]); xlabel('time')
% ylim([0 105])
% 
% subplot(222)
% plot([1:run_option_init.time],SV_OF.beta_x(1:run_option_init.time),'k')
% hold on
% plot(run_option_init.time-9:run_option_init.time,median_betax_of*ones(10,1),'r','linewidth',2)
% legend('beta x','median last 10')
% ylabel('OF \beta_x')
% xlabel('time')
% ylim([0 1])
% 
% subplot(224)
% plot([1:run_option_init.time],SV_NOF.beta_x(1:run_option_init.time),'k')
% hold on
% plot(run_option_init.time-9:run_option_init.time,median_betax_nof*ones(10,1),'r','linewidth',2)
% legend('beta x','median last 10')
% ylabel('NOF \beta_x')
% xlabel('time')
% ylim([0 1])
% pause(0.1)

X_OFinit  = X_OF;
X_NOFinit = X_NOF;
ACOMinit  = ACOM;
MMTinit   = MMT;
% re-initialize physical environmental variables
[M,MMT,ACOM]   = model_initialize(run_option_main);

% generate new scenarios if different from 1
[A_NOF,X_NOF,~] = agent_initialize(M.T,ACOM.n_NOF,run_option_main,'back');
[A_OF,X_OF,~]   = agent_initialize(M.T,ACOM.n_OF,run_option_main,'front');
[~,X_NOF]       = create_scenario(X_NOF,M,run_option_main,'back');
[M,X_OF]        = create_scenario(X_OF,M,run_option_main,'front');

% start agent variables at appropriate values based on burn in
A_OF.beta_x     = median(SV_OF.beta_x(run_option_init.time-9:run_option_init.time))
A_NOF.beta_x    = median(SV_NOF.beta_x(run_option_init.time-9:run_option_init.time))
X_OF.price(1)   = X_OFinit.price(run_option_init.time);
X_NOF.price(1)  = X_NOFinit.price(run_option_init.time);
X_OF.mkt(1)     = X_OFinit.mkt(run_option_init.time);
X_NOF.mkt(1)    = X_NOFinit.mkt(run_option_init.time);
X_OF.rent(1)    = X_OFinit.rent(run_option_init.time);
X_NOF.rent(1)   = X_NOFinit.rent(run_option_init.time);
X_OF.WTP_alph   = X_OFinit.WTP_alph;
X_OF.WTP_base   = X_OFinit.WTP_base;
X_OF.rp_base    = X_OFinit.rp_base;
X_NOF.WTP_alph  = X_NOFinit.WTP_alph;
X_NOF.WTP_base  = X_NOFinit.WTP_base;
X_NOF.rp_base   = X_NOFinit.rp_base;
X_OF.tau_o      = X_OFinit.tau_o;
X_NOF.tau_o     = X_NOFinit.tau_o;

OF_capgains = SV_OF.g_o(end-10:end,:);
NOF_capgains = SV_NOF.g_o(end-10:end,:);
A_OF.burn_in_capgains = OF_capgains(:);
A_NOF.burn_in_capgains = NOF_capgains(:);

X_OF.rp_o    = X_OFinit.rp_o;
X_OF.rp_I    = X_OFinit.rp_I;
X_NOF.rp_o   = X_NOFinit.rp_o;
X_NOF.rp_I   = X_NOFinit.rp_I;

ACOM.E_ER(1) = M.ER_bw(1);
% if ~run_option_init.nourish_off
%     findbw_state = find(MMTinit.bw==100);
%     ACOM.Ebw(1)   = ACOMinit.Ebw(findbw_state(end));
% else
%     ACOM.Ebw(1) = MMT.x0 - 3.5 *M.ER_bw(1);
% end

% clear saving structures
SV_NOF.meanAWTP_alph(2:end) = 0;
SV_NOF.meanAWTP_base(2:end) = 0;
SV_NOF.meanAtauo(2:end)     = 0;
SV_NOF.meanArp(2:end)       = 0;
SV_NOF.g_o(2:end,:)         = 0;
SV_NOF.g_I(2:end)           = 0;
SV_NOF.rp_o(2:end,:)        = 0;
SV_NOF.rp_I(2:end)          = 0;
SV_NOF.beta_x(2:end)        = 0;
SV_OF.meanAWTP_alph(2:end)  = 0;
SV_OF.meanAWTP_base(2:end)  = 0;
SV_OF.meanAtauo(2:end)      = 0;
SV_OF.meanArp(2:end)        = 0;
SV_OF.g_o(2:end,:)          = 0;
SV_OF.g_I(2:end)            = 0;
SV_OF.rp_o(2:end,:)         = 0;
SV_OF.rp_I(2:end)           = 0;
SV_OF.beta_x(2:end)         = 0;

for it=2:t
    SV_NOF.tau_inc{t}       = [];
    SV_OF.tau_inc{t}        = [];
end

% time starts at 2, so we don't want anything showing up in the net benefits plots
MMT.netbenNOF_priceincrease(1) = NaN;
MMT.netbenNOF_taxburden(1)     = NaN;
MMT.netbenNOF_total(1)         = NaN;
MMT.netbenOF_priceincrease(1)  = NaN;
MMT.netbenOF_taxburden(1)      = NaN;
MMT.netbenOF_total(1)          = NaN;

M.time = 1;
[ACOM] = agent_assign_properties(ACOM,X_OFinit,X_NOFinit,M);
t      = 1;
BPC.last_payed_nourish=2;
BPC.last_plan_start=0;
[bw,nourish_xshore,nourish_yr,mbw] = evaluate_nourishment_future_beach_width(ACOM,M,MMT,MMT.nourish_plan_horizon+1);
ACOM.Ebw(1) = mean(bw(2:end));
save_dynamic_var;% save the starting variables from burn in
clearvars -except SV_* X_OF X_NOF M MMT ACOM A_OF A_NOF plotstarttime filetag run_option* input_sea_level flag_out er_rate parm
% rand('state',2); randn('state',2); % reseed the random vars
