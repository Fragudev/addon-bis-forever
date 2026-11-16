"""Shared pieces for every BiS source: HTTP, validation and the schema 3 Lua emitter."""

from __future__ import annotations

import json
import re
import urllib.request

USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/140.0.0.0 Safari/537.36"
)

CLASS_KEYS = ("warrior", "hunter", "mage", "rogue", "priest", "warlock", "paladin", "druid", "shaman")
SOURCE_KINDS = ("quest", "profession", "dungeon", "world", "unknown")
SOURCE_FIELDS = ("faction", "zone", "boss", "dropRate", "quest", "skill", "skillLevel", "bindsToMaker", "reported")


def http_get(url, accept="*/*", headers=None):
    request = urllib.request.Request(
        url,
        headers={"User-Agent": USER_AGENT, "Accept": accept, "Accept-Language": "en-US,en;q=0.9", **(headers or {})},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        if response.status != 200:
            raise RuntimeError(f"HTTP {response.status} for {url}")
        return response.read().decode("utf-8", errors="replace")


def http_json(url, headers=None):
    return json.loads(http_get(url, "application/json", headers))


def lua_quote(value):
    value = str(value or "")
    value = value.replace("\\", "\\\\").replace('"', '\\"')
    value = value.replace("\r", " ").replace("\n", " ")
    return '"' + value + '"'


def lua_key(key):
    return key if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", key) else f"[{lua_quote(key)}]"


def lua_value(value):
    if value is True:
        return "true"
    if isinstance(value, (int, float)):
        return repr(value)
    return lua_quote(value)


def lua_source(source):
    parts = [f"kind = {lua_quote(source['kind'])}", f"text = {lua_quote(source['text'])}"]
    parts.extend(f"{field} = {lua_value(source[field])}" for field in SOURCE_FIELDS if field in source)
    return "{ " + ", ".join(parts) + " }"


def validate(data):
    """Reject data the Lua side cannot use. `data` maps route -> {phase id: (title, slots)}."""
    if not data:
        raise ValueError("no lists were produced")
    for route, phases in data.items():
        if route.split("/", 1)[0] not in CLASS_KEYS:
            raise ValueError(f"route {route!r} does not start with a class key")
        for phase_id, (_, slots) in phases.items():
            if not slots:
                raise ValueError(f"{route}/{phase_id} has no slots")
            for slot_name, items, _ in slots:
                for _, source, _ in items:
                    if source.get("kind") not in SOURCE_KINDS or not source.get("text"):
                        raise ValueError(f"{route}/{phase_id}/{slot_name} has an invalid item source: {source!r}")


def emit_lua(meta, data, labels, phases):
    """Write one source file (schema 3).

    `meta` has id/label/order/url, `phases` is [{id, label, level|None}] and `data` maps
    route -> {phase id: (title, [(slot, [(name, source dict, id|None)], [(effect, spell, source, formula|None)])])}.
    """
    lines = [
        "ForeverBiSData = ForeverBiSData or { schema = 3, sources = {} }",
        f"ForeverBiSData.sources[{lua_quote(meta['id'])}] = {{",
        f"  label = {lua_quote(meta['label'])},",
        f"  order = {meta['order']},",
        f"  url = {lua_quote(meta['url'])},",
        "  phases = {",
    ]
    for phase in phases:
        level = f", level = {phase['level']}" if phase.get("level") is not None else ""
        lines.append(f"    {{ id = {lua_quote(phase['id'])}, label = {lua_quote(phase['label'])}{level} }},")
    lines.extend(["  },", "  lists = {"])
    for key, route_phases in sorted(data.items()):
        lines.append(f"    [{lua_quote(key)}] = {{")
        if key in labels:
            lines.append(f"      label = {lua_quote(labels[key])},")
        lines.append("      phases = {")
        for phase_id, (title, slots) in sorted(route_phases.items()):
            lines.append(f"        {lua_key(phase_id)} = {{")
            lines.append(f"          title = {lua_quote(title)},")
            lines.append("          slots = {")
            for slot_name, items, enchants in slots:
                lines.append(f"            {{ slot = {lua_quote(slot_name)},")
                lines.append("              items = {")
                for name, source, itemid in items:
                    item_id = f"id = {itemid}, " if itemid else ""
                    lines.append(f"                {{ {item_id}name = {lua_quote(name)}, source = {lua_source(source)} }},")
                lines.append("              },")
                if enchants:
                    lines.append("              enchants = {")
                    for effect, spell, source, formula in enchants:
                        formula_part = f", formulaId = {formula}" if formula else ""
                        lines.append(
                            f"                {{ effect = {lua_quote(effect)}, spell = {lua_quote(spell)}, "
                            f"source = {lua_quote(source)}{formula_part} }},"
                        )
                    lines.append("              },")
                lines.append("            },")
            lines.extend(["          },", "        },"])
        lines.extend(["      },", "    },"])
    lines.extend(["  },", "}"])
    return "\n".join(lines) + "\n"


def sorted_phases(phases):
    """By level, phases without a level last."""
    return sorted(phases, key=lambda phase: (phase.get("level") is None, phase.get("level") or 0, phase["id"]))


def source_text(parts):
    return ", ".join(part for part in parts if part)
