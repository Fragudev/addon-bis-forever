"""ForeverChanges source: scrapes https://foreverchanges.pro."""

from __future__ import annotations

import re
import time
import urllib.parse
from html.parser import HTMLParser

from .common import http_get, sorted_phases

BASE = "https://foreverchanges.pro"


class Node:
    def __init__(self, tag="", attrs=()):
        self.tag = tag
        self.attrs = dict(attrs)
        self.children = []

    def text(self):
        return " ".join(
            part for part in (child if isinstance(child, str) else child.text() for child in self.children)
            if part
        )

    def walk(self):
        yield self
        for child in self.children:
            if isinstance(child, Node):
                yield from child.walk()

    def classes(self):
        return self.attrs.get("class", "").split()


class PageParser(HTMLParser):
    VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = Node("document")
        self.stack = [self.root]

    def handle_starttag(self, tag, attrs):
        if tag in {"script", "style", "noscript"}:
            node = Node(tag, attrs)
            self.stack[-1].children.append(node)
            if tag not in self.VOID:
                self.stack.append(node)
            return
        node = Node(tag, attrs)
        self.stack[-1].children.append(node)
        if tag not in self.VOID:
            self.stack.append(node)

    def handle_startendtag(self, tag, attrs):
        self.stack[-1].children.append(Node(tag, attrs))

    def handle_endtag(self, tag):
        for index in range(len(self.stack) - 1, 0, -1):
            if self.stack[index].tag == tag:
                del self.stack[index:]
                break

    def handle_data(self, data):
        if self.stack[-1].tag not in {"script", "style", "noscript"}:
            value = " ".join(data.split())
            if value:
                self.stack[-1].children.append(value)


def download(path):
    return http_get(urllib.parse.urljoin(BASE, path), "text/html")


def parse_page(html):
    parser = PageParser()
    parser.feed(html)
    return parser.root


def route_from_href(href):
    parsed = urllib.parse.urlparse(href or "")
    path = parsed.path if parsed.scheme else href.split("?", 1)[0].split("#", 1)[0]
    if not path.startswith("/bis/"):
        return None
    return path.rstrip("/")


def links(root):
    for node in root.walk():
        if node.tag == "a" and node.attrs.get("href"):
            yield node.attrs["href"], node.text().strip()


def item_id(row, item_link):
    values = [item_link.attrs.get("href", "")]
    values.extend(row.attrs.get(key, "") for key in ("data-item-id", "data-id"))
    for node in row.walk():
        values.extend(node.attrs.get(key, "") for key in ("data-item-id", "data-id"))
        if node.tag == "img":
            values.append(node.attrs.get("src", ""))
    for value in values:
        match = re.search(r"(?:item(?:s)?[/=:-])([0-9]{2,})", value, re.I)
        if match:
            return int(match.group(1))
        match = re.search(r"[?&](?:id|itemId)=([0-9]{2,})", value, re.I)
        if match:
            return int(match.group(1))
    return None


def slot_rows(section):
    rows = [node for node in section.walk() if node.tag == "li"]
    if rows:
        return rows
    return [node for node in section.walk() if "bis-item" in node.classes() or "item-row" in node.classes()]


def raw_text(node):
    return "".join(child if isinstance(child, str) else raw_text(child) for child in node.children)


def enchant_targets(label, headings):
    """Map an enchant slot label such as "Hands, Legs" onto the list's own slot headings."""
    targets = []
    candidates = [label] if label in headings else [part.strip() for part in label.split(",")]
    for candidate in candidates:
        for heading in headings:
            if heading == candidate or heading.startswith(candidate + ":"):
                targets.append(heading)
    return targets


def parse_enchants(root):
    """Return [(slot label, effect, spell name, source, formula item id)] from the Enchants section."""
    found = []
    for section in root.walk():
        if "bis-enchants" not in section.classes():
            continue
        for row in (node for node in section.walk() if node.tag == "li" and "bis-enchant-row" in node.classes()):
            find = lambda cls: next((node for node in row.walk() if cls in node.classes()), None)
            slots_node, effect_node, from_node = find("bis-enchant-slots"), find("bis-enchant-line"), find("bis-from")
            paragraph = next((node for node in from_node.walk() if node.tag == "p"), None) if from_node else None
            if not (slots_node and effect_node and paragraph):
                continue
            link = next((node for node in paragraph.walk() if node.tag == "a"), None)
            name_node = link or next((node for node in paragraph.children if isinstance(node, Node) and node.tag == "b"), None)
            spell = name_node.text().strip() if name_node else ""
            requirement = re.search(r"\(([^)]*)\)", raw_text(paragraph))
            detail = next((node for node in paragraph.children if isinstance(node, Node) and node.tag == "span"), None)
            detail_text = re.sub(r"\s+", " ", raw_text(detail)).strip().replace(" .", ".") if detail else ""
            source = ": ".join(part for part in (requirement.group(1) if requirement else "", detail_text) if part)
            effect = re.sub(r"^Enchanted:\s*", "", effect_node.text().strip())
            formula = item_id(row, link) if link else None
            found.append((slots_node.text().strip(), effect, spell, source, formula))
    return found


def parse_list(route, html):
    root = parse_page(html)
    headings = [node.text().strip() for node in root.walk() if node.tag == "h1" and node.text().strip()]
    title = headings[0] if headings else route.rsplit("/", 1)[-1].replace("-", " ").title()
    sections = []
    for node in root.walk():
        if "bis-slot" not in node.classes() or "bis-enchants" in node.classes() or "bis-consumables" in node.classes():
            continue
        heading = next((child.text().strip() for child in node.walk() if child.tag in {"h2", "h3"} and child.text().strip()), None)
        if not heading:
            continue
        items = []
        for row in (child for child in node.walk() if child.tag == "li" and "bis-row" in child.classes()):
            item_link = next((child for child in row.walk() if child.tag == "a" and "bis-name" in child.classes()), None)
            if not item_link:
                continue
            name = item_link.text().strip()
            if not name or name.isdigit():
                continue
            source_node = next((child for child in row.walk() if "bis-from" in child.classes()), None)
            source = re.sub(r"\s+", " ", source_node.text()).strip() if source_node else "Location not listed on ForeverChanges"
            items.append((name, source, item_id(row, item_link)))
        if items:
            sections.append((heading, items))
    headings = [heading for heading, _ in sections]
    enchants = {heading: [] for heading in headings}
    for label, *enchant in parse_enchants(root):
        for heading in enchant_targets(label, headings):
            enchants[heading].append(tuple(enchant))
    sections = [(heading, items, enchants[heading]) for heading, items in sections]
    return title, sections


def discover_routes():
    root = parse_page(download("/bis"))
    class_roots = set()
    for href, _ in links(root):
        route = route_from_href(href)
        if route and re.fullmatch(r"/bis/[a-z-]+", route):
            class_roots.add(route)
    if not class_roots:
        raise RuntimeError("Could not find class links on ForeverChanges /bis")

    routes = set(class_roots)
    labels = {}
    for class_route in sorted(class_roots):
        page = parse_page(download(class_route))
        time.sleep(0.35)
        for href, label in links(page):
            route = route_from_href(href)
            if route and (route == class_route or route.startswith(class_route + "/")):
                routes.add(route)
                if label:
                    labels[route.removeprefix("/bis/")] = label
    return sorted(routes), labels




# --- Structured item sources -------------------------------------------------------------
# These lists mirror professionSourceIcons / Sources.dungeons in ForeverBiS/Core/Sources.lua so the
# "kind" computed here matches the category the addon derived from the free text. A new raid or
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
)

# Extra zone names that only fill `zone` and `boss`; they never change `kind`, so behaviour stays identical.
EXTRA_ZONES = (
    ("gnomeregan", "Gnomeregan"),
    ("the stockade", "The Stockade"),
    ("razorfen kraul", "Razorfen Kraul"),
    ("razorfen downs", "Razorfen Downs"),
    ("scarlet monastery", "Scarlet Monastery"),
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


# --- Phases -------------------------------------------------------------------------------


def phase_from_title(title):
    """Derive the phase of a list from its title.

    NOTE: real phase discovery from ForeverChanges is pending because the page structure after launch is
    unknown; for now the phase comes from the title only ("... at level 30" -> lvl30, otherwise "current").
    """
    match = re.search(r"\bat level\s+(\d+)\s*$", title.strip(), re.I)
    if match:
        level = int(match.group(1))
        return {"id": f"lvl{level}", "label": f"Level {level}", "level": level}
    return {"id": "current", "label": "Current", "level": None}


def collect_phases(data):
    """Sorted union of the phases used by every list: by level, lists without a level last."""
    found = {}
    for phases in data.values():
        for title, _ in phases.values():
            phase = phase_from_title(title)
            found[phase["id"]] = phase
    return sorted_phases(found.values())


def structure_slots(slots):
    """Replace the raw source text of every item by its structured source dict."""
    return [
        (heading, [(name, structure_source(source), itemid) for name, source, itemid in items], enchants)
        for heading, items, enchants in slots
    ]


def fetch():
    """Return (data, labels, phases); raise if any page is missing so the previous file is kept."""
    routes, labels = discover_routes()
    data = {}
    failures = []
    for index, route in enumerate(routes, start=1):
        try:
            title, slots = parse_list(route, download(route))
            if not slots:
                raise RuntimeError("no item slots were found in the page")
            key = route.removeprefix("/bis/")
            data[key] = {phase_from_title(title)["id"]: (title, structure_slots(slots))}
            class_name = route.split("/")[2].replace("-", " ").title()
            build_label = re.sub(rf"\b{re.escape(class_name)}\b", "", title, count=1, flags=re.I).strip()
            build_label = re.sub(r"\s+best in slot at level\s+\d+\s*$", "", build_label, flags=re.I)
            build_label = re.sub(r"\s+", " ", build_label).strip()
            if build_label:
                labels[key] = build_label
            count = sum(len(items) for _, items, _ in slots)
            print(f"[{index}/{len(routes)}] {title}: {count} items")
        except Exception as exc:
            failures.append(f"{route}: {exc}")
        time.sleep(0.35)
    if failures or len(data) != len(routes):
        raise RuntimeError("incomplete download: " + "; ".join(failures))
    return data, labels, collect_phases(data)
