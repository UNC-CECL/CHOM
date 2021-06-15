import numpy as np
import copy as copy


def evolve_environment(time_index, agentsame, mgmt, modelforcing):
    """
    This is an explanation of what the hell this function does. I love to over explain things.

    :param time_index: int, this is the time
    :param agentsame:
    :param mgmt:
    :param modelforcing:
    :return:

    """

    t = time_index
    nourish_now = 0  # initialize nourishment and dune rebuild trackers as false
    rebuild_dune_now = 0

    if mgmt._nourishtime[t] == 1:  # if nourish is scheduled
        mgmt._bw[t] = mgmt._x0  # set beach width to desired beach width
        nourish_now = 1  # track when nourishment occurs
    elif mgmt._bw[t] != 0:  # if beach width is already specified (if coupled with another model), then don't modify
        pass
    else:
        mgmt._bw[t] = mgmt._bw[t - 1] - modelforcing._ER[t]

    # calculate agent expected erosion rate
    agentsame._E_ER[t] = (
        agentsame._theta_er * modelforcing._ER[t]
        + (1 - agentsame._theta_er) * agentsame._E_ER[t - 1]
    )

    if mgmt._builddunetime[t] == 1:  # if dune build is scheduled
        mgmt._h_dune[t] = mgmt._h0  # then build it back up
        rebuild_dune_now = 1  # track when dune building occurs
    elif mgmt._h_dune[t] != 0:  # if dune_height is already specified (if coupled with another model), then don't modify
        pass
    else:
        mgmt._h_dune[t] = mgmt._h_dune[t - 1] - 0.1  # erode the dune slightly from the last time step

    if mgmt._bw[t] < 1:
        mgmt._bw[t] = 1

    if mgmt._h_dune[t] < 0.1:
        mgmt._h_dune[t] = 0.1

    return mgmt, agentsame, nourish_now, rebuild_dune_now


def calculate_expected_beach_width(time_index, mgmt, agentsame, agent_of, agent_nof):
    t = time_index
    exp_bw = copy.deepcopy(mgmt._bw)
    bw_back = np.zeros(t + mgmt._nourish_plan_horizon)

    for time in range(t + 1, t + mgmt._nourish_plan_horizon):
        if mgmt._nourishtime[time] == 1:
            exp_bw[time] = mgmt._x0
        else:
            exp_bw[time] = exp_bw[time - 1] - agentsame._E_ER[t]

    exp_bw[exp_bw < 1] = 1
    ind = 0

    if t > mgmt._expectation_horizon:
        for time in range(t + 1, t + mgmt._nourish_plan_horizon):
            bw_back[ind] = np.average(
                exp_bw[time - (mgmt._expectation_horizon - 1) : time]
            )
            ind += 1
    else:
        for time in range(t + 1, t + mgmt._nourish_plan_horizon):
            bw_back[ind] = np.average(exp_bw[0:time])
            ind += 1
    agentsame._Ebw[t] = np.mean(bw_back[0:ind])

    # expected willingness to pay
    agent_nof._wtp = (
        agent_nof._WTP_base + agent_nof._WTP_alph * agentsame._Ebw[t] ** agent_nof._bta
    )
    agent_of._wtp = (
        agent_of._WTP_base + agent_of._WTP_alph * agentsame._Ebw[t] ** agent_of._bta
    )

    return agentsame, agent_nof, agent_of
