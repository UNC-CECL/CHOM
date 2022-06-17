import pkg_resources

from .chom import Chom


__version__ = pkg_resources.get_distribution("chom").version
__all__ = ["Chom"]


del pkg_resources
