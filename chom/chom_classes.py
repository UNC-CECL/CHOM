import numpy as np


class ModelParameters:
    def __init__(
        self,
        total_time,
        nourishment_plan_time_commitment,
        shoreline_retreat_rate,
        total_number_agents,
        barrier_island_height,
        sea_level_rise_rate,
    ):

        self._T = total_time + nourishment_plan_time_commitment
        self._ER = shoreline_retreat_rate + np.zeros(self._T)
        self._RNG = np.random.default_rng(seed=total_number_agents)
        self._Tfinal = self._T - nourishment_plan_time_commitment
        self._barr_height = np.zeros(
            self._T
        )  # we subtract MSL from this each time step
        self._barr_height[0] = barrier_island_height
        self._mean_sea_level = np.arange(0, self._T) * sea_level_rise_rate

    @property
    def T(self):
        return self._T

    @T.setter
    def T(self, value):
        self._T = value

    @property
    def ER(self):
        return self._ER

    @ER.setter
    def ER(self, value):
        self._ER = value

    @property
    def RNG(self):
        return self._RNG

    @RNG.setter
    def RNG(self, value):
        self._RNG = value

    @property
    def Tfinal(self):
        return self._Tfinal

    @Tfinal.setter
    def Tfinal(self, value):
        self._Tfinal = value

    @property
    def barr_height(self):
        return self._barr_height

    @barr_height.setter
    def barr_height(self, value):
        self._barr_height = value

    @property
    def mean_sea_level(self):
        return self._mean_sea_level

    @mean_sea_level.setter
    def mean_sea_level(self, value):
        self._mean_sea_level = value


class ManagementParameters:
    def __init__(
        self,
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
    ):
        # self._dune_sand_volume = None
        self._amort = nourishment_plan_loan_amortization_length
        self._beach_plan = (nourishment_plan_time_commitment + 1) + np.zeros(total_time)
        self._bta_NOF = beach_width_beta_nonoceanfront
        self._bta_OF = beach_width_beta_oceanfront
        self._builddunetime = np.zeros(total_time)
        self._x0 = beach_full_cross_shore
        self._bw = np.zeros(total_time)
        if beach_width is None:
            self._bw[0] = self._x0
        else:
            self._bw[0] = beach_width  # allows user to input starting beach width
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
        self._nourishment_menu_cost = np.zeros(nourishment_plan_time_commitment + 1)
        self._nourishment_menu_volumes = np.zeros(
            shape=(
                nourishment_plan_time_commitment + 1,
                agent_expectations_time_horizon,
            )
        )
        self._nourishment_menu_bw = np.zeros(nourishment_plan_time_commitment + 1)
        self._nourishment_menu_add_tax = np.zeros(nourishment_plan_time_commitment + 1)
        self._nourishment_menu_totalcostperyear = np.zeros(
            nourishment_plan_time_commitment + 1
        )
        self._nourishment_menu_taxburden = np.zeros(
            shape=(total_number_agents, nourishment_plan_time_commitment + 1)
        )
        self._nourishment_pricelist = np.zeros(
            shape=(total_number_agents, nourishment_plan_time_commitment + 1)
        )
        self._dune_pricelist = np.zeros(shape=(total_number_agents, 2))
        self._OF_plan_price = np.zeros(nourishment_plan_time_commitment + 1)
        self._NOF_plan_price = np.zeros(nourishment_plan_time_commitment + 1)

    @property
    def NOF_plan_price(self):
        return self._NOF_plan_price

    @property
    def builddunetime(self):
        return self._builddunetime

    @builddunetime.setter
    def builddunetime(self, value):
        self._builddunetime = value

    @property
    def bta_OF(self):
        return self._bta_OF

    @property
    def bta_NOF(self):
        return self._bta_NOF

    @property
    def beach_plan(self):
        return self._beach_plan

    @property
    def amort(self):
        return self._amort

    @property
    def Ddepth(self):
        return self._Ddepth

    @property
    def bw(self):
        return self._bw

    @bw.setter
    def bw(self, value):
        self._bw = value

    @property
    def x0(self):
        return self._x0

    @property
    def h0(self):
        return self._h0

    @property
    def fixedcost_dune(self):
        return self._fixedcost_dune

    @property
    def fixedcost_beach(self):
        return self._fixedcost_beach

    @property
    def lLength(self):
        return self._lLength

    @property
    def newplan(self):
        return self._newplan

    @newplan.setter
    def newplan(self, value):
        self._newplan = value

    @property
    def addvolume(self):
        return self._addvolume

    @addvolume.setter
    def addvolume(self, value):
        self._addvolume = value

    @property
    def dune_sand_volume(self):
        return self._dune_sand_volume

    @dune_sand_volume.setter
    def dune_sand_volume(self, value):
        self._dune_sand_volume = value

    @property
    def nourishtime(self):
        return self._nourishtime

    @nourishtime.setter
    def nourishtime(self, value):
        self._nourishtime = value

    @property
    def h_dune(self):
        return self._h_dune

    @h_dune.setter
    def h_dune(self, value):
        self._h_dune = value

    @property
    def dune_width(self):
        return self._dune_width

    @property
    def taxratio_OF(self):
        return self._taxratio_OF

    @property
    def delta_disc(self):
        return self._delta_disc

    @property
    def expectation_horizon(self):
        return self._expectation_horizon

    @property
    def nourish_subsidy(self):
        return self._nourish_subsidy

    @property
    def sandcost(self):
        return self._sandcost

    @property
    def nourish_plan_horizon(self):
        return self._nourish_plan_horizon

    @property
    def nourishment_menu_volumes(self):
        return self._nourishment_menu_volumes

    @nourishment_menu_volumes.setter
    def nourishment_menu_volumes(self, value):
        self._nourishment_menu_volumes = value

    @property
    def nourishment_menu_cost(self):
        return self._nourishment_menu_cost

    @nourishment_menu_cost.setter
    def nourishment_menu_cost(self, value):
        self._nourishment_menu_cost = value

    @property
    def nourishment_menu_bw(self):
        return self._nourishment_menu_bw

    @nourishment_menu_bw.setter
    def nourishment_menu_bw(self, value):
        self._nourishment_menu_bw = value

    @property
    def nourishment_menu_add_tax(self):
        return self._nourishment_menu_add_tax

    @nourishment_menu_add_tax.setter
    def nourishment_menu_add_tax(self, value):
        self._nourishment_menu_add_tax = value

    @property
    def nourishment_menu_totalcostperyear(self):
        return self._nourishment_menu_totalcostperyear

    @nourishment_menu_totalcostperyear.setter
    def nourishment_menu_totalcostperyear(self, value):
        self._nourishment_menu_totalcostperyear = value

    @property
    def nourishment_menu_taxburden(self):
        return self._nourishment_menu_taxburden

    @nourishment_menu_taxburden.setter
    def nourishment_menu_taxburden(self, value):
        self._nourishment_menu_taxburden = value

    @property
    def nourishment_pricelist(self):
        return self._nourishment_pricelist

    @nourishment_pricelist.setter
    def nourishment_pricelist(self, value):
        self._nourishment_pricelist = value

    @property
    def dune_pricelist(self):
        return self._dune_pricelist

    @NOF_plan_price.setter
    def NOF_plan_price(self, value):
        self._NOF_plan_price = value

    @property
    def OF_plan_price(self):
        return self._OF_plan_price

    @OF_plan_price.setter
    def OF_plan_price(self, value):
        self._OF_plan_price = value


class AgentCommon:
    def __init__(
        self,
        average_interior_width,
        share_oceanfront,
        agent_erosion_update_weight,
        total_time,
        beach_full_cross_shore,
        shoreline_retreat_rate,
        total_number_agents,
        external_housing_market_value_oceanfront,
        external_housing_market_value_nonoceanfront,
    ):
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

    @property
    def average_interior_width(self):
        return self._average_interior_width

    @average_interior_width.setter
    def average_interior_width(self, value):
        self._average_interior_width = value

    @property
    def share_OF(self):
        return self._share_OF

    @property
    def theta_er(self):
        return self._theta_er

    @property
    def Ebw(self):
        return self._Ebw

    @Ebw.setter
    def Ebw(self, value):
        self._Ebw = value

    @property
    def E_ER(self):
        return self._E_ER

    @E_ER.setter
    def E_ER(self, value):
        self._E_ER = value

    @property
    def n_agent_total(self):
        return self._n_agent_total

    @property
    def n_NOF(self):
        return self._n_NOF

    @property
    def n_OF(self):
        return self._n_OF

    @property
    def I_OF(self):
        return self._I_OF

    @property
    def I_own(self):
        return self._I_own

    @I_own.setter
    def I_own(self, value):
        self._I_own = value

    @property
    def P_e_OF(self):
        return self._P_e_OF

    @property
    def P_e_NOF(self):
        return self._P_e_NOF


class VariableSave:
    def __init__(
        self,
        total_number_agents,
        share_oceanfront,
        total_time,
    ):
        n_nof = round(total_number_agents * (1 - share_oceanfront))
        n_of = round(total_number_agents * share_oceanfront)

        self._of_beta_x = np.zeros(total_time)
        self._of_income_distribution = np.zeros(shape=(n_of, total_time))
        self._of_willingness_to_pay = np.zeros(shape=(n_of, total_time))
        self._of_risk_premium = np.zeros(shape=(n_of, total_time))

        self._nof_beta_x = np.zeros(total_time)
        self._nof_income_distribution = np.zeros(shape=(n_nof, total_time))
        self._nof_willingness_to_pay = np.zeros(shape=(n_nof, total_time))
        self._nof_risk_premium = np.zeros(shape=(n_nof, total_time))

    @property
    def of_beta_x(self):
        return self._of_beta_x

    @of_beta_x.setter
    def of_beta_x(self, value):
        self._of_beta_x = value

    @property
    def of_income_distribution(self):
        return self._of_income_distribution

    @of_income_distribution.setter
    def of_income_distribution(self, value):
        self._of_income_distribution = value

    @property
    def of_willingness_to_pay(self):
        return self._of_willingness_to_pay

    @of_willingness_to_pay.setter
    def of_willingness_to_pay(self, value):
        self._of_willingness_to_pay = value

    @property
    def of_risk_premium(self):
        return self._of_risk_premium

    @of_risk_premium.setter
    def of_risk_premium(self, value):
        self._of_risk_premium = value

    @property
    def nof_beta_x(self):
        return self._nof_beta_x

    @nof_beta_x.setter
    def nof_beta_x(self, value):
        self._nof_beta_x = value

    @property
    def nof_income_distribution(self):
        return self._nof_income_distribution

    @nof_income_distribution.setter
    def nof_income_distribution(self, value):
        self._nof_income_distribution = value

    @property
    def nof_willingness_to_pay(self):
        return self._nof_willingness_to_pay

    @nof_willingness_to_pay.setter
    def nof_willingness_to_pay(self, value):
        self._nof_willingness_to_pay = value

    @property
    def nof_risk_premium(self):
        return self._nof_risk_premium

    @nof_risk_premium.setter
    def nof_risk_premium(self, value):
        self._nof_risk_premium = value
