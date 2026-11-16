#!/usr/bin/env python3
"""Download the BiS lists of every source in bis_sources into ForeverBiS_Data_<Source>.lua (schema 3)."""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from bis_sources import SOURCES, select  # noqa: E402
from bis_sources.common import emit_lua, validate  # noqa: E402


ROUTE_KEY = re.compile(r'^    \["([^"]+)"\] = \{$', re.M)


def committed_routes(path):
    """Route keys of an existing source file (the `lists` entries emit_lua writes), empty if it is missing."""
    try:
        return set(ROUTE_KEY.findall(path.read_text(encoding="utf-8")))
    except OSError:
        return set()


def update_source(source, addon_dir, allow_shrink=False):
    """Fetch, validate and atomically write one source file; return the number of lists written."""
    data, labels, phases = source.fetch()
    validate(data)
    destination = addon_dir / source.filename
    missing = sorted(committed_routes(destination) - set(data))
    if missing and not allow_shrink:
        raise ValueError(
            f"it would drop {len(missing)} committed route(s): {', '.join(missing)}; "
            "pass --allow-shrink if that is intended"
        )
    temporary = destination.with_suffix(".lua.tmp")
    temporary.write_text(emit_lua(source.meta, data, labels, phases), encoding="utf-8")
    os.replace(temporary, destination)
    return len(data)


def run(addon_dir, sources, allow_shrink=False):
    """Update every source; a failing one keeps its previous file. Return (succeeded count, failed sources)."""
    succeeded = 0
    failed = []
    for source in sources:
        try:
            count = update_source(source, addon_dir, allow_shrink)
            succeeded += 1
            print(f"Updated {count} lists in {addon_dir / source.filename}")
        except Exception as exc:
            failed.append(source)
            print(f"::warning::{source.label}: update failed, {source.filename} left unchanged ({exc})")
    return succeeded, failed


def shipped_failures(failed):
    return [source for source in failed if source.ship]


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("addon_dir", nargs="?", help="Interface/AddOns/ForeverBiS folder")
    parser.add_argument("--include-unshipped", action="store_true", help="also update sources that are not shipped yet")
    parser.add_argument("--only", action="append", default=[], metavar="ID", help="update just this source (repeatable)")
    parser.add_argument(
        "--allow-shrink",
        action="store_true",
        help="write a source even if it lost a route its committed file has (default: keep the old file and fail it)",
    )
    args = parser.parse_args(argv)
    if args.addon_dir:
        addon_dir = Path(args.addon_dir).expanduser().resolve()
    else:
        print("Enter the path to Interface/AddOns/ForeverBiS (or press Enter to use this folder).")
        entered = input("> ").strip().strip('"')
        addon_dir = Path(entered).expanduser().resolve() if entered else Path(__file__).resolve().parent
    if not addon_dir.is_dir():
        raise SystemExit("That folder does not exist. No files were changed.")
    try:
        sources = select(args.include_unshipped, args.only)
    except ValueError as error:
        raise SystemExit(str(error))
    succeeded, failed = run(addon_dir, sources, args.allow_shrink)
    if succeeded == 0:
        raise SystemExit("Every source failed; no files were changed.")
    print("Restart WoW or run /reload to load the refreshed data.")
    broken = shipped_failures(failed)
    if broken:
        raise SystemExit("Shipped source(s) failed and kept their previous data: " + ", ".join(s.label for s in broken))


if __name__ == "__main__":
    main()
