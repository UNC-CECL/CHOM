import numpy as np

from agents import Agents
from nourishment import (
    calculate_nourishment_plan_cost,
    calculate_nourishment_plan_ben,
    evaluate_nourishment_plans,
    calculate_evaluate_dunes,
)
from environment import (
    evolve_environment,
    calculate_expected_dune_height,
    # calculate_expected_beach_width,
)
from user_cost import (
    calculate_risk_premium,
)


class Chome:
    def __init__(
        self,
        name="default",
        total_number_of_agents=2500,
        agent_expectations_time_horizon=30,
        agent_erosion_update_weight=0.5,
        barrier_island_height=1,
        beach_width_beta_oceanfront=0.2,
        beach_width_beta_nonoceanfront=0.1,
        beach_nourishment_fill_depth=10,
        beach_nourishment_fill_width=2000,
        beach_full_cross_shore=100,
        discount_rate=0.06,
        dune_height_build=4,
        external_housing_market_value_oceanfront=6e5,
        external_housing_market_value_nonoceanfront=4e5,
        fixed_cost_beach_nourishment=4e6,
        fixed_cost_dune_nourishment=1e6,
        nourishment_cost_subsidy=12e6,
        nourishment_plan_loan_amortization_length=5,
        nourishment_plan_time_commitment=10,
        share_oceanfront=0.25,
        shoreline_retreat_rate=4,
        storm_frequency=1 / 20,
        sand_cost=10,
        total_time=400,
        taxratio_oceanfront=3,
    ):
        """Coastal Home Ownership Model CHOM
        Parameters
        ----------
        name: string, optional
            Name of simulation
        total_number_of_agents: int, optional
            Total number of agents in simulation
        total_time: int, optional
            Total time of simulation
        beach_width_beta_oceanfront: float, optional
            Hedonic beach width coefficient for oceanfront housing
        beach_width_beta_nonoceanfront: float, optional
            Hedonic beach width coefficient for non-oceanfront housing
        share_oceanfront: float, optional
            Fraction of agents/housing units in oceanfront (front row)
        taxratio_oceanfront: float, optional
            The proportion of tax burden placed on oceanfront row for beach management
        agent_erosion_update_weight: float, optional
            Agent's perceived erosion rate update. 0=never update, 1=instantaneous erosion rate
        storm_frequency: float, optional
            Average frequency of major storms
        sand_cost: int, optional
            Unit cost of sand $/m^3
        fixed_cost_beach_nourishment: int, optional
            Fixed cost of 1 nourishment project
        fixed_cost_dune_nourishment: int, optional
            Fixed cost of building dunes once
        nourishment_cost_subsidy: int, optional
            Subsidy on cost of entire nourishment plan
        external_housing_market_value_oceanfront:  , optional
            Value of comparable housing option outside the coastal system
        external_housing_market_value_nonoceanfront:  , optional
            Value of comparable housing option outside the coastal system
        agent_expectations_time_horizon: int, optional
            Time horizon over which agent's consider physical environment
        nourishment_plan_loan_amortization_length: int, optional
            Number of years over which homeowners pay back nourishment cost
        nourishment_plan_time_commitment: int, optional
            Time span of nourishment plan (i.e. multiple nourishments over multiple X years)
        beach_nourishment_fill_depth: int, optional
            Average depth (meters) of nourishment volume place on shoreface
        beach_nourishment_fill_width: int, optional
            Average alongshore width (meters) of nourishment volume place on shoreface
        beach_full_cross_shore: int, optional
            The cross-shore extent (meters) of fully nourished beach
        discount_rate: float, optional
            Rate at which future flows of value are discounted
        dune_height_build: int, optional
            Height (meters) of fully built dunes
        barrier_island_height: int, optional
            Height of barrier island (meters) with respect to fixed reference point
        Examples
        --------
        >>> from chome import Chome
        >>> chome = Chome()
        """

        self._name = name
        self._time_index = 1
        self._n = total_number_of_agents
        # average risk premium real estate (same for investor and owner)
        self._rp_I = np.zeros(1)
        self._nourishment_off = 0

        ###############################################################################
        # share subsets of the variables in different classes for easy passing
        ###############################################################################

        class ModelParameters:
            def __init__(self):
                self._T = total_time
                self._ER = shoreline_retreat_rate + np.zeros(self._T)
                self._horizon = nourishment_plan_time_commitment  # Zack, should this be"_M._nourish_plan_horizon"?
                self._lam_storm = storm_frequency
                self._P_e_OF = external_housing_market_value_oceanfront + np.zeros(
                    self._T
                )
                self._P_e_NOF = external_housing_market_value_nonoceanfront + np.zeros(
                    self._T
                )
                # KA: added seeded random number generator the size of n
                self._RNG = np.random.default_rng(seed=total_number_of_agents)
                self._storms = self._RNG.poisson(lam=self._lam_storm, size=self._T)
                self._Tfinal = self._T - self._horizon
                self._barr_elev = barrier_island_height
                self._msl = np.zeros(self._T)

        class ManagementParameters:
            def __init__(self):
                self._amort = nourishment_plan_loan_amortization_length
                self._beach_plan = 11 + np.zeros(total_time)
                self._bta_NOF = beach_width_beta_nonoceanfront
                self._bta_OF = beach_width_beta_oceanfront
                self._builddunetime = np.zeros(total_time)
                self._x0 = beach_full_cross_shore
                self._bw = np.zeros(total_time)
                self._bw[0] = self._x0
                self._Ddepth = beach_nourishment_fill_depth
                self._lLength = beach_nourishment_fill_width
                # self._dunebens =  ZACK - delete?
                self._fixedcost_beach = fixed_cost_beach_nourishment
                self._fixedcost_dune = fixed_cost_dune_nourishment
                self._h0 = dune_height_build
                self._h_dune = np.zeros(total_time)
                self._h_dune[0] = self._h0
                self._nourishtime = np.zeros(total_time)
                self._newplan = np.zeros(total_time)
                # self._nourish_plan_horizon =   ZACK - what goes here?
                self._sandcost = sand_cost
                self._expectation_horizon = agent_expectations_time_horizon
                self._delta_disc = discount_rate
                self._taxratio_OF = taxratio_oceanfront
                self._nourish_subsidy = nourishment_cost_subsidy

        class AgentCommon:
            def __init__(self):
                self._share_OF = share_oceanfront
                self._theta_er = agent_erosion_update_weight
                self._Ebw = np.zeros(total_time)
                self._Edh = np.zeros(total_time)
                self._E_ER = np.zeros(total_time)
                self._n_agent_total = total_number_of_agents
                self._n_NOF = round(self._n_agent_total * (1 - self._share_OF))
                self._n_OF = round(self._n_agent_total * self._share_OF)
                self._I_OF = np.zeros(self._n_agent_total)
                self._I_OF[
                    self._n_NOF + 1 : -1
                ] = 1  # KA: check that this is right in Matlab
                self._I_own = np.zeros(self._n_agent_total)

        self._M = ModelParameters()
        self._MMT = ManagementParameters()
        self._ACOM = AgentCommon()

        ###############################################################################
        # agents/user cost
        ###############################################################################

        # front row
        self._A_OF = Agents(  # also includes former X_OF variables
            total_time,
            self._ACOM._n_OF,
            self._MMT._bta_OF,
        )
        # back row
        self._A_NOF = Agents(  # also includes former X_NOF variables
            total_time,
            self._ACOM._n_NOF,
            self._MMT._bta_NOF,
        )

    def update(self):
        """Update Chome by a single time step"""

        # update market share = number of renters, 1-mkt = number renters
        n1 = round(self._ACOM._n_NOF * (1 - self._A_NOF.mkt[self._time_index - 1]))
        n2 = round(self._ACOM._n_OF * (1 - self._A_OF.mkt[self._time_index - 1]))

        self._ACOM._I_own = 0 * self._ACOM._I_own
        rand_ownNOF = np.random.randint(1, high=self._ACOM._n_NOF, size=n1)
        rand_ownOF = np.random.randint(
            self._ACOM._n_NOF + 1, high=self._ACOM._n_NOF + self._ACOM._n_OF, size=n2
        )
        self._ACOM._I_own[
            rand_ownNOF
        ] = 1  # ZACK: is this the right index? same for below? (maybe add -1)
        self._ACOM._I_own[rand_ownOF] = 1

        [self._MMT, self._ACOM] = evolve_environment(
            self._time_index, self._ACOM, self._MMT, self._M
        )
        self._ACOM = calculate_expected_dune_height(
            self._time_index, self._ACOM, self._MMT
        )
        self._A_NOF = calculate_risk_premium(
            self._time_index, self._ACOM, self._A_NOF, self._M
        )
        self._A_OF = calculate_risk_premium(
            self._time_index, self._ACOM, self._A_OF, self._M
        )
        # BPC = calculate_nourishment_plan_cost(
        #     self._ACOM, self._M, self._MMT, self._A_NOF, self._A_OF
        # )
        # [BPB, BPC] = calculate_nourishment_plan_ben(
        #     self._A_NOF,
        #     self._A_OF,
        #     self._ACOM,
        #     BPC,
        #     self._M,
        #     self._MMT,
        # )
        # [self._A_NOF, self._A_OF, self._MMT] = evaluate_nourishment_plans(
        #     self._A_NOF,
        #     self._A_OF,
        #     self._ACOM,
        #     BPB,
        #     BPC,
        #     self._M,
        #     self._MMT,
        #     self._nourishment_off,
        # )
        # [self._ACOM, self._A_NOF, self._A_OF] = calculate_expected_beach_width(
        #     self._ACOM, self._M, self._MMT
        # )
        #
        # # if t > 5:
        # if self._time_index > 4:
        #     [self._A_NOF, self._A_OF, self._MMT] = calculate_evaluate_dunes(
        #         self._ACOM, self._M, self._MMT, self._A_NOF, self._A_OF
        #     )
        #     [self._A_NOF, SV_NOF] = expected_capital_gains(
        #         self._ACOM,
        #         self._A_NOF,
        #         self._M,
        #         self._MMT,
        #         0,
        #         self._M._P_e_NOF,
        #         self._ACOM._n_NOF,
        #     )
        #     [self._A_OF, SV_OF] = expected_capital_gains(
        #         self._ACOM,
        #         self._A_OF,
        #         self._M,
        #         self._MMT,
        #         1,
        #         self._M._P_e_OF,
        #         self._ACOM._n_OF,
        #     )
        # self._A_NOF = calculate_user_cost(
        #     self._M,
        #     self._A_NOF,
        #     self._A_NOF._WTP[self._time_index],
        #     self._A_NOF._tau_prop[self._time_index],
        # )
        # self._A_NOF = calculate_user_cost(
        #     self._M,
        #     self._A_OF,
        #     self._A_OF._WTP[self._time_index],
        #     self._A_OF._tau_prop[self._time_index],
        # )
        # [self._A_NOF, SV_NOF] = agent_distribution_adjust(
        #     self._ACOM, self._A_NOF, self._M, SV_NOF, 0, self._MMT
        # )
        # [self._A_OF, SV_OF] = agent_distribution_adjust(
        #     self._ACOM, self._A_OF, self._M, SV_OF, 1, self._MMT
        # )

        self._time_index += 1

    @property
    def time_index(self):
        return self._time_index
