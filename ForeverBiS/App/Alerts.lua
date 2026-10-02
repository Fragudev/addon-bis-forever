-- BiS loot alerts: when someone in the group receives an item that is BiS for the selected build and phase,
-- print a highlighted message (worded like the tooltip) and play a short sound.
local _, ns = ...

local Alerts = {}
ns.Alerts = Alerts

local Settings, Player, Loot, Chat, L = ns.Settings, ns.Player, ns.Loot, ns.Chat, ns.L

-- Recent drops by item id, so the same drop never alerts twice.
local seen = {}

--- The alert text for a loot message, or nil when it needs none.
local function alertFor(message)
    local itemId, link = Loot.item(message)
    if not itemId or not Loot.isReceived(message, Chat.lootFormats()) then
        return nil
    end
    local route = Settings.route()
    local phaseId = Settings.effectivePhase(route, Player.level())
    local entry = Loot.bestEntry(ForeverBiSModel.bisEntries(itemId), route, phaseId)
    if not entry or not Loot.isNewDrop(seen, itemId, GetTime()) then
        return nil
    end
    local description = L["BiS #%d %s - %s (%s)"]:format(entry.rank, entry.slot, entry.label, entry.phaseLabel)
    return "|cffffe35b" .. L["Forever BiS"] .. "|r " .. (link or "") .. " - " .. description
end

--- Handles one CHAT_MSG_LOOT message. Returns whether it alerted.
function Alerts.onLoot(message)
    if not Settings.alertsEnabled() or type(message) ~= "string" then
        return false
    end
    local text = alertFor(message)
    if not text then
        return false
    end
    print(text)
    Chat.playAlertSound()
    return true
end

function Alerts.install()
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("CHAT_MSG_LOOT")
    watcher:SetScript("OnEvent", function(_, _, message)
        Alerts.onLoot(message)
    end)
end
