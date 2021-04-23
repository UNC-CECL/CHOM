import numpy as np
import scipy.constants
import yaml
from numpy.lib.scimath import power as cpower, sqrt as csqrt
from scipy.interpolate import interp1d
from scipy.sparse import csr_matrix
from scipy.sparse.linalg import spsolve

test
class Chome:
    def __init__(
        self,
        name="default",
        total_time=400,
        willingness_to_pay_min=1000,
        willingness_to_pay_max=2000,
    ):
        """Coastal Home Ownership Model CHOM

        Parameters
        ----------
        name: string, optional
            Name of simulation
        total_time: int, optional
            Total time of simulation
        willingness_to_pay_bounds: int, optional
            Base willingness to pay distribution bounds


        Examples
        --------
        >>> from chome import Chome
        >>> datadir = "/Users/KatherineAnardeWheels/PycharmProjects/CASCADE/B3D_Inputs/"
        >>> chome = Chome(datadir)
        """

        self._T = total_time

        ###############################################################################
        # owner-agent
        ###############################################################################

        self._mWTP = [willingness_to_pay_min, willingness_to_pay_max]

        # agents/user-cost
        self._rp_I = np.zeros(
            1
        )  # average risk premium real estate (same for investor and owner)

        E = TaxParam(
            "fieldNames",
            "horizon",
            "x0",
            "amort",
            "nourish_plan_horizon",
            "expectation_horizon",
            "share_oceanfront",
            "share_owner",
        )
