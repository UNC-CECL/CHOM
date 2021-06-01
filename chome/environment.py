import numpy as np
import copy as copy


def evolve_environment(time_index, acom, mmt, m):
    t = time_index

    if mmt._nourishtime[t] == 1:  # if nourish is scheduled
        mmt._bw[t] = mmt._x0
        acom._E_ER[t] = (
            acom._theta_er * m._ER[t] + (1 - acom._theta_er) * acom._E_ER[t - 1]
        )
    else:
        mmt._bw[t] = mmt._bw[t - 1] - m._ER[t]
        acom._E_ER[t] = (
            acom._theta_er * m._ER[t] + (1 - acom._theta_er) * acom._E_ER[t - 1]
        )

    if mmt._builddunetime[t] == 1:  # if dune build is scheduled
        mmt._h_dune[t] = mmt._h0  # then build it back up
    else:
        mmt._h_dune[t] = mmt._h_dune[t - 1] - 0.2


    if mmt._bw[t] < 1:
        mmt._bw[t] = 1

    if mmt._h_dune[t] < 0.1:
        mmt._h_dune[t] = 0.1

    return mmt, acom


def calculate_expected_dune_height(time_index, acom, mmt):
    t = time_index
    expectation_horizon = mmt._expectation_horizon
    if t > expectation_horizon:
        acom._Edh[t] = np.mean(mmt._h_dune[t - (expectation_horizon-1): t])
    else:
        acom._Edh[t] = np.mean(mmt._h_dune[0:t])
    return acom


def calculate_expected_beach_width(time_index, mmt, acom, a_of, a_nof):
    t = time_index
    exp_bw = copy.deepcopy(mmt._bw)
    bw_back = np.zeros(t + mmt._nourish_plan_horizon)

    for time in range(t + 1, t + mmt._nourish_plan_horizon):
        if mmt._nourishtime[time] == 1:
            exp_bw[time] = mmt._x0
        else:
            exp_bw[time] = exp_bw[time - 1] - acom._E_ER[t]

    exp_bw[exp_bw < 1] = 1
    ind = 0

    if t > mmt._expectation_horizon:
        for time in range(t + 1, t + mmt._nourish_plan_horizon):
            bw_back[ind] = np.average(exp_bw[time - (mmt._expectation_horizon-1):time])
            ind += 1
    else:
        for time in range(t + 1, t + mmt._nourish_plan_horizon):
            bw_back[ind] = np.average(exp_bw[time - t:time])
            ind += 1
    acom._Ebw[t] = np.mean(bw_back)

    # expected willingness to pay
    a_nof._wtp = a_nof._WTP_base + a_nof._WTP_alph * acom._Ebw[t] ** a_nof._bta
    a_of._wtp  = a_of._WTP_base + a_of._WTP_alph * acom._Ebw[t] ** a_of._bta

    return acom, a_nof, a_of
