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
from bis_sources import common, kamilabs, wowsims  # noqa: E402
from bis_sources import foreverchanges as updater  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures"

PAGE = """
<html><body><h1>Feral Druid PvE best in slot at level 30</h1>
<section class="bis-slot" id="neck"><h2>Neck</h2><ol>
  <li class="bis-row"><a class="bis-name" href="/item/1234">Erudite's Amulet</a>
    <div class="bis-from">Quest: Friend of the Library</div></li>
</ol></section>
<section class="bis-slot" id="hands"><h2>Hands</h2><ol>
  <li class="bis-row"><a class="bis-name" href="/item/42">Rough Gloves</a>
    <div class="bis-from">Leatherworking (10)</div></li>
</ol></section>
<section class="bis-slot" id="legs"><h2>Legs</h2><ol>
  <li class="bis-row"><a class="bis-name" href="/item/43">Rough Pants</a>
    <div class="bis-from">Tailoring (10)</div></li>
</ol></section>
<section class="bis-slot" id="off"><h2>Off hand: shield</h2><ol>
  <li class="bis-row"><a class="bis-name" href="/item/44">Wooden Buckler</a>
    <div class="bis-from">Vendor</div></li>
</ol></section>
<section class="bis-slot bis-enchants" id="enchants"><h2>Enchants</h2><ol>
  <li class="bis-row bis-enchant-row"><img src="/icon/trade_engraving.jpg" alt=""/>
    <div class="bis-name-cell"><small class="bis-enchant-slots">Neck</small>
      <p class="bis-enchant-line">Enchanted: Agility +5</p></div>
    <div class="bis-from"><p><a href="/item/249504" data-tip="249504">Enchant Necklace - Agility</a> <!-- -->(Enchanting 210)<span>F<!-- -->ormula sold by Alynsia<!-- -->.</span></p></div></li>
  <li class="bis-row bis-enchant-row"><img src="/icon/trade_engraving.jpg" alt=""/>
    <div class="bis-name-cell"><small class="bis-enchant-slots">Hands, Legs</small>
      <p class="bis-enchant-line">Enchanted: Agility +7</p></div>
    <div class="bis-from"><p><b>Enchant Gloves - Agility</b> <!-- -->(Enchanting 210)<span>T<!-- -->aught by the trainer<!-- -->.</span></p></div></li>
  <li class="bis-row bis-enchant-row"><img src="/icon/trade_engraving.jpg" alt=""/>
    <div class="bis-name-cell"><small class="bis-enchant-slots">Off hand: shield</small>
      <p class="bis-enchant-line">Enchanted: Stamina +3</p></div>
    <div class="bis-from"><p><b>Enchant Shield - Minor Stamina</b> <!-- -->(Enchanting 80)<span>T<!-- -->aught by the trainer<!-- -->.</span></p></div></li>
</ol></section>
</body></html>
"""


class ParseEnchantsTest(unittest.TestCase):
    def setUp(self):
        self.enchants = updater.parse_enchants(updater.parse_page(PAGE))

    def test_reads_every_enchant_row(self):
        self.assertEqual(3, len(self.enchants))

    def test_strips_the_enchanted_prefix_from_the_effect(self):
        self.assertEqual("Agility +5", self.enchants[0][1])

    def test_reads_spell_name_requirement_and_formula_id_from_a_linked_row(self):
        label, effect, spell, source, formula = self.enchants[0]
        self.assertEqual("Neck", label)
        self.assertEqual("Enchant Necklace - Agility", spell)
        self.assertEqual("Enchanting 210: Formula sold by Alynsia.", source)
        self.assertEqual(249504, formula)

    def test_reads_a_trainer_row_without_a_formula(self):
        _, _, spell, source, formula = self.enchants[1]
        self.assertEqual("Enchant Gloves - Agility", spell)
        self.assertEqual("Enchanting 210: Taught by the trainer.", source)
        self.assertIsNone(formula)

    def test_ignores_pages_without_an_enchants_section(self):
        self.assertEqual([], updater.parse_enchants(updater.parse_page("<html><body><h1>x</h1></body></html>")))


class EnchantTargetsTest(unittest.TestCase):
    HEADINGS = ["Neck", "Hands", "Legs", "Main hand", "Off hand: shield", "Two-hand weapon"]

    def test_matches_an_exact_heading(self):
        self.assertEqual(["Neck"], updater.enchant_targets("Neck", self.HEADINGS))

    def test_splits_a_comma_separated_label(self):
        self.assertEqual(["Hands", "Legs"], updater.enchant_targets("Hands, Legs", self.HEADINGS))

    def test_prefers_a_literal_heading_over_splitting(self):
        self.assertEqual(["Two-hand weapon"], updater.enchant_targets("Two-hand weapon", self.HEADINGS))

    def test_matches_a_heading_with_a_qualifier(self):
        self.assertEqual(["Main hand", "Off hand: shield"], updater.enchant_targets("Main hand, Off hand", self.HEADINGS))

    def test_returns_nothing_for_an_unknown_slot(self):
        self.assertEqual([], updater.enchant_targets("Tabard", self.HEADINGS))


class ParseListTest(unittest.TestCase):
    def setUp(self):
        self.title, self.sections = updater.parse_list("/bis/druid", PAGE)
        self.by_slot = {heading: (items, enchants) for heading, items, enchants in self.sections}

    def test_reads_the_title_and_every_item_slot(self):
        self.assertEqual("Feral Druid PvE best in slot at level 30", self.title)
        self.assertEqual(["Neck", "Hands", "Legs", "Off hand: shield"], [s[0] for s in self.sections])

    def test_does_not_treat_the_enchants_section_as_a_slot(self):
        self.assertNotIn("Enchants", self.by_slot)

    def test_attaches_enchants_to_their_slots(self):
        self.assertEqual(1, len(self.by_slot["Neck"][1]))
        self.assertEqual(1, len(self.by_slot["Hands"][1]))
        self.assertEqual(1, len(self.by_slot["Legs"][1]))
        self.assertEqual("Stamina +3", self.by_slot["Off hand: shield"][1][0][0])

    def test_keeps_the_item_name_source_and_id(self):
        self.assertEqual(("Erudite's Amulet", "Quest: Friend of the Library", 1234), self.by_slot["Neck"][0][0])


class PhaseFromTitleTest(unittest.TestCase):
    def test_reads_the_level_from_the_title(self):
        self.assertEqual(
            {"id": "lvl30", "label": "Level 30", "level": 30},
            updater.phase_from_title("Feral Druid PvE best in slot at level 30"),
        )

    def test_reads_a_different_level(self):
        self.assertEqual("lvl60", updater.phase_from_title("Mage PvP best in slot at level 60")["id"])

    def test_falls_back_to_the_current_phase_without_a_level(self):
        self.assertEqual(
            {"id": "current", "label": "Current", "level": None},
            updater.phase_from_title("Mage PvE best in slot"),
        )

    def test_collects_phases_by_level_with_levelless_ones_last(self):
        data = {
            "/bis/a": {"lvl60": ("A at level 60", []), "current": ("A best in slot", [])},
            "/bis/b": {"lvl30": ("B at level 30", [])},
        }
        self.assertEqual(["lvl30", "lvl60", "current"], [p["id"] for p in updater.collect_phases(data)])


class StructureSourceTest(unittest.TestCase):
    def test_keeps_the_raw_text(self):
        text = "Quest: Friend of the Library Ten books"
        self.assertEqual(text, updater.structure_source(text)["text"])

    def test_classifies_a_quest_and_extracts_its_name(self):
        source = updater.structure_source("Quest: Bartolo's Yeti Fur Cloak \u2197 Alliance, level 34 in Classic")
        self.assertEqual("quest", source["kind"])
        self.assertEqual("Bartolo's Yeti Fur Cloak", source["quest"])
        self.assertEqual("Alliance", source["faction"])

    def test_classifies_a_profession_with_skill_and_level(self):
        source = updater.structure_source("Leatherworking (100) Only its maker can wear it")
        self.assertEqual("profession", source["kind"])
        self.assertEqual("Leatherworking", source["skill"])
        self.assertEqual(100, source["skillLevel"])
        self.assertTrue(source["bindsToMaker"])

    def test_profession_without_a_level_has_no_skill_level(self):
        source = updater.structure_source("Leatherworking")
        self.assertEqual("Leatherworking", source["skill"])
        self.assertNotIn("skillLevel", source)

    def test_classifies_a_dungeon_with_boss_zone_and_drop_rate(self):
        source = updater.structure_source("Archmage Arugal, Shadowfang Keep 34.05% in Classic")
        self.assertEqual("dungeon", source["kind"])
        self.assertEqual("Shadowfang Keep", source["zone"])
        self.assertEqual("Archmage Arugal", source["boss"])
        self.assertEqual(34.05, source["dropRate"])

    def test_a_zone_outside_the_dungeon_list_keeps_the_world_kind(self):
        source = updater.structure_source("Crowd Pummeler 9-60, Gnomeregan")
        self.assertEqual("world", source["kind"])
        self.assertEqual("Gnomeregan", source["zone"])
        self.assertEqual("Crowd Pummeler 9-60", source["boss"])

    def test_classifies_a_world_drop_and_flags_it_as_reported(self):
        source = updater.structure_source("A world drop, not bound: the auction house is quickest Reported, not checked")
        self.assertEqual("world", source["kind"])
        self.assertTrue(source["reported"])
        self.assertNotIn("zone", source)
        self.assertNotIn("boss", source)

    def test_classifies_unknown_sources(self):
        source = updater.structure_source("Where it comes from is not known yet Nothing places it yet")
        self.assertEqual({"kind": "unknown", "text": source["text"]}, source)

    def test_detects_a_horde_exclusive_source_but_not_a_shared_one(self):
        self.assertEqual("Horde", updater.structure_source("Horde quest The Book of Ur")["faction"])
        self.assertNotIn("faction", updater.structure_source("Quest: Both Horde and Alliance"))


FC_META = {"id": "foreverchanges", "label": "ForeverChanges", "order": 1, "url": "https://foreverchanges.pro"}


def emit(data, labels):
    data = {
        route: {pid: (title, updater.structure_slots(slots)) for pid, (title, slots) in phases.items()}
        for route, phases in data.items()
    }
    return common.emit_lua(FC_META, data, labels, updater.collect_phases(data))


class EmitLuaTest(unittest.TestCase):
    def setUp(self):
        title, slots = updater.parse_list("/bis/druid", PAGE)
        data = {"druid": {updater.phase_from_title(title)["id"]: (title, slots)}}
        self.lua = emit(data, {"druid": "Feral PvE"})

    def test_defines_the_schema_3_source_table(self):
        self.assertTrue(
            self.lua.startswith(
                'ForeverBiSData = ForeverBiSData or { schema = 3, sources = {} }\n'
                'ForeverBiSData.sources["foreverchanges"] = {\n'
                '  label = "ForeverChanges",\n  order = 1,\n  url = "https://foreverchanges.pro",\n  phases = {\n'
            )
        )
        for legacy in ("ForeverBiSLists", "ForeverBiSItemIDs", "ForeverBiSBuildLabels", "schema = 2"):
            self.assertNotIn(legacy, self.lua)

    def test_emits_the_phase_list_and_the_route_label(self):
        self.assertIn('{ id = "lvl30", label = "Level 30", level = 30 },', self.lua)
        self.assertIn('["druid"] = {\n      label = "Feral PvE",', self.lua)
        self.assertIn("        lvl30 = {\n          title = \"Feral Druid PvE best in slot at level 30\",", self.lua)

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
        self.assertEqual(4, self.lua.count("enchants = {"))

    def test_omits_the_id_when_unknown(self):
        data = {"x": {"current": ("X", [("Slot", [("Plain", "Vendor", None)], [])])}}
        lua = emit(data, {})
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


class WowsimsMappingTest(unittest.TestCase):
    def map(self, path):
        return wowsims.map_preset(f"ui/specs/{path}.gear.json")

    def test_maps_routes_and_phases(self):
        cases = {
            "warrior/dps/gear_sets/p1_arms": ("warrior/arms", "raid1"),
            "warrior/dps/gear_sets/prebis_fury": ("warrior/fury", "lvl60"),
            "warrior/protection/gear_sets/p1_bis": ("warrior/tank", "raid1"),
            "druid/feralbear/gear_sets/default": ("druid/tank", "raid1"),
            "druid/feralcat/gear_sets/pre_raid": ("druid/feral", "lvl60"),
            "paladin/retribution/gear_sets/holy_shock": ("paladin/shockadin", "raid1"),
            "paladin/retribution/gear_sets/default": ("paladin/retribution", "raid1"),
            "rogue/dps/gear_sets/p1_muti": ("rogue/assassination", "raid1"),
            "rogue/dps/gear_sets/p1_bscombat": ("rogue/combat", "raid1"),
            "rogue/dps/gear_sets/p1_bssub": ("rogue/subtlety", "raid1"),
            "mage/dps/gear_sets/p1Arcane": ("mage/arcane", "raid1"),
            "priest/healer/gear_sets/preraid": ("priest/holy", "lvl60"),
            "hunter/dps/gear_sets/p1_melee": ("hunter/melee", "raid1"),
        }
        for path, (route, phase) in cases.items():
            mapped = self.map(path)
            self.assertEqual((route, phase), (mapped[0], mapped[2]), path)

    def test_skips_item_swaps_unknown_variants_and_unknown_specs(self):
        for path in (
            "paladin/retribution/gear_sets/holy_shock_item_swap",
            "rogue/dps/gear_sets/p1_slowmh",
            "warrior/dps/gear_sets/p1",
            "shaman/dps/gear_sets/p1",
        ):
            self.assertIsNone(self.map(path), path)

    def test_every_route_starts_with_a_class_key(self):
        for variants in wowsims.ROUTES.values():
            for target in variants.values():
                if target:
                    self.assertIn(target[0].split("/")[0], common.CLASS_KEYS)

    def test_prefers_the_plain_prebis_over_variants_and_preraid(self):
        paths = [f"warrior/protection/gear_sets/{name}" for name in ("preraid", "prebis_threat", "prebis")]
        best = min(paths, key=lambda path: self.map(path)[3])
        self.assertTrue(best.endswith("/prebis"))

    def test_phase_ids_are_the_declared_ones(self):
        self.assertEqual({"lvl60", "raid1"}, set(wowsims.PHASES))
        self.assertNotIn("level", wowsims.RAID_1)


class WowsimsSlotsTest(unittest.TestCase):
    ITEMS = {
        1: {"name": "Helm"},
        2: {"name": "Ring A"},
        3: {"name": "Ring B"},
        4: {"name": "Great Axe", "handType": 4},
        5: {"name": "Sword", "handType": 2},
        6: {"name": "Buckler", "weaponType": 7},
        7: {"name": "Tome", "weaponType": 5},
    }
    ENCHANTS = {100: {"name": "Enchant Weapon - Crusader"}}

    def slots(self, entries):
        return wowsims.build_slots({"items": entries}, self.ITEMS, self.ENCHANTS)

    def test_follows_the_itemslot_order_and_merges_rings(self):
        entries = [{"id": 1}] + [{}] * 9 + [{"id": 2}, {"id": 3}]
        slots = self.slots(entries)
        self.assertEqual(["Head", "Finger"], [slot[0] for slot in slots])
        self.assertEqual([2, 3], [item[2] for item in slots[1][1]])

    def test_slot_order_matches_the_proto(self):
        self.assertEqual(17, len(wowsims.ITEM_SLOTS))
        self.assertEqual(["Finger", "Finger", "Trinket", "Trinket", "Main hand", "Off hand", "Ranged"], list(wowsims.ITEM_SLOTS[10:]))

    def test_weapon_labels_follow_the_hand_and_weapon_type(self):
        blank = [{}] * 14
        self.assertEqual("Two-hand weapon", self.slots(blank + [{"id": 4}])[0][0])
        self.assertEqual("Main hand", self.slots(blank + [{"id": 5}])[0][0])
        self.assertEqual("Off hand: shield", self.slots(blank + [{"id": 5}, {"id": 6}])[1][0])
        self.assertEqual("Off hand: held item", self.slots(blank + [{"id": 5}, {"id": 7}])[1][0])

    def test_handles_short_lists_empty_entries_and_unknown_ids(self):
        slots = self.slots([{"id": 999}, {}])
        self.assertEqual([("Head", [("Item 999", wowsims.NO_SOURCE, 999)], [])], slots)

    def test_reads_enchant_effect_ids(self):
        slots = self.slots([{}] * 14 + [{"id": 5, "enchant": 100}])
        self.assertEqual([("Crusader", "Enchant Weapon - Crusader", "", None)], slots[0][2])
        self.assertEqual([], self.slots([{"id": 1, "enchant": 12345}])[0][2])

    def test_items_have_an_unknown_source(self):
        self.assertEqual({"kind": "unknown", "text": "Source not listed by wowsims"}, self.slots([{"id": 1}])[0][1][0][1])

    def test_fetch_picks_one_preset_per_route_and_phase(self):
        paths = [
            "ui/specs/warrior/protection/gear_sets/prebis.gear.json",
            "ui/specs/warrior/protection/gear_sets/prebis_threat.gear.json",
            "ui/specs/warrior/protection/gear_sets/p1_bis.gear.json",
            "ui/specs/rogue/dps/gear_sets/p1_slowmh.gear.json",
        ]
        requested = []

        def get_json(url, headers=None):
            if url == wowsims.TREE_URL:
                return {"tree": [{"path": path} for path in paths]}
            if url.endswith(wowsims.DB_PATH):
                return {"items": [{"id": 1, "name": "Helm"}], "enchants": []}
            requested.append(url.removeprefix(wowsims.RAW_URL))
            return {"items": [{"id": 1}]}

        with contextlib.redirect_stdout(io.StringIO()):
            data, labels, phases = wowsims.fetch(get_json=get_json)
        self.assertEqual(["warrior/tank"], list(data))
        self.assertEqual({"lvl60", "raid1"}, set(data["warrior/tank"]))
        self.assertEqual(["ui/specs/warrior/protection/gear_sets/p1_bis.gear.json", "ui/specs/warrior/protection/gear_sets/prebis.gear.json"], sorted(requested))
        self.assertEqual(["lvl60", "raid1"], [phase["id"] for phase in phases])
        self.assertEqual("wowsims Protection Warrior preset (pre-raid)", data["warrior/tank"]["lvl60"][0])


class RegistryTest(unittest.TestCase):
    def test_registry_matches_the_contract(self):
        rows = [(s.id, s.file_name, s.label, s.order, s.ship) for s in bis_sources.SOURCES]
        self.assertEqual(
            [
                ("foreverchanges", "ForeverChanges", "ForeverChanges", 1, True),
                ("kamilabs", "KamiLabs", "Kami Labs", 2, False),
                ("wowsims", "Wowsims", "wowsims", 3, True),
            ],
            rows,
        )
        self.assertEqual("ForeverBiS_Data_KamiLabs.lua", bis_sources.SOURCES[1].filename)

    def test_unshipped_sources_need_the_flag(self):
        self.assertEqual(["foreverchanges", "wowsims"], [s.id for s in bis_sources.select()])
        self.assertEqual(["foreverchanges", "kamilabs", "wowsims"], [s.id for s in bis_sources.select(include_unshipped=True)])

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
    def run_sources(self, sources, directory):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            succeeded = cli.run(Path(directory), sources)
        return succeeded, out.getvalue()

    def test_a_failing_source_keeps_its_file_and_the_others_are_written(self):
        with tempfile.TemporaryDirectory() as directory:
            old = Path(directory, "ForeverBiS_Data_Bad.lua")
            old.write_text("previous", encoding="utf-8")
            succeeded, output = self.run_sources(
                [fake_source("bad", "Bad", 1, broken_fetch), fake_source("good", "Good", 2, good_fetch)], directory
            )
            self.assertEqual(1, succeeded)
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

    def test_emission_is_deterministic(self):
        with tempfile.TemporaryDirectory() as directory:
            source = fake_source("good", "Good", 1, good_fetch)
            self.run_sources([source], directory)
            first = Path(directory, "ForeverBiS_Data_Good.lua").read_bytes()
            self.run_sources([source], directory)
            self.assertEqual(first, Path(directory, "ForeverBiS_Data_Good.lua").read_bytes())


if __name__ == "__main__":
    unittest.main()
