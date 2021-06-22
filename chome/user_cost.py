import numpy as np


def calculate_risk_premium(time_index, agent, modelforcing, mgmt, frontrow_on):

    t = time_index
    a = 0.46
    b = 0.4
    c = 0.0125
    d = 0.005

    if frontrow_on:
        of = 1
    else:
        of = 0

    for ii in range(np.size(agent.rp_o)):
        agent.rp_o[ii] = (
            (a + of * 0.02)
            - b * modelforcing.barr_elev[t]
            - c * mgmt.h_dune[t] * modelforcing.barr_elev[t]
        ) + agent.rp_base[ii] * d
    agent.rp_I = (
        (a + of * 0.02)
        - b * modelforcing.barr_elev[t]
        - c * mgmt.h_dune[t] * modelforcing.barr_elev[t]
    ) + d

    return


def calculate_user_cost(time_index, agent, tau_prop):

    t = time_index
    # R = np.zeros(agent._n)
    # R_i = np.zeros(1)
    # P_o = np.zeros(agent._n)
    # P_bid = np.zeros(1)
    # owner_info = np.zeros(shape=(agent._n, 2))
    rent_store = np.zeros(agent.n)
    P_invest_store = np.zeros(agent.n)
    vacancies = np.zeros(agent.n)

    R = agent.wtp + agent.HV
    P_o = R / (
        (agent.delta + tau_prop) * (1 - agent.tau_o)
        + agent.gam
        + agent.rp_o
        - agent.g_o
    )
    owner_info = np.column_stack((P_o, R))
    owner_info = owner_info[np.argsort(owner_info[:, 0])]

    for i in range(0, agent.n):
        P_bid = owner_info[i, 0] + agent.epsilon
        R_i = (
            P_bid
            * (
                (agent.delta + tau_prop) * (1 - agent.tau_c)
                + agent.gam
                + agent.rp_I
                - agent.g_I
            )
            - agent.m
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
        mkt_share_invest = (ii + 1) / agent.n
        if ii == agent.n - 1:
            vac_check = 1
        else:
            ii += 1

    agent.price[t] = P_equ
    agent.rent[t] = R_equ
    agent.mkt[t] = mkt_share_invest

    return


def expected_capital_gains(time_index, agent):

    t = time_index

    Lmin = 30
    Lmax = 30
    price_return = np.zeros(Lmax - Lmin + 1)

    if t > Lmax + 1:
        price = agent.price[0:t]

        for L in range(Lmin, Lmax + 1):
            pricereturn_L = (price[t - 1] - price[t - 1 - L]) / price[t - 1 - L]
            price_return[L - Lmin] = (1 + pricereturn_L) ** (1 / L) - 1

        agent.g_I = np.median(price_return)
        agent.g_o = agent.g_o * 0 + price_return

    return
