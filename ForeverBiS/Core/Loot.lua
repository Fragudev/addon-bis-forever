-- Reads loot chat messages and decides which are alerts. Pure: formats, time and entries are passed in.
local _, ns = ...

local Loot = {}
ns.Loot = Loot

-- Two identical loot messages this close together are the same drop.
Loot.DEDUP_SECONDS = 3

--- A Lua pattern matching messages built from a client format string such as "%s receives loot: %s.".
function Loot.patternFrom(format)
    local text = format:gsub("%%%d%$s", "\1"):gsub("%%s", "\1"):gsub("%%d", "\2")
    text = text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    text = text:gsub("\1", ".+"):gsub("\2", "%%d+")
    return "^" .. text .. "$"
end

--- Whether the message is a "receives loot" one (what a player actually got), judged by the client's own formats.
--- Without any format every message counts, so a client that lacks them still alerts.
function Loot.isReceived(message, formats)
    if #formats == 0 then
        return true
    end
    for _, format in ipairs(formats) do
        if message:match(Loot.patternFrom(format)) then
            return true
        end
    end
    return false
end

--- The item id and link in a chat message, or nil without an item link.
function Loot.item(message)
    local id = message:match("|Hitem:(%d+)")
    if not id then
        return nil
    end
    local link = message:match("(|c%x+|Hitem:%d+[^|]*|h%[[^%]]*%]|h|r)")
    return tonumber(id), link
end

--- The best-ranked entry for the selected route and phase, or nil when the item is not BiS there.
--- entries are Model.bisEntries results.
function Loot.bestEntry(entries, route, phaseId)
    local best
    for _, entry in ipairs(entries) do
        if entry.route == route and entry.phase == phaseId and (not best or entry.rank < best.rank) then
            best = entry
        end
    end
    return best
end

--- Records the item as seen at `now` and returns whether it is a new drop (not seen in the last few seconds).
--- state is a table the caller keeps between calls.
function Loot.isNewDrop(state, itemId, now)
    local last = state[itemId]
    state[itemId] = now
    return last == nil or now - last > Loot.DEDUP_SECONDS
end
