import numpy as np


def calculate_risk_premium(time_index, ACOM, A, M):
    t = time_index

    if (
        t > 4
    ):  # Zack: need to check the indexing here (remember that t starts at 1 in this model and not 2, changed all the 5 to 4 below)
        if np.sum(M._storms[t - 4 : t]) != 0:
            storm_flag = 1
            storm_time = M._storms[t - 4 : t]

            # for ii=2:6
            for ii in range(
                1, 6
            ):  # Zack: same here, I think you want the second time step through the 5th?
                if storm_time[ii] != 1 & storm_time[ii - 1] > 0:
                    storm_time[ii] = storm_time[ii - 1] - 0.2
                storm_salience = 0.03 * storm_time[-1]
        else:
            storm_flag = 0
    else:
        storm_flag = 0

    p1 = 1 / (M._barr_elev - M._msl[t]) ** 0.2
    p2 = 1 / (2 + ACOM._Edh[t] ** 0.2 * (M._barr_elev - M._msl[t]))

    # for ii =1:size(chome._rp_o, 1)
    for ii in range(1, np.size(A._rp_o)):

        if A._I_realist[ii] == 0:
            A._rp_o[ii] = 0.2 * p1 * p2 - A._rp_base[ii]

        if A._I_realist[ii] == 1 & storm_flag == 0:
            A._rp_o[ii] = 0.2 * p1 * p2 - A._rp_base[ii]

        if A._I_realist[ii] == 1 & storm_flag == 1:
            A._rp_o[ii] = 0.2 * p1 * p2 - A._rp_base[ii] + storm_salience

    X_rpI_base = np.mean(A._range_rp_base)
    A._rp_I = 0.2 * p1 * p2 - X_rpI_base

    return A
