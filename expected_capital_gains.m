function [X,SV] = expected_capital_gains(ACOM,A,M,MMT,X,OF,SV,P_e,n);

t   = M.time;

% bubbly component
capgain_feedbackparam = A.capgain_feedbackparam;
risk_to_EnvExptdGains = A.risk_to_EnvExptdGains;
theta     = 0.25;
gamma     = 0.25;
a = 2; b = 10;
Price     = mean(X.price(t-2:t-1));
meandiff1 = mean(X.price(t-2:t-1)-P_e(t-2:t-1));
meandiff2 = mean(P_e(t-2:t-1)-X.price(t-2:t-1));

% % % form suggest for use in Dieci_inprint
% vu=100/(mean(P_e(t-2:t-1))^2);
% vl=vu;
% cl=10000/(mean(P_e(t-2:t-1))^3); % making smaller increases feedback at small differences
% cu=cl;
% if Price<mean(P_e(t-2:t-1))
%     capgain_feedbackparam=vl-cl*(Price-mean(P_e(t-2:t-1)));
% else
%     capgain_feedbackparam=vu+cu*(Price-mean(P_e(t-2:t-1)));
% end

w         = 1/(1+capgain_feedbackparam*(meandiff1).^2);
y2        = -(b-a)*w+b;
y1        = (b-a)*w+a;
f         = betarnd(y1,y2,n,1);
Pe_tplus1 = f*(X.price(t-1)+gamma*(meandiff1))+(1-f)*(X.price(t-1)+theta*(meandiff2));
Eg_bubbly = (Pe_tplus1-X.price(t-1))/X.price(t-1);

% % % environtmental component
Eg_beliefs          = -risk_to_EnvExptdGains*X.rp_o; % environmental expectations 
env_risk_exposure   = 1-X.rp_o/A.env_risk_immediacy; %  (denom is max risk exposure)  % note this MUST be made to vary between 0 and 1 - so at start, make sure the barr elev is 1
                                        
I_realist           = A.I_realist;

% add components together
find_realist           = find(I_realist==1);
X.g_o(find_realist)    = env_risk_exposure(find_realist).*Eg_bubbly(find_realist) + (1-env_risk_exposure(find_realist)).*Eg_beliefs(find_realist); % as the risk goes up, realists stop caring about arbitrage component
find_surrealist        = find(I_realist==0);
X.g_o(find_surrealist) = Eg_bubbly(find_surrealist);

env_risk_exposure   = 1-X.rp_I/A.env_risk_immediacy;
Eg_beliefsI         = -risk_to_EnvExptdGains*X.rp_I; 
X.g_I               =  env_risk_exposure*0.03 + (1-env_risk_exposure)*Eg_beliefsI; 
