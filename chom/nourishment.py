"""Nourishment

This module does agent stuff (formerly user_cost.m and others)

References
----------
Mullin, Smith, McNamara

Notes

"""

import numpy as np
from .user_cost import calculate_risk_premium, calculate_user_cost
import copy as copy


def evaluate_nourishment_future_beach_width(
    time_index, mgmt, agentsame, nourish_interval
):
    """
    This is an explanation of what the hell this function does. I love to over explain things.

    :param time_index: int, this is the time
    :param agentsame:
    :param mgmt:
    :param nourish_interval:
    :return:

    """

    t = time_index
    t_horiz = mgmt.expectation_horizon
    bw_future = np.zeros(t_horiz)

    if nourish_interval != mgmt.nourish_plan_horizon + 1:
        bw_future[0] = mgmt.x0
        nourish_xshore = np.zeros(t_horiz)
        nourishplan_new = np.zeros(t_horiz)
        nourishplan_last = mgmt.nourishtime[t + 1 : t + t_horiz + 1]
        nourish_times = np.arange(0, mgmt.nourish_plan_horizon, nourish_interval)
        nourishplan_new[nourish_times] = 1
        planned_nourishment = (
            nourishplan_last + nourishplan_new
        )  # z question to self: does this account for overlapping nourishments - does this get assigned 2's ever?
    else:
        nourishplan_last = mgmt.nourishtime[t + 1 : t + t_horiz + 1]
        bw_future[0] = mgmt.bw[t] - agentsame.E_ER[t]
        nourish_xshore = []
        nourish_times = []
        planned_nourishment = nourishplan_last

    for time in range(1, t_horiz):
        if planned_nourishment[time] == 1:  # if planned_nourishment[time] > 0:
            bw_future[time] = mgmt.x0
            nourish_xshore[time] = mgmt.x0 - (bw_future[time - 1] - agentsame.E_ER[t])
        else:
            bw_future[time] = bw_future[time - 1] - agentsame.E_ER[t]

    bw_future = bw_future[0 : mgmt.nourish_plan_horizon]
    bw_future[bw_future < 1] = 1
    if len(nourish_times) > 0:
        nourish_xshore = nourish_xshore[nourish_times]
        nourish_yr = nourish_times
    else:
        nourish_yr = []

    mean_beach_width = np.average(bw_future)

    if nourish_interval != mgmt.nourish_plan_horizon + 1:
        nourish_xshore[0] = mgmt.x0 - mgmt.bw[t]

    return nourish_xshore, nourish_yr, mean_beach_width


def calculate_nourishment_plan_cost(
    time_index, agentsame, mgmt, modelforcing, agent_of, agent_nof
):
    """


    :param time_index: the time index
    :param agentsame: class with variables that are the same between both sets of agents (ocean front and non-OF)
    :param mgmt: class containing human management variables
    :param modelforcing: class of modeling (environmental) forcing parameters
    :param agent_of: class containing ocean front agents
    :param agent_nof: class containing non-ocean front agents

    """

    t = time_index
    alongshore_barrier_length = mgmt.lLength
    shoreface_depth = mgmt.Ddepth
    fixed_cost_bulldoze = (
        mgmt.fixedcost_beach
    )  # fixed cost ass. with nourishment (permits, bulldozer, you name it)
    delta = mgmt.delta_disc  # KA: left off here
    amort = mgmt.amort
    barrier_height_msl = modelforcing.barr_height[
        t
    ]  # has already been updated this time step for SLR

    mgmt.nourishment_menu_volumes = 0 * mgmt.nourishment_menu_volumes
    mgmt.nourishment_menu_bw = 0 * mgmt.nourishment_menu_bw
    mgmt.nourishment_menu_taxburden = 0 * mgmt.nourishment_menu_taxburden
    mgmt.nourishment_pricelist = 0 * mgmt.nourishment_pricelist

    # calculate costs and tax rate for various nourishment intervals for nourishing every 1 - 10 years
    # index describes nourishing every (nourishment interval + 1) years the case of no nourishment is
    #  indexed as nourishment interval = 10 (+1)
    for nourish_interval in range(0, mgmt.nourish_plan_horizon + 1):

        i = nourish_interval
        [
            nourish_xshore,
            nourish_yr,
            mean_beach_width,
        ] = evaluate_nourishment_future_beach_width(time_index, mgmt, agentsame, i + 1)

        if nourish_interval < mgmt.nourish_plan_horizon:
            nourish_yr = nourish_yr + 1
            fcost = fixed_cost_bulldoze / ((1 + delta) ** nourish_yr)
            namount = alongshore_barrier_length * (
                nourish_xshore * (2 * barrier_height_msl + shoreface_depth) / 2
            )
            varcost = (mgmt.sandcost * namount) / ((1 + delta) ** nourish_yr)
            mgmt.nourishment_menu_volumes[i, nourish_yr] = namount
            mgmt.nourishment_menu_cost[i] = (1 - mgmt.nourish_subsidy) * (
                np.sum(fcost) + np.sum(varcost)
            )
            mgmt.nourishment_menu_bw[i] = mean_beach_width
            mgmt.nourishment_menu_totalcostperyear[i] = (
                mgmt.nourishment_menu_cost[i]
                * delta
                * (1 + delta) ** amort
                / ((1 + delta) ** amort - 1)
            )
        else:
            mgmt.nourishment_menu_cost[i] = 0
            mgmt.nourishment_menu_bw[i] = mean_beach_width
            mgmt.nourishment_menu_totalcostperyear[i] = 0

    for i in range(0, mgmt.nourish_plan_horizon + 1):
        if mgmt.nourishment_menu_totalcostperyear[i] < 0:
            mgmt.nourishment_menu_totalcostperyear[i] = 0
        mgmt.nourishment_menu_add_tax[i] = (
            amort
            * mgmt.nourishment_menu_totalcostperyear[i]
            / np.sum(
                mgmt.taxratio_OF * agentsame.I_OF * agent_of.price[t - 1]
                + (1 - agentsame.I_OF) * agent_nof.price[t - 1]
            )
        )
        mgmt.nourishment_menu_taxburden[:, i] = amort * (
            mgmt.nourishment_menu_add_tax[i]
            * (1 - agentsame.I_OF)
            * agent_nof.price[t - 1]
            + mgmt.taxratio_OF
            * mgmt.nourishment_menu_add_tax[i]
            * agentsame.I_OF
            * agent_of.price[t - 1]
        )

    return


def calculate_nourishment_plan_ben(time_index, agent_of, agent_nof, mgmt, agentsame):
    t = time_index

    for nourishment_interval in range(0, 11):
        agent_nof_copy = copy.deepcopy(agent_nof)
        agent_of_copy = copy.deepcopy(agent_of)
        tau_prop_nof = np.zeros(1)
        tau_prop_of = np.zeros(1)
        i = nourishment_interval
        mbw = mgmt.nourishment_menu_bw[nourishment_interval]
        agent_nof_copy.wtp = (
            agent_nof.WTP_base + agent_nof.WTP_alph * mbw ** agent_nof.bta
        )
        agent_of_copy.wtp = agent_of.WTP_base + agent_of.WTP_alph * mbw ** agent_of.bta
        tau_prop_nof[0] = (
            agent_nof_copy.tau_prop[t + 1] + mgmt.nourishment_menu_add_tax[i]
        )
        tau_prop_of[0] = (
            agent_of_copy.tau_prop[t + 1]
            + mgmt.nourishment_menu_add_tax[i] * mgmt.taxratio_OF
        )

        calculate_user_cost(time_index, agent_nof_copy, tau_prop_nof)
        calculate_user_cost(time_index, agent_of_copy, tau_prop_of)
        mgmt.OF_plan_price[i] = agent_of_copy.price[t]
        mgmt.NOF_plan_price[i] = agent_nof_copy.price[t]

    mgmt.nourishment_pricelist = 0 * mgmt.nourishment_pricelist  # just added 6/15

    for i in range(0, 11):
        mgmt.nourishment_pricelist[0 : agentsame.n_NOF, i] = mgmt.NOF_plan_price[i]
        mgmt.nourishment_pricelist[agentsame.n_NOF :, i] = mgmt.OF_plan_price[i]

    return


def evaluate_nourishment_plans(
    time_index, mgmt, modelforcing, agent_of, agent_nof, agentsame
):
    t = time_index
    price_increase = np.zeros(1)
    vote = np.zeros(shape=(agentsame.n_agent_total, 10))
    net_benefit = np.zeros(shape=(agentsame.n_agent_total, 10))
    schedule_conflict = np.zeros(10)
    tally_vote = np.zeros(10)
    nourish_schedule = np.tile(
        mgmt.nourishtime[t + 1 : t + mgmt.nourish_plan_horizon + 1], (11, 1)
    )

    for j in range(0, 10):
        nindx = np.arange(1, mgmt.nourish_plan_horizon + 1, j + 1)
        nourish_schedule[j, nindx - 1] = nourish_schedule[j, nindx - 1] + 1

        if np.any(nourish_schedule[j, :] > 1):  # catch doubly scheduled nourishments
            schedule_conflict[j] = 1

        if np.any(
            nourish_schedule[j, 0:-1] + nourish_schedule[j, 1:] == 2
        ):  # catch back to back scheduled
            schedule_conflict[j] = 1

        if t > 5:
            if np.any(mgmt.nourishtime[t - 2 : t + 1] > 0):
                schedule_conflict[j] = 1

    # Net Benefits: for every property in every nourishment menu option
    # determine the net benefit of the plan as the 1-year increase
    # in property value minus the yearly tax burden
    for j in range(0, 10):
        for i in range(0, agentsame.n_agent_total):
            price_increase = (
                mgmt.nourishment_pricelist[i, j] - mgmt.nourishment_pricelist[i, 10]
            )
            net_benefit[i, j] = price_increase - mgmt.nourishment_menu_taxburden[i, j]

    # Voting: vote on nourishment menu options, only resident home owners vote
    # agents can vote for multiple plans, agents vote yes (1) for a plan when
    # the net benefits are greater than zero
    for j in range(0, 10):
        for i in range(0, agentsame.n_agent_total):
            if agentsame.I_own[i] == 1 and schedule_conflict[j] == 0:
                if net_benefit[i, j] > 0:
                    vote[i, j] = 1
                else:
                    vote[i, j] = 0

    # tally up the votes
    for j in range(0, 10):
        tally_vote[j] = np.sum(vote[:, j]) / np.sum(agentsame.I_own)

    tally_vote[0] = 0  # don't allow nourishment every year
    tally_vote[9] = 0  # don't allow only 1 nourishment (must commit to more than 1)
    voter_choice = np.argwhere(tally_vote > 0.5)

    if np.size(voter_choice) == 0 or mgmt.nourishtime[t] == 1 or mgmt.bw[t] > mgmt.x0:
        final_choice = 10
    elif np.size(voter_choice) == 1:
        final_choice = voter_choice
    else:
        not_voter_choice = np.ones(10)
        not_voter_choice[voter_choice] = 0
        summed_net_benefit = np.zeros(10)
        for j in range(0, 10):
            summed_net_benefit[j] = np.sum(net_benefit[:, j] * agentsame.I_own) + 0.0
        summed_net_benefit[np.argwhere(not_voter_choice == 1)] = None
        final_choice = np.argwhere(summed_net_benefit == np.nanmax(summed_net_benefit))

    if final_choice == 10:
        mgmt.newplan[t + 1] = 0
    else:
        mgmt.newplan[t + 1] = 1
        mgmt.addvolume[t + 1 : t + mgmt.nourish_plan_horizon + 1] = (
            mgmt.nourishment_menu_volumes[
                final_choice, 1 : mgmt.nourish_plan_horizon + 1
            ]
            + mgmt.addvolume[t + 1 : t + mgmt.nourish_plan_horizon + 1]
        )
        mgmt.nourishtime[t + 1 : t + mgmt.nourish_plan_horizon + 1] = nourish_schedule[
            final_choice, :
        ]
        agent_nof.tau_prop[t + 1 : t + mgmt.amort + 1] = (
            agent_nof.tau_prop[t + 1 : t + mgmt.amort + 1]
            + mgmt.nourishment_menu_add_tax[final_choice]
        )
        agent_of.tau_prop[t + 1 : t + mgmt.amort + 1] = (
            agent_of.tau_prop[t + 1 : t + mgmt.amort + 1]
            + mgmt.taxratio_OF * mgmt.nourishment_menu_add_tax[final_choice]
        )

    return


def calculate_evaluate_dunes(
    time_index, mgmt, modelforcing, agentsame, agent_of, agent_nof
):
    t = time_index
    vote = np.zeros(shape=agentsame.n_agent_total)
    price_increase = np.zeros(shape=agentsame.n_agent_total)

    if mgmt.dune_sand_volume[t] == 0:
        mgmt.dune_sand_volume[t] = (
            mgmt.lLength * mgmt.dune_width * (mgmt.h0 - mgmt.h_dune[t])
        )

    # calculate the cost of building a dune
    # translate cost into proposed property tax increase
    # and tax burden over amortization period
    var_cost = mgmt.dune_sand_volume[t] * mgmt.sandcost
    totalcost = (1 - mgmt.nourish_subsidy) * (var_cost + mgmt.fixedcost_dune)
    tc_peryear = (
        totalcost
        * mgmt.delta_disc
        * (1 + mgmt.delta_disc) ** mgmt.amort
        / ((1 + mgmt.delta_disc) ** mgmt.amort - 1)
    )
    tau_add = (
        mgmt.amort
        * tc_peryear
        / np.sum(
            mgmt.taxratio_OF * agentsame.I_OF * agent_of.price[t - 1]
            + (1 - agentsame.I_OF) * agent_nof.price[t - 1]
        )
    )
    tax_burden = mgmt.amort * (
        tau_add * (1 - agentsame.I_OF) * agent_nof.price[t - 1]
        + mgmt.taxratio_OF * tau_add * agentsame.I_OF * agent_of.price[t - 1]
    )

    # create copies to evaluate market price
    # with and without the dunes/property tax increase
    agent_of_nodune = copy.deepcopy(agent_of)
    agent_nof_nodune = copy.deepcopy(agent_nof)
    agent_of_dune = copy.deepcopy(agent_of)
    agent_nof_dune = copy.deepcopy(agent_nof)
    mgmt_dune = copy.deepcopy(mgmt)
    mgmt_dune.h_dune[t] = mgmt_dune.h0

    # risk premium withOUT dunes for non-oceanfront; updates agent class
    calculate_risk_premium(
        time_index, agent_nof_nodune, modelforcing, mgmt, frontrow_on=False
    )

    # risk premium WITH dunes for non-oceanfront
    calculate_risk_premium(
        time_index, agent_nof_dune, modelforcing, mgmt_dune, frontrow_on=False
    )

    # risk premium withOUT dunes for oceanfront
    calculate_risk_premium(
        time_index, agent_of_nodune, modelforcing, mgmt, frontrow_on=True
    )

    # risk premium WITH dunes for oceanfront
    calculate_risk_premium(
        time_index, agent_of_dune, modelforcing, mgmt_dune, frontrow_on=True
    )

    # forward simulate the oceanfront/nonoceanfront market values; updates agent class
    # withOUT dunes
    calculate_user_cost(time_index, agent_of_nodune, agent_of_nodune.tau_prop[t + 1])
    calculate_user_cost(time_index, agent_nof_nodune, agent_nof_nodune.tau_prop[t + 1])

    # forward simulate the oceanfront/nonoceanfront market values
    # WITH dunes
    calculate_user_cost(
        time_index,
        agent_of_dune,
        agent_of_dune.tau_prop[t + 1] + tau_add * mgmt.taxratio_OF,
    )
    calculate_user_cost(
        time_index, agent_nof_dune, agent_nof_dune.tau_prop[t + 1] + tau_add
    )

    # agent index locations for nof/of in price_increase
    nof_index = np.arange(0, agentsame.n_NOF)
    of_index = np.arange(agentsame.n_NOF, agentsame.n_agent_total)

    price_increase[nof_index] = agent_nof_dune.price[t] - agent_nof_nodune.price[t]
    price_increase[of_index] = agent_of_dune.price[t] - agent_of_nodune.price[t]

    # loop over all agent properties and cast vote for each
    # agent/property where the house price increase is greater
    # than the tax burden
    for i in range(0, agentsame.n_agent_total):
        if agentsame.I_own[i] == 1:
            if price_increase[i] - tax_burden[i] > 0:
                vote[i] = 1
            else:
                vote[i] = 0

    tally_vote = np.sum(vote) / np.sum(agentsame.I_own)

    # if more than half of resident owners vote yes (1)
    # then build the dunes and update the property taxes
    if tally_vote > 0.5 and mgmt.nourishtime[t + 1] == 1:
        mgmt.builddunetime[t + 1] = 1

        agent_nof.tau_prop[t + 1 : t + mgmt.amort + 1] = (
            agent_nof.tau_prop[t + 1 : t + mgmt.amort + 1] + tau_add
        )

        agent_of.tau_prop[t + 1 : t + mgmt.amort + 1] = (
            agent_of.tau_prop[t + 1 : t + mgmt.amort + 1] + mgmt.taxratio_OF * tau_add
        )

    return
