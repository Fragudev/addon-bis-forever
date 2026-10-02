local function loadSources()
    WowStub.reset()
    WowStub.loadFiles({ "ForeverBiS_Data.lua", "ForeverBiS_Model.lua", "Core/Sources.lua" })
    return WowStub.ns.Sources
end

describe("Sources", function()
    local Sources

    before_each(function()
        Sources = loadSources()
    end)

    describe("category", function()
        it("recognizes quests before anything else", function()
            assert.are.equal("quest", Sources.category("Quest: Cooking with Mining (Alchemy)"))
        end)

        it("recognizes professions", function()
            assert.are.equal("profession", Sources.category("Leatherworking; Auction House"))
        end)

        it("recognizes dungeons by name", function()
            assert.are.equal("dungeon", Sources.category("Sneed's Shredder, The Deadmines"))
        end)

        it("treats everything else as the open world", function()
            assert.are.equal("world", Sources.category("World drop; Auction House"))
            assert.are.equal("world", Sources.category(nil))
        end)
    end)

    describe("icon", function()
        it("returns the shared icon of the quest, dungeon and world categories", function()
            assert.are.equal("Interface\\GossipFrame\\AvailableQuestIcon", Sources.icon("Quest: Anything"))
            assert.is_truthy(Sources.icon("Wailing Caverns"):find("ForeverBiSDungeonIcon", 1, true))
            assert.are.equal("Interface\\WorldMap\\UI-World-Icon", Sources.icon("World drop"))
        end)

        it("returns the profession's own icon", function()
            assert.are.equal("Interface\\Icons\\Trade_Tailoring", Sources.icon("Tailoring"))
        end)
    end)

    describe("exclusiveFaction", function()
        it("names the faction when only one is mentioned", function()
            assert.are.equal("Horde", Sources.exclusiveFaction("Quest: Dangerous! (Horde)"))
            assert.are.equal("Alliance", Sources.exclusiveFaction("Quest: Sleeper (Alliance)"))
        end)

        it("returns nil for neutral sources and for sources naming both", function()
            assert.is_nil(Sources.exclusiveFaction("World drop"))
            assert.is_nil(Sources.exclusiveFaction("Horde: A; Alliance: B"))
            assert.is_nil(Sources.exclusiveFaction(nil))
        end)
    end)

    describe("format", function()
        it("colors the boss and the location", function()
            assert.are.equal(
                "|cffffd100Sneed's Shredder|r, |cff65d9ffThe Deadmines|r",
                Sources.format("Sneed's Shredder, The Deadmines")
            )
        end)

        it("leaves quests and plain text alone", function()
            assert.are.equal("Quest: Hello, World", Sources.format("Quest: Hello, World"))
            assert.are.equal("World drop", Sources.format("World drop"))
        end)

        it("drops the Classic note from a drop chance", function()
            assert.are.equal(
                "|cffffd100Boss|r, |cff65d9ff1.5% in Zone|r",
                (Sources.format("Boss, 1.5% in Classic in Zone"))
            )
        end)
    end)

    describe("isMakerOnly", function()
        it("detects the maker-only note case-insensitively", function()
            assert.is_true(Sources.isMakerOnly("Tailoring (Only its maker can wear it)"))
            assert.is_false(Sources.isMakerOnly("Tailoring"))
            assert.is_false(Sources.isMakerOnly(nil))
        end)
    end)

    describe("remainingByCategory", function()
        local function missing(source)
            return { done = false, target = { name = "X", source = source } }
        end

        it("counts the missing slots by the category of the item to get, in display order", function()
            local slots = {
                missing("Boss, The Deadmines"),
                missing("Quest: Something"),
                missing("Tailoring"),
                missing("Other Boss, Wailing Caverns"),
                missing("World drop"),
            }
            assert.are.same(
                { { "quest", 1 }, { "dungeon", 2 }, { "world", 1 }, { "profession", 1 } },
                Sources.remainingByCategory(slots)
            )
        end)

        it("hides categories with nothing missing and ignores finished slots", function()
            local slots = { missing("Tailoring"), { done = true }, { done = false } }
            assert.are.same({ { "profession", 1 } }, Sources.remainingByCategory(slots))
        end)

        it("sums to the number of missing slots", function()
            local slots = { missing("Quest: A"), missing("Quest: B"), missing("World drop") }
            local total = 0
            for _, entry in ipairs(Sources.remainingByCategory(slots)) do
                total = total + entry[2]
            end
            assert.are.equal(#slots, total)
        end)

        it("returns nothing when no slot is missing", function()
            assert.are.same({}, Sources.remainingByCategory({}))
        end)
    end)

    it("has an icon for every category", function()
        for _, category in ipairs(Sources.categories) do
            assert.is_string(Sources.categoryIcons[category])
        end
    end)

    it("normalizes slot names through the model", function()
        assert.are.equal(ForeverBiSModel.slotKey("Main Hand"), Sources.normalizeSlotName("Main Hand"))
    end)

    it("lists the dungeons the filter knows", function()
        assert.are.equal("The Deadmines", Sources.dungeons[1][2])
    end)
end)
