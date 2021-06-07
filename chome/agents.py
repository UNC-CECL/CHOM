"""Agents

This module does agent stuff (formerly agent_initialize.m and others)

References
----------

.. [1] Jaap H. Nienhuis, Jorge Lorenzo Trueba; Simulating barrier island response to sea level rise with the barrier
    island and inlet environment (BRIE) model v1.0 ; Geosci. Model Dev., 12, 4013–4030, 2019;
    https://doi.org/10.5194/gmd-12-4013-2019


Notes
---------


"""

import numpy as np

# from copulas.multivariate import GaussianMultivariate
from scipy.stats import beta
from scipy.stats import norm  # contains PDF of Gaussian
from scipy.stats import multivariate_normal
from .user_cost import calculate_risk_premium


def agent_distribution(
    rcov,
    range_WTP_base,
    range_WTP_alph,
    range_tau_o,
    range_rp_base,
    beta_x,
    n,
):
    # beta distribution max/min parameter values
    # dist = GaussianMultivariate()
    # sampled = dist.sample(1000)

    beta_max = 10
    beta_min = 0.5

    bline2 = -1 * (beta_max - beta_min) * beta_x + beta_max
    bline1 = (beta_max - beta_min) * beta_x + beta_min

    r12 = rcov
    r13 = rcov
    r14 = rcov
    r23 = rcov
    r24 = rcov
    r34 = rcov

    rho = np.array(
        [[1, r12, r13, r14], [r12, 1, r23, r24], [r13, r23, 1, r34], [r14, r24, r34, 1]]
    )
    # U = copularnd('Gaussian', Rho, n);
    #  gaussian copula is based on the Gaussian Multivariate distribution
    # ZW - I'm looking into this - matlab gives a different output from "copularnd" (confined to interval 0 to 1)
    #     since np.random.multivariate_normal produces values outside [0 1], the result is beta.ppf produces NaN for vals outside this range
    size = rho.shape[0]
    means = np.zeros(size)
    y = multivariate_normal(means, rho)  # , size=n)
    mvnData = y.rvs(size=n)
    U = norm.cdf(mvnData)

    # X = [betainv(U(:, 1), bline1, bline2) betainv(U(:, 2), bline1, bline2) betainv(U(:, 3), bline1, bline2) betainv(
    #     U(:, 4), bline1, bline2)];
    X = [
        beta.ppf(U[:, 0], bline1, bline2),
        beta.ppf(U[:, 1], bline1, bline2),
        beta.ppf(U[:, 2], bline1, bline2),
        beta.ppf(U[:, 3], bline1, bline2),
    ]

    tau_o = X[0]
    WTP_base = X[1]
    WTP_alph = X[2]
    rp_base = X[3]

    # rescale to property intervals
    tau_o = tau_o * (range_tau_o[1] - range_tau_o[0])
    tau_o = tau_o + range_tau_o[0]

    WTP_base = WTP_base * (range_WTP_base[1] - range_WTP_base[0])
    WTP_base = WTP_base + range_WTP_base[0]

    WTP_alph = WTP_alph * (range_WTP_alph[1] - range_WTP_alph[0])
    WTP_alph = WTP_alph + range_WTP_alph[0]

    rp_base = rp_base * (range_rp_base[1] - range_rp_base[0])
    rp_base = rp_base + range_rp_base[0]

    # tau_o = np.linspace(0.05, 0.25, n)
    # WTP_base = np.linspace(range_WTP_base[1]*0.5 ,range_WTP_base[1] , n)
    # WTP_alph = np.linspace(range_WTP_base[1]*0.5 , range_WTP_alph[1], n)
    # rp_base = np.linspace(0.5, 1, n)


    return tau_o, WTP_base, rp_base, WTP_alph


def agent_distribution_adjust(time_index, modelforcing, agent, agentsame, frontrow_on):
    t = time_index
    cutoff1 = 0.1
    cutoff2 = 0.9

    if frontrow_on:
        P_e = agent._P_e
    else:
        P_e = agent._P_e


    if agent._beta_x < cutoff1 and agent._beta_x >= 0:
        switching_speed = agent._beta_x * (agent._adjust_beta_x) / cutoff1

    if agent._beta_x > cutoff2 and agent._beta_x <= 1:
        switching_speed = (
            -(agent._adjust_beta_x / cutoff1) * agent._beta_x + agent._adjust_beta_x / cutoff1
        )

    if agent._beta_x >= cutoff1 and agent._beta_x <= cutoff2:
        switching_speed = agent._adjust_beta_x

    dP_e = (P_e[t] - P_e[t - 1]) / P_e[t - 1]

    if dP_e > 0:
        agent._range_WTP_base[1] = dP_e * agent._range_WTP_base[1] + agent._range_WTP_base[1]
        agent._range_WTP_alph[1] = dP_e * agent._range_WTP_alph[1] + agent._range_WTP_alph[1]

    W = 1 / (1 + agent._beta_x_feedbackparam * (agent._price[t] - P_e[t]) ** 2)

    agent._beta_x = (
        agent._beta_x
        + W * switching_speed * (agent._price[t] - P_e[t])
        + (1 - W) * switching_speed * (P_e[t] - agent._price[t])
    )

    if agent._beta_x > 1:
        agent._beta_x = 1

    if agent._beta_x < 0:
        agent._beta_x = 0

    [agent._tau_o, agent._WTP_base, agent._rp_base, agent._WTP_alph,] = agent_distribution(
        agent._rcov,
        agent._range_WTP_base,
        agent._range_WTP_alph,
        agent._range_tau_o,
        agent._range_rp_base,
        agent._beta_x,
        agent._n,
    )

    agent = calculate_risk_premium(time_index, agentsame, agent, modelforcing, frontrow_on)

    return agent


class Agents:
    def __init__(
        self,
        T,
        n,
        agentsame,
        increasing_outside_market,
        frontrow_on,
    ):

        """These variables were formerly contained in structures "agent" and "X"

        Examples
        --------

        #>>> from agents import Agents
        #>>> agents_doing_thangs = Agents()

        Parameters
        ----------
        # bta: float, optional
        #     Hedonic beach width coefficient for oceanfront housing
        # m: float, optional
        #     Additional investor-only fees of renting the propoerty (just investors)
        # delta: float, optional
        #     Interest rate (same for investor and owner)
        # gam: float, optional
        #     Depreciation rate on housing capital (same for investor and owner)
        # HV: int, optional
        #     Annualized value of housing services (same for investor and owner)
        # epsilon: int, optional
        #     Additional bid for investor
        # tau_c: float, optional
        #     Corporate tax rate (just investors) -- U.S. federal rate (could add 2.5# for NC)
        # beta_x_feedbackparam: int, optional
        #     Feedback parameter for agent distribution fluxes, reacts to outside market price
        # adjust_beta_x: int, optional
        #     Increment to adjust beta_x (agent distribution fluxes)
        # rcov: int, optional
        #     Covariance between agent income tax bracket, willingness to pay, and risk tolerance
        """

        self._T = T
        self._n = n
        self._m = 1000
        self._delta = 0.06
        self._gam = 0.01
        self._HV = 25000
        self._epsilon = 1
        self._tau_c = 0.2
        self._beta_x_feedbackparam = 1e-7
        self._adjust_beta_x = 1e-8
        self._rcov = 0.9

        RNG = np.random.default_rng(
            seed=self._n
        )  # KA: added seeded random number generator the size of n

        # owner agent
        if frontrow_on:
            self._range_WTP_base = [5000, 35000]
            self._range_WTP_alph = [5000, 35000]
            self._range_tau_o = [0.05, 0.37]
            self._beta_x = 0.6
            self._bta = 0.2
            if increasing_outside_market:
                self._P_e = np.linspace(agentsame._P_e_OF,
                                                      3 * agentsame._P_e_OF, self._T)
            else:
                self._P_e = agentsame._P_e_OF * np.ones(self._T)

        else:
            self._range_WTP_base = [5000, 35000]
            self._range_WTP_alph = [5000, 35000]
            self._range_tau_o = [0.05, 0.37]
            self._beta_x = 0.38
            self._bta = 0.1
            if increasing_outside_market:
                self._P_e = np.linspace(agentsame._P_e_NOF,
                                                       3 * agentsame._P_e_NOF, self._T)
            else:
                self._P_e = agentsame._P_e_NOF * np.ones(self._T)

        self._range_rp_base = [0.25, 1.25]
        self._rp_I = np.zeros(1)
        self._rp_o = np.zeros(self._n)
        self._tau_prop = 0.01 * np.ones(self._T)

        [
            self._tau_o,
            self._WTP_base,
            self._rp_base,
            self._WTP_alph,
        ] = agent_distribution(
            self._rcov,
            self._range_WTP_base,
            self._range_WTP_alph,
            self._range_tau_o,
            self._range_rp_base,
            self._beta_x,
            n,
        )  # generate agent variables

        self._rp_base_sorted = np.sort(self._rp_base)
        self._I = np.argsort(self._rp_base)
        self._g_I = 0
        self._g_o = np.zeros(self._n)
        self._price = np.zeros(self._T)
        self._rent = np.zeros(self._T)
        self._mkt = np.zeros(self._T)
        self._wtp = np.zeros(self._n)

        if frontrow_on:
            self._price[0] = 6e5
            self._rent[0] = 0
        else:
            self._price[0] = 4e5
            self._rent[0] = 0
        self._mkt[0] = 0

    @property
    def mkt(self):
        return self._mkt
