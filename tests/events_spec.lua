local timers, renders, shown, ns

local function frameWithEvent(event)
    for _, frame in ipairs(WowStub.frames) do
        if frame.events[event] then
            return frame
        end
    end
end

local function load()
    WowStub.reset()
    _G.ForeverBiSDB = { class = "rogue", build = "pve" }
    _G.ForeverBiSItemIDs = { ["Tracked Item"] = 111 }
    ns = WowStub.loadFiles({
        "Core/Settings.lua",
        "Core/Catalog.lua",
        "Adapters/Items.lua",
        "Adapters/Player.lua",
        "App/Events.lua",
    })
    timers, renders, shown = {}, 0, true
    -- Unlike the stub's immediate timers, keep callbacks queued so a burst can be observed.
    _G.C_Timer = {
        After = function(_, callback)
            table.insert(timers, callback)
        end,
    }
    ns.MainFrame = {
        isShown = function()
            return shown
        end,
    }
    ns.MinimapButton = { refresh = function() end }
    ns.requestRender = function()
        renders = renders + 1
    end
    ns.Events.install()
end

local function runTimers()
    local pending = timers
    timers = {}
    for _, callback in ipairs(pending) do
        callback()
    end
end

describe("Events", function()
    local realTimer = _G.C_Timer

    before_each(load)

    after_each(function()
        _G.C_Timer = realTimer
        _G.ForeverBiSDB, _G.ForeverBiSItemIDs = nil, nil
    end)

    describe("scheduleRender", function()
        it("coalesces a burst into one delayed redraw", function()
            ns.Events.scheduleRender()
            ns.Events.scheduleRender()
            ns.Events.scheduleRender()
            assert.are.equal(1, #timers)
            assert.are.equal(0, renders)
            runTimers()
            assert.are.equal(1, renders)
        end)

        it("schedules again once the previous redraw ran", function()
            ns.Events.scheduleRender()
            runTimers()
            ns.Events.scheduleRender()
            runTimers()
            assert.are.equal(2, renders)
        end)

        it("skips the redraw when the window was closed in the meantime", function()
            ns.Events.scheduleRender()
            shown = false
            runTimers()
            assert.are.equal(0, renders)
        end)
    end)

    describe("item and gear events", function()
        it("redraws for bag and equipment changes", function()
            local watcher = frameWithEvent("BAG_UPDATE")
            WowStub.fire(watcher, "OnEvent", "BAG_UPDATE")
            WowStub.fire(watcher, "OnEvent", "PLAYER_EQUIPMENT_CHANGED")
            runTimers()
            assert.are.equal(1, renders)
        end)

        it("redraws for received item data only when the addon tracks the item", function()
            local watcher = frameWithEvent("GET_ITEM_INFO_RECEIVED")
            WowStub.fire(watcher, "OnEvent", "GET_ITEM_INFO_RECEIVED", 999, true)
            assert.are.equal(0, #timers)
            WowStub.fire(watcher, "OnEvent", "GET_ITEM_INFO_RECEIVED", 111, false)
            assert.are.equal(0, #timers)
            WowStub.fire(watcher, "OnEvent", "GET_ITEM_INFO_RECEIVED", 111, true)
            assert.are.equal(1, #timers)
        end)

        it("ignores events while the window is closed", function()
            shown = false
            WowStub.fire(frameWithEvent("BAG_UPDATE"), "OnEvent", "BAG_UPDATE")
            assert.are.equal(0, #timers)
        end)
    end)

    describe("login", function()
        it("re-binds the saved variables, detects the class and redraws", function()
            _G.ForeverBiSDB = { class = "mage", build = "pve" }
            WowStub.player = { class = "Druid", token = "DRUID", level = 30 }
            WowStub.fire(frameWithEvent("PLAYER_LOGIN"), "OnEvent")
            assert.are.equal("druid", ForeverBiSDB.class)
            assert.is_table(ForeverBiSDB.minimap)
            assert.are.equal(1, renders)
        end)

        it("creates the saved variables on a first run", function()
            _G.ForeverBiSDB = nil
            WowStub.fire(frameWithEvent("PLAYER_LOGIN"), "OnEvent")
            assert.are.equal("rogue", ForeverBiSDB.class)
        end)
    end)
end)
