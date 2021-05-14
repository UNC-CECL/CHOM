import pkg_resources

from .chome import Chome


__version__ = pkg_resources.get_distribution("chome").version
__all__ = ["Chome"]


del pkg_resources
