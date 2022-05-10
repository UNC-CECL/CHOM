clear all; close all;
cd 'C:\Users\Zack\Desktop\chom_matlab_2_python'

% rand('state',filetag(2));
% randn('state',filetag(2));
beep off; format compact

% define run times          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_initialization         = 100;             % initialization/burn-in time
time_simulation             = 200;             % main model run time

% initialization options    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initialize_model            = true;            % include a burn-in/spin-up before model simulation
nourishoff_initialize       = false;           % nourishment off ( = true), nourishment on ( = false)
beach_width_ER_initialize   = 7;              % beach erosion rate over duration of initialization
beach_width_t0_initialize   = 70;             % initial beach width (fixed width if beach_width_ER_initialize = 0)
dune_height_ER_initialize   = 0;               % dune erosion rate over duration of initialization
dune_height_t0_initialize   = 4;               % initial dune height (fixed height if dune_height_ER_initialize = 0)
sea_level_initialize        = 0.0;             % mean sea level over duration of initialization

% main run options          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nourishoff_main             = false;           % turn nourishment off during main simulation
beach_width_t0_main         = 70;             % beach width at startup
dune_height_t0_main         = 4;               % dune height at startup
environ_changepts           = [ 1   ,  time_simulation ];  % start and stop time for increase in ER/sea level
ER_increase                 = 0.00;            % meters/yr
beach_width_ER_main         = [  5,  ...       % beach erosion rate (m/yr), [initial time, final time]
    5];
dune_height_ER_main         = [0  ,  0];     % dune erosion rate ,  [initial time, final time]
sea_level_main              = [0  ,  1];      % mean sea level,     [initial time, final time]

% outside market option     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outside_market_OF           = 6e5 * [ 1, 1];
outside_market_NOF          = 4e5 * [ 1, 1];
outside_market_changepts    = [ 1  , time_simulation ];  % start(1) stop(2) time for outside market change

% initialization values are column 1 only
% main simulation values start in column 1, and end at column 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

make_run_option
% need to address the first expected beach width estimate
% it should just be equal to the starting beach width but
% should include the projected beach width with the initial erosion rate


if initialize_model
    initialization_with_burn_in;  % initialize the model with values obtained after running model forward "initialization_time" years
else
    initialization_no_burn_in;    % run the model with initial values as defined in agent/model_initialize
end

if flag_out == 0
    main_loop
else
    disp('nothing to see')
end


% print_figures
