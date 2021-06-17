# import os

import numpy as np

from .agents import (
    Agents,
    agent_distribution_adjust,
)
from .nourishment import (
    calculate_nourishment_plan_cost,
    calculate_nourishment_plan_ben,
    evaluate_nourishment_plans,
    calculate_evaluate_dunes,
)
from .environment import (
    evolve_environment,
    calculate_expected_beach_width,
)
from .user_cost import (
    calculate_risk_premium,
    calculate_user_cost,
    expected_capital_gains,
)


def calculate_total_number_agents(
    average_interior_width, alongshore_domain_extent, house_footprint
):
    number_rows = np.floor(average_interior_width / house_footprint)
    house_units_per_row = np.floor(alongshore_domain_extent / house_footprint)
    total_number_agents = int(number_rows * house_units_per_row)
    share_oceanfront = house_units_per_row / total_number_agents

    return total_number_agents, share_oceanfront


class Chome:
    def __init__(
        self,
        name="default",
        total_time=400,
        average_interior_width=100,  # Zach, need to add descriptions below
        barrier_island_height=1,
        beach_width=None,
        dune_height=None,
        shoreface_depth=10,
        dune_width=4,
        dune_height_build=4,
        alongshore_domain_extent=3000,
        shoreline_retreat_rate=4,
        sand_cost=10,
        taxratio_oceanfront=3,
        external_housing_market_value_oceanfront=6e5,
        external_housing_market_value_nonoceanfront=4e5,
        fixed_cost_beach_nourishment=2e6,
        fixed_cost_dune_nourishment=1e5,
        nourishment_cost_subsidy=5e6,
        house_footprint=10,  # Zach, need to add descriptions below
        agent_expectations_time_horizon=30,
        agent_erosion_update_weight=0.5,
        beach_width_beta_oceanfront=0.175,
        beach_width_beta_nonoceanfront=0.1,
        beach_full_cross_shore=100,
        discount_rate=0.06,
        nourishment_plan_loan_amortization_length=5,
        nourishment_plan_time_commitment=10,
    ):
        """Coastal Home Ownership Model CHOM
        Parameters
        ----------
        name: string, optional
            Name of simulation
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
        external_housing_market_value_nonoceanfront:  , optional
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
            Height of barrier island (meters) with respect to mean sea level
        average_interior_width: average interior width of barrier (meters)

        Examples
        --------
        >>> from chome import Chome
        >>> chome = Chome()
        """

        self._name = name
        self._time_index = 1
        self._nourishment_off = 0
        self._increasing_outside_market = True

        [total_number_agents, share_oceanfront] = calculate_total_number_agents(
            average_interior_width,
            alongshore_domain_extent,
            house_footprint,
        )
        self._n = total_number_agents
        self._share_oceanfront = share_oceanfront

        ###############################################################################
        # share subsets of the variables in different classes for easy passing
        ###############################################################################

        class ModelParameters:
            def __init__(self):
                self._T = total_time + nourishment_plan_time_commitment
                self._ER = shoreline_retreat_rate + np.zeros(self._T)
                self._RNG = np.random.default_rng(seed=total_number_agents)
                self._Tfinal = self._T - nourishment_plan_time_commitment
                self._barr_elev = barrier_island_height + np.zeros(self._T)

        class ManagementParameters:
            def __init__(self):
                self._dune_sand_volume = None
                self._amort = nourishment_plan_loan_amortization_length
                self._beach_plan = 11 + np.zeros(total_time)
                self._bta_NOF = beach_width_beta_nonoceanfront
                self._bta_OF = beach_width_beta_oceanfront
                self._builddunetime = np.zeros(total_time)
                self._x0 = beach_full_cross_shore
                self._bw = np.zeros(total_time)
                if beach_width is None:
                    self._bw[0] = self._x0
                else:
                    self._bw[
                        0
                    ] = beach_width  # allows user to input starting beach width
                self._Ddepth = shoreface_depth
                self._lLength = alongshore_domain_extent
                self._fixedcost_beach = fixed_cost_beach_nourishment
                self._fixedcost_dune = fixed_cost_dune_nourishment
                self._h0 = dune_height_build
                self._dune_width = dune_width
                self._h_dune = np.zeros(total_time)
                if dune_height is None:
                    self._h_dune[0] = self._h0  # set to dune design height
                else:
                    self._h_dune[0] = dune_height
                self._nourishtime = np.zeros(total_time)
                self._dune_sand_volume = np.zeros(total_time)
                self._addvolume = np.zeros(total_time)
                self._newplan = np.zeros(total_time)
                self._nourish_plan_horizon = nourishment_plan_time_commitment
                self._sandcost = sand_cost
                self._expectation_horizon = agent_expectations_time_horizon
                self._delta_disc = discount_rate
                self._taxratio_OF = taxratio_oceanfront
                self._nourish_subsidy = nourishment_cost_subsidy
                self._nourishment_menu_cost = np.zeros(11)
                self._nourishment_menu_volumes = np.zeros(
                    shape=(11, agent_expectations_time_horizon)
                )
                self._nourishment_menu_bw = np.zeros(
                    shape=(11, agent_expectations_time_horizon)
                )
                self._nourishment_menu_add_tax = np.zeros(11)
                self._nourishment_menu_totalcostperyear = np.zeros(11)
                self._nourishment_menu_taxburden = np.zeros(
                    shape=(total_number_agents, 11)
                )
                self._nourishment_pricelist = np.zeros(shape=(total_number_agents, 11))
                self._dune_pricelist = np.zeros(shape=(total_number_agents, 2))
                self._OF_plan_price = np.zeros(11)
                self._NOF_plan_price = np.zeros(11)

        class AgentCommon:
            def __init__(self):
                self._average_interior_width = average_interior_width
                self._share_OF = share_oceanfront
                self._theta_er = agent_erosion_update_weight
                self._Ebw = np.zeros(total_time)
                self._Ebw[0] = beach_full_cross_shore
                self._E_ER = np.zeros(total_time)
                self._E_ER[0] = shoreline_retreat_rate
                self._n_agent_total = total_number_agents
                self._n_NOF = round(self._n_agent_total * (1 - self._share_OF))
                self._n_OF = round(self._n_agent_total * self._share_OF)
                self._I_OF = np.zeros(
                    self._n_agent_total
                )  # the first n_NOF spots are back row, remaining are front row
                self._I_OF[self._n_NOF + 1 :] = 1
                self._I_own = np.zeros(self._n_agent_total)
                self._P_e_OF = external_housing_market_value_oceanfront
                self._P_e_NOF = external_housing_market_value_nonoceanfront

        class VariableSave:
            def __init__(self):
                n_nof = round(total_number_agents * (1 - share_oceanfront))
                n_of = round(total_number_agents * share_oceanfront)
                self._of_beta_x = np.zeros(total_time)
                self._of_income_distribution = np.zeros(shape=(n_of, total_time))
                self._of_willingness_to_pay = np.zeros(shape=(n_of, total_time))
                self._of_risk_premium = np.zeros(shape=(n_of, total_time))
                # self._of_owner_bid_prices = np.zeros(shape=(total_number_agents, total_time))
                self._nof_beta_x = np.zeros(total_time)
                self._nof_income_distribution = np.zeros(shape=(n_nof, total_time))
                self._nof_willingness_to_pay = np.zeros(shape=(n_nof, total_time))
                self._nof_risk_premium = np.zeros(shape=(n_nof, total_time))
                # self._nof_owner_bid_prices = np.zeros(shape=(total_number_agents, total_time))
                # self._nourishment_cost_minus_ben = np.zeros(total_time)

        self._modelforcing = ModelParameters()
        self._mgmt = ManagementParameters()
        self._agentsame = AgentCommon()
        self._savevar = VariableSave()

        # time series for tracking nourishment and dune rebuild
        self._nourish_now = np.zeros(total_time)
        self._rebuild_dune_now = np.zeros(total_time)

        ###############################################################################
        # agents/user cost
        ###############################################################################

        # define the front row homes
        self._agent_oceanfront = Agents(  # also includes former X_OF variables
            total_time,
            self._agentsame._n_OF,
            self._agentsame,
            self._increasing_outside_market,
            frontrow_on=True,
        )
        # define the back row homes
        self._agent_nonoceanfront = Agents(  # also includes former X_NOF variables
            total_time,
            self._agentsame._n_NOF,
            self._agentsame,
            self._increasing_outside_market,
            frontrow_on=False,
        )

    def update(self):
        """Update Chome by a single time step"""

        # Znote: I've re-written this to be simpler
        # number of NOF units owned by residents = n1, number of NOF units owned by investor = n_NOF - n1
        # number of OF  units owned by residents = n2, number of OF units  owned by investor = n_OF - n1
        n1 = round(
            self._agentsame._n_NOF
            * (1 - self._agent_nonoceanfront._mkt[self._time_index - 1])
        )
        n2 = round(
            self._agentsame._n_OF
            * (1 - self._agent_oceanfront._mkt[self._time_index - 1])
        )
        self._agentsame._I_own = np.zeros(
            self._agentsame._n_NOF + self._agentsame._n_OF
        )
        nof_indices = np.arange(self._agentsame._n_NOF)
        of_indices = self._agentsame._n_NOF + np.arange(self._agentsame._n_OF)
        self._agentsame._I_own[nof_indices[0:n1]] = 1
        self._agentsame._I_own[of_indices[0:n2]] = 1

        [self._mgmt, self._agentsame, self._nourish_now[self._time_index], self._rebuild_dune_now[self._time_index]] = \
            evolve_environment(
                self._time_index, self._agentsame, self._mgmt, self._modelforcing
        )

        self._agent_nonoceanfront = calculate_risk_premium(
            self._time_index,
            self._agent_nonoceanfront,
            self._modelforcing,
            self._mgmt,
            frontrow_on=False,
        )
        self._agent_oceanfront = calculate_risk_premium(
            self._time_index,
            self._agent_oceanfront,
            self._modelforcing,
            self._mgmt,
            frontrow_on=True,
        )
        self._mgmt = calculate_nourishment_plan_cost(
            self._time_index,
            self._agentsame,
            self._mgmt,
            self._modelforcing,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
        )

        self._mgmt = calculate_nourishment_plan_ben(
            self._time_index,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
            self._mgmt,
            self._agentsame,
        )

        [
            self._agent_nonoceanfront,
            self._agent_oceanfront,
            self._mgmt,
        ] = evaluate_nourishment_plans(
            self._time_index,
            self._mgmt,
            self._modelforcing,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
            self._agentsame,
        )

        [
            self._agentsame,
            self._agent_nonoceanfront,
            self._agent_oceanfront,
        ] = calculate_expected_beach_width(
            self._time_index,
            self._mgmt,
            self._agentsame,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
        )

        [
            self._agent_oceanfront,
            self._agent_nonoceanfront,
            self._mgmt,
        ] = calculate_evaluate_dunes(
            self._time_index,
            self._mgmt,
            self._modelforcing,
            self._agentsame,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
        )

        self._agent_oceanfront = expected_capital_gains(
            self._time_index,
            self._agent_oceanfront,
            self._modelforcing,
            frontrow_on=True,
        )

        self._agent_nonoceanfront = expected_capital_gains(
            self._time_index,
            self._agent_nonoceanfront,
            self._modelforcing,
            frontrow_on=False,
        )

        self._agent_oceanfront = calculate_user_cost(
            self._time_index,
            self._agent_oceanfront,
            self._agent_oceanfront._tau_prop[self._time_index],
        )

        self._agent_nonoceanfront = calculate_user_cost(
            self._time_index,
            self._agent_nonoceanfront,
            self._agent_nonoceanfront._tau_prop[self._time_index],
        )

        self._agent_oceanfront = agent_distribution_adjust(
            self._time_index,
            self._modelforcing,
            self._mgmt,
            self._agent_oceanfront,
            self._agentsame,
            frontrow_on=True,
        )

        self._agent_nonoceanfront = agent_distribution_adjust(
            self._time_index,
            self._modelforcing,
            self._mgmt,
            self._agent_nonoceanfront,
            self._agentsame,
            frontrow_on=False,
        )

        if self._time_index == 1:
            self._agent_oceanfront._price[0] = self._agent_oceanfront._price[1]
            self._agent_nonoceanfront._price[0] = self._agent_nonoceanfront._price[1]

        self._savevar._of_beta_x[self._time_index] = self._agent_oceanfront._beta_x
        self._savevar._of_income_distribution[
            :, self._time_index
        ] = self._agent_oceanfront._tau_o
        self._savevar._of_willingness_to_pay[
            :, self._time_index
        ] = self._agent_oceanfront._wtp
        self._savevar._of_risk_premium[
            :, self._time_index
        ] = self._agent_oceanfront._rp_o
        # self._savevar._of_owner_bid_prices[time_index]
        self._savevar._nof_beta_x[self._time_index] = self._agent_nonoceanfront._beta_x
        self._savevar._nof_income_distribution[
            :, self._time_index
        ] = self._agent_nonoceanfront._tau_o
        self._savevar._nof_willingness_to_pay[
            :, self._time_index
        ] = self._agent_nonoceanfront._wtp
        self._savevar._nof_risk_premium[
            :, self._time_index
        ] = self._agent_nonoceanfront._rp_o
        # self._savevar._nof_owner_bid_prices[time_index]
        # self._savevar._nourishment_cost_minus_ben[time_index]

        self._time_index += 1

    ###############################################################################
    # save data
    ###############################################################################

    # def save(self, directory):
    #     filename = self._filename + ".npz"
    #
    #     chome = [self]
    #
    #     os.chdir(directory)
    #     np.savez(filename, chome=chome)

    @property
    def time_index(self):
        return self._time_index

    @property
    def barr_elev(self):
        return (
            self._modelforcing._barr_elev
        )  # Barrier elevation, this was a scalar is now a time series

    @barr_elev.setter
    def barr_elev(self, value):
        self._modelforcing._barr_elev = value

    @property
    def beach_width(self):
        return self._mgmt._bw  # Note: beach width - this is a time series

    @beach_width.setter
    def beach_width(self, value):
        self._mgmt._bw = value

    @property
    def bw_erosion_rate(self):
        return (
            self._modelforcing._ER
        )  # beach width erosion rate - this is a time series

    @bw_erosion_rate.setter
    def bw_erosion_rate(self, value):
        self._modelforcing._ER = value

    @property
    def dune_height(self):
        return self._mgmt._h_dune  # dune height - this is a time series

    @dune_height.setter
    def dune_height(self, value):
        self._mgmt._h_dune = value

    @property
    def dune_sand_volume(self):
        return self._mgmt._dune_sand_volume  # m^3

    @dune_sand_volume.setter
    def dune_sand_volume(self, value):
        self._mgmt._dune_sand_volume = value

    @property
    def nourishment_volume(self):
        return (
            self._mgmt._addvolume
        )  # this is the nourishment volume in m^3/m, time series

    @property
    def lLength(self):
        return self._mgmt._lLength  # alongshore length of domain

    @property
    def average_interior_width(self):
        return (
            self._agentsame._average_interior_width
        )  # Zack, is this the reight location of this variable?

    @average_interior_width.setter
    def average_interior_width(self, value):
        self._agentsame._average_interior_width = value

    @property
    def nourish_now(self):
        return self._nourish_now  # time series

    @property
    def rebuild_dune_now(self):
        return self._rebuild_dune_now  # time series
