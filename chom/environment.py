import numpy as np
import copy as copy


def evolve_environment(time_index, agentsame, mgmt, modelforcing):
    """
    Nourish the beach and rebuild the dune; if not a nourishment or rebuilding year, just erode the beach and the dunes
    """

    t = time_index
    nourish_now = 0  # initialize nourishment and dune rebuild trackers as false
    rebuild_dune_now = 0

    # nourishment decision -------------------------------------------------------------------
    # if nourishment is scheduled, nourish!
    if mgmt.nourishtime[t] == 1:
        mgmt.bw[t] = mgmt.x0  # set beach width to desired beach width
        nourish_now = 1  # track when nourishment occurs

    # otherwise, don't nourish -----------
    # if beach width is already specified for this time step, that means this value came from CASCADE
    # and the beach has already been eroded, so just skip
    elif mgmt.bw[t] != 0:
        pass
    # but if the beach width is not specified, that means the model isn't coupled, and we need eroded the beach
    else:
        mgmt.bw[t] = mgmt.bw[t - 1] - modelforcing.ER[t]

    # calculate agent expected erosion rate
    agentsame.E_ER[t] = (
        agentsame.theta_er * modelforcing.ER[t]
        + (1 - agentsame.theta_er) * agentsame.E_ER[t - 1]
    )

    # if the beach width is less than 1, don't let it become negative
    if mgmt.bw[t] < 1:
        mgmt.bw[t] = 1

    # rebuild dune decision -------------------------------------------------------------------
    # if dune build is scheduled, rebuild dune
    if mgmt.builddunetime[t] == 1:
        mgmt.h_dune[t] = mgmt.h0  # set dune height to desired dune height
        rebuild_dune_now = 1  # track when dune building occurs

    # otherwise, don't rebuild dune -----------
    # if dune_height is already specified for this time step, that means this value came from CASCADE, so just skip
    elif mgmt.h_dune[t] != 0:
        pass
    # but if the dune height is not specified, that means the model isn't coupled, and we need eroded the dune slightly
    # from the last time step
    else:
        mgmt.h_dune[t] = mgmt.h_dune[t - 1] - 0.1

    # if the dune height is less than 1, don't let it become negative
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
