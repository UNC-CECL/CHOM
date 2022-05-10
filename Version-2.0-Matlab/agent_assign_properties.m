function [ACOM] = agent_assign_properties(ACOM,X_OF,X_NOF,M);

t           = M.time;
n1          = round(ACOM.n_NOF*(1-X_NOF.mkt(t))); 
n2          = round(ACOM.n_OF*(1-X_OF.mkt(t)));
ACOM.I_own  = zeros(ACOM.n_NOF+ACOM.n_OF,1);
NOF_indices = [1:ACOM.n_NOF]; 
OF_indices  = [ACOM.n_NOF+1:ACOM.n_NOF+ACOM.n_OF];
ACOM.I_own(NOF_indices(1:n1)) = 1;
ACOM.I_own(OF_indices(1:n2))  = 1;