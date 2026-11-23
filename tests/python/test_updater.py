"""Tests for the multi-source updater: UpdateForeverBiS.py and bis_sources (stdlib only, no network)."""

import contextlib
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import UpdateForeverBiS as cli  # noqa: E402
import bis_sources  # noqa: E402
from bis_sources import common, kamilabs  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures"

META = {"id": "leveling", "label": "ForeverBiS", "order": 0, "url": "https://github.com/wowsims/forever"}
TITLE = "Feral Druid level 30"
SLOTS = [
    (
        "Neck",
        [("Erudite's Amulet", {"kind": "quest", "text": "Quest: Friend of the Library", "quest": "Friend of the Library"}, 1234)],
        [("Agility +5", "Enchant Necklace - Agility", "Enchanting 210: Formula sold by Alynsia.", 249504)],
    ),
    (
        "Hands",
        [("Rough Gloves", {"kind": "profession", "text": "Leatherworking (10)", "skill": "Leatherworking", "skillLevel": 10}, 42)],
        [("Agility +7", "Enchant Gloves - Agility", "Enchanting 210: Taught by the trainer.", None)],
    ),
    (
        "Off hand: shield",
        [("Wooden Buckler", {"kind": "world", "text": "Vendor"}, 44)],
        [("Stamina +3", "Enchant Shield - Minor Stamina", "Enchanting 80: Taught by the trainer.", None)],
    ),
]
LVL30 = {"id": "lvl30", "label": "Level 30", "level": 30}


class EmitLuaTest(unittest.TestCase):
    def setUp(self):
        self.lua = common.emit_lua(META, {"druid/feral": {"lvl30": (TITLE, SLOTS)}}, {"druid/feral": "Feral"}, [LVL30])

    def test_defines_the_schema_3_source_table(self):
        self.assertTrue(
            self.lua.startswith(
                'ForeverBiSData = ForeverBiSData or { schema = 3, sources = {} }\n'
                'ForeverBiSData.sources["leveling"] = {\n'
                '  label = "ForeverBiS",\n  order = 0,\n  url = "https://github.com/wowsims/forever",\n  phases = {\n'
            )
        )
        for legacy in ("ForeverBiSLists", "ForeverBiSItemIDs", "ForeverBiSBuildLabels", "schema = 2"):
            self.assertNotIn(legacy, self.lua)

    def test_emits_the_phase_list_and_the_route_label(self):
        self.assertIn('{ id = "lvl30", label = "Level 30", level = 30 },', self.lua)
        self.assertIn('["druid/feral"] = {\n      label = "Feral",', self.lua)
        self.assertIn('        lvl30 = {\n          title = "Feral Druid level 30",', self.lua)

    def test_writes_one_line_per_item_with_id_and_structured_source(self):
        self.assertIn(
            '{ id = 1234, name = "Erudite\'s Amulet", source = { kind = "quest", '
            'text = "Quest: Friend of the Library", quest = "Friend of the Library" } },',
            self.lua,
        )

    def test_writes_one_line_per_enchant_with_the_formula_id(self):
        self.assertIn(
            '{ effect = "Agility +5", spell = "Enchant Necklace - Agility", '
            'source = "Enchanting 210: Formula sold by Alynsia.", formulaId = 249504 },',
            self.lua,
        )

    def test_omits_the_formula_when_the_enchant_has_none(self):
        self.assertIn(
            '{ effect = "Agility +7", spell = "Enchant Gloves - Agility", source = "Enchanting 210: Taught by the trainer." },',
            self.lua,
        )

    def test_writes_an_enchants_block_per_slot_that_has_enchants(self):
        slot = self.lua.split('{ slot = "Off hand: shield",')[1]
        self.assertIn('effect = "Stamina +3"', slot)
        self.assertEqual(3, self.lua.count("enchants = {"))

    def test_omits_the_id_when_unknown(self):
        slots = [("Slot", [("Plain", {"kind": "world", "text": "Vendor"}, None)], [])]
        lua = common.emit_lua(META, {"x": {"current": ("X", slots)}}, {}, [{"id": "current", "label": "Current", "level": None}])
        self.assertIn('{ name = "Plain", source = { kind = "world", text = "Vendor" } },', lua)
        self.assertNotIn("label =", lua.split("lists")[1])
        self.assertNotIn("enchants", lua)
        self.assertIn('{ id = "current", label = "Current" },', lua)

    def test_escapes_quotes_in_lua_strings(self):
        self.assertEqual('"say \\"hi\\""', common.lua_quote('say "hi"'))


def kami_payload():
    return json.loads((FIXTURES / "kami_tier60.json").read_text(encoding="utf-8"))


class KamiLabsTest(unittest.TestCase):
    def setUp(self):
        self.lists = kamilabs.build_lists("60-preraid", kami_payload())
        self.slots = {name: (items, enchants) for name, items, enchants in self.lists["warrior/arms"][2]}

    def test_discovers_tier_urls_from_the_data_tiers_attribute(self):
        page = (FIXTURES / "kami_page.html").read_text(encoding="utf-8")
        tiers = kamilabs.discover_tiers(page)
        self.assertEqual(["30", "60-preraid"], [key for key, _ in tiers])
        self.assertTrue(tiers[1][1].startswith("https://kami-labs.fr/") and "forever-bis-60-preraid.json?v=" in tiers[1][1])

    def test_missing_data_tiers_is_an_error(self):
        with self.assertRaises(RuntimeError):
            kamilabs.discover_tiers("<html></html>")

    def test_maps_the_slug_to_a_route_label_and_title(self):
        self.assertEqual(["mage/fire", "warrior/arms", "warrior/protection"], sorted(self.lists))
        self.assertEqual(("Arms", "Arms Warrior at level 60 (pre-raid)"), self.lists["warrior/arms"][:2])
        self.assertEqual("Fire Mage at level 60 (pre-raid)", self.lists["mage/fire"][1])

    def test_titles_the_level_30_tier(self):
        self.assertEqual("Arms Warrior at level 30", kamilabs.build_lists("30", kami_payload())["warrior/arms"][1])

    def test_rings_and_trinkets_are_one_slot_with_two_items(self):
        self.assertEqual([18500, 17713], [item[2] for item in self.slots["Finger"][0]])
        self.assertEqual(2, len(self.slots["Trinket"][0]))

    def test_weapon_slot_labels_follow_the_item_type(self):
        self.assertIn("Two-hand weapon", self.slots)
        self.assertNotIn("Main hand", self.slots)
        protection = [name for name, _, _ in self.lists["warrior/protection"][2]]
        self.assertIn("Main hand", protection)
        self.assertIn("Off hand: shield", protection)
        self.assertIn("Off hand: held item", [name for name, _, _ in self.lists["mage/fire"][2]])

    def test_slot_labels_match_the_model_aliases(self):
        allowed = {"Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger", "Trinket",
                   "Main hand", "Two-hand weapon", "Off hand: shield", "Off hand: held item", "Ranged"}  # fmt: skip
        for _, _, slots in self.lists.values():
            self.assertLessEqual({name for name, _, _ in slots}, allowed)

    def test_maps_a_craft_source(self):
        source = self.slots["Head"][0][0][1]
        self.assertEqual({"kind": "profession", "text": "Blacksmithing (300)", "skill": "Blacksmithing", "skillLevel": 300}, source)

    def test_maps_a_quest_source(self):
        source = self.slots["Neck"][0][0][1]
        self.assertEqual("quest", source["kind"])
        self.assertEqual("Falrin's Vendetta", source["quest"])
        self.assertTrue(source["text"].startswith("Quest: Falrin's Vendetta"))

    def test_maps_a_boss_source_with_zone_and_percent_drop_rate(self):
        source = self.slots["Chest"][0][0][1]
        self.assertEqual("dungeon", source["kind"])
        self.assertTrue(source["boss"] and source["zone"])
        self.assertIn(source["boss"], source["text"])
        self.assertNotIn("dropRate", source)

    def test_boss_drop_rate_is_kept_as_a_percent(self):
        entry = {"k": "boss", "i": "scarlet-monastery", "n": {"en": "Bloodmage Thalnos"}, "p": 48.8}
        source = kamilabs.map_entry(entry, kami_payload())
        self.assertEqual((48.8, "Bloodmage Thalnos", "Scarlet Monastery"), (source["dropRate"], source["boss"], source["zone"]))
        self.assertIn("48.8%", source["text"])

    def test_maps_a_vendor_source_to_world_with_faction(self):
        source = self.slots["Shoulder"][0][0][1]
        self.assertEqual(("world", "Alliance", "Arathi Highlands"), (source["kind"], source["faction"], source["zone"]))

    def test_unknown_source_kinds_become_unknown(self):
        self.assertEqual("unknown", kamilabs.source_of({"src": [{"k": "mystery"}]}, kami_payload())["kind"])
        self.assertEqual("unknown", kamilabs.source_of({"src": []}, kami_payload())["kind"])

    def test_every_item_has_a_valid_kind_and_text(self):
        data = {route: {"lvl60": (title, slots)} for route, (_, title, slots) in self.lists.items()}
        common.validate(data)

    def test_enchants_use_the_enchant_table_names(self):
        self.assertEqual(("Strength", "Enchant Necklace - Strength", "", None), self.slots["Neck"][1][0])
        self.assertEqual([], self.slots["Head"][1])

    def test_fetch_builds_one_phase_per_known_tier_and_skips_unknown_ones(self):
        page = (FIXTURES / "kami_page.html").read_text(encoding="utf-8")
        page = page.replace("forever-bis-30.json", "forever-bis-xx.json").replace("&quot;key&quot;:&quot;30&quot;", "&quot;key&quot;:&quot;99&quot;")
        with contextlib.redirect_stdout(io.StringIO()):
            data, labels, phases = kamilabs.fetch(lambda *_: page, lambda url: kami_payload())
        self.assertEqual(["lvl60"], [phase["id"] for phase in phases])
        self.assertEqual({"lvl60"}, set(data["warrior/arms"]))
        self.assertEqual("Arms", labels["warrior/arms"])


class RegistryTest(unittest.TestCase):
    def test_registry_matches_the_contract(self):
        rows = [(s.id, s.file_name, s.label, s.order, s.ship) for s in bis_sources.SOURCES]
        self.assertEqual(
            [
                ("leveling", "Leveling", "ForeverBiS", 0, True),
                ("kamilabs", "KamiLabs", "Kami Labs", 2, False),
            ],
            rows,
        )
        self.assertEqual("ForeverBiS_Data_KamiLabs.lua", bis_sources.SOURCES[1].filename)

    def test_unshipped_sources_need_the_flag(self):
        self.assertEqual(["leveling"], [s.id for s in bis_sources.select()])
        self.assertEqual(["leveling", "kamilabs"], [s.id for s in bis_sources.select(include_unshipped=True)])

    def test_only_narrows_the_selection_and_rejects_unknown_ids(self):
        self.assertEqual(["kamilabs"], [s.id for s in bis_sources.select(only=["kamilabs"])])
        with self.assertRaises(ValueError):
            bis_sources.select(only=["nope"])


def fake_source(source_id, file_name, order, fetch):
    return bis_sources.Source(source_id, file_name, source_id.title(), order, "https://example.test", True, fetch)


def good_fetch():
    slots = [("Head", [("Helm", {"kind": "world", "text": "Vendor"}, 1)], [])]
    return {"warrior/arms": {"lvl30": ("Arms", slots)}}, {"warrior/arms": "Arms"}, [{"id": "lvl30", "label": "Level 30", "level": 30}]


def broken_fetch():
    raise RuntimeError("site down")


class FailureGuardTest(unittest.TestCase):
    def run_sources(self, sources, directory, allow_shrink=False):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            succeeded, failed = cli.run(Path(directory), sources, allow_shrink=allow_shrink)
        self.failed = failed
        return succeeded, out.getvalue()

    def test_a_failing_source_keeps_its_file_and_the_others_are_written(self):
        with tempfile.TemporaryDirectory() as directory:
            old = Path(directory, "ForeverBiS_Data_Bad.lua")
            old.write_text("previous", encoding="utf-8")
            succeeded, output = self.run_sources(
                [fake_source("bad", "Bad", 1, broken_fetch), fake_source("good", "Good", 2, good_fetch)], directory
            )
            self.assertEqual(1, succeeded)
            self.assertEqual(["Bad"], [source.label for source in self.failed])
            self.assertEqual("previous", old.read_text(encoding="utf-8"))
            self.assertIn("::warning::", output)
            self.assertTrue(Path(directory, "ForeverBiS_Data_Good.lua").read_text(encoding="utf-8").startswith("ForeverBiSData = "))
            self.assertEqual(["ForeverBiS_Data_Bad.lua", "ForeverBiS_Data_Good.lua"], sorted(p.name for p in Path(directory).iterdir()))

    def test_invalid_data_is_treated_as_a_failure(self):
        def wrong_class():
            data, labels, phases = good_fetch()
            return {"death-knight/blood": data["warrior/arms"]}, labels, phases

        with tempfile.TemporaryDirectory() as directory:
            succeeded, output = self.run_sources([fake_source("odd", "Odd", 1, wrong_class)], directory)
            self.assertEqual(0, succeeded)
            self.assertIn("class key", output)
            self.assertEqual([], list(Path(directory).iterdir()))

    def test_exits_with_an_error_only_when_every_source_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            for sources, expected in (([fake_source("bad", "Bad", 1, broken_fetch)], 0), ([fake_source("good", "Good", 1, good_fetch)], 1)):
                self.assertEqual(expected, self.run_sources(sources, directory)[0])

    def test_shipped_failures_are_reported_but_unshipped_ones_are_not(self):
        unshipped = bis_sources.Source("kami", "Kami", "Kami", 1, "https://example.test", False, broken_fetch)
        with tempfile.TemporaryDirectory() as directory:
            self.run_sources([unshipped, fake_source("good", "Good", 2, good_fetch)], directory)
            self.assertEqual([unshipped], self.failed)
            self.assertEqual([], cli.shipped_failures(self.failed))
            self.run_sources([fake_source("bad", "Bad", 3, broken_fetch)], directory)
            self.assertEqual(["Bad"], [s.label for s in cli.shipped_failures(self.failed)])

    def test_emission_is_deterministic(self):
        with tempfile.TemporaryDirectory() as directory:
            source = fake_source("good", "Good", 1, good_fetch)
            self.run_sources([source], directory)
            first = Path(directory, "ForeverBiS_Data_Good.lua").read_bytes()
            self.run_sources([source], directory)
            self.assertEqual(first, Path(directory, "ForeverBiS_Data_Good.lua").read_bytes())


def run_main(argv):
    out = io.StringIO()
    code = 0
    with contextlib.redirect_stdout(out):
        try:
            cli.main(argv)
        except SystemExit as exit_:
            code = exit_.code if exit_.code not in (None, 0) else 0
    return code, out.getvalue()


class ExitCodeTest(unittest.TestCase):
    def patched(self, sources):
        original = cli.select
        cli.select = lambda *_: sources
        self.addCleanup(setattr, cli, "select", original)

    def test_exits_non_zero_when_a_shipped_source_failed_but_still_writes_the_others(self):
        self.patched([fake_source("bad", "Bad", 1, broken_fetch), fake_source("good", "Good", 2, good_fetch)])
        with tempfile.TemporaryDirectory() as directory:
            code, output = run_main([directory])
            self.assertNotEqual(0, code)
            self.assertTrue(Path(directory, "ForeverBiS_Data_Good.lua").is_file())
            self.assertIn("Bad", str(code) + output)

    def test_exits_zero_when_every_shipped_source_succeeded(self):
        self.patched([fake_source("good", "Good", 1, good_fetch)])
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(0, run_main([directory])[0])

    def test_allow_shrink_flag_is_documented_and_accepted(self):
        out = io.StringIO()
        with contextlib.redirect_stdout(out), self.assertRaises(SystemExit):
            cli.main(["--help"])
        self.assertIn("--allow-shrink", out.getvalue())


def two_routes_fetch():
    data, labels, phases = good_fetch()
    data["warrior/fury"] = data["warrior/arms"]
    return data, labels, phases


class ShrinkGuardTest(unittest.TestCase):
    def write_committed(self, directory):
        source = fake_source("shrink", "Shrink", 1, two_routes_fetch)
        data, labels, phases = two_routes_fetch()
        path = Path(directory, source.filename)
        path.write_text(common.emit_lua(source.meta, data, labels, phases), encoding="utf-8")
        return path

    def run_shrunk(self, directory, allow_shrink):
        out = io.StringIO()
        shrunk = fake_source("shrink", "Shrink", 1, good_fetch)
        with contextlib.redirect_stdout(out):
            succeeded, failed = cli.run(Path(directory), [shrunk], allow_shrink=allow_shrink)
        return succeeded, failed, out.getvalue()

    def test_reads_the_committed_route_keys(self):
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_committed(directory)
            self.assertEqual({"warrior/arms", "warrior/fury"}, cli.committed_routes(path))
            self.assertEqual(set(), cli.committed_routes(Path(directory, "missing.lua")))

    def test_a_disappearing_route_fails_the_source_and_keeps_the_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_committed(directory)
            before = path.read_bytes()
            succeeded, failed, output = self.run_shrunk(directory, allow_shrink=False)
            self.assertEqual(0, succeeded)
            self.assertEqual(1, len(failed))
            self.assertEqual(before, path.read_bytes())
            self.assertIn("::warning::", output)
            self.assertIn("warrior/fury", output)
            self.assertIn("--allow-shrink", output)
            self.assertFalse(Path(directory, "ForeverBiS_Data_Shrink.lua.tmp").exists())

    def test_allow_shrink_writes_the_smaller_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_committed(directory)
            succeeded, failed, _ = self.run_shrunk(directory, allow_shrink=True)
            self.assertEqual((1, []), (succeeded, failed))
            self.assertEqual({"warrior/arms"}, cli.committed_routes(path))

    def test_growing_or_equal_route_sets_are_written(self):
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_committed(directory)
            out = io.StringIO()
            with contextlib.redirect_stdout(out):
                succeeded, failed = cli.run(Path(directory), [fake_source("shrink", "Shrink", 1, two_routes_fetch)])
            self.assertEqual((1, []), (succeeded, failed))
            self.assertEqual({"warrior/arms", "warrior/fury"}, cli.committed_routes(path))


class TocTest(unittest.TestCase):
    def test_every_shipped_source_is_loaded_before_the_model(self):
        toc = (Path(__file__).resolve().parents[2] / "ForeverBiS" / "ForeverBiS.toc").read_text(encoding="utf-8")
        files = [line.strip().replace("\\", "/") for line in toc.splitlines() if line.strip() and not line.startswith("#")]
        self.assertIn("ForeverBiS_Model.lua", files)
        model = files.index("ForeverBiS_Model.lua")
        for source in bis_sources.SOURCES:
            if source.ship:
                self.assertIn(source.filename, files, source.id)
                self.assertLess(files.index(source.filename), model, source.id)


if __name__ == "__main__":
    unittest.main()
