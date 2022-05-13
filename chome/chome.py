import numpy as np

# Zach, need to add descriptions below

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
from .chome_classes import (
    ModelParameters,
    ManagementParameters,
    AgentCommon,
    VariableSave,
)


def calculate_total_number_agents(
    average_interior_width,
    alongshore_domain_extent,
    house_footprint_x,
    house_footprint_y,
):
    number_rows = np.floor(average_interior_width / house_footprint_y)
    house_units_per_row = np.floor(alongshore_domain_extent / house_footprint_x)
    total_number_agents = int(number_rows * house_units_per_row)
    share_oceanfront = (2 * house_units_per_row / total_number_agents
    )  # multiply by 2 so to consider first 2 rows as oceanfront

    return total_number_agents, share_oceanfront


class Chome:
    def __init__(
        self,
        name="default",
        total_time=400,
        average_interior_width=300,  # Zach, need to add descriptions below
        barrier_island_height=1,
        beach_width=None,
        dune_height=None,
        shoreface_depth=10,
        dune_width=25,
        dune_height_build=4,
        alongshore_domain_extent=3000,
        shoreline_retreat_rate=1,
        sand_cost=10,
        taxratio_oceanfront=3,
        external_housing_market_value_oceanfront=6e5,
        external_housing_market_value_nonoceanfront=4e5,
        fixed_cost_beach_nourishment=1e6,
        fixed_cost_dune_nourishment=1e5,
        nourishment_cost_subsidy=0.9125,
        house_footprint_x=15,
        house_footprint_y=20,
        agent_expectations_time_horizon=30,
        agent_erosion_update_weight=0.5,
        beach_width_beta_oceanfront=0.25,
        beach_width_beta_nonoceanfront=0.15,
        beach_full_cross_shore=70,
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
        beach_full_cross_shore: int, optional
            The cross-shore extent (meters) of fully nourished beach
        discount_rate: float, optional
            Rate at which future flows of value are discounted
        dune_height_build: int, optional
            Height (meters) of fully built dunes
        barrier_island_height: int, optional
            Height of barrier island (meters) with respect to mean sea level
        average_interior_width: average interior width of barrier (meters)
        house_footprint_x: def
        house_footprint_y: def

        Examples
        --------
        >>> from chome import Chome
        >>> chome = Chome()
        """

        self._name = name
        self._time_index = 1
        self._nourishment_off = 0
        self._increasing_outside_market = False

        [total_number_agents, share_oceanfront] = calculate_total_number_agents(
            average_interior_width,
            alongshore_domain_extent,
            house_footprint_x,
            house_footprint_y,
        )
        self._n = total_number_agents
        self._share_oceanfront = share_oceanfront

        ###############################################################################
        # share subsets of the variables in different classes for easy passing
        ###############################################################################

        self._modelforcing = ModelParameters(
            total_time,
            nourishment_plan_time_commitment,
            shoreline_retreat_rate,
            total_number_agents,
            barrier_island_height,
        )

        self._mgmt = ManagementParameters(
            nourishment_plan_loan_amortization_length,
            total_time,
            beach_width_beta_nonoceanfront,
            beach_width_beta_oceanfront,
            beach_full_cross_shore,
            beach_width,
            shoreface_depth,
            alongshore_domain_extent,
            fixed_cost_beach_nourishment,
            fixed_cost_dune_nourishment,
            dune_height_build,
            dune_width,
            dune_height,
            nourishment_plan_time_commitment,
            sand_cost,
            agent_expectations_time_horizon,
            discount_rate,
            taxratio_oceanfront,
            nourishment_cost_subsidy,
            total_number_agents,
        )

        self._agentsame = AgentCommon(
            average_interior_width,
            share_oceanfront,
            agent_erosion_update_weight,
            total_time,
            beach_full_cross_shore,
            shoreline_retreat_rate,
            total_number_agents,
            external_housing_market_value_oceanfront,
            external_housing_market_value_nonoceanfront,
        )

        self._savevar = VariableSave(
            total_number_agents,
            share_oceanfront,
            total_time,
        )

        # time series for tracking nourishment and dune rebuild
        self._nourish_now = np.zeros(total_time)
        self._rebuild_dune_now = np.zeros(total_time)

        ###############################################################################
        # agents/user cost
        ###############################################################################

        # define the front row homes
        self._agent_oceanfront = Agents(  # also includes former X_OF variables
            total_time,
            self._agentsame.n_OF,
            self._agentsame,
            self._increasing_outside_market,
            frontrow_on=True,
        )
        # define the back row homes
        self._agent_nonoceanfront = Agents(  # also includes former X_NOF variables
            total_time,
            self._agentsame.n_NOF,
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
            self._agentsame.n_NOF
            * (1 - self._agent_nonoceanfront.mkt[self._time_index - 1])
        )
        n2 = round(
            self._agentsame.n_OF
            * (1 - self._agent_oceanfront.mkt[self._time_index - 1])
        )
        self._agentsame.I_own = np.zeros(self._agentsame.n_NOF + self._agentsame.n_OF)
        nof_indices = np.arange(self._agentsame.n_NOF)
        of_indices = self._agentsame.n_NOF + np.arange(self._agentsame.n_OF)
        self._agentsame.I_own[nof_indices[0:n1]] = 1
        self._agentsame.I_own[of_indices[0:n2]] = 1

        # updates mgmt, agentsame to evolve the environment
        [
            self._nourish_now[self._time_index],
            self._rebuild_dune_now[self._time_index],
        ] = evolve_environment(
            self._time_index, self._agentsame, self._mgmt, self._modelforcing
        )

        # these functions update the agent classes
        calculate_risk_premium(
            self._time_index,
            self._agent_nonoceanfront,
            self._modelforcing,
            self._mgmt,
            frontrow_on=False,
        )

        calculate_risk_premium(
            self._time_index,
            self._agent_oceanfront,
            self._modelforcing,
            self._mgmt,
            frontrow_on=True,
        )

        calculate_nourishment_plan_cost(
            self._time_index,
            self._agentsame,
            self._mgmt,
            self._modelforcing,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
        )

        calculate_nourishment_plan_ben(
            self._time_index,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
            self._mgmt,
            self._agentsame,
        )

        evaluate_nourishment_plans(
            self._time_index,
            self._mgmt,
            self._modelforcing,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
            self._agentsame,
        )

        calculate_expected_beach_width(
            self._time_index,
            self._mgmt,
            self._agentsame,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
        )

        calculate_evaluate_dunes(
            self._time_index,
            self._mgmt,
            self._modelforcing,
            self._agentsame,
            self._agent_oceanfront,
            self._agent_nonoceanfront,
        )

        expected_capital_gains(
            self._time_index,
            self._agent_oceanfront,
        )

        expected_capital_gains(
            self._time_index,
            self._agent_nonoceanfront,
        )

        calculate_user_cost(
            self._time_index,
            self._agent_oceanfront,
            self._agent_oceanfront.tau_prop[self._time_index],
        )

        calculate_user_cost(
            self._time_index,
            self._agent_nonoceanfront,
            self._agent_nonoceanfront.tau_prop[self._time_index],
        )

        agent_distribution_adjust(
            self._time_index,
            self._modelforcing,
            self._mgmt,
            self._agent_oceanfront,
            self._agentsame,
            frontrow_on=True,
        )

        agent_distribution_adjust(
            self._time_index,
            self._modelforcing,
            self._mgmt,
            self._agent_nonoceanfront,
            self._agentsame,
            frontrow_on=False,
        )

        if self._time_index == 1:
            self._agent_oceanfront.price[0] = self._agent_oceanfront.price[1]
            self._agent_nonoceanfront.price[0] = self._agent_nonoceanfront.price[1]

        self._savevar.of_beta_x[self._time_index] = self._agent_oceanfront.beta_x
        self._savevar.of_income_distribution[
            :, self._time_index
        ] = self._agent_oceanfront.tau_o
        self._savevar.of_willingness_to_pay[
            :, self._time_index
        ] = self._agent_oceanfront.wtp
        self._savevar.of_risk_premium[:, self._time_index] = self._agent_oceanfront.rp_o
        # self._savevar._of_owner_bid_prices[time_index]
        self._savevar.nof_beta_x[self._time_index] = self._agent_nonoceanfront.beta_x
        self._savevar.nof_income_distribution[
            :, self._time_index
        ] = self._agent_nonoceanfront.tau_o
        self._savevar.nof_willingness_to_pay[
            :, self._time_index
        ] = self._agent_nonoceanfront.wtp
        self._savevar.nof_risk_premium[
            :, self._time_index
        ] = self._agent_nonoceanfront.rp_o
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
            self._modelforcing.barr_elev
        )  # Barrier elevation, this was a scalar is now a time series

    @barr_elev.setter
    def barr_elev(self, value):
        self._modelforcing.barr_elev = value

    @property
    def beach_width(self):
        return self._mgmt.bw  # Note: beach width - this is a time series

    @beach_width.setter
    def beach_width(self, value):
        self._mgmt.bw = value

    @property
    def bw_erosion_rate(self):
        return self._modelforcing.ER  # beach width erosion rate - this is a time series

    @bw_erosion_rate.setter
    def bw_erosion_rate(self, value):
        self._modelforcing.ER = value

    @property
    def dune_height(self):
        return self._mgmt.h_dune  # dune height - this is a time series

    @dune_height.setter
    def dune_height(self, value):
        self._mgmt.h_dune = value

    @property
    def dune_sand_volume(self):
        return self._mgmt.dune_sand_volume  # m^3

    @dune_sand_volume.setter
    def dune_sand_volume(self, value):
        self._mgmt.dune_sand_volume = value

    @property
    def nourishment_volume(self):
        return (
            self._mgmt.addvolume
        )  # this is the nourishment volume in m^3/m, time series

    @property
    def lLength(self):
        return self._mgmt.lLength  # alongshore length of domain

    @property
    def average_interior_width(self):
        return (
            self._agentsame.average_interior_width
        )  # Zack, is this the reight location of this variable?

    @average_interior_width.setter
    def average_interior_width(self, value):
        self._agentsame.average_interior_width = value

    @property
    def nourish_now(self):
        return self._nourish_now  # time series

    @property
    def rebuild_dune_now(self):
        return self._rebuild_dune_now  # time series
