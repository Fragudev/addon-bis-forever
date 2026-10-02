-- Chat output and the edit box. The only place that sends messages or reads the group and modifier state.
local _, ns = ...

local Chat = {}
ns.Chat = Chat

--- RAID in a raid, PARTY in a group, otherwise SAY.
function Chat.channel()
    if IsInRaid and IsInRaid() then
        return "RAID"
    end
    if IsInGroup and IsInGroup() then
        return "PARTY"
    end
    return "SAY"
end

function Chat.send(message)
    SendChatMessage(message, Chat.channel())
end

--- Puts a link in the chat edit box (opening it when closed). Returns whether the client took it.
function Chat.insertLink(link)
    return ChatEdit_InsertLink ~= nil and ChatEdit_InsertLink(link) == true
end

--- Whether the link modifier (shift) is held right now.
function Chat.linkModifierHeld()
    return IsShiftKeyDown ~= nil and IsShiftKeyDown() == true
end

local LOOT_FORMAT_NAMES = {
    "LOOT_ITEM",
    "LOOT_ITEM_SELF",
    "LOOT_ITEM_MULTIPLE",
    "LOOT_ITEM_SELF_MULTIPLE",
    "LOOT_ITEM_PUSHED",
    "LOOT_ITEM_PUSHED_SELF",
}

--- The client's "receives loot" message formats (own loot and other players', single and stacked).
function Chat.lootFormats()
    local formats = {}
    for _, name in ipairs(LOOT_FORMAT_NAMES) do
        if type(_G[name]) == "string" then
            formats[#formats + 1] = _G[name]
        end
    end
    return formats
end

-- The raid warning sound: short and distinct from the usual chat noises.
local ALERT_SOUND = 8959

function Chat.playAlertSound()
    if PlaySound then
        PlaySound(ALERT_SOUND)
    end
end
