local function loadFilters()
    WowStub.reset()
    WowStub.loadFiles({
        "ForeverBiS_Locale.lua",
        "ForeverBiS_Data.lua",
        "ForeverBiS_Model.lua",
        "Core/Sources.lua",
        "Core/Filters.lua",
    })
    local Filters = WowStub.ns.Filters
    Filters.reset()
    return Filters
end

local QUEST = { "Cape of Dawn", "Quest: Dangerous! (Horde)" }
local DUNGEON = { "Deadmines Blade", "Sneed's Shredder, The Deadmines" }
local WORLD = { "Plain Cloak", "World drop; Auction House" }
local MAKER = { "Maker Robe", "Tailoring (Only its maker can wear it)" }

describe("Filters", function()
    local Filters

    before_each(function()
        Filters = loadFilters()
    end)

    it("passes every item while no filter is active", function()
        for _, item in ipairs({ QUEST, DUNGEON, WORLD, MAKER }) do
            assert.is_true(Filters.matches(item, nil))
        end
    end)

    describe("search", function()
        it("matches the item name or the source, case-insensitively", function()
            Filters.setSearch("DEADMINES")
            assert.is_true(Filters.matches(DUNGEON, nil))
            assert.is_false(Filters.matches(WORLD, nil))
            Filters.setSearch("plain")
            assert.is_true(Filters.matches(WORLD, nil))
        end)

        it("treats the text literally, not as a pattern", function()
            Filters.setSearch("%")
            assert.is_false(Filters.matches(WORLD, nil))
        end)
    end)

    describe("sources", function()
        it("keeps only the selected categories", function()
            Filters.toggleSource("quest")
            assert.is_true(Filters.matches(QUEST, nil))
            assert.is_false(Filters.matches(WORLD, nil))
            Filters.toggleSource("world")
            assert.is_true(Filters.matches(WORLD, nil))
        end)

        it("clears the dungeon choice when the dungeon source is turned off", function()
            Filters.toggleSource("dungeon")
            Filters.setDungeon("the deadmines")
            assert.is_true(Filters.matches(DUNGEON, nil))
            assert.is_false(Filters.matches({ "Other", "Wailing Caverns" }, nil))
            Filters.toggleSource("dungeon")
            assert.are.equal("all", Filters.state.dungeon)
        end)
    end)

    describe("faction", function()
        it("hides items exclusive to the other faction", function()
            assert.is_true(Filters.matches(QUEST, "Horde"))
            assert.is_false(Filters.matches(QUEST, "Alliance"))
        end)

        it("shows both factions once toggled", function()
            Filters.toggleBothFactions()
            assert.is_true(Filters.matches(QUEST, "Alliance"))
            Filters.toggleBothFactions()
            assert.is_false(Filters.matches(QUEST, "Alliance"))
        end)

        it("does not filter by faction when the player has none", function()
            assert.is_true(Filters.matches(QUEST, nil))
        end)
    end)

    describe("maker", function()
        it("cycles all, only, hide and back", function()
            assert.are.equal("all", Filters.state.maker)
            Filters.cycleMaker()
            assert.are.equal("only", Filters.state.maker)
            Filters.cycleMaker()
            assert.are.equal("hide", Filters.state.maker)
            Filters.cycleMaker()
            assert.are.equal("all", Filters.state.maker)
        end)

        it("keeps only maker items in only mode and hides them in hide mode", function()
            Filters.cycleMaker()
            assert.is_true(Filters.matches(MAKER, nil))
            assert.is_false(Filters.matches(WORLD, nil))
            Filters.cycleMaker()
            assert.is_false(Filters.matches(MAKER, nil))
            assert.is_true(Filters.matches(WORLD, nil))
        end)

        it("labels every mode", function()
            for mode in pairs({ all = true, only = true, hide = true }) do
                assert.is_string(Filters.makerLabels[mode])
            end
        end)
    end)

    it("resets every filter, keeping the same state table", function()
        local state = Filters.state
        Filters.setSearch("x")
        Filters.toggleSource("quest")
        Filters.setDungeon("wailing caverns")
        Filters.toggleBothFactions()
        Filters.cycleMaker()
        Filters.reset()
        assert.are.equal(state, Filters.state)
        assert.are.same({ search = "", sources = {}, dungeon = "all", bothFactions = false, maker = "all" }, state)
    end)

    it("offers every dungeon after the all option", function()
        local options = Filters.dungeonOptions()
        assert.are.same({ "all", "All dungeons" }, options[1])
        assert.are.equal(#WowStub.ns.Sources.dungeons + 1, #options)
    end)
end)
