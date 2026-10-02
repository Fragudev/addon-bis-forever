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


class EmitLuaTest(unittest.TestCase):
    def setUp(self):
        data = {"/bis/druid": updater.parse_list("/bis/druid", PAGE)}
        self.lua = updater.emit_lua(data, {"druid": "Feral PvE"})

    def test_writes_enchants_as_a_third_element_of_the_slot(self):
        self.assertIn(
            '    }, {\n      {"Agility +5", "Enchant Necklace - Agility", "Enchanting 210: Formula sold by Alynsia.", 249504},',
            self.lua,
        )

    def test_omits_the_formula_when_the_enchant_has_none(self):
        self.assertIn('{"Agility +7", "Enchant Gloves - Agility", "Enchanting 210: Taught by the trainer."},', self.lua)

    def test_writes_slots_without_enchants_in_the_two_element_form(self):
        slot = self.lua.split('{"Off hand: shield", {')[1]
        self.assertIn('{"Stamina +3"', slot)

    def test_escapes_quotes_in_lua_strings(self):
        self.assertEqual('"say \\"hi\\""', updater.lua_quote('say "hi"'))

    def test_emits_the_item_id_and_build_label_tables(self):
        self.assertIn('["Erudite\'s Amulet"] = 1234,', self.lua)
        self.assertIn('["druid"] = "Feral PvE",', self.lua)


if __name__ == "__main__":
    unittest.main()
