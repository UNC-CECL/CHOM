import numpy as np

from .agents import (
    Agents,
    agent_distribution_adjust,
)
from .nourishment import (
      calculate_nourishment_plan_cost,
      calculate_nourishment_plan_ben,
      evaluate_nourishment_plans,
#     # calculate_evaluate_dunes,
)
from .environment import (
    evolve_environment,
    calculate_expected_dune_height,
    calculate_expected_beach_width,
)
from .user_cost import (
    calculate_risk_premium,
    calculate_user_cost,
    expected_capital_gains,
)


class Chome:
    def __init__(
        self,
        name="default",
        total_number_of_agents=2500,
        agent_expectations_time_horizon= 30,
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
        fixed_cost_beach_nourishment=3e6,
        fixed_cost_dune_nourishment=1e6,
        nourishment_cost_subsidy=12e6,
        nourishment_plan_loan_amortization_length=5,
        nourishment_plan_time_commitment=10,
        share_oceanfront=0.25,
        shoreline_retreat_rate=4,
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
        exter nal_housing_market_value_nonoceanfront:  , optional
            Value of comparable housing option outside the coastal system
        agent_expectations_time_horizon: int, optional
            Time horizon into past over which agent's consider physical environment
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
        # >>> from chome import Chome
        # >>> chome = Chome()
        """

        self._name = name
        self._time_index = 1
        self._n = total_number_of_agents
        # average risk premium real estate (same for investor and owner)
        self._nourishment_off = 0

        ###############################################################################
        # share subsets of the variables in different classes for easy passing
        ###############################################################################

        class ModelParameters:
            def __init__(self):
                self._T = total_time + nourishment_plan_time_commitment
                self._ER = shoreline_retreat_rate + np.zeros(self._T)
                self._P_e_OF = external_housing_market_value_oceanfront + np.zeros(
                    self._T
                )
                self._P_e_NOF = external_housing_market_value_nonoceanfront + np.zeros(
                    self._T
                )
                # KA: added seeded random number generator the size of n
                # Znote: since i removed storms, should be okay to remove RNG now ya?
                self._RNG = np.random.default_rng(seed=total_number_of_agents)
                self._Tfinal = self._T - nourishment_plan_time_commitment
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
                self._fixedcost_beach = fixed_cost_beach_nourishment
                self._fixedcost_dune = fixed_cost_dune_nourishment
                self._h0 = dune_height_build
                self._h_dune = np.zeros(total_time)
                self._h_dune[0] = self._h0
                self._nourishtime = np.zeros(total_time)
                self._newplan = np.zeros(total_time)
                self._nourish_plan_horizon = nourishment_plan_time_commitment
                self._sandcost = sand_cost
                self._expectation_horizon = agent_expectations_time_horizon
                self._delta_disc = discount_rate
                self._taxratio_OF = taxratio_oceanfront
                self._nourish_subsidy = nourishment_cost_subsidy
                self._nourishment_menu_cost = np.zeros(11)
                self._nourishment_menu_bw = np.zeros(shape=(11, agent_expectations_time_horizon))
                self._nourishment_menu_add_tax = np.zeros(11)
                self._nourishment_menu_totalcostperyear = np.zeros(11)
                self._nourishment_menu_taxburden = np.zeros(shape=(total_number_of_agents, 11))
                self._nourishment_pricelist = np.zeros(shape=(total_number_of_agents, 11))
                self._OF_plan_price = np.zeros(11)
                self._NOF_plan_price = np.zeros(11)

        class AgentCommon:
            def __init__(self):
                self._share_OF = share_oceanfront
                self._theta_er = agent_erosion_update_weight
                self._Ebw = np.zeros(total_time)
                self._Ebw[0] = beach_full_cross_shore
                self._Edh = np.zeros(total_time)
                self._Edh[0] = dune_height_build
                self._E_ER = np.zeros(total_time)
                self._E_ER[0] = shoreline_retreat_rate
                self._n_agent_total = total_number_of_agents
                self._n_NOF = round(self._n_agent_total * (1 - self._share_OF))
                self._n_OF = round(self._n_agent_total * self._share_OF)
                self._I_OF = np.zeros(self._n_agent_total) # the first n_NOF spots are back row, remaining are front row
                self._I_OF[self._n_NOF + 1 : -1] = 1
                self._I_own = np.zeros(self._n_agent_total)

        self._M = ModelParameters()
        self._MMT = ManagementParameters()
        self._ACOM = AgentCommon()

        class VariableSave:
            def __init__(self):
                n_nof = round(total_number_of_agents * (1 - share_oceanfront))
                n_of = round(total_number_of_agents * share_oceanfront)
                self._of_beta_x = np.zeros(total_time)
                self._of_income_distribution = np.zeros(shape=(n_of, total_time))
                self._of_willingness_to_pay = np.zeros(shape=(n_of, total_time))
                self._of_risk_premium = np.zeros(shape=(n_of, total_time))
                # self._of_owner_bid_prices = np.zeros(shape=(total_number_of_agents, total_time))
                self._nof_beta_x = np.zeros(total_time)
                self._nof_income_distribution = np.zeros(shape=(n_nof, total_time))
                self._nof_willingness_to_pay = np.zeros(shape=(n_nof, total_time))
                self._nof_risk_premium = np.zeros(shape=(n_nof, total_time))
                # self._nof_owner_bid_prices = np.zeros(shape=(total_number_of_agents, total_time))
                # self._nourishment_cost_minus_ben = np.zeros(total_time)

        self._savevar = VariableSave()

        ###############################################################################
        # agents/user cost
        ###############################################################################

        # define the front row homes
        self._A_OF = Agents(  # also includes former X_OF variables
            total_time,
            self._ACOM._n_OF,
            frontrow_on=True,
        )
        # define the back row homes
        self._A_NOF = Agents(  # also includes former X_NOF variables
            total_time,
            self._ACOM._n_NOF,
            frontrow_on=False,
        )

    def update(self):
        """Update Chome by a single time step"""

        # Znote: I've re-written this to be simpler
        # number of NOF units owned by residents = n1, number of NOF units owned by investor = n_NOF - n1
        # number of OF  units owned by residents = n2, number of OF units  owned by investor = n_OF - n1
        n1 = round(self._ACOM._n_NOF * (1 - self._A_NOF._mkt[self._time_index - 1]))
        n2 = round(self._ACOM._n_OF * (1 - self._A_OF._mkt[self._time_index - 1]))
        self._ACOM._I_own = np.zeros(self._ACOM._n_NOF + self._ACOM._n_OF)
        nof_indices = np.arange(self._ACOM._n_NOF)
        of_indices = self._ACOM._n_NOF + np.arange(self._ACOM._n_OF)
        self._ACOM._I_own[nof_indices[0:n1]] = 1
        self._ACOM._I_own[of_indices[0:n2]] = 1

        [self._MMT, self._ACOM] = evolve_environment(
            self._time_index,
            self._ACOM,
            self._MMT,
            self._M
        )

        self._ACOM = calculate_expected_dune_height(
            self._time_index,
            self._ACOM,
            self._MMT
        )
        self._A_NOF = calculate_risk_premium(
            self._time_index,
            self._ACOM,
            self._A_NOF,
            self._M,
            frontrow_on=True,
        )
        self._A_OF = calculate_risk_premium(
            self._time_index,
            self._ACOM,
            self._A_OF,
            self._M,
            frontrow_on=False,
        )
        self._MMT = calculate_nourishment_plan_cost(
            self._time_index,
            self._ACOM,
            self._MMT,
            self._A_NOF,
            self._A_OF
        )

        self._MMT = calculate_nourishment_plan_ben(
            self._time_index,
            self._A_OF,
            self._A_NOF,
            self._MMT,
            self._ACOM,
        )

        [self._A_NOF, self._A_OF, self._MMT] = evaluate_nourishment_plans(
            self._time_index,
            self._MMT,
            self._A_OF,
            self._A_NOF,
            self._ACOM
        )

        [self._ACOM, self._A_NOF, self._A_OF] = calculate_expected_beach_width(
            self._time_index,
            self._MMT,
            self._ACOM,
            self._A_OF,
            self._A_NOF
        )

        #     [self._A_NOF, self._A_OF, self._MMT] = calculate_evaluate_dunes(
        #         self._ACOM, self._M, self._MMT, self._A_NOF, self._A_OF
        #     )

        self._A_OF = expected_capital_gains(
            self._time_index,
            self._A_OF,
            self._M,
            frontrow_on=True,
        )

        self._A_OF = expected_capital_gains(
            self._time_index,
            self._A_OF,
            self._M,
            frontrow_on=False,
        )

        self._A_NOF = calculate_user_cost(
            self._time_index,
            self._A_NOF,
            self._A_OF._tau_prop[self._time_index],
        )

        self._A_OF = calculate_user_cost(
            self._time_index,
            self._A_OF,
            self._A_NOF._tau_prop[self._time_index],
        )

        self._A_OF = agent_distribution_adjust(
            self._time_index,
            self._M,
            self._A_OF,
            self._ACOM,
            frontrow_on=True,
        )

        self._A_NOF = agent_distribution_adjust(
            self._time_index,
            self._M,
            self._A_NOF,
            self._ACOM,
            frontrow_on=False,
        )

        if self._time_index == 1:
            self._A_OF._price[0] = self._A_OF._price[1]
            self._A_NOF._price[0] = self._A_NOF._price[1]

        self._savevar._of_beta_x[self._time_index] = self._A_OF._beta_x
        self._savevar._of_income_distribution[:, self._time_index] = self._A_OF._tau_o
        self._savevar._of_willingness_to_pay[:, self._time_index] = self._A_OF._wtp
        self._savevar._of_risk_premium[:, self._time_index] = self._A_OF._rp_o
        # self._savevar._of_owner_bid_prices[self._time_index]
        self._savevar._nof_beta_x[self._time_index] = self._A_NOF._beta_x
        self._savevar._nof_income_distribution[:, self._time_index] = self._A_NOF._tau_o
        self._savevar._nof_willingness_to_pay[:, self._time_index] = self._A_NOF._wtp
        self._savevar._nof_risk_premium[:, self._time_index] = self._A_NOF._rp_o
        # self._savevar._nof_owner_bid_prices[self._time_index]
        # self._savevar._nourishment_cost_minus_ben[self._time_index]

        self._time_index += 1

    @property
    def time_index(self):
        return self._time_index