function [X]=calculate_risk_premium(A,M,X,MMT,OF);


% X = X_OF;
% A = A_OF;

% risk premium components: 1) barrier height relative to sea level (sunny day flooding)
%                          2) dune height (protection from storms) 
%                          3) risk premium for front row homes 
%                          3) heterogeneous agent risk tolerance 

a = 365;
b = 200;
c = 5;
d = 0.1;
e = 0.04;
f = 0.02;
dune_height_risk_param = 8;


OF = 1;
t = M.time;
MSL = M.msl(t)^2.5;

% % % (1)
height_above_msl       =  (M.barr_elev-MSL); 
num_sunny_day_flood    = a*(1-height_above_msl);
% sunny_day_flood_premium   = num_sunny_day_flood/365;                             % convert number of sunny day floods to risk premium 
sunny_day_flood_premium = (num_sunny_day_flood^1)/(365^1);

X.num_sunny_day_floods_and_premium(t,:)=[num_sunny_day_flood sunny_day_flood_premium];
% t = M.time;
% % % (1)
% sea_level_rel_to_barrier  = 1 - (M.barr_elev-MSL); 
% num_sunny_day_flood       = a ./ (1 + b*exp( -c * sea_level_rel_to_barrier )); % logistic function 
% sunny_day_flood_premium   = num_sunny_day_flood/a;                             % convert number of sunny day floods to risk premium 

% % (2)
storm_risk_increases_with_sea_level = 1 + d / ( M.barr_elev-MSL );
% dunes_reduce_storm_risk             = MMT.h_dune(t)/MMT.h0;
dunes_reduce_storm_risk             = 1-exp(-dune_height_risk_param*(MMT.h_dune(t)/MMT.h0)^2);
dune_premium                        = e * (storm_risk_increases_with_sea_level - dunes_reduce_storm_risk);

% % (3)
front_row_risk = OF * f;

% % (4)
agent_risk_tolerance    = X.rp_base;
investor_risk_tolerance = 1;
for ii=1:X.n
      X.rp_o(ii) = (sunny_day_flood_premium + dune_premium + front_row_risk) *agent_risk_tolerance(ii);      
end

X.rp_o(X.rp_o>1)=1;
X.rp_o(X.rp_o<0)=0;

X.rp_I = (sunny_day_flood_premium + dune_premium + front_row_risk) * investor_risk_tolerance;
if X.rp_I > 1
    X.rp_I=1;
end
if X.rp_I<0
    X.rp_I=0;
end







% % ref: patterns and projections of high tide flooding along the us coastline using a common impact threshold
% msl=linspace(0,1,100);
% for t=1:100
%     number_sunny_day_floods(t) = 565./(1.5+400*exp(-12*msl(t)));
% end
% close all
% plot(number_sunny_day_floods(1:80))
% % % 
% % plot(msl,number_sunny_day_floods)
% % xlabel('mean sea level')
% ylabel('numberof sunny day floods')
% 
% barr_elev=1;
% risk_prem_sunny_day = number_sunny_day_floods/365;
% rel_barr_height = barr_elev - msl;
% plot(rel_barr_height,risk_prem_sunny_day)
% xlabel('barrier height relative to sea level')
% ylabel('risk premium - sea level component')
% 
% 
% % filename='C:\Users\Zack\Desktop\riskprem3';
% % set(gcf, 'PaperPosition', [0 0 6 5]); %Position plot at left hand corner with width 5 and height 5.
% % set(gcf, 'PaperSize', [6 5]); 
% % % print('-dpdf','-painters',filename)
% % 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd C:\Users\Zack\Dropbox\coastal_housing\coastal_housing\10_June_2021\ver1
% clear all; close all; format compact; rand('state',2); % randn('state',2); beep off
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%         Coastal Home Ownership Model CHOM         %%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % define run times          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time_initialization         = 400;              % initialization/burn-in time
% time_simulation             = 400;             % main model run time
% % initialization options    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize_model            = true;            % include a burn-in/spin-up before model simulation
% nourishoff_initialize       = false;            % nourishment off ( = true), nourishment on ( = false)
% beach_width_ER_initialize   = .8;               % beach erosion rate over duration of initialization
% beach_width_t0_initialize   = 90;              % initial beach width (fixed width if beach_width_ER_initialize = 0)
% dune_height_ER_initialize   = .01;               % dune erosion rate over duration of initialization
% dune_height_t0_initialize   = 4;               % initial dune height (fixed height if dune_height_ER_initialize = 0)
% sea_level_initialize        = 0;               % mean sea level over duration of initialization
% % main run options          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nourishoff_main             = false;           % turn nourishment off during main simulation
% beach_width_t0_main         = 90;              % beach width at startup
% dune_height_t0_main         = 4;               % dune height at startup
% beach_width_ER_main         = [ 0.8    ,  5 ];      % beach erosion rate (m/yr), [initial time, final time]
% dune_height_ER_main         = [ 0.01 ,  0.01 ];   % dune erosion rate ,  [initial time, final time]
% sea_level_main              = [ 0    ,  1 ];    % mean sea level,     [initial time, final time]
% environ_changepts           = [ 1   , 400 ];     % start and stop time for increase in ER/sea level
% % outside market option     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% outside_market_OF           = [ 6e5 , 1.00 * 6e5 ];  %
% outside_market_NOF          = [ 4e5 , 1.00 * 4e5 ];  %
% outside_market_changepts    = [ 51  , 150 ]; % start(1) stop(2) time for outside market change
% % initialization values are column 1 only
% % main simulation values start in column 1, and end at column 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_run_option
% [M,MMT,ACOM]            = model_initialize(run_option_main);
% [A_NOF,X_NOF,SV_NOF]    = agent_initialize(M.T,ACOM.n_NOF,'back');
% [A_OF,X_OF,SV_OF]       = agent_initialize(M.T,ACOM.n_OF,'front');
% [~,X_NOF]               = create_scenario(X_NOF,M,run_option_main,'back');
% [M,X_OF]                = create_scenario(X_OF,M,run_option_main,'front');
% for t=2:400
%     MMT.h_dune(t)=MMT.h_dune(t-1)-M.ER_d(t);
% end
% OF=0
% clear rp_o
% 
% for tm = 1:400
%     for td=1:399
%         % % (1)
%         sea_level_rel_to_barrier  = 1 - (M.barr_elev-M.msl(tm));
%         num_sunny_day_flood       = 365./(1+300*exp(-10*sea_level_rel_to_barrier));
%         sunny_day_flood_premium   = num_sunny_day_flood/365;
%         % % (2)
%         storm_risk_increases_with_sea_level = 1 + 0.1/(M.barr_elev-M.msl(tm));
%         dunes_reduce_storm_risk             = MMT.h_dune(td)/MMT.h0;
%         dune_premium                        = 0.04*(storm_risk_increases_with_sea_level - dunes_reduce_storm_risk);
%         % % (3)
%         front_row_risk = OF * 0.02;
%         % % (4)
%         agent_risk_tolerance    = 1;     
%         rp_o(tm,td) = (sunny_day_flood_premium + dune_premium + front_row_risk) * 1;
%     end
% end
% 
% min(rp_o(:))
% max(rp_o(:))
% [C,h]=contourf(MMT.h_dune(1:2:end),M.barr_elev-M.msl(1:2:397),log10(rp_o(1:2:397,1:2:end)),8)
% 
% cmap = colormap(magma(9)) ; %Create Colormap
% cbh = colorbar ; %Create Colorbar
% 
% cbh.TickLabels =  round(10.^cbh.Ticks,3)
% xlabel('Dune height (m)')
% ylabel('Barrier height (m)')
% ylabel(cbh, 'Risk premium (%)','fontsize',12)
% set( cbh, 'YDir', 'reverse');
% 
% filename='C:\Users\Zack\Desktop\riskprem1';
% set(gcf, 'PaperPosition', [0 0 6 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [6 5]); 
% print('-dpdf','-painters',filename)
% % 
% % 
% clear all; close all;
% d=0.1;
% e=0.04;
% MMT.h_dune=linspace(0.1,4,100);
% M.barr_elev=1;
% MMT.h0=4;
% 
% for t=1:100
% storm_risk_increases_with_sea_level = 1 + d / ( M.barr_elev );
% dunes_reduce_storm_risk             = MMT.h_dune(t)/MMT.h0;
% dune_premium(t)                        = e * (storm_risk_increases_with_sea_level - dunes_reduce_storm_risk);
% end
% plot(MMT.h_dune,dune_premium)
% hold on
% 
% for t=1:100
% storm_risk_increases_with_sea_level = 1 + d / ( M.barr_elev );
% dunes_reduce_storm_risk             = 1-exp(-5*(MMT.h_dune(t)/MMT.h0)^2);
% dune_premium(t)                        = e * (storm_risk_increases_with_sea_level - dunes_reduce_storm_risk);
% end
% plot(MMT.h_dune,dune_premium)
% hold on
% 
% 
% for t=1:100
% storm_risk_increases_with_sea_level = 1 + d / ( M.barr_elev );
% dunes_reduce_storm_risk             = 1-exp(-8*(MMT.h_dune(t)/MMT.h0)^2);
% dune_premium(t)                        = e * (storm_risk_increases_with_sea_level - dunes_reduce_storm_risk);
% end
% plot(MMT.h_dune,dune_premium)
% hold on
% 
% 
% legend('fig 4, linear','fig 7 nonlinear','fig 8 more nonlinear')
% 
% ylabel('risk premium dune')
% xlabel('dune height')
% 
% filename='C:\Users\Zack\Desktop\fig6_dune';
% set(gcf, 'PaperPosition', [0 0 6 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [6 5]); 
% print('-dpdf','-painters',filename)
% 






