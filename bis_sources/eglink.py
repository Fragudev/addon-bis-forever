"""Drop chances observed by EG Link players (JIVESCORP/eg-link-output-wowf, CC BY 4.0).

Data from Efficient Games (https://efficient.games), licensed under CC BY 4.0.

`load()` reads the `loot` (and `encounters`) dataset of every live `wowf` client build and pools them into
DropRates, which answers "how often does this NPC drop this item" as a percent, or None when EG Link has not seen
enough kills to say. The beta product (`wow_classic_beta`) is never read. See DATASETS.md in that repository for
the meaning of every field used here.

Rules:
- Kills only: corpse keys `npc:<id>` with any of `|quest` and `|group`. Skinning and pick pocket
  (`|spell:<id>`), objects, containers and fishing are not kills and are left out.
- Each key publishes `chance`, the expected number of the item per kill. Keys are pooled across builds as
  Σ chance × windows / Σ windows, so a key counts as much as the loot windows behind it. A key of the NPC that does
  not list the item counts as observations without a drop.
- Dungeon bosses (an NPC named in an encounter's `bosses`): in a group, another member often opens the corpse
  first and the rolled item is gone from it, so their `|group` corpse keys are left out and their `rolls` are used
  instead, each as `drops` over `kills` + `unconfirmed`. A roll key only counts for items whose quality reaches its
  loot threshold, since items under it are never rolled for.
- At least MIN_OBSERVATIONS pooled observations (loot windows plus rolled kills) are needed for a rate, and an
  item that never dropped gets no rate (never 0%).
- NPC matching: the NPC the wowsims drop names. When it names none (trash, "Multiple NPCs"), the NPC with the most
  observations among those that dropped the item; SourceDescriber only asks that for dungeon drops, never for world
  drops.
"""

from __future__ import annotations

import re
from collections import defaultdict

from .common import http_json

REPO = "JIVESCORP/eg-link-output-wowf"
DATA_URL = f"https://raw.githubusercontent.com/{REPO}/main/data/"
INDEX_URL = DATA_URL + "index.json"
PRODUCT = "wowf"
LICENSE = "CC BY 4.0"
ATTRIBUTION = "Data from Efficient Games (https://efficient.games), licensed under CC BY 4.0."
# The same minimum EG Link itself asks for before it trusts a creature's share of corpses with loot (10 looked
# deaths); with fewer, one lucky kill reads as 100%.
MIN_OBSERVATIONS = 10

CORPSE_KEY = re.compile(r"^npc:(\d+)((?:\|quest)?)((?:\|group)?)$")
ROLL_KEY = re.compile(r"^encounter:(\d+)\|threshold:(\d+)$")


def percent(chance):
    """A 0-1 chance as a percent with one decimal (two under 0.1%), capped at 100."""
    value = min(chance, 1) * 100
    rounded = round(value, 1)
    return rounded if rounded or not value else round(value, 2)


class Pool:
    """Observations of one source: how many, and the expected drops of each item over them."""

    def __init__(self):
        self.observations = 0
        self.drops = defaultdict(float)

    def add(self, observations, drops):
        self.observations += observations
        for item_id, count in drops.items():
            self.drops[item_id] += count


class DropRates:
    """Pooled EG Link loot; call it with a db.json item and the NPC id wowsims names (or None)."""

    def __init__(self, loot_files, encounter_files=()):
        bosses = defaultdict(set)  # npc id -> encounter ids
        for data in encounter_files:
            for encounter_id, encounter in (data.get("encounters") or {}).items():
                for npc_id in encounter.get("bosses") or []:
                    bosses[int(npc_id)].add(int(encounter_id))
        corpses = defaultdict(Pool)
        rolls = defaultdict(lambda: defaultdict(Pool))  # encounter id -> loot threshold -> pool
        for data in loot_files:
            for key, source in (data.get("sources") or {}).items():
                match = CORPSE_KEY.match(key)
                if not match or (match.group(3) and int(match.group(1)) in bosses):
                    continue
                windows = source.get("windows") or 0
                items = source.get("items") or {}
                corpses[int(match.group(1))].add(
                    windows, {int(i): entry.get("chance", 0) * windows for i, entry in items.items()}
                )
            for key, roll in (data.get("rolls") or {}).items():
                match = ROLL_KEY.match(key)
                if not match:
                    continue
                kills = (roll.get("kills") or 0) + (roll.get("unconfirmed") or 0)
                items = roll.get("items") or {}
                rolls[int(match.group(1))][int(match.group(2))].add(
                    kills, {int(i): entry.get("drops", 0) for i, entry in items.items()}
                )
        self.corpses = corpses
        self.bosses = bosses
        self.rolls = rolls
        self.npcs = set(corpses) | {npc for npc, encounters in bosses.items() if any(e in rolls for e in encounters)}
        self.cache = {}

    def observed(self, item, npc_id):
        """(observations, expected drops) of the item at the NPC, from its kills and its encounters' rolls."""
        pools = [self.corpses[npc_id]] if npc_id in self.corpses else []
        quality = item.get("quality") or 0
        for encounter_id in sorted(self.bosses.get(npc_id, ())):
            pools.extend(pool for threshold, pool in self.rolls.get(encounter_id, {}).items() if threshold <= quality)
        return sum(p.observations for p in pools), sum(p.drops.get(item["id"], 0) for p in pools)

    def rate(self, item, npc_id):
        """(observations, percent) of the item at the NPC, or None without enough observations or any drop."""
        observations, drops = self.observed(item, npc_id)
        if observations < MIN_OBSERVATIONS or drops <= 0:
            return None
        return observations, percent(drops / observations)

    def __call__(self, item, npc_id):
        """Drop % of the item at the NPC wowsims names (npc_id), or None.

        With no NPC named (npc_id None), the rate of the NPC with the most observations among those that dropped it.
        A named NPC never borrows another NPC's rate, since the source text names that NPC.
        """
        key = (item["id"], item.get("quality"), npc_id)
        if key not in self.cache:
            self.cache[key] = self.lookup(item, npc_id)
        return self.cache[key]

    def lookup(self, item, npc_id):
        if npc_id is not None:
            found = self.rate(item, npc_id)
            return found[1] if found else None
        found = [rate for npc in sorted(self.npcs) if (rate := self.rate(item, npc))]
        return max(found, key=lambda rate: rate[0])[1] if found else None


def load(get_json=http_json):
    """DropRates from every live (`wowf`) build with a loot dataset; any download failure raises."""
    index = get_json(INDEX_URL)
    if index.get("license") != LICENSE:
        raise ValueError(f"EG Link data license is {index.get('license')!r}, expected {LICENSE!r}")
    builds = index.get("products", {}).get(PRODUCT, {})
    loot, encounters = [], []
    for build, datasets in sorted(builds.items()):
        if "loot" not in datasets:
            continue
        loot.append(get_json(f"{DATA_URL}{PRODUCT}/{build}/loot.json"))
        if "encounters" in datasets:
            encounters.append(get_json(f"{DATA_URL}{PRODUCT}/{build}/encounters.json"))
    return DropRates(loot, encounters)
