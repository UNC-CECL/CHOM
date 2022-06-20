"""
Written by K.Anarde

- imports matlab outputs from chom and compares to python version

"""
import pathlib

import numpy as np
import pytest
from scipy.io import loadmat

from chom import Chom


DATA_DIR = pathlib.Path(__file__).parent / "test_chom_matlab_2_python"

# import matfile with run output you will be comparing to the python version
def load_test_cases(datadir):
    data = loadmat(datadir / "test_chom_cascade_parameters.mat")["output"]
    cases = []
    # for inputs in data.flat:
    #     cases.append(
    #         {
    #             "dt": float(inputs["dt"]),
    #             "dy": float(inputs["dy"]),
    #             "x_shoreline": np.asarray(inputs["xs"][0][0], dtype=int).reshape(-1),
    #             "wave_angle": np.asarray(
    #                 inputs["wave_angle"][0][0], dtype=float
    #             ).reshape(-1),
    #             "inlet_age": np.squeeze(inputs["inlet_age"][0][0]),
    #             "q_overwash": np.squeeze(inputs["Qoverwash"][0][0]),
    #             "q_inlet": np.squeeze(inputs["Qinlet"][0][0]),
    #         }
    #     )
    for inputs in data.flat:
        cases.append(
            {  # Z: on the left i put the python variable name, on the right i put the matlab variable name
                "agent_oceanfront_price": np.asarray(inputs["X_OF.price"]).reshape(-1),
                "agent_nonoceanfront_price": np.asarray(inputs["X_NOF.price"]).reshape(
                    -1
                ),
                "agent_oceanfront_rent": np.asarray(inputs["X_OF.rent"]).reshape(-1),
                "agent_nonoceanfront_rent": np.asarray(inputs["X_NOF.rent"]).reshape(
                    -1
                ),
                "agent_oceanfront_mkt": np.asarray(inputs["X_OF.mkt"]).reshape(-1),
                "agent_nonoceanfront_mkt": np.asarray(inputs["X_NOF.mkt"]).reshape(-1),
                "beach_width": np.asarray(inputs["MMT.bw"][0], dtype=int).reshape(-1),
                "dune_height": np.asarray(inputs["MMT.h_dune"][0], dtype=int).reshape(
                    -1
                ),
            }
        )
    return cases


ALL_CASES = load_test_cases(DATA_DIR)


@pytest.fixture(params=range(len(ALL_CASES)))
def test_case(request):
    return ALL_CASES[request.param]


# make sure you use all the same inputs in the python version
def run_brie(n_steps, dt, dy, x_shoreline, wave_angle):
    total_time = 50

    chom = Chom(
        name="chom_test",
        total_time=total_time,
        average_interior_width=388.2,  # default is 300
        barrier_island_height=1.09,  # 1
        beach_width=30.0,  # None
        dune_height=0.4977,  # None
        shoreface_depth=8.9,  # 10
        dune_width=20.0,  # 25
        dune_height_build=2.26,  # 4
        shoreline_retreat_rate=0.268,
        # coupled is zero, default is 1 *** I took this from t=1 in the coupled model, ask Zach
        alongshore_domain_extent=3000,  # ------- all variables below are default (same as in coupled) --------
        sand_cost=10,
        taxratio_oceanfront=3,
        external_housing_market_value_oceanfront=6e5,
        external_housing_market_value_nonoceanfront=4e5,
        fixed_cost_beach_nourishment=1e6,
        fixed_cost_dune_nourishment=1e5,
        nourishment_cost_subsidy=0.9125,
        house_footprint_x=15,
        house_footprint_y=20,
        beach_full_cross_shore=70,
        agent_expectations_time_horizon=30,
        # ------- these are also default (but we don't allow you to change them in CASCADE) --------
        agent_erosion_update_weight=0.5,
        beach_width_beta_oceanfront=0.25,
        beach_width_beta_nonoceanfront=0.15,
        discount_rate=0.06,
        nourishment_plan_loan_amortization_length=5,
        nourishment_plan_time_commitment=10,
    )

    for _ in range(total_time - 1):
        chom.update()  # update the model by a time step

    return chom


# compare the output
@pytest.mark.parametrize("n_steps", [8, 16, 32, 64, 128])
def test_brie_matlab(test_case, n_steps):
    brie = run_brie(
        n_steps,
        test_case["dt"],
        test_case["dy"],
        test_case["x_shoreline"],
        test_case["wave_angle"],
    )

    actual_q_overwash_mean = brie._Qoverwash.mean()
    actual_inlet_mean = brie._Qinlet.mean()

    expected_q_overwash_mean = test_case["q_overwash"][:n_steps].mean()
    expected_inlet_mean = test_case["q_inlet"][:n_steps].mean()

    assert len(brie._Qoverwash) == n_steps
    assert len(brie._Qinlet) == n_steps

    assert actual_q_overwash_mean == pytest.approx(expected_q_overwash_mean, rel=0.1)
    assert actual_inlet_mean == pytest.approx(expected_inlet_mean, rel=0.1)
