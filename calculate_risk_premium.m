function [M]=calculate_risk_premium(A,M,X)

t = X.time;

for ii=1:M.n
    M.rp_o(ii) = M.rp_base(ii) + M.rp_dune/X.mdh(t)^.05;
    %     M.rp_o(ii) = M.rp_base(ii) + M.rp_storm/X.mlamda_storm(t) + M.rp_dune/X.mdh(t)^.05;
end

M.rp_I = mean([A.mrp(1) A.mrp(2)]) + M.rp_dune/X.mdh(t)^.05;



