"""Tests for the EG Link drop chances (CC BY 4.0): pooling, minimum observations and NPC matching (no network)."""

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from bis_sources import eglink  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures"


def fake_json(urls=None):
    """get_json serving the eglink_* fixtures by URL; any other URL fails like an unreachable host."""
    files = {
        eglink.INDEX_URL: "eglink_index.json",
        f"{eglink.DATA_URL}wowf/1.0.1/loot.json": "eglink_loot_1.0.1.json",
        f"{eglink.DATA_URL}wowf/1.0.2/loot.json": "eglink_loot_1.0.2.json",
        f"{eglink.DATA_URL}wowf/1.0.1/encounters.json": "eglink_encounters_1.0.1.json",
    }

    def get_json(url):
        if urls is not None:
            urls.append(url)
        if url not in files:
            raise OSError(f"unreachable: {url}")
        return json.loads((FIXTURES / files[url]).read_text(encoding="utf-8"))

    return get_json


def item(item_id, quality=2):
    return {"id": item_id, "quality": quality}


class LoadTest(unittest.TestCase):
    def test_reads_only_the_live_product_builds_that_have_loot(self):
        urls = []
        eglink.load(fake_json(urls))
        self.assertEqual(
            sorted(urls),
            sorted(
                [
                    eglink.INDEX_URL,
                    f"{eglink.DATA_URL}wowf/1.0.1/loot.json",
                    f"{eglink.DATA_URL}wowf/1.0.1/encounters.json",
                    f"{eglink.DATA_URL}wowf/1.0.2/loot.json",
                ]
            ),
        )

    def test_refuses_data_under_another_license(self):
        def get_json(url):
            data = fake_json()(url)
            if url == eglink.INDEX_URL:
                data["license"] = "CC BY-NC 4.0"
            return data

        with self.assertRaisesRegex(ValueError, "license"):
            eglink.load(get_json)

    def test_an_unreachable_build_fails_the_whole_load(self):
        def get_json(url):
            if url.endswith("1.0.2/loot.json"):
                raise OSError("timeout")
            return fake_json()(url)

        with self.assertRaises(OSError):
            eglink.load(get_json)


class DropRateTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rates = eglink.load(fake_json())

    def test_pools_every_build_and_corpse_key_weighted_by_loot_windows(self):
        # npc:1 (4 windows at 50%) + npc:1|quest|group (8 windows at 25%) = 4 drops in 12 windows.
        self.assertEqual(33.3, self.rates(item(100), 1))

    def test_skinning_pick_pocket_and_objects_are_not_kills(self):
        # npc:1|spell:921 (50 windows at 100%) and object:55|spell:3365 would dominate the pool if counted.
        self.assertEqual(33.3, self.rates(item(100), 1))
        self.assertNotIn(55, self.rates.npcs)

    def test_needs_ten_observations(self):
        self.assertEqual(10, eglink.MIN_OBSERVATIONS)
        self.assertIsNone(self.rates(item(100), 5))  # 3 windows only

    def test_never_reports_a_zero_rate(self):
        self.assertIsNone(self.rates(item(103), 1))

    def test_a_named_npc_with_too_few_observations_does_not_borrow_another_npc_rate(self):
        self.assertIsNone(self.rates(item(100), 5))

    def test_a_named_npc_eg_link_never_saw_gets_no_rate(self):
        self.assertIsNone(self.rates(item(100), 99))

    def test_without_a_named_npc_the_best_observed_npc_wins(self):
        # npc:3|group has 30 windows at 10%, npc:1 has 12 at 33.3%, npc:5 is under the minimum.
        self.assertEqual(10.0, self.rates(item(100), None))

    def test_a_boss_uses_its_rolls_and_solo_corpses_but_not_its_group_corpses(self):
        # Solo corpse 3 drops in 6 windows + threshold-2 rolls 2 drops in 6 kills; npc:7|group is left out.
        self.assertEqual(41.7, self.rates(item(101, quality=2), 7))

    def test_rolls_count_only_at_thresholds_the_item_quality_reaches(self):
        # Rare item: corpse 6 + threshold-2 rolls 6 + threshold-3 rolls 8 observations, 4 drops.
        self.assertEqual(20.0, self.rates(item(102, quality=3), 7))
        # The same item counted as uncommon could not be rolled at threshold 3: no drops left, no rate.
        self.assertIsNone(self.rates(item(102, quality=2), 7))


class PercentTest(unittest.TestCase):
    def test_rounds_to_one_decimal_and_keeps_small_rates_visible(self):
        self.assertEqual(33.3, eglink.percent(1 / 3))
        self.assertEqual(0.04, eglink.percent(0.0004))

    def test_caps_at_one_hundred(self):
        self.assertEqual(100, eglink.percent(1.4))


if __name__ == "__main__":
    unittest.main()
