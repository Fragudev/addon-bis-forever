-- Entering a dungeon or raid: when the selected build lists items from it, offer them in a small notice.
local _, ns = ...

local ZoneWatcher = {}
ns.ZoneWatcher = ZoneWatcher

local Filters, Settings, Sources, Player, Lists, Zone, L =
    ns.Filters, ns.Settings, ns.Sources, ns.Player, ns.Lists, ns.Zone, ns.L

local NOTICE_SECONDS = 12
local shownAt = 0

--- Opens the window with the dungeon filter applied (the same state the filter bar edits).
local function openFiltered(dungeonKey)
    Filters.reset()
    Filters.toggleSource("dungeon")
    Filters.setDungeon(dungeonKey)
    ns.openWindow()
    ns.requestRender({ scrollTop = true })
end

--- Shows the notice when the player is inside a dungeon with listed items. Returns whether it did.
function ZoneWatcher.check()
    if not Settings.dungeonNoticeEnabled() then
        return false
    end
    local dungeon = Sources.matchDungeon(Zone.instanceName())
    if not dungeon then
        return false
    end
    local route = Settings.route()
    local view = Lists.view(route, Settings.effectivePhase(route, Player.level()))
    local count = view.data and Sources.countForDungeon(view.data.slots, dungeon[1]) or 0
    if count == 0 then
        return false
    end
    ns.DungeonNotice.show(L["%d BiS items in %s - click to view"]:format(count, dungeon[2]), function()
        openFiltered(dungeon[1])
    end)
    shownAt = GetTime()
    C_Timer.After(NOTICE_SECONDS, function()
        -- A newer notice keeps its own full time.
        if GetTime() - shownAt >= NOTICE_SECONDS then
            ns.DungeonNotice.hide()
        end
    end)
    return true
end

function ZoneWatcher.install()
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    watcher:SetScript("OnEvent", function()
        ZoneWatcher.check()
    end)
end
