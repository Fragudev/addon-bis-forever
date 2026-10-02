#!/usr/bin/env python3
"""Download the current ForeverChanges BiS lists into ForeverBiS_Data.lua."""

from __future__ import annotations

import os
import re
import sys
import time
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from pathlib import Path

BASE = "https://foreverchanges.pro"
USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/140.0.0.0 Safari/537.36"
)


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
    request = urllib.request.Request(
        urllib.parse.urljoin(BASE, path),
        headers={"User-Agent": USER_AGENT, "Accept": "text/html", "Accept-Language": "en-US,en;q=0.9"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        if response.status != 200:
            raise RuntimeError(f"HTTP {response.status} for {path}")
        return response.read().decode("utf-8", errors="replace")


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


def lua_quote(value):
    value = str(value or "")
    value = value.replace("\\", "\\\\").replace('"', '\\"')
    value = value.replace("\r", " ").replace("\n", " ")
    return '"' + value + '"'


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


def emit_lua(data, labels):
    lines = ["ForeverBiSLists = {"]
    item_ids = {}
    for route, (title, slots) in sorted(data.items()):
        key = route.removeprefix("/bis/")
        lines.append(f"  [{lua_quote(key)}] = {{ title = {lua_quote(title)}, slots = {{")
        for slot_name, items, enchants in slots:
            lines.append(f"    {{{lua_quote(slot_name)}, {{")
            for name, source, itemid in items:
                lines.append(f"      {{{lua_quote(name)}, {lua_quote(source)}}},")
                if itemid:
                    item_ids[name] = itemid
            if enchants:
                lines.append("    }, {")
                for effect, spell, source, formula in enchants:
                    formula_part = f", {formula}" if formula else ""
                    lines.append(f"      {{{lua_quote(effect)}, {lua_quote(spell)}, {lua_quote(source)}{formula_part}}},")
            lines.append("    }},")
        lines.append("  }},")
    lines.append("}")
    lines.append("ForeverBiSItemIDs = {")
    for name, itemid in sorted(item_ids.items()):
        lines.append(f"  [{lua_quote(name)}] = {itemid},")
    lines.append("}")
    lines.append("ForeverBiSBuildLabels = {")
    for route, label in sorted(labels.items()):
        lines.append(f"  [{lua_quote(route)}] = {lua_quote(label)},")
    lines.append("}")
    return "\n".join(lines) + "\n"


def main():
    if len(sys.argv) > 1:
        addon_dir = Path(sys.argv[1]).expanduser().resolve()
    else:
        print("Enter the path to Interface/AddOns/ForeverBiS (or press Enter to use this folder).")
        entered = input("> ").strip().strip('"')
        addon_dir = Path(entered).expanduser().resolve() if entered else Path(__file__).resolve().parent
    if not addon_dir.is_dir() or not (addon_dir / "ForeverBiS.toc").is_file():
        raise SystemExit("That folder does not contain ForeverBiS.toc. No files were changed.")

    routes, labels = discover_routes()
    data = {}
    failures = []
    for index, route in enumerate(routes, start=1):
        try:
            html = download(route)
            title, slots = parse_list(route, html)
            if not slots:
                raise RuntimeError("no item slots were found in the page")
            data[route] = (title, slots)
            class_name = route.split("/")[2].replace("-", " ").title()
            build_label = re.sub(rf"\b{re.escape(class_name)}\b", "", title, count=1, flags=re.I).strip()
            build_label = re.sub(r"\s+best in slot at level\s+\d+\s*$", "", build_label, flags=re.I)
            build_label = re.sub(r"\s+", " ", build_label).strip()
            if build_label:
                labels[route.removeprefix("/bis/")] = build_label
            count = sum(len(items) for _, items, _ in slots)
            print(f"[{index}/{len(routes)}] {title}: {count} items")
        except Exception as exc:
            failures.append(f"{route}: {exc}")
        time.sleep(0.35)

    if failures or len(data) != len(routes):
        print("Update cancelled; the existing data file was left unchanged.")
        for failure in failures:
            print(" - " + failure)
        raise SystemExit(1)

    destination = addon_dir / "ForeverBiS_Data.lua"
    temporary = destination.with_suffix(".lua.tmp")
    temporary.write_text(emit_lua(data, labels), encoding="utf-8")
    os.replace(temporary, destination)
    print(f"Updated {len(data)} lists in {destination}")
    print("Restart WoW or run /reload to load the refreshed data.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"Update failed: {error}")
        raise SystemExit(1)
