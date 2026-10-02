local function loadShare()
    WowStub.reset()
    WowStub.loadFiles({
        "ForeverBiS_Locale.lua",
        "ForeverBiS_Data.lua",
        "ForeverBiS_Model.lua",
        "Core/Sources.lua",
        "Core/Share.lua",
    })
    return WowStub.ns.Share
end

local SLOTS = {
    { "Head", { { "A", "x" } } },
    { "Finger", { { "B", "x" } } },
    { "Two-hand weapon", { { "C", "x" } } },
    { "Main hand", { { "D", "x" } } },
    { "Off hand: held item", { { "E", "x" } } },
}

local function headings(matched)
    local names = {}
    for _, slot in ipairs(matched) do
        table.insert(names, slot[1])
    end
    return names
end

describe("Share", function()
    local Share

    before_each(function()
        Share = loadShare()
    end)

    describe("matchSlots", function()
        it("matches a heading regardless of case, spaces and punctuation", function()
            assert.are.same({ "Head" }, headings(Share.matchSlots(SLOTS, "HEAD")))
            assert.are.same({ "Two-hand weapon" }, headings(Share.matchSlots(SLOTS, "two hand weapon")))
        end)

        it("prefers an exact heading over the position it belongs to", function()
            assert.are.same({ "Main hand" }, headings(Share.matchSlots(SLOTS, "main hand")))
        end)

        it("matches a position when no heading is exactly that", function()
            local variants = { { "Two-hand weapon", { { "C", "x" } } }, { "Head", { { "A", "x" } } } }
            assert.are.same({ "Two-hand weapon" }, headings(Share.matchSlots(variants, "main hand")))
        end)

        it("matches the start of a heading", function()
            assert.are.same({ "Off hand: held item" }, headings(Share.matchSlots(SLOTS, "off")))
            assert.are.same({ "Finger" }, headings(Share.matchSlots(SLOTS, "fin")))
        end)

        it("matches nothing for an unknown or empty name", function()
            assert.are.same({}, Share.matchSlots(SLOTS, "tabard"))
            assert.are.same({}, Share.matchSlots(SLOTS, ""))
            assert.are.same({}, Share.matchSlots(SLOTS, "   "))
            assert.are.same({}, Share.matchSlots(SLOTS, nil))
        end)
    end)

    it("lists the slot headings", function()
        assert.are.same(
            { "Head", "Finger", "Two-hand weapon", "Main hand", "Off hand: held item" },
            Share.slotNames(SLOTS)
        )
    end)

    describe("chunk", function()
        it("keeps everything in one message when it fits", function()
            assert.are.same({ "BiS: a, b, c" }, Share.chunk("BiS: ", { "a", "b", "c" }))
        end)

        it("starts a new message, repeating the prefix, when the next part would pass the limit", function()
            local messages = Share.chunk("P: ", { "aaaa", "bbbb", "cccc" }, ", ", 12)
            assert.are.same({ "P: aaaa", "P: bbbb", "P: cccc" }, messages)
        end)

        it("packs as many parts as fit in each message", function()
            local messages = Share.chunk("", { "aa", "bb", "cc", "dd" }, "-", 5)
            assert.are.same({ "aa-bb", "cc-dd" }, messages)
        end)

        it("keeps every message under the chat limit", function()
            local parts = {}
            for index = 1, 40 do
                parts[index] = "|cffffffff|Hitem:" .. index .. "::::::::|h[Some Item Name " .. index .. "]|h|r"
            end
            local messages = Share.chunk("Rogue PvE BiS: ", parts)
            assert.is_true(#messages > 1)
            for _, message in ipairs(messages) do
                assert.is_true(#message < 255, #message)
            end
        end)

        it("returns no messages without parts", function()
            assert.are.same({}, Share.chunk("P: ", {}))
        end)

        it("still sends a single part that is longer than the limit", function()
            assert.are.same({ "P: " .. string.rep("x", 20) }, Share.chunk("P: ", { string.rep("x", 20) }, ", ", 10))
        end)
    end)
end)
