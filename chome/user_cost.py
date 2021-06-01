import numpy as np


def calculate_risk_premium(time_index, ACOM, A, M, frontrow_on):
    t = time_index
    a = 0.47
    b = 0.4
    c = 0.0125

    if frontrow_on:
        of = 1
    else:
        of = 0

    for ii in range(1, np.size(A._rp_o)):
        A._rp_o[ii] = (
            a
            - b * (M._barr_elev - M._msl[t])
            - c * ACOM._Edh[t] * (M._barr_elev - M._msl[t])
        ) * A._rp_base[ii] + of * 0.01

    A._rp_I = (
        a
        - b * (M._barr_elev - M._msl[t])
        - c * ACOM._Edh[t] * (M._barr_elev - M._msl[t])
    ) * np.mean(A._range_rp_base) + of * 0.01

    return A


def calculate_user_cost(time_index, A, tau_prop):
    t = time_index
    R = np.zeros(A._n)
    R_i = np.zeros(1)
    P_O = np.zeros(A._n)
    P_bid = np.zeros(1)
    owner_info = np.zeros(shape=(A._n, 2))
    rent_store = np.zeros(A._n)
    P_invest_store = np.zeros(A._n)
    vacancies = np.zeros(A._n)

    R = A._wtp + A._HV
    P_o = R / ((A._delta + tau_prop) * (1 - A._tau_o) + A._gam + A._rp_o - A._g_o)
    owner_info = np.column_stack((P_o, R))
    owner_info = owner_info[np.argsort(owner_info[:, 0])]

    for i in range(0, A._n):
        P_bid = owner_info[i, 0] + A._epsilon
        R_i = (
            P_bid
            * ((A._delta + A._tau_prop[t]) * (1 - A._tau_c) + A._gam + A._rp_I - A._g_I)
            - A._m
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
        mkt_share_invest = (ii + 1) / A._n
        if ii == A._n - 1:
            vac_check = 1
        else:
            ii += 1

    A._price[t] = P_equ
    A._rent[t] = R_equ
    A._mkt[t] = mkt_share_invest

    return A


def expected_capital_gains(time_index, A, M, frontrow_on):

    t = time_index

    # if frontrow_on:
    #     P_e = M._P_e_OF[0:t]
    # else:
    #     P_e = M._P_e_NOF[0:t]

    Lmin = 30
    Lmax = 30
    price_return = np.zeros(Lmax - Lmin + 1)

    if t > Lmax + 1:
        price = A._price[0:t]

        for L in range(Lmin, Lmax + 1):
            pricereturn_L = (price[t - 1] - price[t - 1 - L]) / price[t - 1 - L]
            price_return[L - Lmin] = (1 + pricereturn_L) ** (1 / L) - 1

        A._g_I = np.median(price_return)
        A._g_o = A._g_o * 0 + price_return

    return A
