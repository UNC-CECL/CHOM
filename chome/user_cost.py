import numpy as np


def calculate_risk_premium(time_index, agentsame, agent, modelforcing, frontrow_on):
    t = time_index
    a = 0.47
    b = 0.4
    c = 0.0125

    if frontrow_on:
        of = 1
    else:
        of = 0

    for ii in range(np.size(agent._rp_o)):
        agent._rp_o[ii] = (
            a
            - b * (modelforcing._barr_elev - modelforcing._msl[t])
            - c * agentsame._Edh[t] * (modelforcing._barr_elev - modelforcing._msl[t])
        ) * agent._rp_base[ii] + of * 0.01

    agent._rp_I = (
        a
        - b * (modelforcing._barr_elev - modelforcing._msl[t])
        - c * agentsame._Edh[t] * (modelforcing._barr_elev - modelforcing._msl[t])
    ) * np.mean(agent._range_rp_base) + of * 0.01

    return agent


def calculate_user_cost(time_index, agent, tau_prop):
    t = time_index
    R = np.zeros(agent._n)
    R_i = np.zeros(1)
    P_O = np.zeros(agent._n)
    P_bid = np.zeros(1)
    owner_info = np.zeros(shape=(agent._n, 2))
    rent_store = np.zeros(agent._n)
    P_invest_store = np.zeros(agent._n)
    vacancies = np.zeros(agent._n)

    R = agent._wtp + agent._HV
    P_o = R / ((agent._delta + tau_prop) * (1 - agent._tau_o) + agent._gam + agent._rp_o - agent._g_o)
    owner_info = np.column_stack((P_o, R))
    owner_info = owner_info[np.argsort(owner_info[:, 0])]

    for i in range(0, agent._n):
        P_bid = owner_info[i, 0] + agent._epsilon
        R_i = (
            P_bid
            * ((agent._delta + tau_prop) * (1 - agent._tau_c) + agent._gam + agent._rp_I - agent._g_I)
            - agent._m
        )

        vacant = np.zeros(i)
        if R_i < 0:
            R_i = 1

        for j in range(0, i):
            if R_i > owner_info[j, 1]:
                vacant[j] = 1

        vacancies[i] = np.sum(vacant[0 : i + 1])
        rent_store[i] = R_i
        P_invest_store[i] = P_bid

    results = np.column_stack((vacancies, rent_store, P_invest_store))
    vac_check = 0
    ii = 0
    P_equ = 0
    R_equ = 0
    mkt_share_invest = 0

    while vac_check < 1:
        R_equ = results[ii, 1]
        P_equ = results[ii, 2]
        vac_check = results[ii, 0]
        mkt_share_invest = (ii + 1) / agent._n
        if ii == agent._n - 1:
            vac_check = 1
        else:
            ii += 1

    agent._price[t] = P_equ
    agent._rent[t] = R_equ
    agent._mkt[t] = mkt_share_invest

    return agent


def expected_capital_gains(time_index, agent, modelforcing, frontrow_on):

    t = time_index

    # if frontrow_on:
    #     P_e = modelforcing._P_e_OF[0:t]
    # else:
    #     P_e = modelforcing._P_e_NOF[0:t]

    Lmin = 30
    Lmax = 30
    price_return = np.zeros(Lmax - Lmin + 1)

    if t > Lmax + 1:
        price = agent._price[0:t]

        for L in range(Lmin, Lmax + 1):
            pricereturn_L = (price[t - 1] - price[t - 1 - L]) / price[t - 1 - L]
            price_return[L - Lmin] = (1 + pricereturn_L) ** (1 / L) - 1

        agent._g_I = np.median(price_return)
        agent._g_o = agent._g_o * 0 + price_return

    return agent
