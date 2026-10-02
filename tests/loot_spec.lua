local function loadLoot()
    WowStub.reset()
    return WowStub.loadFiles({ "Core/Loot.lua" }).Loot
end

local LINK = "|cffa335ee|Hitem:12345::::::::|h[Fine Cloak]|h|r"

describe("Loot", function()
    local Loot

    before_each(function()
        Loot = loadLoot()
    end)

    describe("patternFrom", function()
        it("matches a client format with each placeholder standing for any text", function()
            local pattern = Loot.patternFrom("%s receives loot: %s.")
            assert.is_truthy(("Bob receives loot: " .. LINK .. "."):match(pattern))
            assert.is_nil(("Bob has selected Need for: " .. LINK):match(pattern))
        end)

        it("treats punctuation in the format literally", function()
            local pattern = Loot.patternFrom("You receive loot: %s.")
            assert.is_truthy(("You receive loot: " .. LINK .. "."):match(pattern))
            assert.is_nil(("You receive loot: " .. LINK .. "!"):match(pattern))
        end)

        it("handles counts and positional placeholders", function()
            assert.is_truthy(
                ("Bob receives loot: " .. LINK .. "x3."):match(Loot.patternFrom("%s receives loot: %sx%d."))
            )
            assert.is_truthy(("Loot: " .. LINK):match(Loot.patternFrom("%2$s: %1$s")))
        end)
    end)

    describe("isReceived", function()
        local formats = { "%s receives loot: %s.", "You receive loot: %s." }

        it("accepts messages built from the client's receive formats", function()
            assert.is_true(Loot.isReceived("You receive loot: " .. LINK .. ".", formats))
            assert.is_true(Loot.isReceived("Bob receives loot: " .. LINK .. ".", formats))
        end)

        it("rejects roll and other messages that merely mention the item", function()
            assert.is_false(Loot.isReceived("Bob has selected Need for: " .. LINK, formats))
            assert.is_false(Loot.isReceived("You won: " .. LINK, formats))
        end)

        it("accepts every message when the client gives no formats", function()
            assert.is_true(Loot.isReceived("anything", {}))
        end)
    end)

    describe("item", function()
        it("extracts the id and the full link", function()
            local id, link = Loot.item("You receive loot: " .. LINK .. ".")
            assert.are.equal(12345, id)
            assert.are.equal(LINK, link)
        end)

        it("returns nil for a message without an item link", function()
            assert.is_nil(Loot.item("You receive 3 gold."))
        end)
    end)

    describe("bestEntry", function()
        local entries = {
            { route = "rogue", phase = "lvl30", rank = 3 },
            { route = "rogue", phase = "lvl30", rank = 1 },
            { route = "rogue", phase = "lvl20", rank = 1 },
            { route = "mage", phase = "lvl30", rank = 1 },
        }

        it("keeps only the selected route and phase and picks the best rank", function()
            assert.are.equal(1, Loot.bestEntry(entries, "rogue", "lvl30").rank)
            assert.are.equal("lvl30", Loot.bestEntry(entries, "rogue", "lvl30").phase)
        end)

        it("returns nil when the item is not BiS for that build and phase", function()
            assert.is_nil(Loot.bestEntry(entries, "rogue", "lvl40"))
            assert.is_nil(Loot.bestEntry(entries, "druid", "lvl30"))
            assert.is_nil(Loot.bestEntry({}, "rogue", "lvl30"))
        end)
    end)

    describe("isNewDrop", function()
        it("alerts the first time and ignores the same item right after", function()
            local state = {}
            assert.is_true(Loot.isNewDrop(state, 1, 100))
            assert.is_false(Loot.isNewDrop(state, 1, 101))
        end)

        it("treats the same item later on as a new drop", function()
            local state = {}
            Loot.isNewDrop(state, 1, 100)
            assert.is_true(Loot.isNewDrop(state, 1, 100 + Loot.DEDUP_SECONDS + 1))
        end)

        it("tracks items independently", function()
            local state = {}
            Loot.isNewDrop(state, 1, 100)
            assert.is_true(Loot.isNewDrop(state, 2, 100))
        end)
    end)
end)
