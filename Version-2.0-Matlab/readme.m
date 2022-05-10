
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% structures have suffixes: _OF and _NOF referring to OceanFront and 
% Non-OceanFront markets respectively.
%
% structures and contents:
%
%       M:          model forcing variables. Contains model forcing time series:
%                   -   ER              Erosion rate forcing time series,   size [T,1]
%                   -   storms          storm time series,                  size [T,1]
%                   -   msl             mean sea level starts               size [T,1]
%       MMT:        management related variables. Contains beach and dune management stuff
%       ACOM:       variables common to all agents
%                   -   Ebw             Expected beach width,               size [T,1]
%                   -   Edh             expected dune height,               size [T,1]
%                   -   E_ER            expected erosion rate,              size [T,1]
%       A_OF/A_NOF: front/back row specific agent stuff. Distribution bounds
%                   for income/WTP/baseriskpremium/property tax/
%       X_OF/X_NOF: economic variables, user cost parameters:
%                   -   price           equilbrium price,                   size [T,1]
%                   -   P_e/P_e         outside markets time series,        size [T,1]
%                   -   mkt             market share,                       size [T,1]
%                   -   rent            rent                                size [T,1]
%                   -   g_o             owner expected capital gains,       size [1,n]
%                   -   g_I             invester capital gains,             size [1]
%                   -   rp_base         base risk premium,                  size [n,1]
%                   -   rp_I            investor risk premium,              size [1]
%                   -   rp_o            owner risk premium,                 size [n,1]
%                   -   tau_o           owner income,                       size [n,1]
%                   -   WTP_base        base willingness to pay,            size [n,1]
%                   -   WTP_alph        alpha component willingness to pay, size [n,1]
%                   -   WTP             total willingness to pay,           size [n,1]
%                   -   Ouc             owner user cost (UC denominator),   size [n,1]
%                   -   P_o             owner bid prices,                   size [n,T]
%      SV_OF/_NOF: saving variables from X_OF/X_NOF for each time step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%