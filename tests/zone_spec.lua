local printed, realPrint

local function noticeButton()
    return ForeverBiSDungeonNotice
end

local function noticeText()
    local fontString = noticeButton().regions[1]
    return fontString and fontString.text
end

local function enter(name, kind)
    WowStub.instance = { name = name, type = kind or "party" }
    WowStub.ns.ZoneWatcher.check()
end

local function listedCount(dungeonKey)
    local route = WowStub.ns.Settings.route()
    local view = WowStub.ns.Lists.view(route, WowStub.ns.Settings.effectivePhase(route, 30))
    return WowStub.ns.Sources.countForDungeon(view.data.slots, dungeonKey)
end

describe("Zone notice", function()
    before_each(function()
        printed, realPrint = {}, _G.print
        _G.print = function(...)
            table.insert(printed, table.concat({ ... }, " "))
        end
        WowStub.load({ class = "rogue", build = "" })
    end)

    after_each(function()
        _G.print = realPrint
    end)

    it("shows a notice with the count when entering a dungeon with listed items", function()
        local count = listedCount("the deadmines")
        assert.is_true(count > 0, "fixture needs a listed Deadmines item")
        enter("The Deadmines")
        assert.is_true(noticeButton():IsShown())
        assert.are.equal(count .. " BiS items in The Deadmines - click to view", noticeText())
    end)

    it("recognizes name variants", function()
        enter("Deadmines")
        assert.is_true(noticeButton():IsShown())
    end)

    it("shows nothing outside instances", function()
        WowStub.instance = nil
        assert.is_false(WowStub.ns.ZoneWatcher.check())
        assert.is_false(noticeButton():IsShown())
    end)

    it("shows nothing in a dungeon the filter does not know", function()
        enter("The Stockade")
        assert.is_false(noticeButton():IsShown())
    end)

    it("shows nothing in a known dungeon when the selected build lists nothing from it", function()
        WowStub.load({ class = "rogue", build = "" }, function(data)
            for _, entry in pairs(data.lists) do
                for _, phase in pairs(entry.phases) do
                    phase.slots = {}
                end
            end
        end)
        enter("The Deadmines")
        assert.is_false(noticeButton():IsShown())
    end)

    it("opens the window with the dungeon filter applied when clicked", function()
        enter("The Deadmines")
        assert.is_false(ForeverBiSFrame:IsShown())
        WowStub.fire(noticeButton(), "OnClick")
        assert.is_false(noticeButton():IsShown())
        assert.is_true(ForeverBiSFrame:IsShown())
        assert.is_true(WowStub.ns.Filters.state.sources.dungeon)
        assert.are.equal("the deadmines", WowStub.ns.Filters.state.dungeon)
        assert.is_true(WowStub.hasText("Deadmines"))
    end)

    it("resets earlier filters when it applies the dungeon one", function()
        WowStub.ns.Filters.setSearch("zzz")
        enter("The Deadmines")
        WowStub.fire(noticeButton(), "OnClick")
        assert.are.equal("", WowStub.ns.Filters.state.search)
    end)

    it("fires on entering the world and on zone changes", function()
        local watcher
        for _, frame in ipairs(WowStub.frames) do
            if frame.events.ZONE_CHANGED_NEW_AREA then
                watcher = frame
            end
        end
        assert.is_true(watcher.events.PLAYER_ENTERING_WORLD)
        WowStub.instance = { name = "The Deadmines", type = "party" }
        WowStub.fire(watcher, "OnEvent", "ZONE_CHANGED_NEW_AREA")
        assert.is_true(noticeButton():IsShown())
    end)

    it("is turned off and on with /bis dungeon, and the choice is account-wide", function()
        SlashCmdList["FOREVERBIS"]("dungeon")
        assert.is_false(ForeverBiSDB.dungeonNotice)
        assert.is_truthy(printed[1]:find("off", 1, true))
        enter("The Deadmines")
        assert.is_false(noticeButton():IsShown())
        SlashCmdList["FOREVERBIS"]("dungeon")
        assert.is_true(WowStub.ns.Settings.dungeonNoticeEnabled())
        enter("The Deadmines")
        assert.is_true(noticeButton():IsShown())
    end)
end)
