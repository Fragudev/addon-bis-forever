"""Tests for the ForeverChanges parser in UpdateForeverBiS.py (stdlib only, no network)."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import UpdateForeverBiS as updater  # noqa: E402

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


class EmitLuaTest(unittest.TestCase):
    def setUp(self):
        title, slots = updater.parse_list("/bis/druid", PAGE)
        data = {"/bis/druid": {updater.phase_from_title(title)["id"]: (title, slots)}}
        self.lua = updater.emit_lua(data, {"druid": "Feral PvE"})

    def test_defines_only_the_v2_table(self):
        self.assertTrue(self.lua.startswith("ForeverBiSData = {\n  schema = 2,\n"))
        for legacy in ("ForeverBiSLists", "ForeverBiSItemIDs", "ForeverBiSBuildLabels"):
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
        data = {"/bis/x": {"current": ("X", [("Slot", [("Plain", "Vendor", None)], [])])}}
        lua = updater.emit_lua(data, {})
        self.assertIn('{ name = "Plain", source = { kind = "world", text = "Vendor" } },', lua)
        self.assertNotIn("label =", lua.split("lists")[1])
        self.assertNotIn("enchants", lua)
        self.assertIn('{ id = "current", label = "Current" },', lua)

    def test_escapes_quotes_in_lua_strings(self):
        self.assertEqual('"say \\"hi\\""', updater.lua_quote('say "hi"'))


if __name__ == "__main__":
    unittest.main()
