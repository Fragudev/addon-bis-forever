"""Tests for the wowsims source: .gear.siml presets, slug resolution and unmapped-preset warnings (no network)."""

import contextlib
import io
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from bis_sources import wowsims  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures"
DB = json.loads((FIXTURES / "wowsims_db.json").read_text(encoding="utf-8"))
SIML = (FIXTURES / "wowsims_preset.gear.siml").read_text(encoding="utf-8")
GEAR_JSON = json.loads((FIXTURES / "wowsims_preset.gear.json").read_text(encoding="utf-8"))


def lookups():
    items = {item["id"]: item for item in DB["items"]}
    enchants = {}
    for enchant in DB["enchants"]:
        enchants.setdefault(enchant["effectId"], enchant)
    return items, enchants


def quiet(function, *args, **kwargs):
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        result = function(*args, **kwargs)
    return result, out.getvalue()


class SimlParsingTest(unittest.TestCase):
    def parse(self, text, name="preset.gear.siml"):
        resolver = wowsims.SlugResolver(DB)
        gear, out = quiet(wowsims.parse_siml, text, resolver, name)
        return gear, out

    def test_siml_matches_the_equivalent_gear_json_slots(self):
        items, enchants = lookups()
        gear, out = self.parse(SIML)
        self.assertEqual("", out)
        self.assertEqual(wowsims.build_slots(GEAR_JSON, items, enchants), wowsims.build_slots(gear, items, enchants))

    def test_slot_keys_follow_the_itemslot_order(self):
        text = "\n".join(f"{key} lionheart_helm" for key in ("ranged", "trinket2", "shoulders", "head"))
        gear, _ = self.parse(text)
        self.assertEqual([1, 1, 1, 1], [gear["items"][i]["id"] for i in (0, 2, 13, 16)])
        self.assertEqual(17, len(gear["items"]))

    def test_slugs_resolve_by_normalised_name(self):
        resolver = wowsims.SlugResolver(DB)
        self.assertEqual(8, resolver.item("horn_of_vehan")["id"])
        self.assertEqual(10, resolver.item("don_julios_band")["id"])
        self.assertEqual(2, resolver.item("beastmasters_bindings_ilvl65")["id"])

    def test_enchant_slugs_resolve_by_name_or_effect_id_suffix(self):
        resolver = wowsims.SlugResolver(DB)
        self.assertEqual("Enchant Weapon - Crusader", resolver.enchant("weapon_crusader")["name"])
        self.assertEqual("Enchant Weapon - Agility", resolver.enchant("weapon_agility")["name"])
        self.assertEqual("Arcanum of Rapidity", resolver.enchant("arcanum_of_rapidity")["name"])
        self.assertEqual("Enchant Bracer - Agility", resolver.enchant("bracer_agility_7656")["name"])

    def test_random_suffix_after_a_space_resolves_the_base_item(self):
        gear, out = self.parse("ranged   hawkeye_bow of_agility + weapon_crusader")
        self.assertEqual(5, gear["items"][16]["id"])
        self.assertEqual("", out)

    def test_unknown_item_slug_is_reported_and_skipped(self):
        gear, out = self.parse("head   no_such_item + arcanum_of_rapidity\nneck lionheart_helm", "x.gear.siml")
        self.assertIn("::warning::wowsims: x.gear.siml: unknown item slug no_such_item", out)
        self.assertEqual({}, gear["items"][0])
        self.assertEqual(1, gear["items"][1]["id"])

    def test_unknown_enchant_slug_is_reported_and_item_kept(self):
        gear, out = self.parse("head   lionheart_helm + no_such_enchant", "x.gear.siml")
        self.assertIn("::warning::wowsims: x.gear.siml: unknown enchant slug no_such_enchant", out)
        self.assertEqual(1, gear["items"][0]["id"])
        self.assertNotIn("enchantEntry", gear["items"][0])

    def test_unknown_slot_key_is_reported(self):
        _, out = self.parse("tabard lionheart_helm", "x.gear.siml")
        self.assertIn("::warning::wowsims: x.gear.siml: unknown slot tabard", out)

    def test_ambiguous_names_pick_the_highest_required_level_and_warn(self):
        gear, out = self.parse("hands   raider_gloves", "x.gear.siml")
        self.assertEqual(7, gear["items"][6]["id"])
        self.assertIn("::warning::wowsims: x.gear.siml: ambiguous item slug raider_gloves", out)

    def test_header_and_blank_lines_are_ignored(self):
        gear, out = self.parse("siml 1\n\n# comment\nhead lionheart_helm\n")
        self.assertEqual(1, gear["items"][0]["id"])
        self.assertEqual("", out)


class MappingTest(unittest.TestCase):
    def test_siml_presets_map_to_the_committed_routes(self):
        cases = {
            "hunter/dps/gear_sets/prebis_melee": ("hunter/melee", "lvl60"),
            "hunter/dps/gear_sets/prebis_turret": ("hunter/ranged", "lvl60"),
            "paladin/retribution/gear_sets/default": ("paladin/retribution", "raid1"),
            "paladin/retribution/gear_sets/holy_shock": ("paladin/shockadin", "raid1"),
            "paladin/protection/gear_sets/default": ("paladin/tank", "raid1"),
        }
        for path, (route, phase) in cases.items():
            mapped = wowsims.map_preset(f"ui/specs/{path}.gear.siml")
            self.assertEqual((route, phase), (mapped[0], mapped[2]), path)

    def test_mage_preraid_maps_to_arcane(self):
        mapped = wowsims.map_preset("ui/specs/mage/dps/gear_sets/preraid.gear.json")
        self.assertEqual(("mage/arcane", "lvl60"), (mapped[0], mapped[2]))

    def test_cheap_and_weave_variants_are_deliberately_skipped(self):
        for name in ("prebis_melee_cheap", "prebis_turret_cheap", "prebis_weave", "prebis_weave_cheap"):
            self.assertIsNone(wowsims.map_preset(f"ui/specs/hunter/dps/gear_sets/{name}.gear.siml"), name)

    def test_gear_json_presets_still_map_as_before(self):
        mapped = wowsims.map_preset("ui/specs/rogue/dps/gear_sets/p1_bscombat.gear.json")
        self.assertEqual(("rogue/combat", "Combat", "raid1"), mapped[:3])


class FetchTest(unittest.TestCase):
    def run_fetch(self, paths, siml=SIML):
        requested = []

        def get_json(url, headers=None):
            if url == wowsims.TREE_URL:
                return {"tree": [{"path": path} for path in paths]}
            if url.endswith(wowsims.DB_PATH):
                return DB
            requested.append(url)
            return GEAR_JSON

        def get_text(url, *args, **kwargs):
            requested.append(url)
            return siml

        result, out = quiet(wowsims.fetch, get_text=get_text, get_json=get_json)
        return result, out, requested

    def test_fetch_reads_siml_and_json_presets_into_the_same_slots(self):
        (data, labels, phases), out, _ = self.run_fetch(
            [
                "ui/specs/paladin/retribution/gear_sets/default.gear.siml",
                "ui/specs/mage/dps/gear_sets/preraid.gear.json",
            ]
        )
        self.assertEqual({"paladin/retribution", "mage/arcane"}, set(data))
        self.assertEqual(data["paladin/retribution"]["raid1"][1], data["mage/arcane"]["lvl60"][1])
        self.assertNotIn("::warning::", out)

    def test_unmapped_preset_emits_a_loud_warning(self):
        _, out, _ = self.run_fetch(
            [
                "ui/specs/mage/dps/gear_sets/preraid.gear.json",
                "ui/specs/shaman/dps/gear_sets/p1.gear.siml",
                "ui/specs/hunter/dps/gear_sets/prebis_weave.gear.siml",
            ]
        )
        self.assertIn("::warning::wowsims: unmapped preset ui/specs/shaman/dps/gear_sets/p1.gear.siml", out)
        self.assertNotIn("::warning::wowsims: unmapped preset ui/specs/hunter", out)

    def test_unknown_preset_extension_is_a_warning_not_silence(self):
        _, out, _ = self.run_fetch(
            ["ui/specs/mage/dps/gear_sets/preraid.gear.json", "ui/specs/mage/dps/gear_sets/other.gear.yaml"]
        )
        self.assertIn("::warning::wowsims: unmapped preset ui/specs/mage/dps/gear_sets/other.gear.yaml", out)


if __name__ == "__main__":
    unittest.main()
