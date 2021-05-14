import numpy as np


def calculate_nourishment_plan_cost(chome, agents_front_row, agents_back_row):
    # function[BPC] = calculate_nourishment_plan_cost(ACOM, M, MMT, X_NOF, X_OF)

    #
    # t = M.time;
    # I_OF = ACOM.I_OF;
    # I_own = ACOM.I_own;
    t = chome.time_index
    I_OF = chome._I_OF
    I_own = chome._I_own

    # these for variables will probably come from physical model
    # Llength = MMT.lLength;
    # sandcost = MMT.sandcost;
    # Ddepth = MMT.Ddepth;
    # fixedcost = MMT.fixedcost_beach;
    # nourish_plan_horizon = MMT.nourish_plan_horizon; % nourish
    # proposal
    # length(10
    # yrs)
    # expectation_horizon = MMT.expectation_horizon; % might
    # rename
    # delta = MMT.delta_disc;
    #
    # % loop
    # over
    # all
    # nourishment
    # plans(indexed as the
    # nourishment
    # interval
    # for nourishment_interval = 1:10
    #
    # i = nourishment_interval; % i = nourishment
    # interval(nourish
    # every
    # i
    # years)
    #
    # [bw, nourish_xshore, nourish_yr, mbw] = evaluate_nourishment_future_beach_width(ACOM, M, MMT, i);
    #
    # fcost = fixedcost. * ones(length(nourish_yr), 1). / ((1 + delta). ^ nourish_yr(:));
    # namount = nourish_xshore * Ddepth * Llength * sandcost;
    # varcost = namount. / ((1 + delta). ^ nourish_yr);
    # maxplan = find(nourish_yr > 11); % how
    # many
    # years
    # to
    # consider
    # costs
    # over?
    # maxplan = maxplan(1) - 1;
    # BPC.cost(i) = sum(fcost(1:maxplan))+sum(varcost(1: maxplan))-MMT.nourish_subsidy;
    #
    # if t > 30
    # bw_future = [MMT.bw(1:t); bw]; % consists
    # of
    # past
    # beach
    # width
    # plus
    # future
    # expected
    # nourishments
    # ind = 1;
    # for t2 = t + 1:t + expectation_horizon
    # Ebw_future(ind) = mean(bw_future(t2 - 29:t2)); % projection
    # of
    # expected
    # beach
    # width
    # over
    # next
    # 30
    # years
    # ind = ind + 1;
    # end
    # BPC.bw(i,:) = Ebw_future(:);
    # else
    # bw_future = [MMT.bw(1:t); bw]; % consists
    # of
    # past
    # beach
    # width
    # plus
    # future
    # expected
    # nourishments
    # ind = 1;
    # for t2 = t + 1:t + expectation_horizon
    # Ebw_future(ind) = mean(bw_future(t2 - (t - 1):t2));
    # ind = ind + 1;
    # end
    # BPC.bw(i,:) = Ebw_future(:);
    # end
    #
    # BPC.tc_peryear(i) = BPC.cost(i) * delta * (1 + delta) ^ MMT.amort / ((1 + delta) ^ MMT.amort - 1); % loan
    # amortization
    #
    # end
    #
    # for nourishment_interval = 1:10
    # i = nourishment_interval;
    #
    # % get
    # base
    # tax
    # rate
    # BPC.tau_add(i) = (MMT.amort) * BPC.tc_peryear(i) / sum(
    #     MMT.taxratio_OF * I_OF. * X_OF.price(t - 1) + (1 - I_OF) * X_NOF.price(t - 1));
    #
    # % total
    # tax
    # burden
    # BPC.tax_burden(:, i) = (MMT.amort) * (BPC.tau_add(i) * (1 - I_OF) * X_NOF.price(t - 1) + ...
    #                                       MMT.taxratio_OF * BPC.tau_add(i) * I_OF. * X_OF.price(t - 1));
    #
    # end
    return t


def calculate_nourishment_plan_ben(chome, agents_back_row, agents_front_row, BPC):
    # def calculate_nourishment_plan_cost(chome, agents_front_row, agents_back_row):
    # function [BPB,BPC]=calculate_nourishment_plan_ben(A_NOF,A_OF,ACOM,BPC,M,MMT,X_NOF,X_OF)
    #
    # t=M.time;
    #
    # for nourishment_interval = 1:10
    #     i                  = nourishment_interval;
    #     BPC.mbw(i)         = mean(BPC.bw(i,:));
    #     WTP_plan_NOF       = X_NOF.WTP_base+X_NOF.WTP_alph*BPC.mbw(i)^MMT.bta_NOF;
    #     WTP_plan_OF        = X_OF.WTP_base+X_OF.WTP_alph*BPC.mbw(i)^MMT.bta_OF;
    #     tauprop_NOF        = A_NOF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(i);
    #     [X_NOF]            = calculate_user_cost(M,X_NOF,WTP_plan_NOF,tauprop_NOF(1));
    #     tauprop_OF         = A_OF.tau_prop(t+1:t+MMT.amort)+BPC.tau_add(i)*MMT.taxratio_OF;
    #     [X_OF]             = calculate_user_cost(M,X_OF,WTP_plan_OF,tauprop_OF(1));
    #     BPB.prop_plan(1,i) = X_NOF.price(t);
    #     BPB.prop_plan(2,i) = X_OF.price(t);
    # end
    #
    # mbw_noplan = MMT.bw(t)-ACOM.E_ER(t):-ACOM.E_ER(t):MMT.bw(t)-ACOM.E_ER(t)*MMT.expectation_horizon;
    # mbw_noplan(mbw_noplan<1)=1;
    # mbw_noplan = mean(mbw_noplan);
    #
    # WTP_plan_NOF        =  X_NOF.WTP_base+X_NOF.WTP_alph *mbw_noplan ^MMT.bta_NOF;
    # WTP_plan_OF         =  X_OF.WTP_base+X_OF.WTP_alph *mbw_noplan ^MMT.bta_OF;
    #
    # [X_NOF]             = calculate_user_cost(M,X_NOF,WTP_plan_NOF,A_NOF.tau_prop(t+1));
    # [X_OF]              = calculate_user_cost(M,X_OF,WTP_plan_OF,A_OF.tau_prop(t+1));
    # BPB.prop_plan(1,11) = X_NOF.price(t);
    # BPB.prop_plan(2,11) = X_OF.price(t);
    #
    #
    # price_list=zeros(ACOM.n_agent_total,11);
    # for ii=1:11
    #     price_list(1:ACOM.n_NOF,ii)=BPB.prop_plan(1,ii);
    #     price_list(ACOM.n_NOF+1:ACOM.n_NOF+ACOM.n_OF,ii)=BPB.prop_plan(2,ii);
    # end
    # BPB.price_list=price_list;

    return BPB, BPC


def evaluate_nourishment_plans(chome, agents_back_row, agents_front_row, BPB, BPC):

    return MMT


def calculate_evaluate_dunes(chome, agents_back_row, agents_front_row, MMT):

    return MMT
