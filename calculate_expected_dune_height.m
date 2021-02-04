function [X]=calculate_expected_dune_height(X)

t = X.time;

% should pass in a control on backward time depth
if t>10
    X.mdh(t) = mean(X.h_dune(t-9:t));
else
    X.mdh(t) = mean(X.h_dune(1:t));
end


