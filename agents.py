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
from scipy.stats import beta


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
    beta_max = 10.5
    beta_min = 2

    bline2 = -1 * (beta_max - beta_min) * beta_x + beta_max
    bline1 = (beta_max - beta_min) * beta_x + beta_min

    # covariances (KA: are these linear correlation parameters?)
    #              ZW: yep
    r12 = rcov
    r13 = rcov
    r14 = rcov
    r23 = 0.9
    r24 = rcov
    r34 = rcov

    Rho = np.array(
        [[1, r12, r13, r14], [r12, 1, r23, r24], [r13, r23, 1, r34], [r14, r24, r34, 1]]
    )
    # U = copularnd('Gaussian', Rho, n);
    #  gaussian copula is based on the Gaussian Multivariate distribution
    # ZW - I'm looking into this - matlab gives a different output from "copularnd" (confined to interval 0 to 1)
    #     since np.random.multivariate_normal produces values outside [0 1], the result is beta.ppf produces NaN for vals outside this range
    size = Rho.shape[0]
    means = np.zeros(size)
    U = np.random.multivariate_normal(means, Rho, size=n)

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

    return tau_o, WTP_base, rp_base, WTP_alph


def agent_distribution_adjust():
    return


class Agents:
    def __init__(
        self,
        T=400,
        n=2500,
        bta=0.2,
        m=0.003,  # which of these will be tuned for locations? keep here, otherwise, move below
        delta=0.06, # ZW: they won't all need to be upfront, but for initial model coupling I'll likely have to adjust some quite a bit, so lets keep them together for the time being
        gam=0.01,
        HV=1000,
        rp_storm=0,
        epsilon=1,
        tau_c=0.2,
        capgain_feedbackparam=1e-10,
        beta_x_feedbackparam=1e-10,
        adjust_beta_x=5e-8,
        risk_to_EnvExptdGains=0.2,
        frac_realist=0.75,
        rcov=0.8,
        env_risk_immediacy=0.2,
    ):

        """These variables were formerly contained in structures "A" and "X"

        Examples
        --------
        >>> from agents import Agents
        >>> agents_doing_thangs = Agents()

        Parameters
        ----------
        bta: float, optional
            Hedonic beach width coefficient for oceanfront housing
        m: float, optional
            Additional investor-only fees of renting the propoerty (just investors)
        delta: float, optional
            Interest rate (same for investor and owner)
        gam: float, optional
            Depreciation rate on housing capital (same for investor and owner)
        HV: int, optional
            Annualized value of housing services (same for investor and owner)
        rp_storm: int, optional
            Coefficient to convert storm return interval to risk premium
        epsilon: int, optional
            Additional bid for investor
        tau_c: float, optional
            Corporate tax rate (just investors) -- U.S. federal rate (could add 2.5# for NC)
        capgain_feedbackparam: float, optional
            Feedback parameter for expected capital gains
        beta_x_feedbackparam: int, optional
            Feedback parameter for agent distribution fluxes, reacts to outside market price
        adjust_beta_x: int, optional
            Increment to adjust beta_x (agent distribution fluxes)
        risk_to_EnvExptdGains: int, optional
            Coefficient converting risk premium to an expected capital loss (applies only to I_realist=1)
        frac_realist: int, optional
            Total fraction of agents who consider internal system dyanmics to inform risk premia, and expected cap gains
        rcov: int, optional
            Covariance between agent income tax bracket, willingness to pay, and risk tolerance
        env_risk_immediacy: int, optional
            Determines how quickly people switch from abitrage to environmental risk in capital gains
        """

        self._T = T
        self._n = n
        self._bta = bta
        self._m = m
        self._delta = delta
        self._gam = gam
        self._HV = HV
        self._rp_storm = rp_storm
        self._epsilon = epsilon
        self._tau_c = tau_c
        self._capgain_feedbackparam = capgain_feedbackparam
        self._beta_x_feedbackparam = beta_x_feedbackparam
        self._adjust_beta_x = adjust_beta_x
        self._risk_to_EnvExptdGains = risk_to_EnvExptdGains
        self._frac_realist = frac_realist
        self._rcov = rcov
        self._env_risk_immediacy = env_risk_immediacy

        RNG = np.random.default_rng(
            seed=self._n
        )  # KA: added seeded random number generator the size of n

        # owner agent
        if self._bta == 2:
            # base willingness to pay distribution bounds
            self._range_WTP_base = [5000, 35000]
            self._range_WTP_alph = [5000, 35000]
            self._range_tau_o = [0.0, 0.35]  # income tax bracket (0 to 0.37)
        else:
            self._range_WTP_base = [5000, 25000]
            self._range_WTP_alph = [5000, 25000]
            self._range_tau_o = [0.0, 0.35]

        if self._bta == 0.2:
            # base risk premium distribution - random distribution of shifts to base risk premium
            self._range_rp_base = [-0.03, 0.03]
        else:
            self._range_rp_base = [0, 0.03]

        # average risk premium real estate (same for investor and owner)
        self._rp_I = np.zeros(1)
        self._rp_o = np.zeros(self._n)

        # base property tax rate (same for investor and owner)
        self._tau_prop = 0.01 * np.ones(self._T)

        if bta == 2:
            self._beta_x = 0.4
        else:
            self._beta_x = 0.4

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

        self._I_realist = np.zeros(len(self._rp_base))
        self._I_realist[
            self._I[-1 - round(len(self._rp_base) * self._frac_realist) + 1 : -1]
        ] = 1  # KA -- make sure this matches matlab re: indices (ZW -- this is correct)
        self._g_I = 0.01
        self._g_o = 0.04 * RNG.standard_normal(self._n)  # randn(n,1)
        self._price = np.zeros(self._T)
        self._rent = np.zeros(self._T)
        self._mkt = np.zeros(self._T)

        if self._bta >= 0.2:
            self._price[0] = 6e5
            self._rent[0] = 1e5
        else:
            self._price[0] = 4e5
            self._rent[0] = 1e5
        self._mkt[0] = 0.4
