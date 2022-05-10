
if initialize_model
     
    sea_level_initialize(2)            = sea_level_initialize(1);
    dune_ER_initialize(2)              = dune_height_ER_initialize(1);
    beach_ER_initialize(2)             = beach_width_ER_initialize(1);

    
    
    run_option_init.name               = 'init';
    run_option_init.initialize         = initialize_model;
    run_option_init.time               = time_initialization;
    run_option_init.nourish_off        = nourishoff_initialize;
    run_option_init.beach_t0           = beach_width_t0_initialize;
    run_option_init.beach_ER           = [beach_width_ER_initialize(1), beach_width_ER_initialize(1)];
    run_option_init.dune_t0            = dune_height_t0_initialize;
    run_option_init.dune_ER            = [dune_height_ER_initialize(1), dune_height_ER_initialize(1)];
    run_option_init.sea_level          = [sea_level_initialize(1), sea_level_initialize(1)];
    run_option_init.outside_market_OF  = [outside_market_OF(1), outside_market_OF(1)];
    run_option_init.outside_market_NOF = [outside_market_NOF(1), outside_market_NOF(1)];

    run_option_main.name                  = 'main';
    run_option_main.initialize            = initialize_model;
    run_option_main.nourish_off           = nourishoff_main;
    run_option_main.time                  = time_simulation;
    run_option_main.beach_t0              = beach_width_t0_main;
    run_option_main.beach_ER              = beach_width_ER_main;
    run_option_main.dune_t0               = dune_height_t0_main;
    run_option_main.dune_ER               = dune_height_ER_main;
    run_option_main.sea_level             = sea_level_main;
    run_option_main.environ_changepts     = environ_changepts;
    run_option_main.outside_mkt_changepts = outside_market_changepts;
    run_option_main.outside_market_OF     = outside_market_OF;
    run_option_main.outside_market_NOF    = outside_market_NOF;
    
    
else
    
    run_option_init.initialize = initialize_model;
    
    run_option_main.name                  = 'main';
    run_option_main.initialize            = initialize_model;
    run_option_main.nourish_off           = nourishoff_main;
    run_option_main.time                  = time_simulation;
    run_option_main.beach_t0              = beach_width_t0_main;
    run_option_main.beach_ER              = beach_width_ER_main;
    run_option_main.dune_t0               = dune_height_t0_main;
    run_option_main.dune_ER               = dune_height_ER_main;
    run_option_main.sea_level             = sea_level_main;
    run_option_main.environ_changepts     = environ_changepts;
    run_option_main.outside_mkt_changepts = outside_market_changepts;
    run_option_main.outside_market_OF     = outside_market_OF;
    run_option_main.outside_market_NOF    = outside_market_NOF;

end

