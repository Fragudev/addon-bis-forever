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
        "ForeverBiS_Data_Leveling.lua",
        "ForeverBiS_Model.lua",
        "Core/Settings.lua",
        "Core/Catalog.lua",
        "Adapters/Items.lua",
        "Adapters/Player.lua",
        "App/Events.lua",
    })
    -- The model replaced ForeverBiSItemIDs with the bundled ids: track the fixture's one by hand.
    ns.Items.track(111)
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
        it("redraws once for a burst of equipment changes, and not for bag changes", function()
            local watcher = frameWithEvent("PLAYER_EQUIPMENT_CHANGED")
            assert.is_nil(frameWithEvent("BAG_UPDATE"))
            WowStub.fire(watcher, "OnEvent", "PLAYER_EQUIPMENT_CHANGED")
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
            WowStub.fire(frameWithEvent("PLAYER_EQUIPMENT_CHANGED"), "OnEvent", "PLAYER_EQUIPMENT_CHANGED")
            assert.are.equal(0, #timers)
        end)
    end)

    describe("login", function()
        it("re-binds the saved variables, detects the class and spec and redraws", function()
            _G.ForeverBiSDB = { class = "mage", build = "pve" }
            WowStub.player = { class = "Druid", token = "DRUID", level = 30 }
            local talents = _G.GetTalentTabInfo
            _G.GetTalentTabInfo = function(tab)
                return tab, "Tree", "", "icon", tab == 2 and 31 or 0
            end
            WowStub.fire(frameWithEvent("PLAYER_LOGIN"), "OnEvent")
            _G.GetTalentTabInfo = talents
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/feral", ForeverBiSCharDB.build)
            assert.is_table(ForeverBiSDB.minimap)
            assert.are.equal(1, renders)
        end)

        it("binds the saved variables once", function()
            local binds = 0
            local bind = ns.Settings.bind
            ns.Settings.bind = function(...)
                binds = binds + 1
                return bind(...)
            end
            WowStub.fire(frameWithEvent("PLAYER_LOGIN"), "OnEvent")
            assert.are.equal(1, binds)
        end)

        it("creates the saved variables on a first run", function()
            _G.ForeverBiSDB = nil
            WowStub.fire(frameWithEvent("PLAYER_LOGIN"), "OnEvent")
            assert.are.equal("rogue", ForeverBiSCharDB.class)
        end)
    end)
end)
