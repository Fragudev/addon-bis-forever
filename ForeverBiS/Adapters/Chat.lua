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
