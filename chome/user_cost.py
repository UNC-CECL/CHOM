"""User Cost

This module does agent stuff (formerly user_cost.m and others)

References
----------
Poterba [1]
Noaa flood report [2]

Notes

"""

import numpy as np


def calculate_risk_premium(time_index, agent, modelforcing, mgmt, frontrow_on):
    """
    This is an explanation of what the hell this function does. I love to over explain things.

    :param time_index: int, this is the time
    :param agent:
    :param mgmt:
    :param modelforcing:
    :param frontrow_on
    :return:

    """

    t = time_index
    max_flood_days = 365
    logistic_param_denom1 = 200
    logistic_param_denom2 = 5
    storm_risk_param = 0.1
    dune_sealevel_param = 0.04
    front_row_risk_factor = 0.02
    dune_height_risk_param = 8

    if frontrow_on:
        of = 1
    else:
        of = 0

    number_sunny_day_flood = max_flood_days / (
        1
        + logistic_param_denom1
        * np.exp(-logistic_param_denom2 * modelforcing.barr_elev[t])
    )
    sunny_day_flood_premium = number_sunny_day_flood / max_flood_days
    storm_risk_increases_with_sea_level = (
        1 + storm_risk_param / modelforcing.barr_elev[t]
    )
    dunes_reduce_storm_risk = 1 - np.exp(
        -dune_height_risk_param * (mgmt.h_dune[t] / mgmt.h0) ** 8
    )
    dune_premium = dune_sealevel_param * (
        storm_risk_increases_with_sea_level - dunes_reduce_storm_risk
    )
    front_row_extra_risky = of * front_row_risk_factor
    investor_risk_tolerance = np.median(agent.rp_base)

    for ii in range(agent.n):
        agent.rp_o[ii] = agent.rp_base[ii] * (
            sunny_day_flood_premium + dune_premium + front_row_extra_risky
        )

    agent.rp_I = investor_risk_tolerance * (
        sunny_day_flood_premium + dune_premium + front_row_extra_risky
    )

    return


def calculate_user_cost(time_index, agent, tau_prop):

    t = time_index
    rent_store = np.zeros(agent.n)
    price_invest_store = np.zeros(agent.n)
    vacancies = np.zeros(agent.n)
    rent_bid_agents = agent.wtp
    price_bid_agent = rent_bid_agents / (
        (agent.delta + tau_prop) * (1 - agent.tau_o)
        + agent.gam
        + agent.rp_o
        - agent.g_o
    )
    owner_info = np.column_stack((price_bid_agent, rent_bid_agents))
    owner_info = owner_info[np.argsort(owner_info[:, 0])]

    for i in range(0, agent.n):
        price_bid_investor = owner_info[i, 0] + agent.epsilon
        rent_offer_investor = (
            price_bid_investor
            * (
                (agent.delta + tau_prop) * (1 - agent.tau_c)
                + agent.gam
                + agent.rp_I
                - agent.g_I
            )
            - agent.m
        )

        vacant = np.zeros(i)
        if rent_offer_investor < 0:
            rent_offer_investor = 1

        for j in range(0, i):
            if rent_offer_investor > owner_info[j, 1]:
                vacant[j] = 1

        vacancies[i] = np.sum(vacant[0 : i + 1])
        rent_store[i] = rent_offer_investor
        price_invest_store[i] = price_bid_investor

    results = np.column_stack((vacancies, rent_store, price_invest_store))
    vacancies_check = 0
    ii = 0
    price_equilibrium = 0
    rent_equilibrium = 0
    market_share_investor = 0

    while vacancies_check < 1:
        rent_equilibrium = results[ii, 1]
        price_equilibrium = results[ii, 2]
        vacancies_check = results[ii, 0]
        market_share_investor = (ii + 1) / agent.n
        if ii == agent.n - 1:
            vacancies_check = 1
        else:
            ii += 1

    agent.price[t] = price_equilibrium
    agent.rent[t] = rent_equilibrium
    agent.mkt[t] = market_share_investor

    return


def expected_capital_gains(time_index, agent):

    t = time_index
    min_year = 20
    max_year = 30
    annualized_return = np.zeros(max_year - min_year + 1)

    if t > max_year + 1:
        price = agent.price[0:t]

        for year_interval in range(min_year, max_year + 1):
            cumulative_return = (price[t - 1] - price[t - 1 - year_interval]) / price[
                t - 1 - year_interval
            ]
            annualized_return[year_interval - min_year] = (1 + cumulative_return) ** (
                1 / year_interval
            ) - 1

        agent.g_I = np.median(annualized_return)
        # assign annualized returns randomly to agents
        # agent.g_o = annualized[-1] * np.ones(agent.n)
        agent.g_o = annualized_return[
            np.random.randint(max_year - min_year, size=agent.n)
        ]

    return
