local function loadSources()
    WowStub.reset()
    WowStub.loadFiles({
        "ForeverBiS_Data_Leveling.lua",
        "ForeverBiS_Model.lua",
        "Core/Sources.lua",
    })
    return WowStub.ns.Sources
end

describe("Sources", function()
    local Sources

    before_each(function()
        Sources = loadSources()
    end)

    describe("matchDungeon", function()
        it("matches the known dungeons by name", function()
            assert.are.equal("the deadmines", Sources.matchDungeon("The Deadmines")[1])
            assert.are.equal("Wailing Caverns", Sources.matchDungeon("Wailing Caverns")[2])
        end)

        it("accepts name variants: case, punctuation and a missing leading The", function()
            assert.are.equal("the deadmines", Sources.matchDungeon("Deadmines")[1])
            assert.are.equal("the deadmines", Sources.matchDungeon("the DEADMINES")[1])
            assert.are.equal("shadowfang keep", Sources.matchDungeon("Shadowfang  Keep ")[1])
            assert.are.equal("ragefire chasm", Sources.matchDungeon("Ragefire-Chasm")[1])
        end)

        it("returns nil for any other name", function()
            assert.is_nil(Sources.matchDungeon("Eastern Kingdoms"))
            assert.is_nil(Sources.matchDungeon("Deadmines Annex"))
            assert.is_nil(Sources.matchDungeon(""))
            assert.is_nil(Sources.matchDungeon(nil))
        end)
    end)

    describe("countForDungeon", function()
        local slots = {
            { "Head", { { "A", "Boss, The Deadmines" }, { "B", "World drop" } } },
            { "Neck", { { "C", "Other, The Deadmines" }, { "D", "Boss, Wailing Caverns" } } },
        }

        it("counts the listed items that come from the dungeon", function()
            assert.are.equal(2, Sources.countForDungeon(slots, "the deadmines"))
            assert.are.equal(1, Sources.countForDungeon(slots, "wailing caverns"))
        end)

        it("is zero for a dungeon with no listed items", function()
            assert.are.equal(0, Sources.countForDungeon(slots, "ragefire chasm"))
            assert.are.equal(0, Sources.countForDungeon({}, "the deadmines"))
        end)
    end)

    it("normalizes slot names through the model", function()
        assert.are.equal(ForeverBiSModel.slotKey("Main Hand"), Sources.normalizeSlotName("Main Hand"))
    end)

    it("lists the dungeons the zone notice knows", function()
        assert.are.equal("The Deadmines", Sources.dungeons[1][2])
        local names = {}
        for _, dungeon in ipairs(Sources.dungeons) do
            names[dungeon[2]] = dungeon[1]
        end
        for _, name in ipairs({
            "Gnomeregan",
            "The Stockade",
            "Razorfen Kraul",
            "Razorfen Downs",
            "Scarlet Monastery",
            "Uldaman",
        }) do
            assert.are.equal(name:lower(), names[name], name)
        end
    end)
end)
