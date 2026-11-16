"""Source registry: every entry writes its own ForeverBiS_Data_<file_name>.lua."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable

from . import foreverchanges, kamilabs, wowsims


@dataclass(frozen=True)
class Source:
    id: str
    file_name: str
    label: str
    order: int
    url: str
    ship: bool
    fetch: Callable  # () -> (data, labels, phases)

    @property
    def filename(self):
        return f"ForeverBiS_Data_{self.file_name}.lua"

    @property
    def meta(self):
        return {"id": self.id, "label": self.label, "order": self.order, "url": self.url}


SOURCES = (
    Source("foreverchanges", "ForeverChanges", "ForeverChanges", 1, "https://foreverchanges.pro", True, foreverchanges.fetch),
    # Not shipped until the site owner gives permission.
    Source("kamilabs", "KamiLabs", "Kami Labs", 2, "https://kami-labs.fr/en/bis-list-wow-forever/", False, kamilabs.fetch),
    Source("wowsims", "Wowsims", "wowsims", 3, "https://github.com/wowsims/forever", True, wowsims.fetch),
)


def select(include_unshipped=False, only=(), sources=SOURCES):
    """Sources to attempt: shipped ones (plus unshipped on request), narrowed by --only ids."""
    unknown = set(only) - {source.id for source in sources}
    if unknown:
        raise ValueError("unknown source id(s): " + ", ".join(sorted(unknown)))
    return [
        source
        for source in sources
        if (not only or source.id in only) and (source.ship or include_unshipped or source.id in only)
    ]
