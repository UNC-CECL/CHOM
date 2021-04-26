import numpy as np
import scipy.constants
import yaml
from numpy.lib.scimath import power as cpower, sqrt as csqrt
from scipy.interpolate import interp1d
from scipy.sparse import csr_matrix
from scipy.sparse.linalg import spsolve
from agents import Agents


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
        willingness_to_pay_min=1000,
        willingness_to_pay_max=2000,
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
        self._n = total_number_of_agents
        self._T = total_time
        self._bta_OF = beach_width_beta_oceanfront
        self._bta_NOF = beach_width_beta_nonoceanfront
        self._share_OF = share_oceanfront
        self._taxratio_OF = taxratio_oceanfront
        self._theta_er = agent_erosion_update_weight
        self._lam_storm = storm_frequency
        self._sandcost = sand_cost
        self._fixedcost_beach = fixed_cost_beach_nourishment
        self._fixedcost_dune = fixed_cost_dune_nourishment
        self._nourish_subsidy = nourishment_cost_subsidy
        self._P_e_OF = external_housing_market_value_oceanfront
        self._P_e_NOF = external_housing_market_value_nonoceanfront
        self._expectation_horizon = agent_expectations_time_horizon
        self._amort = nourishment_plan_loan_amortization_length
        self._nourish_plan_horizon = nourishment_plan_time_commitment
        self._Ddepth = beach_nourishment_fill_depth
        self._lLength = beach_nourishment_fill_width
        self._x0 = beach_full_cross_shore
        self._delta_disc = discount_rate
        self._h0 = dune_height_build
        self._barr_elev = barrier_island_height

        ###############################################################################
        # dependent variables: owner-agent
        ###############################################################################

        self._mWTP = [willingness_to_pay_min, willingness_to_pay_max]
        self._P_e_OF = external_housing_market_value_oceanfront + np.zeros(self._T)
        self._P_e_NOF = external_housing_market_value_nonoceanfront + np.zeros(self._T)
        self._n_NOF = round(self._n * (1 - self._share_OF))
        self._n_OF = round(self._n * self._share_OF)
        self._n_agent_total = self._n
        self._Ebw = np.zeros(self._T)
        self._Edh = np.zeros(self._T)
        self._I_OF = np.zeros(self._n_agent_total)
        self._I_OF[self._n_NOF + 1 : -1] = 1  # KA: check that this is right in Matlab
        self._I_own = np.zeros(self._n_agent_total)

        ###############################################################################
        # physical parameters
        ###############################################################################

        self._beach_plan = 11 + np.zeros(self._T)
        self._h_dune = np.zeros(self._T)
        self._h_dune[0] = self._h0
        self._bw = np.zeros(self._T)
        self._bw[0] = self._x0
        self._E_ER = np.zeros(self._T)
        self._ER = shoreline_retreat_rate + np.zeros(self._T)
        self._nourishtime = np.zeros(self._T)
        self._newplan = np.zeros(self._T)
        self._builddunetime = np.zeros(self._T)
        self._msl = np.zeros(self._T)

        # storms
        self._RNG = np.random.default_rng(
            seed=self._n
        )  # KA: added seeded random number generator the size of n
        self._storms = self._RNG.poisson(
            lam=self._lam_storm, size=self._T
        )  # poissrnd(lam_storm,T,1)

        ###############################################################################
        # agents/user cost
        ###############################################################################

        # average risk premium real estate (same for investor and owner)
        self._rp_I = np.zeros(1)
        self._agents_front_row = Agents(
            self._T,
            self._n_OF,
            self._bta_OF,
        )
        self._agents_back_row = Agents(
            self._T,
            self._n_NOF,
            self._bta_NOF,
        )

        self._nourishment_off = 0
