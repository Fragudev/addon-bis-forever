"""Generated leveling lists: every usable wowsims item (MIT) scored with a stat weight per spec, top 6 per slot.

Items, stats, required levels and sources come from the wowsims item database. Weights come from the wowsims
EP presets where the simulator has them, and from the weights written below for the specs it leaves empty.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Union

from . import eglink
from .common import http_get, http_json
from .sources_text import NO_SOURCE, RAW_URL, SourceDescriber

DB_PATH = "assets/database/db.json"
TOP = 6

# proto/common.proto Stat enum, by index.
STAT_NAMES = (
    "Strength", "Agility", "Stamina", "Intellect", "HealingPower", "SpellDamage", "ArcaneDamage", "FireDamage",
    "FrostDamage", "HolyDamage", "NatureDamage", "ShadowDamage", "SpellPiercing", "Spirit", "AttackPower",
    "RangedAttackPower", "FeralAttackPower", "HitRating", "CritRating", "HasteRating", "ArmorPenetration",
    "ExpertiseRating", "DefenseRating", "BlockRating", "BlockValue", "DodgeRating", "ParryRating", "Armor",
    "BonusArmor", "Health", "Mana", "MP5", "ArcaneResistance", "FireResistance", "FrostResistance",
    "NatureResistance", "ShadowResistance", "PhysicalDamage", "ArmorNoMods",
)  # fmt: skip
STAT = {name: index for index, name in enumerate(STAT_NAMES)}

# proto enums used below.
CLASS_IDS = {
    "warrior": 1, "paladin": 2, "hunter": 3, "rogue": 4, "priest": 5, "shaman": 7, "mage": 8, "warlock": 9, "druid": 11,
}  # fmt: skip
CLOTH, LEATHER, MAIL, PLATE = 1, 2, 3, 4
AXE, DAGGER, FIST, MACE, HELD, POLEARM, SHIELD, STAFF, SWORD = 1, 2, 3, 4, 5, 6, 7, 8, 9
MAIN_HAND, ONE_HAND, OFF_HAND, TWO_HAND = 1, 2, 3, 4
BOW, CROSSBOW, GUN, THROWN, WAND, IDOL, LIBRAM, TOTEM = 1, 2, 3, 4, 5, 6, 7, 8
WEAPON, RANGED = 13, 14

# Armor a class wears, and the level it learns it at.
ARMOR = {
    "warrior": {CLOTH: 1, LEATHER: 1, MAIL: 1, PLATE: 40},
    "paladin": {CLOTH: 1, LEATHER: 1, MAIL: 1, PLATE: 40},
    "hunter": {CLOTH: 1, LEATHER: 1, MAIL: 40},
    "shaman": {CLOTH: 1, LEATHER: 1, MAIL: 40},
    "rogue": {CLOTH: 1, LEATHER: 1},
    "druid": {CLOTH: 1, LEATHER: 1},
    "priest": {CLOTH: 1},
    "mage": {CLOTH: 1},
    "warlock": {CLOTH: 1},
}
ONE_HANDED = {
    "warrior": {AXE, DAGGER, FIST, MACE, SWORD},
    "paladin": {AXE, MACE, SWORD},
    "hunter": {AXE, DAGGER, FIST, SWORD},
    "rogue": {DAGGER, FIST, MACE, SWORD},
    "priest": {DAGGER, MACE},
    "shaman": {AXE, DAGGER, FIST, MACE},
    "mage": {DAGGER, SWORD},
    "warlock": {DAGGER, SWORD},
    "druid": {DAGGER, FIST, MACE},
}
TWO_HANDED = {
    "warrior": {AXE, MACE, POLEARM, STAFF, SWORD},
    "paladin": {AXE, MACE, POLEARM, SWORD},
    "hunter": {AXE, POLEARM, STAFF, SWORD},
    "rogue": set(),
    "priest": {STAFF},
    "shaman": {AXE, MACE, STAFF},
    "mage": {STAFF},
    "warlock": {STAFF},
    "druid": {MACE, STAFF},
}
SHIELD_CLASSES = {"warrior", "paladin", "shaman"}
RANGED_TYPES = {
    "warrior": {BOW, CROSSBOW, GUN, THROWN},
    "rogue": {BOW, CROSSBOW, GUN, THROWN},
    "hunter": {BOW, CROSSBOW, GUN},  # Auto Shot needs a bow, crossbow or gun
    "priest": {WAND},
    "mage": {WAND},
    "warlock": {WAND},
    "paladin": {LIBRAM},
    "druid": {IDOL},
    "shaman": {TOTEM},
}

# Slot order of the lists; the weapon and ranged slots depend on the spec's weapon style.
ARMOR_SLOTS = (
    (1, "Head"), (2, "Neck"), (3, "Shoulder"), (4, "Back"), (5, "Chest"), (6, "Wrist"), (7, "Hands"), (8, "Waist"),
    (9, "Legs"), (10, "Feet"), (11, "Finger"), (12, "Trinket"),
)  # fmt: skip
# Weapon styles: main hand label and the off hand label plus the off hand weapon types it takes (None: no off hand).
STYLES = {
    "twohand": ("Two-hand weapon", None),
    "dual": ("Main hand", ("Off hand", None)),
    "shield": ("Main hand", ("Off hand: shield", {SHIELD})),
    "caster": ("Main hand", ("Off hand: held item", {HELD})),
    "caster_shield": ("Main hand", ("Off hand", {HELD, SHIELD})),
}

RAID_ZONES = {
    "Molten Core", "Onyxia's Lair", "Blackwing Lair", "Zul'Gurub", "Ruins of Ahn'Qiraj", "Temple of Ahn'Qiraj",
    "Naxxramas",
}  # fmt: skip
PHASES = (
    {"id": "lvl20", "label": "Level 20", "level": 20},
    {"id": "lvl30", "label": "Level 30", "level": 30},
    {"id": "lvl40", "label": "Level 40", "level": 40},
    {"id": "lvl50", "label": "Level 50", "level": 50},
    {"id": "lvl60", "label": "Level 60 (pre-raid)", "level": 60},
)
# Every raid drop in the wowsims database is phase 2 (and tier sets are missing), so there is no raid phase.
FACTIONS = {1: "Alliance", 2: "Horde"}


@dataclass(frozen=True)
class Spec:
    route: str
    label: str
    class_key: str
    style: str
    # Our own weights ({stat: weight}), or (file under wowsims ui/specs, exported constant) holding EP weights.
    weights: Union[dict, tuple]


# Weights written for ForeverBiS where wowsims has none (its spec.ts ships `epWeights: new Stats()`). They follow
# the wowsims scale: spell damage or healing power is 1, ratings are per rating point.
CASTER = {"SpellDamage": 1, "HitRating": 1.3, "CritRating": 0.8, "Intellect": 0.35, "Spirit": 0.05, "MP5": 0.4}
HEALER = {"HealingPower": 1, "Intellect": 0.6, "MP5": 1.4, "CritRating": 0.6, "Spirit": 0.3, "Stamina": 0.1}

ROUTES = (
    Spec("warrior/arms", "Arms", "warrior", "twohand", ("warrior/dps/presets.ts", "PreBiSArmsEpWeights")),
    Spec("warrior/fury", "Fury", "warrior", "dual", ("warrior/dps/presets.ts", "PreBiSFuryEpWeights")),
    Spec("warrior/tank", "Protection", "warrior", "shield", ("warrior/protection/presets.ts", "PreBiSBalancedEpWeights")),
    Spec("paladin/holy", "Holy", "paladin", "caster_shield", {**HEALER, "Intellect": 0.8, "MP5": 1.2, "CritRating": 0.9}),
    Spec("paladin/retribution", "Retribution", "paladin", "twohand", ("paladin/retribution/presets.ts", "UnsealedWrathEpWeights")),
    Spec("paladin/shockadin", "Shockadin", "paladin", "twohand", ("paladin/retribution/presets.ts", "HolyShockEpWeights")),
    Spec(
        "paladin/tank",
        "Protection",
        "paladin",
        "shield",
        {
            "Stamina": 1, "DefenseRating": 1.5, "DodgeRating": 1.2, "ParryRating": 1, "BlockRating": 0.6,
            "BlockValue": 0.5, "Strength": 0.4, "Agility": 0.4, "HitRating": 0.6, "SpellDamage": 0.4,
            "HolyDamage": 0.4, "Armor": 0.02, "BonusArmor": 0.1, "MainHandDps": 1.5,
        },
    ),  # fmt: skip
    Spec("hunter/ranged", "Ranged", "hunter", "twohand", ("hunter/dps/presets.ts", "TurretEpWeights")),
    Spec("hunter/melee", "Melee", "hunter", "twohand", ("hunter/dps/presets.ts", "MeleeEpWeights")),
    Spec("rogue/assassination", "Assassination", "rogue", "dual", ("rogue/dps/presets.ts", "EP_PRESET_COMBAT_DAGS")),
    Spec("rogue/combat", "Combat", "rogue", "dual", ("rogue/dps/presets.ts", "EP_PRESET_COMBAT_SINISTER")),
    Spec("rogue/subtlety", "Subtlety", "rogue", "dual", ("rogue/dps/presets.ts", "EP_PRESET_SUBTLETY")),
    Spec("priest/discipline", "Discipline", "priest", "caster", ("priest/healer/presets.ts", "DiscSingleTargetEpWeights")),
    Spec("priest/holy", "Holy", "priest", "caster", ("priest/healer/presets.ts", "HolySingleTargetEpWeights")),
    Spec("priest/shadow", "Shadow", "priest", "caster", ("priest/dps/presets.ts", "ShadowEpWeights")),
    Spec("shaman/elemental", "Elemental", "shaman", "caster_shield", ("shaman/elemental/presets.ts", "DefaultEpWeights")),
    Spec("shaman/enhancement", "Enhancement", "shaman", "twohand", ("shaman/enhancement/presets.ts", "PreBiSEpWeights")),
    Spec("shaman/restoration", "Restoration", "shaman", "caster_shield", {**HEALER, "MP5": 1.6, "Spirit": 0.2}),
    Spec("mage/arcane", "Arcane", "mage", "caster", {**CASTER, "ArcaneDamage": 1, "Intellect": 0.45, "MP5": 0.6}),
    Spec("mage/fire", "Fire", "mage", "caster", {**CASTER, "FireDamage": 1, "CritRating": 0.9}),
    Spec("mage/frost", "Frost", "mage", "caster", {**CASTER, "FrostDamage": 1, "CritRating": 0.6}),
    Spec(
        "warlock/dps",
        "Damage",
        "warlock",
        "caster",
        {**CASTER, "ShadowDamage": 1, "FireDamage": 0.3, "CritRating": 0.6, "Stamina": 0.2, "Intellect": 0.3},
    ),
    Spec("druid/balance", "Balance", "druid", "caster", ("druid/balance/presets.ts", "DefaultEpWeights")),
    Spec("druid/feral", "Feral", "druid", "twohand", ("druid/feral_ep.ts", "CatEp")),
    Spec("druid/tank", "Guardian", "druid", "twohand", ("druid/feral_ep.ts", "BearEp")),
    Spec("druid/restoration", "Restoration", "druid", "caster", {**HEALER, "Spirit": 0.5, "MP5": 1.5, "CritRating": 0.5}),
)

WEIGHT_RE = re.compile(r"\[(?:Stat|PseudoStat)\.(?:PseudoStat|Stat)(\w+)\]:\s*(-?\d+(?:\.\d+)?)")


def parse_ep_weights(text, name):
    """Return {stat: weight} written in the `export const <name> = ...` block (makePresetEpWeights or Stats.fromMap)."""
    match = re.search(r"export const " + re.escape(name) + r"\s*=", text)
    if not match:
        raise ValueError(f"EP weight preset {name} not found")
    following = text.find("export const", match.end())
    block = text[match.end() : following if following >= 0 else len(text)]
    return {stat: float(value) for stat, value in WEIGHT_RE.findall(block)}


def option(item):
    return (item.get("scalingOptions") or {}).get("0") or {}


def required_level(item):
    return item.get("reqLvl") or max(1, option(item).get("ilvl", 1) - 5)


def can_use(class_key, item, level):
    """Whether a character of the class can equip the item at the given level."""
    allowed = item.get("classAllowlist")
    if allowed and CLASS_IDS[class_key] not in allowed:
        return False
    kind = item.get("type")
    if kind == WEAPON:
        weapon, hand = item.get("weaponType"), item.get("handType")
        if weapon == SHIELD:
            return class_key in SHIELD_CLASSES
        if weapon == HELD:
            return True
        return weapon in (TWO_HANDED if hand == TWO_HAND else ONE_HANDED)[class_key]
    if kind == RANGED:
        return item.get("rangedWeaponType") in RANGED_TYPES[class_key]
    armor = item.get("armorType")
    if armor and armor != CLOTH:
        learned = ARMOR[class_key].get(armor)
        return learned is not None and level >= learned
    return True


def score(item, weights, dps_stat):
    """Σ stat × weight, plus the weapon's DPS times the weight of `dps_stat` (MainHandDps, OffHandDps, RangedDps)."""
    stats = option(item).get("stats") or {}
    total = sum(weights.get(STAT_NAMES[int(index)], 0) * value for index, value in stats.items())
    if dps_stat:
        total += weights.get(dps_stat, 0) * option(item).get("unroundedDps", 0)
    return total


def eligible(item):
    """Items a list can recommend: phase 1, fixed stats, green or better, and not only a PvP reward."""
    sources = item.get("sources") or []
    pvp_only = bool(sources) and all("pvp" in source for source in sources)
    return (
        item.get("phase", 1) <= 1
        and not item.get("randomSuffixOptions")
        and item.get("quality", 0) >= 2
        and not pvp_only
    )


def is_raid_drop(item, zones):
    sources = item.get("sources") or []
    return any(zones.get((source.get("drop") or {}).get("zoneId")) in RAID_ZONES for source in sources)


def hands(item, allowed):
    return item.get("type") == WEAPON and item.get("handType") in allowed


def off_hand_fits(item, types):
    """An off hand weapon for dual wielders (types None), else a shield or held item of the allowed types."""
    if types is None:
        return hands(item, (ONE_HAND, OFF_HAND)) and item.get("weaponType") not in (HELD, SHIELD)
    return item.get("type") == WEAPON and item.get("weaponType") in types


def weapon_lists(spec, usable, weights):
    """[(label, ranked)] for the spec's main hand, off hand and ranged (or relic) slots."""
    main_label, off = STYLES[spec.style]
    off_hand = []
    if off:
        off_hand = ranked([i for i in usable if off_hand_fits(i, off[1])], weights, "OffHandDps")
    if spec.style == "twohand":
        main = ranked([i for i in usable if hands(i, (TWO_HAND,))], weights, "MainHandDps")
    elif spec.style in ("caster", "caster_shield"):
        # A two-hander replaces the off hand too, so it has to beat a one-hander plus the best off hand.
        best_off = off_hand[0][0] if off_hand else 0
        candidates = [i for i in usable if hands(i, (MAIN_HAND, ONE_HAND, TWO_HAND))]
        main = ranked(candidates, weights, "MainHandDps", lambda i: -best_off if i.get("handType") == TWO_HAND else 0)
    else:
        main = ranked([i for i in usable if hands(i, (MAIN_HAND, ONE_HAND))], weights, "MainHandDps")
    lists = [(main_label, main)]
    if off:
        lists.append((off[0], off_hand))
    ranged_label = "Relic" if spec.class_key in ("paladin", "druid", "shaman") else "Ranged"
    lists.append((ranged_label, ranked([i for i in usable if i.get("type") == RANGED], weights, "RangedDps")))
    return lists


def ranked(candidates, weights, dps_stat, bonus=None):
    """Top items by score (ties by id), as (score, item); only items that score above zero."""
    scored = [(score(item, weights, dps_stat) + (bonus(item) if bonus else 0), item) for item in candidates]
    scored = [entry for entry in scored if entry[0] > 0]
    scored.sort(key=lambda entry: (-entry[0], entry[1]["id"]))
    return scored[:TOP]


def generate(db, specs, phases=PHASES, rates=None):
    """Return route -> {phase id: (title, slots)} in the shape common.emit_lua expects.

    `rates(item, npc id)` gives the drop % (eglink.DropRates) attached to drop sources, when known.
    """
    describe = SourceDescriber(db, rates)
    zones = {zone["id"]: zone["name"] for zone in db.get("zones") or []}
    pool = [item for item in db["items"] if eligible(item)]
    data = {}
    for spec in specs:
        weights = spec.weights
        for phase in phases:
            level = phase["level"]
            usable = [
                item
                for item in pool
                if required_level(item) <= level
                and can_use(spec.class_key, item, level)
                and (phase["id"] != "lvl60" or not is_raid_drop(item, zones))
            ]
            slots = []
            for slot_type, label in ARMOR_SLOTS:
                slots.append((label, ranked([i for i in usable if i.get("type") == slot_type], weights, None)))
            slots.extend(weapon_lists(spec, usable, weights))
            built = [(label, [entry(item, describe) for _, item in top], []) for label, top in slots if top]
            if built:
                title = f"ForeverBiS {spec.label} {spec.class_key.title()} list ({phase['label']})"
                data.setdefault(spec.route, {})[phase["id"]] = (title, built)
    return data


def entry(item, describe):
    source = describe(item) if item.get("sources") else dict(NO_SOURCE)
    faction = FACTIONS.get(item.get("factionRestriction"))
    if faction:
        source["faction"] = faction
    return (item.get("name") or f"Item {item['id']}", source, item["id"])


def resolve_weights(specs, get_text=http_get):
    """Specs with every (file, constant) weight read from that wowsims file."""
    files = {}
    resolved = []
    for spec in specs:
        weights = spec.weights
        if isinstance(weights, tuple):
            path, name = weights
            if path not in files:
                files[path] = get_text(f"{RAW_URL}ui/specs/{path}")
            weights = parse_ep_weights(files[path], name)
            if not weights:
                raise ValueError(f"EP weight preset {name} of {path} is empty")
        resolved.append(Spec(spec.route, spec.label, spec.class_key, spec.style, weights))
    return resolved


def load_rates(get_json=http_json):
    """EG Link drop chances, or None (with a warning) when they cannot be read: they are an optional enrichment."""
    try:
        return eglink.load(get_json)
    except Exception as exc:  # noqa: BLE001 - any failure only drops the rates, never the lists
        print(f"::warning::EG Link drop chances unavailable, lists written without drop rates ({exc})")
        return None


def fetch(get_text=http_get, get_json=http_json, routes=ROUTES):
    db = get_json(RAW_URL + DB_PATH)
    specs = resolve_weights(routes, get_text)
    data = generate(db, specs, rates=load_rates(get_json))
    print(f"leveling: {len(data)} lists generated from {len(db['items'])} wowsims items")
    return data, {spec.route: spec.label for spec in specs}, list(PHASES)
