% function [X_NOF,X_OF,X_OF_msd]=calculate_risk_premium(ACOM,A_NOF,A_OF,A_OF_msd,M,X_NOF,X_OF,X_OF_msd);
function [X]=calculate_risk_premium(ACOM,A,M,X,MMT);

t = M.time;

if t>5
    if sum(M.storms(t-5:t))~=0
        storm_flag=1;
        storm_time=M.storms(t-5:t);
        for ii=2:6
            if storm_time(ii)~=1 & storm_time(ii-1)>0
                storm_time(ii)=storm_time(ii-1)-0.2;
            end
            storm_salience=0.03*storm_time(end);
        end
    else
        storm_flag=0;
    end
else
    storm_flag=0;
end

p1=1/(M.barr_elev-M.msl(t))^.2;
p2=1/(2+ACOM.Edh(t)^.2*((M.barr_elev-M.msl(t))));
for ii=1:size(X.rp_o,1)
    
    if A.I_realist(ii)==0
        X.rp_o(ii) = 0.2*p1*p2-X.rp_base(ii);
    end
    
    if A.I_realist(ii)==1 & storm_flag==0
        X.rp_o(ii) = 0.2*p1*p2-X.rp_base(ii);
    end
    
    if A.I_realist(ii)==1 & storm_flag==1
        X.rp_o(ii) = 0.2*p1*p2-X.rp_base(ii)+storm_salience;
    end
    
end

X_rpI_base=mean(A.range_rp_base);
X.rp_I = 0.2*p1*p2-X_rpI_base;
