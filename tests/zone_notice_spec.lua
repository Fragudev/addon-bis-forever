describe("Zone notice on entry", function()
    local shown

    --- Counts the notices the watcher actually shows, keeping the real show function.
    local function countNotices()
        local notice = WowStub.ns.DungeonNotice
        local original = notice.show
        notice.show = function(...)
            shown = shown + 1
            return original(...)
        end
    end

    local function watcher()
        for _, frame in ipairs(WowStub.frames) do
            if frame.events.ZONE_CHANGED_NEW_AREA then
                return frame
            end
        end
    end

    before_each(function()
        shown = 0
        -- The rogue leveling lists have their Deadmines and Stockade drops at level 20.
        WowStub.load({ class = "rogue", build = "", phase = "lvl20" })
        countNotices()
    end)

    it("shows one notice when the entry events fire for the same instance", function()
        WowStub.instance = { name = "The Deadmines", type = "party" }
        WowStub.fire(watcher(), "OnEvent", "PLAYER_ENTERING_WORLD")
        WowStub.fire(watcher(), "OnEvent", "ZONE_CHANGED_NEW_AREA")
        assert.are.equal(1, shown)
        assert.is_true(ForeverBiSDungeonNotice:IsShown())
    end)

    it("shows the notice again for the same instance after the window has passed", function()
        WowStub.instance = { name = "The Deadmines", type = "party" }
        WowStub.ns.ZoneWatcher.check()
        WowStub.now = 6
        WowStub.ns.ZoneWatcher.check()
        assert.are.equal(2, shown)
    end)
end)
