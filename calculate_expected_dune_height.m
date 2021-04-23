function [ACOM]=calculate_expected_dune_height(ACOM,M,MMT)

t = M.time;

% should pass in a control on backward time depth
if t>29
    ACOM.Edh(t) = mean(MMT.h_dune(t-29:t));
else
    ACOM.Edh(t) = mean(MMT.h_dune(1:t));
end


