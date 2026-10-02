local printed, realPrint

--- A BiS item for the rogue's current route and phase: its id, name and the entry the alert should describe.
local function bisItem()
    local route = WowStub.ns.Settings.route()
    local phaseId = WowStub.ns.Settings.effectivePhase(route, 30)
    local item = ForeverBiSModel.list(route, phaseId).slots[1][2][1]
    return ForeverBiSItemIDs[item[1]], item[1]
end

local function message(prefix, id, name)
    return prefix .. "|cffa335ee|Hitem:" .. id .. "::::::::|h[" .. name .. "]|h|r."
end

local function lootWatcher()
    for _, frame in ipairs(WowStub.frames) do
        if frame.events.CHAT_MSG_LOOT then
            return frame
        end
    end
end

describe("Alerts", function()
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

    it("listens for loot messages", function()
        assert.is_truthy(lootWatcher())
    end)

    it("alerts when the player receives a BiS item, worded like the tooltip", function()
        local id, name = bisItem()
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", message("You receive loot: ", id, name))
        assert.are.equal(1, #printed)
        assert.is_truthy(printed[1]:find("Forever BiS", 1, true))
        assert.is_truthy(printed[1]:find("[" .. name .. "]", 1, true))
        assert.is_truthy(printed[1]:find("BiS #1 ", 1, true))
        assert.are.equal(1, #WowStub.sounds)
    end)

    it("alerts when another group member receives it", function()
        local id, name = bisItem()
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", message("Bob receives loot: ", id, name))
        assert.are.equal(1, #printed)
    end)

    it("alerts once per drop", function()
        local id, name = bisItem()
        local text = message("Bob receives loot: ", id, name)
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", text)
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", text)
        assert.are.equal(1, #printed)
        WowStub.now = WowStub.now + 60
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", text)
        assert.are.equal(2, #printed)
    end)

    it("does not alert for an item that is not on the selected build", function()
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", message("You receive loot: ", 987654, "Junk"))
        assert.are.equal(0, #printed)
        assert.are.equal(0, #WowStub.sounds)
    end)

    it("does not alert for an item that is BiS only for another class", function()
        local mageRoute = "mage"
        local item = ForeverBiSModel.list(mageRoute, ForeverBiSModel.effectivePhase(mageRoute, nil, 30)).slots[1][2][1]
        local id = ForeverBiSItemIDs[item[1]]
        if #ForeverBiSModel.bisEntries(id, item[1]) == 1 then
            WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", message("You receive loot: ", id, item[1]))
            assert.are.equal(0, #printed)
        end
    end)

    it("ignores roll messages that only mention the item", function()
        local id, name = bisItem()
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", message("Bob has selected Need for: ", id, name))
        assert.are.equal(0, #printed)
    end)

    it("stays quiet when alerts are turned off", function()
        local id, name = bisItem()
        SlashCmdList["FOREVERBIS"]("alerts")
        WowStub.fire(lootWatcher(), "OnEvent", "CHAT_MSG_LOOT", message("You receive loot: ", id, name))
        assert.are.equal(1, #printed) -- only the "alerts: off" confirmation
        assert.is_truthy(printed[1]:find("off", 1, true))
        assert.are.equal(0, #WowStub.sounds)
    end)

    it("toggles with /bis alerts and keeps the choice account-wide", function()
        assert.is_true(WowStub.ns.Settings.alertsEnabled())
        SlashCmdList["FOREVERBIS"]("alerts")
        assert.is_false(ForeverBiSDB.alerts)
        SlashCmdList["FOREVERBIS"]("alerts")
        assert.is_true(WowStub.ns.Settings.alertsEnabled())
        assert.are.equal("Forever BiS alerts: on", printed[2])
    end)

    it("ignores events without a text message", function()
        assert.is_false(WowStub.ns.Alerts.onLoot(nil))
    end)
end)
