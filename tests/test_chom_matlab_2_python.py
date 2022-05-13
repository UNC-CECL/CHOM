"""
Written by K.Anarde

- imports matlab inputs for seeding of brie.py (for version testing and grid testing)

"""
import pathlib

import numpy as np
import pytest
from scipy.io import loadmat

from brie import Brie


DATA_DIR = pathlib.Path(__file__).parent / "test_brie_matlab"

# import matfile with run output you will be comparing to the python version
def load_test_cases(datadir):
    data = loadmat(datadir / "test_brie_matlab_seed.mat")["output"]
    cases = []
    for inputs in data.flat:
        cases.append(
            { # Z: on the left i put the python variable name, on the right i put the matlab variable name
                # this can't be right, but these are the primary output that need to be similar
                "chome._agent_oceanfront._price": np.asarray(inputs["X_OF.price"]).reshape(-1),
                "chome._agent_nonoceanfront._price": np.asarray(inputs["X_NOF.price"]).reshape(-1),
                "chome._agent_oceanfront._rent": np.asarray(inputs["X_OF.rent"]).reshape(-1),
                "chome._agent_nonoceanfront._rent": np.asarray(inputs["X_NOF.rent"]).reshape(-1),
                "chome._agent_oceanfront._mkt": np.asarray(inputs["X_OF.mkt"]).reshape(-1),
                "chome._agent_nonoceanfront._mkt": np.asarray(inputs["X_NOF.mkt"]).reshape(-1),
                "chome.beach_width": np.asarray(inputs["MMT.bw"][0], dtype=int).reshape(-1),
                "chome.dune_height": np.asarray(inputs["MMT.h_dune"][0], dtype=int).reshape(-1),
            }
        )
    return cases


ALL_CASES = load_test_cases(DATA_DIR)


@pytest.fixture(params=range(len(ALL_CASES)))
def test_case(request):
    return ALL_CASES[request.param]


# make sure you use all the same inputs in the python version
def run_brie(n_steps, dt, dy, x_shoreline, wave_angle):
    brie = Brie(
        name=f"dt={dt},dy={dy}",
        bseed=True,
        wave_height=1.0,
        wave_period=7,
        barrier_width_critical=450.0,
        barrier_height_critical=1.9,
        alongshore_section_length=dy,
        time_step=dt,
        time_step_count=n_steps,
        wave_angle=wave_angle,
        xs=x_shoreline,
    )

    for _ in range(n_steps - 1):
        chome.update()  # update the model by a time step

    # finalize by deleting variables and make Qinlet m^3/yr
    brie.finalize()

    return brie


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
