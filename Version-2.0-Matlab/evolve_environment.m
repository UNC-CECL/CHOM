function [MMT,ACOM]=evolve_environment(ACOM,M,MMT,run_model_options)

% run_option=run_option_init;

t = M.time;

if MMT.nourishtime(t,1) == 1 & MMT.nourishtime(t,2)==1
    MMT.bw(t) = MMT.x0;
    ACOM.E_ER(t) = ACOM.theta_er*M.ER_bw(t)+(1-ACOM.theta_er)*ACOM.E_ER(t-1);
else
    MMT.bw(t) = MMT.bw(t-1)-M.ER_bw(t);
    ACOM.E_ER(t) = ACOM.theta_er*M.ER_bw(t)+(1-ACOM.theta_er)*ACOM.E_ER(t-1);
end

if MMT.builddunetime(t) == 1
    MMT.h_dune(t) = MMT.h0;
else
    MMT.h_dune(t) = MMT.h_dune(t-1)-M.ER_d(t);
end

if MMT.bw(t)<1 % keep beach width positive valued if width low
    MMT.bw(t)=1;
end

if MMT.h_dune(t)<0.1
    MMT.h_dune(t)=0.1;
end