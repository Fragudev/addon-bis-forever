"""wowsims source: gear presets of https://github.com/wowsims/forever (MIT, branch master)."""

from __future__ import annotations

import os
import re

from .common import http_get, http_json, sorted_phases

REPO = "wowsims/forever"
TREE_URL = f"https://api.github.com/repos/{REPO}/git/trees/master?recursive=1"
RAW_URL = f"https://raw.githubusercontent.com/{REPO}/master/"
DB_PATH = "assets/database/db.json"
PRESET_RE = re.compile(r"^ui/specs/([a-z]+)/([a-z0-9_]+)/gear_sets/([A-Za-z0-9_]+)\.gear\.json$")
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
    ("hunter", "dps"): {"": ("hunter/ranged", "Ranged"), "melee": ("hunter/melee", "Melee")},
    ("mage", "dps"): {"arcane": ("mage/arcane", "Arcane")},
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


def slot_label(slot, item):
    if slot == "Main hand":
        return "Two-hand weapon" if item.get("handType") == 4 else "Main hand"
    if slot == "Off hand":
        return {7: "Off hand: shield", 5: "Off hand: held item"}.get(item.get("weaponType"), "Off hand")
    return slot


def enchant_of(effect_id, enchants):
    entry = enchants.get(effect_id)
    if not entry:
        return None
    name = entry["name"]
    return name.split(" - ", 1)[-1], name, "", None


def build_slots(gear, items, enchants):
    """Turn a .gear.json payload into list slots following the wowsims ItemSlot order."""
    grouped = {}
    for index, entry in enumerate((gear.get("items") or [])[: len(ITEM_SLOTS)]):
        item_id = (entry or {}).get("id")
        if not item_id:
            continue
        item = items.get(item_id, {})
        bucket = grouped.setdefault(ITEM_SLOTS[index], [ITEM_SLOTS[index], [], []])
        bucket[0] = slot_label(ITEM_SLOTS[index], item)
        bucket[1].append((item.get("name") or f"Item {item_id}", dict(NO_SOURCE), item_id))
        enchant = entry.get("enchant") and enchant_of(entry["enchant"], enchants)
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
        if not (path.startswith("ui/specs/") and path.endswith(".gear.json")):
            continue
        mapped = map_preset(path)
        if not mapped:
            print(f"wowsims: skipping unmapped preset {path}")
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

    data, labels, phases = {}, {}, {}
    for (route, phase_id), (_, path, label) in sorted(chosen.items()):
        slots = build_slots(get_json(RAW_URL + path), items, enchants)
        if not slots:
            raise RuntimeError(f"{path} has no items")
        class_key = route.split("/", 1)[0]
        title = f"wowsims {label} {class_key.title()} preset ({TITLE_SUFFIX[phase_id]})"
        data.setdefault(route, {})[phase_id] = (title, slots)
        labels[route] = label
        phases[phase_id] = PHASES[phase_id]
    print(f"wowsims: {len(chosen)} presets read")
    return data, labels, sorted_phases(phases.values())
