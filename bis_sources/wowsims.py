"""wowsims source: gear presets of https://github.com/wowsims/forever (MIT, branch master)."""

from __future__ import annotations

import os
import re

from .common import http_get, http_json, sorted_phases
from .foreverchanges import structure_source

REPO = "wowsims/forever"
TREE_URL = f"https://api.github.com/repos/{REPO}/git/trees/master?recursive=1"
RAW_URL = f"https://raw.githubusercontent.com/{REPO}/master/"
DB_PATH = "assets/database/db.json"
PRESET_RE = re.compile(r"^ui/specs/([a-z]+)/([a-z0-9_]+)/gear_sets/([A-Za-z0-9_]+)\.gear\.(?:json|siml)$")
NO_SOURCE = {"kind": "unknown", "text": "Source not listed by wowsims"}

PRE_RAID = {"id": "lvl60", "label": "Level 60 (pre-raid)", "level": 60}
RAID_1 = {"id": "raid1", "label": "Raid (phase 1)"}
PHASES = {PRE_RAID["id"]: PRE_RAID, RAID_1["id"]: RAID_1}
TITLE_SUFFIX = {PRE_RAID["id"]: "pre-raid", RAID_1["id"]: "phase 1"}

# Slot order of proto/common.proto ItemSlot, mapped to list slots (rings and trinkets share one slot).
ITEM_SLOTS = (
    "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet",
    "Finger", "Finger", "Trinket", "Trinket", "Main hand", "Off hand", "Ranged",
)  # fmt: skip

# (class, spec directory) -> {variant: (route, label)}; the "" variant is the default for that directory.
# A variant of None skips the file. Variants are the preset name without its phase prefix, lowercased.
ROUTES = {
    ("warrior", "dps"): {"arms": ("warrior/arms", "Arms"), "fury": ("warrior/fury", "Fury")},
    ("warrior", "protection"): {"": ("warrior/tank", "Protection")},
    ("paladin", "holy"): {"": ("paladin/holy", "Holy")},
    ("paladin", "protection"): {"": ("paladin/tank", "Protection")},
    ("paladin", "retribution"): {
        "": ("paladin/retribution", "Retribution"),
        "holy_shock": ("paladin/shockadin", "Shockadin"),
        "holy_shock_item_swap": None,
    },
    ("rogue", "dps"): {
        "muti": ("rogue/assassination", "Assassination"),
        "bscombat": ("rogue/combat", "Combat"),
        "bssub": ("rogue/subtlety", "Subtlety"),
        "slowmh": None,
    },
    ("hunter", "dps"): {
        "": ("hunter/ranged", "Ranged"),
        "turret": ("hunter/ranged", "Ranged"),
        "melee": ("hunter/melee", "Melee"),
        "melee_cheap": None,
        "turret_cheap": None,
        "weave": None,
        "weave_cheap": None,
    },
    # preraid.gear.json is the gear every mage build in presets.ts shares; Arcane is the addon's mage route.
    ("mage", "dps"): {"": ("mage/arcane", "Arcane"), "arcane": ("mage/arcane", "Arcane")},
    ("priest", "healer"): {"": ("priest/holy", "Holy")},
    ("warlock", "dps"): {"": ("warlock/dps", "Damage")},
    ("druid", "balance"): {"": ("druid/balance", "Balance")},
    ("druid", "feralbear"): {"": ("druid/tank", "Guardian")},
    ("druid", "feralcat"): {"": ("druid/feral", "Feral")},
}

# Variants that only restate the phase ("p1_bis") and so count as the default.
PLAIN_VARIANTS = {"bis"}
# Preset name prefix -> (phase, rank); lower rank wins when two presets land on the same route and phase.
PREFIXES = (
    ("prebis", PRE_RAID, 0),
    ("pre_raid", PRE_RAID, 1),
    ("preraid", PRE_RAID, 1),
    ("p1", RAID_1, 0),
    ("default", RAID_1, 1),
)


def parse_preset(name):
    """Return (phase id, rank, variant) for a preset file name such as p1_bscombat or prebis."""
    stem = name.lower()
    for prefix, phase, rank in PREFIXES:
        if stem.startswith(prefix):
            variant = stem[len(prefix) :].strip("_")
            return phase["id"], rank, "" if variant in PLAIN_VARIANTS else variant
    return RAID_1["id"], 2, stem


def map_preset(path):
    """Return (route, label, phase id, preference) for a gear set path, or None when it is not mapped.

    The preference sorts lower for the preset to keep: a name that is exactly a table variant beats one with a
    leftover suffix (prebis over prebis_threat), then the phase prefix rank, then the file name.
    """
    match = PRESET_RE.match(path)
    variants = match and ROUTES.get(match.group(1, 2))
    if not variants:
        return None
    name = match.group(3)
    phase, rank, variant = parse_preset(name)
    target = variants.get(variant) if variant in variants else variants.get("")
    if not target:
        return None
    return (*target, phase, (variant not in variants, rank, name))


def is_deliberate_skip(path):
    """True when the ROUTES table lists the preset's variant with a None target (an alternative gear set)."""
    match = PRESET_RE.match(path)
    variants = match and ROUTES.get(match.group(1, 2))
    return bool(variants) and variants.get(parse_preset(match.group(3))[2], 0) is None


# .gear.siml slot keys -> index into ITEM_SLOTS (the wowsims ItemSlot order).
SLOT_KEYS = {
    "head": 0, "neck": 1, "shoulder": 2, "shoulders": 2, "back": 3, "chest": 4, "wrist": 5, "hands": 6,
    "waist": 7, "legs": 8, "feet": 9, "finger1": 10, "finger2": 11, "trinket1": 12, "trinket2": 13,
    "main_hand": 14, "off_hand": 15, "ranged": 16,
}  # fmt: skip
# Upstream slugs that are not the normalised db name.
ITEM_ALIASES = {"horn_of_veho": "horn_of_vehan"}


def slugify(name):
    return re.sub(r"[^a-z0-9]+", "_", name.lower().replace("'", "").replace("’", "")).strip("_")


class SlugResolver:
    """Resolve .gear.siml item and enchant slugs against db.json, which has no slug field: slugs are names."""

    def __init__(self, db):
        self.items = {}
        for item in db["items"]:
            self.items.setdefault(slugify(item["name"]), []).append(item)
        self.effects = {}
        layers = ([], [], [])
        for enchant in db["enchants"]:
            self.effects.setdefault(enchant["effectId"], []).append(enchant)
            name = enchant["name"]
            for layer, text in zip(layers, (name, re.sub(r"^Enchant ", "", name), name.split(" - ", 1)[-1])):
                layer.append((slugify(text), enchant))
        self.layers = []
        for pairs in layers:
            layer = {}
            for slug, enchant in pairs:
                layer.setdefault(slug, {}).setdefault(enchant["effectId"], enchant)
            self.layers.append(layer)
        self.ambiguous = set()

    def item(self, slug):
        """Return the db item for a slug, or None. Same-name items resolve to the highest required level."""
        slug = ITEM_ALIASES.get(slug, slug)
        found = self.items.get(slug) or self.items.get(re.sub(r"_ilvl\d+$", "", slug))
        if not found:
            return None
        self.ambiguous = {slug} if len({item["id"] for item in found}) > 1 else set()
        return min(found, key=lambda item: (-(item.get("reqLvl") or 0), item["id"]))

    def enchant(self, slug):
        for layer in self.layers:
            if slug in layer:
                return layer[slug][min(layer[slug])]
        match = re.fullmatch(r"(.+)_(\d{3,})", slug)
        entries = match and self.effects.get(int(match.group(2)))
        if not entries:
            return None
        return next((e for e in entries if slugify(e["name"]).endswith(match.group(1))), entries[0])


def parse_siml(text, resolver, name):
    """Turn a .gear.siml preset (one `slot item_slug [item suffix] [+ enchant_slug]` per line) into a gear payload."""
    entries = [{} for _ in ITEM_SLOTS]

    def warn(message):
        print(f"::warning::wowsims: {name}: {message}")

    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        key, _, rest = line.partition(" ")
        if key == "siml":
            continue
        if key not in SLOT_KEYS:
            warn(f"unknown slot {key}")
            continue
        item_part, _, enchant_part = rest.partition("+")
        slug, _, suffix = item_part.strip().partition(" ")
        item = resolver.item(slug)
        if not item:
            warn(f"unknown item slug {slug}")
            continue
        if resolver.ambiguous:
            warn(f"ambiguous item slug {slug}, using item {item['id']}")
        entry = {"id": item["id"]}
        if suffix.strip():
            entry["suffix"] = " ".join(w if w == "of" else w.capitalize() for w in suffix.strip().split("_"))
        enchant_slug = enchant_part.strip()
        if enchant_slug:
            enchant = resolver.enchant(enchant_slug)
            if enchant:
                entry["enchant"] = enchant["effectId"]
                entry["enchantEntry"] = enchant
            else:
                warn(f"unknown enchant slug {enchant_slug}")
        entries[SLOT_KEYS[key]] = entry
    return {"items": entries}


PROFESSIONS = {1: "Alchemy", 2: "Blacksmithing", 3: "Enchanting", 4: "Engineering", 8: "Leatherworking", 11: "Tailoring"}
FACTIONS = {1: "Alliance", 2: "Horde"}
# db.json source entry type, in the order the addon prefers when an item has several.
SOURCE_PRIORITY = ("drop", "crafted", "quest", "soldBy", "rep", "pvp")


class SourceDescriber:
    """Turn the `sources` of a db.json item into the addon's source dict (kind, text, zone, boss, ...)."""

    def __init__(self, db):
        self.zones = {zone["id"]: zone["name"] for zone in db.get("zones") or []}
        self.npcs = {npc["id"]: npc["name"] for npc in db.get("npcs") or []}
        self.factions = {faction["id"]: faction["name"] for faction in db.get("factions") or []}

    def text(self, kind, entry):
        zone = self.zones.get(entry.get("zoneId"))
        if kind == "drop":
            boss = self.npcs.get(entry.get("npcId")) or entry.get("otherName")
            return ", ".join(part for part in (boss, zone) if part) or None
        if kind == "soldBy":
            vendor = entry.get("npcName") or self.npcs.get(entry.get("npcId"))
            return "Sold by " + ", ".join(part for part in (vendor, zone) if part) if vendor or zone else None
        if kind == "quest":
            if not entry.get("name"):
                return None
            faction = FACTIONS.get(entry.get("faction"))
            return f"Quest: {entry['name']}" + (f" ({faction})" if faction else "")
        if kind == "crafted":
            return PROFESSIONS.get(entry.get("profession"))
        if kind == "rep":
            return "Reputation: " + self.factions.get(entry.get("repFactionId"), "faction")
        return "PvP reward" if kind == "pvp" else None

    def __call__(self, item):
        candidates = []
        for entry in item.get("sources") or []:
            for kind in SOURCE_PRIORITY:
                text = kind in entry and self.text(kind, entry[kind])
                if text:
                    source = structure_source(text)
                    if kind == "quest":
                        source["quest"] = entry[kind]["name"]
                    candidates.append((source["kind"] != "dungeon", SOURCE_PRIORITY.index(kind), len(candidates), source))
        return min(candidates, key=lambda c: c[:3])[3] if candidates else dict(NO_SOURCE)


def slot_label(slot, item):
    if slot == "Main hand":
        return "Two-hand weapon" if item.get("handType") == 4 else "Main hand"
    if slot == "Off hand":
        return {7: "Off hand: shield", 5: "Off hand: held item"}.get(item.get("weaponType"), "Off hand")
    return slot


def enchant_of(effect_id, enchants, entry=None):
    entry = entry or enchants.get(effect_id)
    if not entry:
        return None
    name = entry["name"]
    return name.split(" - ", 1)[-1], name, "", None


def build_slots(gear, items, enchants, describe=None):
    """Turn a .gear.json payload into list slots following the wowsims ItemSlot order."""
    grouped = {}
    for index, entry in enumerate((gear.get("items") or [])[: len(ITEM_SLOTS)]):
        item_id = (entry or {}).get("id")
        if not item_id:
            continue
        item = items.get(item_id, {})
        bucket = grouped.setdefault(ITEM_SLOTS[index], [ITEM_SLOTS[index], [], []])
        bucket[0] = slot_label(ITEM_SLOTS[index], item)
        name = item.get("name") or f"Item {item_id}"
        source = describe(item) if describe else dict(NO_SOURCE)
        bucket[1].append((f"{name} {entry['suffix']}" if entry.get("suffix") else name, source, item_id))
        enchant = entry.get("enchant") and enchant_of(entry["enchant"], enchants, entry.get("enchantEntry"))
        if enchant and enchant not in bucket[2]:
            bucket[2].append(enchant)
    return [tuple(bucket) for bucket in grouped.values()]


def fetch(get_text=http_get, get_json=http_json):
    token = os.environ.get("GITHUB_TOKEN")
    api_headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"} if token else {}
    tree = get_json(TREE_URL, api_headers)
    if tree.get("truncated"):
        raise RuntimeError("the wowsims git tree listing was truncated")
    chosen = {}
    for entry in tree["tree"]:
        path = entry["path"]
        if not (path.startswith("ui/specs/") and "/gear_sets/" in path and ".gear." in path):
            continue
        mapped = map_preset(path)
        if not mapped:
            if is_deliberate_skip(path):
                print(f"wowsims: skipping alternative preset {path}")
            else:
                print(f"::warning::wowsims: unmapped preset {path}")
            continue
        route, label, phase, rank = mapped
        key = (route, phase)
        if key not in chosen or rank < chosen[key][0]:
            chosen[key] = (rank, path, label)
    if not chosen:
        raise RuntimeError("no wowsims presets were mapped")

    db = get_json(RAW_URL + DB_PATH)
    items = {item["id"]: item for item in db["items"]}
    enchants = {}
    for enchant in db["enchants"]:
        enchants.setdefault(enchant["effectId"], enchant)

    resolver = SlugResolver(db)
    describe = SourceDescriber(db)
    data, labels, phases = {}, {}, {}
    for (route, phase_id), (_, path, label) in sorted(chosen.items()):
        if path.endswith(".siml"):
            gear = parse_siml(get_text(RAW_URL + path), resolver, path)
        else:
            gear = get_json(RAW_URL + path)
        slots = build_slots(gear, items, enchants, describe)
        if not slots:
            raise RuntimeError(f"{path} has no items")
        class_key = route.split("/", 1)[0]
        title = f"wowsims {label} {class_key.title()} preset ({TITLE_SUFFIX[phase_id]})"
        data.setdefault(route, {})[phase_id] = (title, slots)
        labels[route] = label
        phases[phase_id] = PHASES[phase_id]
    print(f"wowsims: {len(chosen)} presets read")
    return data, labels, sorted_phases(phases.values())
