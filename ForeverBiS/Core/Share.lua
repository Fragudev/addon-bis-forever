-- Turns a list into chat messages: which slots a query means and how to split text under the chat limit.
-- Pure: item links come in as strings and nothing is sent from here.
local _, ns = ...

local Share = {}
ns.Share = Share

-- Longest chat message the client accepts is 255 characters.
Share.CHAT_LIMIT = 254

local function squash(text)
    return (string.lower(text or ""):gsub("[^%w]", ""))
end

--- The list slots a typed name refers to, in list order. A name matches a heading exactly ("Two-hand weapon"),
--- its position ("main hand" covers every main hand variant) or the start of a heading ("off").
function Share.matchSlots(slots, query)
    local wanted = squash(query)
    if wanted == "" then
        return {}
    end
    local function collect(matches)
        local found = {}
        for _, slot in ipairs(slots) do
            if matches(slot) then
                found[#found + 1] = slot
            end
        end
        return found
    end
    local found = collect(function(slot)
        return squash(slot[1]) == wanted
    end)
    if #found == 0 then
        found = collect(function(slot)
            return squash(ns.Sources.normalizeSlotName(slot[1])) == wanted
        end)
    end
    if #found == 0 then
        found = collect(function(slot)
            return squash(slot[1]):sub(1, #wanted) == wanted
        end)
    end
    return found
end

--- The slot headings of a list, for the "valid slots" help line.
function Share.slotNames(slots)
    local names = {}
    for _, slot in ipairs(slots) do
        names[#names + 1] = slot[1]
    end
    return names
end

--- Joins parts into messages that each start with the prefix and stay within the limit.
--- A part that does not fit after the others starts the next message.
function Share.chunk(prefix, parts, separator, limit)
    separator, limit = separator or ", ", limit or Share.CHAT_LIMIT
    local messages, current, hasParts = {}, prefix, false
    for _, part in ipairs(parts) do
        local candidate = hasParts and (current .. separator .. part) or (current .. part)
        if #candidate > limit and hasParts then
            messages[#messages + 1] = current
            current = prefix .. part
        else
            current = candidate
        end
        hasParts = true
    end
    if hasParts then
        messages[#messages + 1] = current
    end
    return messages
end
