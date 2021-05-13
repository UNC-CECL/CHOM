
function [MMT,ACOM]=evolve_environment(ACOM,M,MMT)

t = M.time;

if MMT.nourishtime(t) == 1                  % if nourish is scheduled
    MMT.bw(t) = MMT.x0;
    ACOM.E_ER(t) = ACOM.theta_er*M.ER(t)+(1-ACOM.theta_er)*ACOM.E_ER(t-1);
else
    MMT.bw(t) = MMT.bw(t-1)-M.ER(t);
    ACOM.E_ER(t) = ACOM.theta_er*M.ER(t)+(1-ACOM.theta_er)*ACOM.E_ER(t-1);
end

if  M.storms(t)==1
    damage=(0.3+(0.3)*rand(1));
    if MMT.nourishtime(t)==1
        MMT.bw(t)=MMT.x0*damage;
        MMT.h_dune(t) = MMT.h0*damage;
    else
        MMT.bw(t)= MMT.bw(t-1)*damage;
        MMT.h_dune(t) = MMT.h_dune(t-1)*damage;
        
    end
end

if MMT.bw(t)<1
    MMT.bw(t)=1;
end

% dunes - build, keep the same, wipeout due to storm
if MMT.builddunetime(t) == 1             % if dune build is scheduled
    MMT.h_dune(t) = MMT.h0;              % then build it back up
end

if MMT.builddunetime(t)==0 & M.storms(t) > 0   % for demonstration purposes only, if storm value greater than 5, then destoy dunes
    MMT.h_dune(t) = 0;
end

if MMT.builddunetime(t)==0
    MMT.h_dune(t) = MMT.h_dune(t-1)-0.2; % or else keep them the same
    if MMT.h_dune(t)<0.1
        MMT.h_dune(t)=0.1;
    end
end







