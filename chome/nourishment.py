import numpy as np
from .user_cost import calculate_risk_premium
from .user_cost import calculate_user_cost
import copy as copy
import numpy.matlib


def evaluate_nourishment_future_beach_width(time_index, mmt, ACOM, nourish_interval):
    t = time_index
    t_horiz = mmt._expectation_horizon + 1
    bw = np.zeros(t_horiz)
    bw[0] = mmt._x0
    nourish_xshore = np.zeros(t_horiz)
    nourishplan_new = np.zeros(t_horiz)
    nourishplan_last = mmt._nourishtime[t + 1 : t + t_horiz + 1]
    n = np.arange(0, t_horiz, nourish_interval)
    nourishplan_new[n] = 1
    nourish_count = nourishplan_last + nourishplan_new
    for time in range(1, t_horiz):
        if nourish_count[time] == 1 and time + 1 < t_horiz:
            bw[time] = mmt._x0
            nourish_xshore[time] = mmt._x0 - (bw[time - 1] - ACOM._E_ER[t])
        elif nourish_count[time] == 2:
            bw[time] = mmt._x0
        else:
            bw[time] = bw[time - 1] - ACOM._E_ER[t]

    bw[bw < 0] = 0
    nourish_yr = np.argwhere(bw == mmt._x0)
    nourish_xshore = nourish_xshore[nourish_yr]
    nourish_xshore[0] = mmt._x0 - mmt._bw[t]
    mbw = np.mean(bw)

    return bw, nourish_xshore, nourish_yr, mbw


def calculate_nourishment_plan_cost(time_index, ACOM, mmt, A_OF, A_NOF):
    t = time_index
    I_OF = ACOM._I_OF
    I_own = ACOM._I_own
    Llength = mmt._lLength
    sandcost = mmt._sandcost
    Ddepth = mmt._Ddepth
    fixedcost = mmt._fixedcost_beach
    nourish_plan_horizon = mmt._nourish_plan_horizon
    expectation_horizon = mmt._expectation_horizon
    delta = mmt._delta_disc
    cost = np.zeros(10)
    amort = mmt._amort

    for i in range(0, 10):
        [bw, nourish_xshore, nourish_yr, mbw] = evaluate_nourishment_future_beach_width(
            time_index, mmt, ACOM, i + 1
        )
        nourish_yr = nourish_yr + 1
        fcost = (fixedcost) / ((1 + delta) ** nourish_yr)
        namount = nourish_xshore * Ddepth * Llength * sandcost
        varcost = namount / (((1 + delta) ** nourish_yr))
        maxplan = np.argwhere(nourish_yr > 11)  # only consider costs over next 10 years
        maxplan = maxplan[0, 0]
        mmt._nourishment_menu_cost[i] = (
            np.sum(fcost[0:maxplan]) + np.sum(varcost[0:maxplan]) - mmt._nourish_subsidy
        )
        Ebw_future = np.zeros(expectation_horizon)
        if t > 30:
            bw_future = np.concatenate((mmt._bw[0 : t + 1], bw))
            ind = 0
            for t2 in range(t + 1, t + expectation_horizon + 1):
                mmt._nourishment_menu_bw[i, ind] = np.average(
                    bw_future[t2 - (expectation_horizon - 1) : t2 + 1]
                )
                ind += 1
        else:
            bw_future = np.concatenate((mmt._bw[0 : t + 1], bw))
            ind = 0
            for t2 in range(t + 1, t + expectation_horizon + 1):
                mmt._nourishment_menu_bw[i, ind] = np.average(
                    bw_future[t2 - (t - 1) - 1 : t2 + 1]
                )
                ind += 1

        mmt._nourishment_menu_totalcostperyear[i] = (
            mmt._nourishment_menu_cost[i]
            * delta
            * (1 + delta) ** amort
            / ((1 + delta) ** amort - 1)
        )

    i = 10
    mmt._nourishment_menu_cost[10] = 0
    if ACOM._E_ER[t] != 0:
        bw = np.arange(
            mmt._bw[t] - ACOM._E_ER[t],
            mmt._bw[t] - ACOM._E_ER[t] * (1 + mmt._expectation_horizon),
            -ACOM._E_ER[t],
        )
    else:
        bw = np.ones(mmt._expectation_horizon) * mmt._bw[t]

    if t > 30:
        bw_future = np.concatenate((mmt._bw[0 : t + 1], bw))
        ind = 0
        for t2 in range(t + 1, t + expectation_horizon + 1):
            mmt._nourishment_menu_bw[i, ind] = np.average(
                bw_future[t2 - (expectation_horizon - 1) : t2 + 1]
            )
            ind += 1
    else:
        bw_future = np.concatenate((mmt._bw[0 : t + 1], bw))
        ind = 0
        for t2 in range(t + 1, t + expectation_horizon + 1):
            mmt._nourishment_menu_bw[i, ind] = np.average(
                bw_future[t2 - (t - 1) - 1 : t2 + 1]
            )
            ind += 1

    mmt._nourishment_menu_totalcostperyear[i] = (
        mmt._nourishment_menu_cost[i]
        * delta
        * (1 + delta) ** amort
        / ((1 + delta) ** amort - 1)
    )

    for i in range(0, 11):
        mmt._nourishment_menu_add_tax[i] = (
            amort
            * mmt._nourishment_menu_totalcostperyear[i]
            / np.sum(
                mmt._taxratio_OF * I_OF * A_OF._price[t - 1]
                + (1 - I_OF) * A_NOF._price[t - 1]
            )
        )
        mmt._nourishment_menu_taxburden[:, i] = amort * (
            mmt._nourishment_menu_add_tax[i] * (1 - I_OF) * A_NOF._price[t - 1]
            + mmt._taxratio_OF
            * mmt._nourishment_menu_add_tax[i]
            * I_OF
            * A_OF._price[t - 1]
        )

    return mmt


def calculate_nourishment_plan_ben(time_index, A_OF, A_NOF, mmt, ACOM):
    t = time_index
    A_NOF_copy = copy.deepcopy(A_NOF)
    A_OF_copy = copy.deepcopy(A_OF)
    tau_prop_NOF = np.zeros(1)
    tau_prop_OF = np.zeros(1)

    for nourishment_interval in range(0, 11):
        i = nourishment_interval
        mbw = np.mean(mmt._nourishment_menu_bw[i, :])
        A_NOF_copy._wtp = A_NOF._WTP_base + A_NOF._WTP_alph * mbw ** A_NOF._bta
        A_OF_copy._wtp = A_OF._WTP_base + A_OF._WTP_alph * mbw ** A_OF._bta
        tau_prop_NOF[0] = A_NOF_copy._tau_prop[t + 1] + mmt._nourishment_menu_add_tax[i]
        tau_prop_OF[0] = (
            A_OF_copy._tau_prop[t + 1]
            + mmt._nourishment_menu_add_tax[i] * mmt._taxratio_OF
        )
        A_NOF_copy = calculate_user_cost(time_index, A_NOF_copy, tau_prop_NOF)
        A_OF_copy = calculate_user_cost(time_index, A_OF_copy, tau_prop_OF)
        mmt._OF_plan_price[i] = A_OF_copy._price[t]
        mmt._NOF_plan_price[i] = A_NOF_copy._price[t]

    for i in range(0, 11):
        mmt._nourishment_pricelist[0 : ACOM._n_NOF, i] = mmt._NOF_plan_price[i]
        mmt._nourishment_pricelist[ACOM._n_NOF + 1 : -1, i] = mmt._OF_plan_price[i]

    return mmt


def evaluate_nourishment_plans(time_index, mmt, A_OF, A_NOF, ACOM):
    t = time_index
    price_increase = np.zeros(1)
    vote = np.zeros(shape=(ACOM._n_agent_total, 10))
    schedule_conflict = np.zeros(10)
    nourish_schedule = np.matlib.repmat(
        mmt._nourishtime[t + 1 : t + mmt._nourish_plan_horizon + 1], 11, 1
    )

    for j in range(0, 10):
        nindx = np.arange(1, mmt._nourish_plan_horizon + 1, j + 1)
        nourish_schedule[j, nindx - 1] = nourish_schedule[j, nindx - 1] + 1

        num_scheduling_conflicts = np.nonzero(nourish_schedule[j, :])
        if np.size(num_scheduling_conflicts) > 0:
            schedule_conflict[j] = 1

        catch_back2back_nourishplans = (
            nourish_schedule[j, 0:-1] + nourish_schedule[j, 1:]
        )
        back2back_scheduling_conflicts = np.nonzero(catch_back2back_nourishplans)
        if np.size(back2back_scheduling_conflicts) > 0:
            schedule_conflict[j] = 1

        # catch_back2back_nourishplans = nourish_schedule(j,1:end-2)+nourish_schedule(j,2:end-1)+nourish_schedule(j,3:end);
        # if numel(find(catch_back2back_nourishplans>1))>0
        #    schedule_conflict(j) = 1;
        # end

        if t > 5:
            if np.sum(mmt._nourishtime[t - 3 : t]) > 0:
                schedule_conflict[j] = 1

    for j in range(0, 10):
        for i in range(0, ACOM._n_agent_total):
            if ACOM._I_own[i] == 1 and schedule_conflict[j] == 0:
                price_increase = (
                    mmt._nourishment_pricelist[i, j] - mmt._nourishment_pricelist[i, 10]
                )
                if mmt._nourishment_menu_taxburden[i, j] < price_increase:
                    vote[i, j] = 1

    tally_vote = np.zeros(10)
    for j in range(0, 10):
        tally_vote[j] = np.sum(vote[:, j]) / np.sum(ACOM._I_own)

    tally_vote[0] = 0
    tally_vote[9] = 0
    voter_choice = np.argwhere(tally_vote > 0.5)

    if mmt._nourishtime[t] == 1 or np.size(voter_choice) == 0:
        voter_choice = 10

    # if nourishment_off:
    #    voter_choice = 10

    if voter_choice == 10:
        mmt._newplan[t + 1] = 0

    if np.size(voter_choice) == 1 and voter_choice != 10:
        mmt._newplan[t + 1] = 1
        mmt._nourishtime[t + 1 : t + mmt._nourish_plan_horizon + 1] = nourish_schedule[
            voter_choice, :
        ]
        if mmt._nourishment_menu_add_tax[voter_choice] > 0:
            mmt._nourishment_menu_add_tax[voter_choice] = 0
        A_NOF._tau_prop[t + 1 : t + mmt._amort + 1] = (
            A_NOF._tau_prop[t + 1 : t + mmt._amort + 1]
            + mmt._nourishment_menu_add_tax[voter_choice]
        )
        A_OF._tau_prop[t + 1 : t + mmt._amort + 1] = (
            A_OF._tau_prop[t + 1 : t + mmt._amort + 1]
            + mmt._taxratio_OF * mmt._nourishment_menu_add_tax[voter_choice]
        )

    if np.size(voter_choice) > 1 and voter_choice != 10:
        voter_choice = voter_choice[-1]
        mmt._newplan[t + 1] = 1
        if mmt._nourishment_menu_add_tax[voter_choice] > 0:
            mmt._nourishment_menu_add_tax[voter_choice] = 0
        A_NOF._tau_prop[t + 1 : t + mmt._amort + 1] = (
            A_NOF._tau_prop[t + 1 : t + mmt._amort + 1]
            + mmt._nourishment_menu_add_tax[voter_choice]
        )
        A_OF._tau_prop[t + 1 : t + mmt._amort + 1] = (
            A_OF._tau_prop[t + 1 : t + mmt._amort + 1]
            + mmt._taxratio_OF * mmt._nourishment_menu_add_tax[voter_choice]
        )

    return A_NOF, A_OF, mmt


def calculate_evaluate_dunes(time_index, mmt, m, acom, a_of, a_nof):
    t = time_index
    dune_plan = np.zeros(shape=(2, 2))
    vote = np.zeros(shape=(acom._n_agent_total))
    I_OF = acom._I_OF
    I_own = acom._I_own
    delta_dune = mmt._h0 - mmt._h_dune[t]
    Llength = mmt._lLength
    sandcost = mmt._sandcost
    width = 4

    fixedcost = mmt._fixedcost_dune
    sandvolume = Llength * width * delta_dune
    var_cost = sandvolume * sandcost
    totalcost = fixedcost + var_cost
    tc_peryear = (
        totalcost
        * mmt._delta_disc
        * (1 + mmt._delta_disc) ** mmt._amort
        / ((1 + mmt._delta_disc) ** mmt._amort - 1)
    )
    tau_add = (
        (mmt._amort)
        * tc_peryear
        / np.sum(
            mmt._taxratio_OF * I_OF * a_of._price[t - 1]
            + (1 - I_OF) * a_nof._price[t - 1]
        )
    )
    tax_burden = (mmt._amort) * (
        tau_add * (1 - I_OF) * a_nof._price[t - 1]
        + mmt._taxratio_OF * tau_add * I_OF * a_of._price[t - 1]
    )

    a_of_nodune = copy.deepcopy(a_of)
    a_nof_nodune = copy.deepcopy(a_nof)
    a_nof_nodune = calculate_risk_premium(
        time_index, acom, a_nof_nodune, m, frontrow_on=False
    )
    a_of_nodune = calculate_risk_premium(
        time_index, acom, a_of_nodune, m, frontrow_on=True
    )
    a_of_nodune = calculate_user_cost(
        time_index, a_of_nodune, a_of_nodune._tau_prop[t + 1]
    )
    a_nof_nodune = calculate_user_cost(
        time_index, a_nof_nodune, a_nof_nodune._tau_prop[t + 1]
    )

    a_of_dune = copy.deepcopy(a_of)
    a_nof_dune = copy.deepcopy(a_nof)
    acom_dune = copy.deepcopy(acom)
    acom_dune._Edh[t] = mmt._h0
    a_nof_dune = calculate_risk_premium(
        time_index, acom_dune, a_nof_dune, m, frontrow_on=False
    )
    a_of_dune = calculate_risk_premium(
        time_index, acom_dune, a_of_dune, m, frontrow_on=True
    )
    a_of_dune = calculate_user_cost(
        time_index, a_of_dune, a_of_dune._tau_prop[t + 1] + tau_add * mmt._taxratio_OF
    )
    a_nof_dune = calculate_user_cost(
        time_index, a_nof_dune, a_nof_dune._tau_prop[t + 1] + tau_add
    )

    dune_plan[0, 0] = a_nof_dune._price[t]
    dune_plan[1, 0] = a_of_dune._price[t]
    dune_plan[0, 1] = a_nof_nodune._price[t]
    dune_plan[1, 1] = a_of_nodune._price[t]

    mmt._dune_pricelist[0 : acom._n_NOF, 0] = dune_plan[0, 0]
    mmt._dune_pricelist[acom._n_NOF + 1 : -1, 0] = dune_plan[1, 0]
    mmt._dune_pricelist[0 : acom._n_NOF, 1] = dune_plan[0, 1]
    mmt._dune_pricelist[acom._n_NOF + 1 : -1, 1] = dune_plan[1, 1]

    for i in range(0, acom._n_agent_total):
        if acom._I_own[i] == 1 and mmt._nourishtime[t + 1] == 1:
            price_increase = mmt._dune_pricelist[i, 0] - mmt._dune_pricelist[i, 1]
            if tax_burden[i] < price_increase:
                vote[i] = 1

    # if sum(vote/ACOM.n_agent_total)>0.5
    #     MMT.builddunetime(t+1) = 1;
    #     A_NOF.tau_prop(t+1:t+MMT.amort)    = A_NOF.tau_prop(t+1:t+MMT.amort)+tau_add;
    #     A_OF.tau_prop(t+1:t+MMT.amort)     = A_OF.tau_prop(t+1:t+MMT.amort)+MMT.taxratio_OF*tau_add;
    # end
    return a_of, a_nof, mmt
