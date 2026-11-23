"""Tests for the generated leveling lists: EP weight parsing, usability, scoring, brackets and output (no network)."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from bis_sources import leveling  # noqa: E402
from bis_sources.common import validate  # noqa: E402

PRESETS_TS = """
export const PreBiSEpWeights = PresetUtils.makePresetEpWeights(
	'Pre-BiS',
	Stats.fromMap(
		{
			[Stat.StatStrength]: 2.2,
			[Stat.StatHitRating]: 1.5,
		},
		{
			[PseudoStat.PseudoStatMainHandDps]: 12.5,
		},
	),
);
export const OtherEpWeights = PresetUtils.makePresetEpWeights(
	'Other',
	Stats.fromMap({
		[Stat.StatAgility]: 9,
	}),
);
"""


def item(item_id, slot_type, stats=None, **extra):
    """A db.json-shaped item; `stats` maps Stat names (without the Stat prefix) to values."""
    option = {"ilvl": extra.pop("ilvl", 30), "stats": {str(leveling.STAT[k]): v for k, v in (stats or {}).items()}}
    if "dps" in extra:
        option["unroundedDps"] = extra.pop("dps")
    data = {"id": item_id, "name": f"Item {item_id}", "type": slot_type, "phase": 1, "quality": 3, "reqLvl": 20}
    data.update(extra)
    data["scalingOptions"] = {"0": option}
    return data


DROP = [{"drop": {"zoneId": 1, "npcId": 10}}]
RAID_DROP = [{"drop": {"zoneId": 2717, "npcId": 11}}]


def db(items):
    return {
        "items": items,
        "zones": [{"id": 1, "name": "The Deadmines"}, {"id": 2717, "name": "Molten Core"}],
        "npcs": [{"id": 10, "name": "Van Cleef"}, {"id": 11, "name": "Ragnaros"}],
        "factions": [],
    }


class EpWeightParsingTest(unittest.TestCase):
    def test_reads_stats_and_pseudo_stats_of_the_named_preset(self):
        weights = leveling.parse_ep_weights(PRESETS_TS, "PreBiSEpWeights")
        self.assertEqual(weights, {"Strength": 2.2, "HitRating": 1.5, "MainHandDps": 12.5})

    def test_other_presets_do_not_leak_in(self):
        self.assertEqual(leveling.parse_ep_weights(PRESETS_TS, "OtherEpWeights"), {"Agility": 9.0})

    def test_missing_preset_raises(self):
        with self.assertRaisesRegex(ValueError, "NopeEpWeights"):
            leveling.parse_ep_weights(PRESETS_TS, "NopeEpWeights")


class UsabilityTest(unittest.TestCase):
    def test_mail_needs_level_40_for_hunters_and_shamans(self):
        mail = item(1, 5, armorType=3)
        self.assertFalse(leveling.can_use("hunter", mail, 30))
        self.assertTrue(leveling.can_use("hunter", mail, 40))
        self.assertFalse(leveling.can_use("mage", mail, 60))

    def test_plate_needs_level_40_for_warriors(self):
        plate = item(1, 5, armorType=4)
        self.assertFalse(leveling.can_use("warrior", plate, 30))
        self.assertTrue(leveling.can_use("warrior", plate, 40))
        self.assertFalse(leveling.can_use("rogue", plate, 60))

    def test_weapon_types_follow_the_class(self):
        sword = item(1, 13, weaponType=9, handType=2)
        self.assertTrue(leveling.can_use("rogue", sword, 30))
        self.assertFalse(leveling.can_use("priest", sword, 30))

    def test_class_allowlist_wins(self):
        ring = item(1, 11, classAllowlist=[8])
        self.assertTrue(leveling.can_use("mage", ring, 30))
        self.assertFalse(leveling.can_use("warrior", ring, 30))

    def test_hunters_cannot_use_thrown_weapons(self):
        thrown = item(1, 14, rangedWeaponType=4)
        self.assertFalse(leveling.can_use("hunter", thrown, 30))
        self.assertTrue(leveling.can_use("rogue", thrown, 30))

    def test_relics_belong_to_their_class(self):
        totem = item(1, 14, rangedWeaponType=8)
        self.assertTrue(leveling.can_use("shaman", totem, 30))
        self.assertFalse(leveling.can_use("druid", totem, 30))


class ScoringTest(unittest.TestCase):
    def test_score_is_the_weighted_sum_plus_weapon_dps(self):
        weights = {"Strength": 2, "HitRating": 1, "MainHandDps": 10}
        weapon = item(1, 13, {"Strength": 5, "HitRating": 10}, weaponType=9, handType=4, dps=20)
        self.assertEqual(leveling.score(weapon, weights, "MainHandDps"), 5 * 2 + 10 + 20 * 10)
        self.assertEqual(leveling.score(weapon, weights, None), 20)


class GenerateTest(unittest.TestCase):
    SPEC = leveling.Spec("warrior/arms", "Arms", "warrior", "twohand", {"Strength": 1, "MainHandDps": 1})

    def lists(self, items):
        return leveling.generate(db(items), [self.SPEC])

    def slot(self, result, phase, name):
        _, slots = result["warrior/arms"][phase]
        return next(s for s in slots if s[0] == name)

    def test_keeps_the_six_best_in_score_order(self):
        heads = [item(100 + n, 1, {"Strength": n}, sources=DROP) for n in range(1, 9)]
        _, items, _ = self.slot(self.lists(heads), "lvl20", "Head")
        self.assertEqual([entry[2] for entry in items], [108, 107, 106, 105, 104, 103])

    def test_brackets_respect_the_required_level(self):
        low = item(1, 1, {"Strength": 1}, reqLvl=18, sources=DROP)
        high = item(2, 1, {"Strength": 9}, reqLvl=35, sources=DROP)
        result = self.lists([low, high])
        self.assertEqual([e[2] for e in self.slot(result, "lvl20", "Head")[1]], [1])
        self.assertEqual([e[2] for e in self.slot(result, "lvl40", "Head")[1]], [2, 1])

    def test_skips_phase_two_random_suffix_low_quality_and_pvp_only_items(self):
        good = item(1, 1, {"Strength": 1}, sources=DROP)
        skipped = [
            item(2, 1, {"Strength": 9}, phase=2, sources=DROP),
            item(3, 1, {"Strength": 9}, randomSuffixOptions=[1], sources=DROP),
            item(4, 1, {"Strength": 9}, quality=1, sources=DROP),
            item(5, 1, {"Strength": 9}, sources=[{"pvp": {}}]),
        ]
        self.assertEqual([e[2] for e in self.slot(self.lists([good, *skipped]), "lvl20", "Head")[1]], [1])

    def test_level_60_leaves_raid_drops_out(self):
        dungeon = item(1, 1, {"Strength": 1}, reqLvl=58, sources=DROP)
        raid = item(2, 1, {"Strength": 9}, reqLvl=60, sources=RAID_DROP)
        self.assertEqual([e[2] for e in self.slot(self.lists([dungeon, raid]), "lvl60", "Head")[1]], [1])

    def test_phases_are_the_five_level_brackets(self):
        self.assertEqual([phase["level"] for phase in leveling.PHASES], [20, 30, 40, 50, 60])

    def test_two_hand_specs_only_list_two_hand_weapons(self):
        two_hand = item(1, 13, {"Strength": 1}, weaponType=9, handType=4, dps=10, sources=DROP)
        one_hand = item(2, 13, {"Strength": 50}, weaponType=9, handType=2, dps=10, sources=DROP)
        name, items, _ = self.slot(self.lists([two_hand, one_hand]), "lvl20", "Two-hand weapon")
        self.assertEqual([e[2] for e in items], [1])

    def test_items_carry_their_source(self):
        head = item(1, 1, {"Strength": 1}, sources=DROP)
        _, items, _ = self.slot(self.lists([head]), "lvl20", "Head")
        self.assertEqual(items[0][1]["kind"], "dungeon")
        self.assertIn("Van Cleef", items[0][1]["text"])

    def test_output_passes_validation(self):
        heads = [item(1, 1, {"Strength": 1}, sources=DROP), item(2, 1, {"Strength": 2})]
        validate(self.lists(heads))


class CasterWeaponTest(unittest.TestCase):
    SPEC = leveling.Spec("mage/fire", "Fire", "mage", "caster", {"SpellDamage": 1})

    def test_a_staff_must_beat_the_best_one_hand_plus_off_hand(self):
        staff = item(1, 13, {"SpellDamage": 30}, weaponType=8, handType=4, sources=DROP)
        dagger = item(2, 13, {"SpellDamage": 20}, weaponType=2, handType=2, sources=DROP)
        held = item(3, 13, {"SpellDamage": 15}, weaponType=5, handType=3, sources=DROP)
        _, slots = leveling.generate(db([staff, dagger, held]), [self.SPEC])["mage/fire"]["lvl20"]
        main = next(s for s in slots if s[0] == "Main hand")
        self.assertEqual([e[2] for e in main[1]], [2, 1])


class RoutesTest(unittest.TestCase):
    def test_every_route_has_weights(self):
        for route in leveling.ROUTES:
            weights = route.weights
            if isinstance(weights, dict):
                self.assertTrue(weights, route.route)
            else:
                self.assertEqual(len(weights), 2, route.route)

    def test_routes_cover_every_class(self):
        classes = {route.class_key for route in leveling.ROUTES}
        self.assertEqual(classes, {"warrior", "paladin", "hunter", "rogue", "priest", "shaman", "mage", "warlock", "druid"})


if __name__ == "__main__":
    unittest.main()
