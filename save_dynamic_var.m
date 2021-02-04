% store for analysis
X.oUC(t)         = mean((M.delta+X.tau_prop(t)).*(1-mean(M.tau_o))+ M.gam + M.rp_o-M.g_o);
X.iUC(t)         = ((M.delta+X.tau_prop(t))*(1-M.tau_c)+ M.gam +M.rp_I-M.g_I);
X.mRP(t)         = mean(M.rp_o);
X.sRP(t)         = std(M.rp_o);
X.meantau(t)     = mean(M.tau_o);
X.stdtau(t)      = std(M.tau_o);

if X.nourishtime(t+1)==1
    X.planbenefit_beach(t) = BP.ben_min_taxburden(BP.beach_plan);
else
    X.planbenefit_beach(t) = max(BP.ben_min_taxburden(1:10));
end




