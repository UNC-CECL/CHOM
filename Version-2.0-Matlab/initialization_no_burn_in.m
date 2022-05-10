% this is the initialization file

disp('initialize no burn-in...')

[M,MMT,ACOM]            = model_initialize(run_option_main);
[A_NOF,X_NOF,SV_NOF]    = agent_initialize(M.T,ACOM.n_NOF,run_option_main,'back');
[A_OF,X_OF,SV_OF]       = agent_initialize(M.T,ACOM.n_OF,run_option_main,'front');
[~,X_NOF]               = create_scenario(X_NOF,M,run_option_main,'back');
[M,X_OF]                = create_scenario(X_OF,M,run_option_main,'front');

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
BPB=[];
BPC=[];
X_OF.price(1) = X_OF.P_e(1);
X_NOF.price(1) = X_NOF.P_e(1);

t=1;
M.time = 1;
[ACOM] = agent_assign_properties(ACOM,X_OF,X_NOF,M);
save_dynamic_var;
MMT.netbenNOF_priceincrease(1) = NaN;
MMT.netbenNOF_taxburden(1)     = NaN;
MMT.netbenNOF_total(1)         = NaN;
MMT.netbenOF_priceincrease(1)  = NaN;
MMT.netbenOF_taxburden(1)      = NaN;
MMT.netbenOF_total(1)          = NaN;
M.burn_in = 0;
BPC = [];
BPC.last_payed_nourish=2;
BPC.last_plan_start=0;
[bw,nourish_xshore,nourish_yr,mbw] = evaluate_nourishment_future_beach_width(ACOM,M,MMT,MMT.nourish_plan_horizon+1);
ACOM.Ebw(1) = mean(bw);

flag_out = 0;

clearvars -except SV_* X_OF X_NOF M MMT ACOM A_OF A_NOF plotstarttime filetag run_option* input_sea_level flag_out parm er_rate BPC
