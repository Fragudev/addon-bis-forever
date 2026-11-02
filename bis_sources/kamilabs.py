"""Kami Labs source: https://kami-labs.fr/en/bis-list-wow-forever/ (tier JSON files found via data-tiers)."""

from __future__ import annotations

import html
import json
import re

from .common import http_get, http_json, sorted_phases

PAGE = "https://kami-labs.fr/en/bis-list-wow-forever/"
NAME = "Kami Labs"

# tier key -> (phase, list title suffix)
TIERS = {
    "30": ({"id": "lvl30", "label": "Level 30", "level": 30}, "at level 30"),
    "60-preraid": ({"id": "lvl60", "label": "Level 60 (pre-raid)", "level": 60}, "at level 60 (pre-raid)"),
}

# Display order and the JSON slot keys that feed each list slot.
SLOTS = (
    ("Head", ("head",)),
    ("Neck", ("neck",)),
    ("Shoulder", ("shoulder",)),
    ("Back", ("back",)),
    ("Chest", ("chest",)),
    ("Wrist", ("wrist",)),
    ("Hands", ("hands",)),
    ("Waist", ("waist",)),
    ("Legs", ("legs",)),
    ("Feet", ("feet",)),
    ("Finger", ("finger1", "finger2")),
    ("Trinket", ("trinket1", "trinket2")),
    ("Main hand", ("mainhand",)),
    ("Off hand", ("offhand",)),
    ("Ranged", ("ranged",)),
)

SIDES = {"Alliance": "Alliance", "Horde": "Horde", "A": "Alliance", "H": "Horde"}


def discover_tiers(page_html):
    """Return [(tier key, json url)] from the data-tiers attribute of the BiS tool root element."""
    match = re.search(r'data-tiers="([^"]*)"', page_html)
    if not match:
        raise RuntimeError("data-tiers attribute not found on the Kami Labs page")
    return [(tier["key"], tier["src"]) for tier in json.loads(html.unescape(match.group(1))) if tier.get("src")]


def en(value, fallback=""):
    return value.get("en") or fallback if isinstance(value, dict) else (value or fallback)


def source_of(item, tier):
    """Map the `src` list of an item to one structured source (first entry) with a readable text."""
    entries = item.get("src") or []
    texts, first = [], None
    for entry in entries:
        source = map_entry(entry, tier)
        texts.append(source["text"])
        first = first or source
    if not first:
        return {"kind": "unknown", "text": "Source not listed by " + NAME}
    first["text"] = "; ".join(dict.fromkeys(texts))
    return first


def zone_name(entry, tier):
    zone = en(entry.get("z"))
    if not zone and entry.get("i"):
        instance = tier["instances"].get(entry["i"], {})
        zone = en(instance, entry["i"].replace("-", " ").title())
    return zone


def map_entry(entry, tier):
    kind, zone = entry.get("k"), zone_name(entry, tier)
    name = en(entry.get("n"))
    side = SIDES.get(entry.get("side") or entry.get("fac"))
    source = {}
    if kind == "boss":
        rate = entry.get("p")
        source = {"kind": "dungeon", "text": (f"{name}, {zone}" + (f" {rate:g}%" if rate else "")).strip(", ")}
        source.update({"zone": zone, "boss": name} if name else {"zone": zone})
        if rate:
            source["dropRate"] = float(rate)
    elif kind == "trash":
        source = {"kind": "dungeon", "text": f"Trash drop, {zone}", "zone": zone}
    elif kind == "quest":
        place = f" ({zone})" if zone else ""
        source = {"kind": "quest", "text": f"Quest: {name}{place}", "quest": name}
    elif kind == "craft":
        skill = en(tier["professions"].get(entry.get("pr"), {}), str(entry.get("pr", "")).title())
        level = entry.get("s")
        source = {"kind": "profession", "text": f"{skill} ({level})" if level else skill, "skill": skill}
        if level:
            source["skillLevel"] = int(level)
    elif kind in ("npc", "vendor"):
        verb = "Sold by " if kind == "vendor" else ""
        source = {"kind": "world", "text": f"{verb}{name}" + (f", {zone}" if zone else "")}
        if zone:
            source["zone"] = zone
    elif kind == "rep":
        source = {"kind": "world", "text": f"Reputation: {en(entry.get('f'))} ({entry.get('r', '')})"}
    elif kind == "pvp":
        source = {"kind": "world", "text": f"PvP reward, rank {entry.get('r', '?')}"}
    elif kind == "world":
        source = {"kind": "world", "text": "World drop"}
    else:
        return {"kind": "unknown", "text": "Source not listed by " + NAME}
    if side and kind != "boss":
        source["faction"] = side
    return source


def slot_label(slot, item):
    kind = item.get("slot")
    if slot == "Main hand":
        return "Two-hand weapon" if kind == "two_hand" else "Main hand"
    if slot == "Off hand":
        return {"shield": "Off hand: shield", "held_off_hand": "Off hand: held item"}.get(kind, "Off hand")
    return slot


def enchant_of(enchant_id, tier):
    entry = tier["enchants"].get(str(enchant_id))
    if not entry:
        return None
    spell = en(entry)
    return spell.split(" - ", 1)[-1], spell, "", None


def build_slots(spec, tier):
    slots = []
    for slot, keys in SLOTS:
        items, enchants, label = [], [], slot
        for key in keys:
            choice = spec["bis"].get(key) or {}
            item_id = choice.get("item")
            if not item_id:
                continue
            item = tier["items"].get(str(item_id), {})
            label = slot_label(slot, item)
            items.append((en(item, f"Item {item_id}"), source_of(item, tier), item_id))
            enchant = choice.get("ench") and enchant_of(choice["ench"], tier)
            if enchant and enchant not in enchants:
                enchants.append(enchant)
        if items:
            slots.append((label, items, enchants))
    return slots


def build_lists(tier_key, payload):
    """Return ({route: (spec label, title, slots)}) for one tier JSON."""
    suffix = TIERS[tier_key][1]
    lists = {}
    for spec in payload["specs"]:
        class_key, _, spec_key = spec["slugEn"].partition("-")
        slots = build_slots(spec, payload)
        if not spec_key or not slots:
            continue
        label = en(spec["spec"], spec_key.replace("-", " ").title())
        class_name = en(payload["classes"].get(class_key, {}), class_key.title())
        lists[f"{class_key}/{spec_key}"] = (label, f"{label} {class_name} {suffix}", slots)
    return lists


def fetch(get_page=http_get, get_json=http_json):
    data, labels, phases = {}, {}, {}
    for tier_key, url in discover_tiers(get_page(PAGE, "text/html")):
        if tier_key not in TIERS:
            print(f"Kami Labs: skipping unknown tier {tier_key!r}")
            continue
        phase = TIERS[tier_key][0]
        for route, (label, title, slots) in build_lists(tier_key, get_json(url)).items():
            data.setdefault(route, {})[phase["id"]] = (title, slots)
            labels[route] = label
        phases[phase["id"]] = phase
        print(f"Kami Labs: tier {tier_key} read")
    return data, labels, sorted_phases(phases.values())
