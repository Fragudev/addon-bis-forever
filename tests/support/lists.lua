-- Small synthetic schema 3 data for the window interaction specs, so they do not depend on the shipped lists:
--   one "leveling" source (the shipped id) with a single "lvl30" phase and two routes, "druid" and "rogue".
-- The druid list covers what the specs exercise: ten armor slots, rings, both weapon headings, two enchants
-- (one with a formula), quest, profession, dungeon and world sources, an Alliance-only item and a maker-only item.

local Lists = {}

local function item(id, name, kind, text)
    return { id = id, name = name, source = { kind = kind, text = text } }
end

local function slot(name, items, enchants)
    return { slot = name, items = items, enchants = enchants }
end

local function druidSlots()
    return {
        slot("Head", {
            item(9101, "Fixture Hood", "dungeon", "Rhahk'Zor, The Deadmines"),
            item(9102, "Fixture Cap", "world", "World Drop"),
            item(9103, "Fixture Circlet", "quest", "Quest: Arathor Supplies (Alliance)"),
        }),
        slot("Neck", {
            item(9111, "Fixture Pendant", "quest", "Quest: The Lost Pendant"),
            item(9112, "Fixture Choker", "world", "World Drop"),
        }, {
            {
                effect = "Agility +5",
                spell = "Enchant Necklace - Agility",
                source = "Enchanting 210",
                formulaId = 9901,
            },
        }),
        slot("Shoulder", { item(9121, "Fixture Spaulders", "world", "World Drop") }),
        slot("Back", { item(9131, "Fixture Cloak", "dungeon", "Mutanus the Devourer, Wailing Caverns") }),
        slot("Chest", {
            item(9141, "Fixture Tunic", "profession", "Leatherworking (100) Only its maker can wear it"),
            item(9142, "Fixture Vest", "world", "World Drop"),
        }),
        slot("Wrist", { item(9151, "Fixture Bracers", "world", "World Drop") }),
        slot("Hands", { item(9161, "Fixture Gloves", "profession", "Leatherworking (75)") }, {
            { effect = "Agility +7", spell = "Enchant Gloves - Agility", source = "Enchanting 210" },
        }),
        slot("Waist", { item(9171, "Fixture Belt", "world", "World Drop") }),
        slot("Legs", { item(9181, "Fixture Leggings", "quest", "Quest: Leggings of the Glade") }),
        slot("Feet", { item(9191, "Fixture Boots", "world", "World Drop") }),
        slot("Finger", {
            item(9201, "Fixture Band", "dungeon", "Cookie, The Deadmines"),
            item(9202, "Fixture Loop", "world", "World Drop"),
        }),
        slot("Two-hand weapon", { item(9211, "Fixture Staff", "quest", "Quest: The Staff of the Glade") }),
        slot("Main hand", { item(9221, "Fixture Mace", "world", "World Drop") }),
    }
end

local function rogueSlots()
    return {
        slot("Head", { item(9301, "Fixture Mask", "world", "World Drop") }),
        slot("Chest", { item(9311, "Fixture Jerkin", "world", "World Drop") }),
    }
end

--- Replaces the sources of a ForeverBiSData with the fixture (use as a WowStub.load / loadData hook).
function Lists.install(data)
    data.sources = {
        leveling = {
            label = "ForeverBiS",
            order = 0,
            url = "https://leveling.test",
            phases = { { id = "lvl30", label = "Level 30", level = 30 } },
            lists = {
                ["druid"] = {
                    label = "Feral PvE",
                    phases = { lvl30 = { title = "Fixture Druid at level 30", slots = druidSlots() } },
                },
                ["rogue"] = {
                    label = "Rogue PvE",
                    phases = { lvl30 = { title = "Fixture Rogue at level 30", slots = rogueSlots() } },
                },
            },
        },
    }
end

return Lists
