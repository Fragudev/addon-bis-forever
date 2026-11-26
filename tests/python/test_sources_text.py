"""Tests for bis_sources/sources_text.py: item source descriptions from the wowsims database (no network)."""

import re
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from bis_sources import sources_text  # noqa: E402


class StructureSourceTest(unittest.TestCase):
    def test_keeps_the_raw_text(self):
        text = "Quest: Friend of the Library Ten books"
        self.assertEqual(text, sources_text.structure_source(text)["text"])

    def test_classifies_a_quest_and_extracts_its_name(self):
        source = sources_text.structure_source("Quest: Bartolo's Yeti Fur Cloak \u2197 Alliance, level 34 in Classic")
        self.assertEqual("quest", source["kind"])
        self.assertEqual("Bartolo's Yeti Fur Cloak", source["quest"])
        self.assertEqual("Alliance", source["faction"])

    def test_classifies_a_profession_with_skill_and_level(self):
        source = sources_text.structure_source("Leatherworking (100) Only its maker can wear it")
        self.assertEqual("profession", source["kind"])
        self.assertEqual("Leatherworking", source["skill"])
        self.assertEqual(100, source["skillLevel"])
        self.assertTrue(source["bindsToMaker"])

    def test_profession_without_a_level_has_no_skill_level(self):
        source = sources_text.structure_source("Leatherworking")
        self.assertEqual("Leatherworking", source["skill"])
        self.assertNotIn("skillLevel", source)

    def test_classifies_a_dungeon_with_boss_zone_and_drop_rate(self):
        source = sources_text.structure_source("Archmage Arugal, Shadowfang Keep 34.05% in Classic")
        self.assertEqual("dungeon", source["kind"])
        self.assertEqual("Shadowfang Keep", source["zone"])
        self.assertEqual("Archmage Arugal", source["boss"])
        self.assertEqual(34.05, source["dropRate"])

    def test_classic_dungeons_in_the_data_are_dungeons(self):
        for zone in (
            "Gnomeregan",
            "The Stockade",
            "Razorfen Kraul",
            "Razorfen Downs",
            "Scarlet Monastery",
            "Scarlet Monastery Graveyard",
            "Uldaman",
        ):
            source = sources_text.structure_source(f"Some Boss, {zone}")
            self.assertEqual("dungeon", source["kind"], zone)
            self.assertEqual(zone.removesuffix(" Graveyard"), source["zone"], zone)

    def test_level_60_dungeons_and_raids_are_dungeons(self):
        for zone in (
            "Zul'Farrak",
            "Maraudon",
            "The Temple of Atal'Hakkar",
            "Blackrock Depths",
            "Blackrock Spire",
            "Dire Maul",
            "Stratholme",
            "Scholomance",
            "Molten Core",
            "Onyxia's Lair",
            "Blackwing Lair",
            "Zul'Gurub",
            "Ruins of Ahn'Qiraj",
            "Temple of Ahn'Qiraj",
            "Naxxramas",
        ):
            source = sources_text.structure_source(f"Some Boss, {zone}")
            self.assertEqual("dungeon", source["kind"], zone)
            self.assertEqual(zone, source["zone"], zone)
            self.assertEqual("Some Boss", source["boss"], zone)

    def test_a_zone_outside_the_dungeon_list_keeps_the_world_kind(self):
        source = sources_text.structure_source("Faldrim Anvilmar, Hall of Thanes")
        self.assertEqual("world", source["kind"])
        self.assertEqual("Hall of Thanes", source["zone"])
        self.assertEqual("Faldrim Anvilmar", source["boss"])

    def test_classifies_a_world_drop_and_flags_it_as_reported(self):
        source = sources_text.structure_source("A world drop, not bound: the auction house is quickest Reported, not checked")
        self.assertEqual("world", source["kind"])
        self.assertTrue(source["reported"])
        self.assertNotIn("zone", source)
        self.assertNotIn("boss", source)

    def test_classifies_unknown_sources(self):
        source = sources_text.structure_source("Where it comes from is not known yet Nothing places it yet")
        self.assertEqual({"kind": "unknown", "text": source["text"]}, source)

    def test_detects_a_horde_exclusive_source_but_not_a_shared_one(self):
        self.assertEqual("Horde", sources_text.structure_source("Horde quest The Book of Ur")["faction"])
        self.assertNotIn("faction", sources_text.structure_source("Quest: Both Horde and Alliance"))


class ItemSourceTest(unittest.TestCase):
    DB = {
        "zones": [{"id": 1581, "name": "The Deadmines"}, {"id": 1519, "name": "Stormwind City"}, {"id": 40, "name": "Westfall"}],
        "npcs": [{"id": 644, "name": "Rhahk'Zor"}, {"id": 1297, "name": "Lina Stover"}],
        "factions": [{"id": 509, "name": "The League of Arathor"}],
    }

    def source(self, *sources):
        return sources_text.SourceDescriber(self.DB)({"id": 1, "name": "X", "sources": list(sources)})

    def test_dungeon_drop_has_zone_and_boss(self):
        source = self.source({"drop": {"difficulty": 1, "npcId": 644, "zoneId": 1581}})
        self.assertEqual(("dungeon", "Rhahk'Zor, The Deadmines"), (source["kind"], source["text"]))
        self.assertEqual(("The Deadmines", "Rhahk'Zor"), (source["zone"], source["boss"]))

    def test_trash_drop_uses_the_other_name(self):
        source = self.source({"drop": {"difficulty": 1, "zoneId": 1581, "otherName": "Trash"}})
        self.assertEqual(("dungeon", "Trash, The Deadmines"), (source["kind"], source["text"]))

    def test_world_drop_is_world(self):
        source = self.source({"drop": {"npcId": 644, "zoneId": 40}})
        self.assertEqual(("world", "Rhahk'Zor, Westfall"), (source["kind"], source["text"]))

    def test_quest_with_faction(self):
        source = self.source({"quest": {"id": 53, "name": "Sweet Amber", "faction": 1}})
        self.assertEqual(("quest", "Quest: Sweet Amber (Alliance)"), (source["kind"], source["text"]))
        self.assertEqual(("Alliance", "Sweet Amber"), (source["faction"], source["quest"]))

    def test_vendor(self):
        source = self.source({"soldBy": {"npcId": 1297, "npcName": "Lina Stover", "zoneId": 1519}})
        self.assertEqual(("world", "Sold by Lina Stover, Stormwind City"), (source["kind"], source["text"]))

    def test_crafted_is_a_profession(self):
        source = self.source({"crafted": {"profession": 2, "spellId": 2675}})
        self.assertEqual(("profession", "Blacksmithing", "Blacksmithing"), (source["kind"], source["text"], source["skill"]))
        self.assertNotIn("craftedBy", source)

    def test_a_drop_that_can_also_be_crafted_names_the_profession(self):
        source = self.source({"drop": {"npcId": 644, "zoneId": 40}}, {"crafted": {"profession": 11, "spellId": 1}})
        self.assertEqual(("world", "Rhahk'Zor, Westfall", "Tailoring"), (source["kind"], source["text"], source["craftedBy"]))

    def test_a_drop_without_a_known_profession_has_no_crafted_by(self):
        source = self.source({"drop": {"npcId": 644, "zoneId": 40}}, {"crafted": {"profession": 99}})
        self.assertNotIn("craftedBy", source)

    def test_pvp_and_reputation(self):
        self.assertEqual("PvP reward", self.source({"pvp": {}})["text"])
        self.assertEqual("Reputation: The League of Arathor", self.source({"rep": {"repFactionId": 509}})["text"])

    def test_dungeon_drop_beats_other_sources(self):
        source = self.source({"quest": {"name": "Q"}}, {"drop": {"npcId": 644, "zoneId": 1581}})
        self.assertEqual("dungeon", source["kind"])

    def test_items_without_sources_stay_unknown(self):
        describe = sources_text.SourceDescriber(self.DB)
        self.assertEqual(sources_text.NO_SOURCE, describe({"id": 1, "name": "X"}))
        self.assertEqual(sources_text.NO_SOURCE, describe({"id": 1, "name": "X", "sources": []}))


class DungeonParityTest(unittest.TestCase):
    def test_python_and_lua_know_the_same_dungeons(self):
        lua = (Path(__file__).resolve().parents[2] / "ForeverBiS" / "Core" / "Sources.lua").read_text(encoding="utf-8")
        block = lua.split("Sources.dungeons = {", 1)[1].split("\n}", 1)[0]
        in_lua = re.findall(r'\{ "([^"]+)", "([^"]+)" \}', block)
        self.assertEqual(list(sources_text.DUNGEON_SOURCES), in_lua)


if __name__ == "__main__":
    unittest.main()
