function [X]=calculate_expected_beach_width(X,M)

t = X.time;
% should pass in a control on backward time depth
if t>30
    X.Ebw(t) = mean(X.bw(t-29:t));
else
    X.Ebw(t) = mean(X.bw(1:t));
end

 X.WTP(:,t) = M.WTP_base+M.alph*X.Ebw(t)^M.bta; % expected willingness to pay

