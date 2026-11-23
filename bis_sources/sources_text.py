"""Item source text: describes where an item of the wowsims item database (MIT) comes from.

SourceDescriber turns the `sources` of a db.json item into a readable text, and structure_source turns that text
into the structured source dict the addon reads (kind, text, zone, boss, quest, faction, ...).
"""

from __future__ import annotations

import re

REPO = "wowsims/forever"
RAW_URL = f"https://raw.githubusercontent.com/{REPO}/master/"
NO_SOURCE = {"kind": "unknown", "text": "Source not listed by wowsims"}


# --- Structured item sources -------------------------------------------------------------
# These lists mirror professionSourceIcons / Sources.dungeons in ForeverBiS/Core/Sources.lua so the
# "kind" computed here matches the category the addon derives from the source text. A new raid or
# dungeon is a one-line addition to the data below.

UNKNOWN_SOURCE_MARKER = "where it comes from is not known yet"

PROFESSIONS = (
    "Alchemy",
    "Blacksmithing",
    "Cooking",
    "Enchanting",
    "Engineering",
    "Fishing",
    "Herbalism",
    "Leatherworking",
    "Mining",
    "Skinning",
    "Tailoring",
)

# Places whose presence in the source text makes the item a "dungeon" drop (lowercase match, display name).
DUNGEON_SOURCES = (
    ("the deadmines", "The Deadmines"),
    ("wailing caverns", "Wailing Caverns"),
    ("shadowfang keep", "Shadowfang Keep"),
    ("blackfathom deeps", "Blackfathom Deeps"),
    ("ragefire chasm", "Ragefire Chasm"),
    ("ruins of lordaeron", "Ruins of Lordaeron"),
    ("gnomeregan", "Gnomeregan"),
    ("the stockade", "The Stockade"),
    ("razorfen kraul", "Razorfen Kraul"),
    ("razorfen downs", "Razorfen Downs"),
    ("scarlet monastery", "Scarlet Monastery"),
    ("uldaman", "Uldaman"),
    ("zul'farrak", "Zul'Farrak"),
    ("maraudon", "Maraudon"),
    ("the temple of atal'hakkar", "The Temple of Atal'Hakkar"),
    ("blackrock depths", "Blackrock Depths"),
    ("blackrock spire", "Blackrock Spire"),
    ("dire maul", "Dire Maul"),
    ("stratholme", "Stratholme"),
    ("scholomance", "Scholomance"),
    ("molten core", "Molten Core"),
    ("onyxia's lair", "Onyxia's Lair"),
    ("blackwing lair", "Blackwing Lair"),
    ("zul'gurub", "Zul'Gurub"),
    ("ruins of ahn'qiraj", "Ruins of Ahn'Qiraj"),
    ("temple of ahn'qiraj", "Temple of Ahn'Qiraj"),
    ("naxxramas", "Naxxramas"),
)

# Extra zone names that only fill `zone` and `boss`; they never change `kind`.
EXTRA_ZONES = (
    ("hall of thanes", "Hall of Thanes"),
)

QUEST_END = re.compile(r"\s*\u2197|\s+(?:Horde|Alliance)\b|,|\s+(?:from\s+)?level\b")


def source_zone(text):
    """Return (zone display name, character offset) of the first known zone in the text, or None."""
    lower = text.lower()
    found = [(lower.find(key), name) for key, name in DUNGEON_SOURCES + EXTRA_ZONES if key in lower]
    if not found:
        return None
    offset, name = min(found)
    return name, offset


def structure_source(text):
    """Turn the raw source text of an item into a dict; `text` is always kept verbatim."""
    lower = text.lower()
    if UNKNOWN_SOURCE_MARKER in lower:
        kind = "unknown"
    elif "quest" in lower:
        kind = "quest"
    elif any(profession.lower() in lower for profession in PROFESSIONS):
        kind = "profession"
    elif any(key in lower for key, _ in DUNGEON_SOURCES):
        kind = "dungeon"
    else:
        kind = "world"
    source = {"kind": kind, "text": text}

    has_horde, has_alliance = "horde" in lower, "alliance" in lower
    if has_horde != has_alliance:
        source["faction"] = "Horde" if has_horde else "Alliance"

    if kind in ("dungeon", "world"):
        zone = source_zone(text)
        if zone:
            source["zone"] = zone[0]
            boss = re.match(r"^([^,]+),\s*" + re.escape(text[zone[1] : zone[1] + len(zone[0])]), text)
            if boss:
                source["boss"] = boss.group(1).strip()

    rate = re.search(r"(\d+(?:\.\d+)?)%", text)
    if rate:
        source["dropRate"] = float(rate.group(1))

    if kind == "quest":
        quest = re.search(r"Quest:\s*(.+)", text)
        name = QUEST_END.split(quest.group(1), maxsplit=1)[0].strip() if quest else ""
        if name:
            source["quest"] = name

    if kind == "profession":
        matches = [
            (match.start(), profession, match.group(1) or match.group(2))
            for profession in PROFESSIONS
            if (match := re.search(rf"\b{profession}\b(?:\s*\((\d+)\)|\s+(\d+)\b)?", text, re.I))
        ]
        if matches:
            _, skill, level = min(matches)
            source["skill"] = skill
            if level:
                source["skillLevel"] = int(level)

    if "only its maker can wear it" in lower:
        source["bindsToMaker"] = True
    if "reported, not checked" in lower:
        source["reported"] = True
    return source


# --- wowsims item database sources ---------------------------------------------------------

CRAFT_PROFESSIONS = {1: "Alchemy", 2: "Blacksmithing", 3: "Enchanting", 4: "Engineering", 8: "Leatherworking", 11: "Tailoring"}
FACTIONS = {1: "Alliance", 2: "Horde"}
# db.json source entry type, in the order the addon prefers when an item has several.
SOURCE_PRIORITY = ("drop", "crafted", "quest", "soldBy", "rep", "pvp")


class SourceDescriber:
    """Turn the `sources` of a db.json item into the addon's source dict (kind, text, zone, boss, ...)."""

    def __init__(self, db, drop_rate=None):
        # drop_rate(item, npc id or None) -> percent or None, attached to a source that is a drop (see eglink).
        self.drop_rate = drop_rate
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
            return CRAFT_PROFESSIONS.get(entry.get("profession"))
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
                    rank = (source["kind"] != "dungeon", SOURCE_PRIORITY.index(kind), len(candidates))
                    candidates.append((*rank, source, kind, entry[kind]))
        if not candidates:
            return dict(NO_SOURCE)
        *_, source, kind, entry = min(candidates, key=lambda c: c[:3])
        # A drop that names no NPC only gets a rate inside a dungeon, where any NPC that drops it is that dungeon's:
        # one mob's rate says nothing about a world drop.
        if kind == "drop" and self.drop_rate and (entry.get("npcId") or source["kind"] == "dungeon"):
            rate = self.drop_rate(item, entry.get("npcId"))
            if rate is not None:
                source["dropRate"] = rate
        return source
