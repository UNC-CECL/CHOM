import numpy as np
import copy as copy


def evolve_environment(time_index, agentsame, mgmt, modelforcing):
    """
    This is an explanation of what the hell this function does. I love to over explain things.

    :param time_index: int, this is the time
    :param agentsame:
    :param mgmt:
    :param modelforcing:
    :return: nourish_now, rebuild_dune_now:

    """

    t = time_index
    nourish_now = 0  # initialize nourishment and dune rebuild trackers as false
    rebuild_dune_now = 0

    if mgmt.nourishtime[t] == 1:  # if nourish is scheduled
        mgmt.bw[t] = mgmt.x0  # set beach width to desired beach width
        nourish_now = 1  # track when nourishment occurs
    elif (
        mgmt.bw[t] != 0
    ):  # if beach width is already specified (if coupled with another model), then don't modify
        pass
    else:
        mgmt.bw[t] = mgmt.bw[t - 1] - modelforcing.ER[t]

    # calculate agent expected erosion rate
    agentsame.E_ER[t] = (
        agentsame.theta_er * modelforcing.ER[t]
        + (1 - agentsame.theta_er) * agentsame.E_ER[t - 1]
    )

    if mgmt.builddunetime[t] == 1:  # if dune build is scheduled
        mgmt.h_dune[t] = mgmt.h0  # then build it back up
        rebuild_dune_now = 1  # track when dune building occurs
    elif (
        mgmt.h_dune[t] != 0
    ):  # if dune_height is already specified (if coupled with another model), then don't modify
        pass
    else:
        mgmt.h_dune[t] = (
            mgmt.h_dune[t - 1] - 0.1
        )  # erode the dune slightly from the last time step

    if mgmt.bw[t] < 1:
        mgmt.bw[t] = 1

    if mgmt.h_dune[t] < 0.1:
        mgmt.h_dune[t] = 0.1

    return nourish_now, rebuild_dune_now


def calculate_expected_beach_width(time_index, mgmt, agentsame, agent_of, agent_nof):
    t = time_index
    exp_bw = copy.deepcopy(mgmt.bw)
    bw_back = np.zeros(t + mgmt.nourish_plan_horizon)

    for time in range(t + 1, t + mgmt.nourish_plan_horizon):
        if mgmt.nourishtime[time] == 1:
            exp_bw[time] = mgmt.x0
        else:
            exp_bw[time] = exp_bw[time - 1] - agentsame.E_ER[t]

    exp_bw[exp_bw < 1] = 1
    ind = 0

    if t > mgmt.expectation_horizon:
        for time in range(t + 1, t + mgmt.nourish_plan_horizon):
            bw_back[ind] = np.average(
                exp_bw[time - (mgmt.expectation_horizon - 1) : time]
            )
            ind += 1
    else:
        for time in range(t + 1, t + mgmt.nourish_plan_horizon):
            bw_back[ind] = np.average(exp_bw[0:time])
            ind += 1
    agentsame.Ebw[t] = np.mean(bw_back[0:ind])

    # expected willingness to pay
    agent_nof.wtp = (
        agent_nof.WTP_base + agent_nof.WTP_alph * agentsame.Ebw[t] ** agent_nof.bta
    )
    agent_of.wtp = (
        agent_of.WTP_base + agent_of.WTP_alph * agentsame.Ebw[t] ** agent_of.bta
    )

    return
