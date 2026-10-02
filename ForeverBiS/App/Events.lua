-- Client events: item data and gear changes redraw the window (debounced); login binds the saved variables.
local _, ns = ...

local Events = {}
ns.Events = Events

local REDRAW_DELAY = 0.2

local renderPending = false

--- Item data arrives in bursts (one event per requested item); coalesce them into a single redraw per burst.
function Events.scheduleRender()
    if renderPending then
        return
    end
    renderPending = true
    C_Timer.After(REDRAW_DELAY, function()
        renderPending = false
        if ns.MainFrame.isShown() then
            ns.requestRender()
        end
    end)
end

local function onItemEvent(_, event, itemID, success)
    if not ns.MainFrame.isShown() then
        return
    end
    if event == "GET_ITEM_INFO_RECEIVED" then
        if success and ns.Items.isTracked(itemID) then
            Events.scheduleRender()
        end
    else
        Events.scheduleRender()
    end
end

-- Saved variables are only reliable once the client has loaded them, which happens after the files execute
-- (the global may even be replaced wholesale), so re-bind and auto-detect the class at PLAYER_LOGIN.
local function onLogin()
    ns.Settings.bind()
    ns.Settings.migrate()
    ns.Settings.applyDetectedClass(ns.Player.classToken())
    ns.MinimapButton.refresh()
    ns.requestRender()
end

function Events.install()
    local itemData = CreateFrame("Frame")
    itemData:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    itemData:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    itemData:RegisterEvent("BAG_UPDATE")
    itemData:SetScript("OnEvent", onItemEvent)

    local login = CreateFrame("Frame")
    login:RegisterEvent("PLAYER_LOGIN")
    login:SetScript("OnEvent", onLogin)
end
