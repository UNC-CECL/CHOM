% store for analysis


SV.beach_plan(t) = MMT.current_plan;

SV_NOF.meanAWTP_alph(t) = mean(X_NOF.WTP_alph);
SV_NOF.meanAWTP_base(t) = mean(X_NOF.WTP_base);
SV_NOF.meanAtauo(t)     = mean(X_NOF.tau_o);
SV_NOF.meanArp(t)       = mean(X_NOF.rp_o);
SV_NOF.tau_inc{t}       = X_NOF.tau_o;

SV_OF.meanAWTP_alph(t) = mean(X_OF.WTP_alph);
SV_OF.meanAWTP_base(t) = mean(X_OF.WTP_base);
SV_OF.meanAtauo(t)     = mean(X_OF.tau_o);
SV_OF.meanArp(t)       = mean(X_OF.rp_o);
SV_OF.tau_inc{t}       = X_OF.tau_o;

SV_NOF.g_o(t,:)=X_NOF.g_o;
SV_NOF.g_I(t)=X_NOF.g_I;
SV_OF.g_o(t,:)=X_OF.g_o;
SV_OF.g_I(t)=X_OF.g_I;

SV_NOF.rp_o(t,:)= (X_NOF.rp_o);
SV_OF.rp_o(t,:)= (X_OF.rp_o);
SV_NOF.rp_I(t)= (X_NOF.rp_I);
SV_OF.rp_I(t)= (X_OF.rp_I);

SV_OF.beta_x(t)=A_OF.beta_x;
SV_NOF.beta_x(t)=A_NOF.beta_x;
