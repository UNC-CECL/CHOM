import numpy as np


def evolve_environment(chome):
    t = chome.time_index

    if chome._nourishtime[t] == 1:  # if nourish is scheduled
        chome._bw[t] = chome._x0
        chome._E_ER[t] = (
            chome._theta_er * chome._ER[t] + (1 - chome._theta_er) * chome._E_ER[t - 1]
        )
    else:
        chome._bw[t] = chome._bw[t - 1] - chome._ER[t]
        chome._E_ER[t] = (
            chome._theta_er * chome._ER[t] + (1 - chome._theta_er) * chome._E_ER[t - 1]
        )

    if chome._storms[t] == 1:
        damage = 0.3 + (0.3 * np.random.rand(1))
        if chome._nourishtime[t] == 1:
            chome._bw[t] = chome._x0 * damage
            chome._h_dune[t] = chome._h0 * damage
        else:
            chome._bw[t] = chome._bw[t - 1] * damage
            chome._h_dune[t] = chome._h_dune[t - 1] * damage

    if chome._bw[t] < 1:
        chome._bw[t] = 1

    # dunes - build, keep the same, wipeout due to storm
    if chome._builddunetime[t] == 1:  # if dune build is scheduled
        chome._h_dune[t] = chome._h0  # then build it back up

    if (
        chome._builddunetime[t] == 0 & chome._storms[t] > 0
    ):  # for demonstration purposes only, if storm value greater than 5, then destoy dunes
        chome._h_dune[t] = 0

    if chome._builddunetime[t] == 0:
        chome._h_dune[t] = chome._h_dune[t - 1] - 0.2  # or else keep them the same
    if chome._h_dune[t] < 0.1:
        chome._h_dune[t] = 0.1

    return


def calculate_expected_dune_height(chome):
    t = chome.time_index

    # should pass in a control on backward time depth
    if t > 29:
        chome._Edh[t] = np.mean(chome._h_dune[t - 29 : t])
    else:
        # ACOM.Edh(t) = mean(MMT.h_dune(1:t));
        chome._Edh[t] = np.mean(chome._h_dune[0:t])

    return


# def calculate_expected_beach_width(chome, agents_front_row, agents_back_row):
#     t = chome.time_index
#
#     # bw var here is historical up to time t, and is predicted and incorporating nourishment for times t+1 to t+10
#     bw = chome._bw
#
#     for time in range(t + 1, t + 30):
#         if chome._nourishtime(time) == 1:
#             bw[time] = chome._x0
#         else:
#             bw[time] = bw[time - 1] - chome._E_ER[t]
#
#     bw[bw < 1] = 1
#
#     # check for problem here - why 10?
#     ind = 1
#     if t > 30:
#         for time in range(t + 1, t + 10):
#             bw_back[ind] = np.mean(bw[time - 29:time])
#             ind = ind + 1
#     else:
#         for time in range(t + 1, t + 10):
#             bw_back[ind] = np.mean(bw[time - t:time])
#             ind = ind + 1
#
#     chome._Ebw[t] = np.mean(bw_back)
#
#     # expected willingness to pay
#     agents_back_row._WTP[t] = agents_back_row._WTP_base + \
#                               agents_back_row._WTP_alph * \
#                               chome._Ebw[t] ** agents_back_row._bta
#
#     agents_front_row._WTP[t] = agents_front_row._WTP_base + \
#                                agents_front_row._WTP_alph * \
#                                chome._Ebw[t] ** agents_front_row._bta
#
#     return
