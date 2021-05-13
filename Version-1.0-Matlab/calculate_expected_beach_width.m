% function [ACOM,X_NOF,X_OF,X_OF_msd]=calculate_expected_beach_width(ACOM,M,MMT,X_NOF,X_OF,X_OF_msd)
function [ACOM,X_NOF,X_OF]=calculate_expected_beach_width(ACOM,M,MMT,X_NOF,X_OF)

t  = M.time;

% bw var here is historical up to time t, and is predicted and incorporating nourishment for times t+1 to t+10
bw = MMT.bw;

for time = t+1:t+30
    if MMT.nourishtime(time)==1
        bw(time)=MMT.x0;
    else
        bw(time)=bw(time-1)-ACOM.E_ER(t);
    end
end
bw(bw<1) = 1;


%%%%% check for problem here- why 10?
ind=1;
if t>30
    for time = t+1:t+10
        bw_back(ind)=mean(bw(time-29:time));
        ind=ind+1;
    end
else
    for time = t+1:t+10
        bw_back(ind)=mean(bw(time-t:time));
        ind=ind+1;
    end
end

ACOM.Ebw(t)     = mean(bw_back);

X_NOF.WTP{t}    = X_NOF.WTP_base+X_NOF.WTP_alph.*ACOM.Ebw(t)^X_NOF.bta; % expected willingness to pay
X_OF.WTP{t}     = X_OF.WTP_base+X_OF.WTP_alph.*ACOM.Ebw(t)^X_OF.bta; % expected willingness to pay



end






