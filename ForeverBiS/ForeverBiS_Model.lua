-- Read model over ForeverBiSData (schema 2). It never touches ForeverBiSDB: saved variables are not
-- reliable while files execute. The UI still consumes the legacy globals built at the bottom of this file.
local _, ns = ...

local Model = {}
ns.Model = Model
ForeverBiSModel = Model

local function asTable(value)
    return type(value) == "table" and value or {}
end

local function rootData()
    local data = ForeverBiSData
    if type(data) == "table" and data.schema == 2 then
        return data
    end
    return {}
end

local function routeEntry(route)
    return asTable(asTable(rootData().lists)[route])
end

--- Ordered phases (oldest first) that the route actually has data for.
function Model.phases(route)
    local available = asTable(routeEntry(route).phases)
    local result, seen = {}, {}
    for _, phase in ipairs(asTable(rootData().phases)) do
        if type(phase) == "table" and type(phase.id) == "string" and available[phase.id] and not seen[phase.id] then
            seen[phase.id] = true
            result[#result + 1] = phase
        end
    end
    -- Phases missing from the global list are appended by id so their data stays reachable.
    local extra = {}
    for id in pairs(available) do
        if type(id) == "string" and not seen[id] then
            extra[#extra + 1] = id
        end
    end
    table.sort(extra)
    for _, id in ipairs(extra) do
        result[#result + 1] = { id = id, label = id }
    end
    return result
end

--- Id of the latest phase available for the route, or nil.
function Model.defaultPhase(route)
    local phases = Model.phases(route)
    local latest = phases[#phases]
    return latest and latest.id or nil
end

local function numericLevel(phase)
    local level = phase.level
    return type(level) == "number" and level == level and level or nil
end

--- The saved phase id when this route has data for it, otherwise nil (meaning "automatic").
function Model.availablePhase(route, phaseId)
    if type(phaseId) ~= "string" then
        return nil
    end
    for _, phase in ipairs(Model.phases(route)) do
        if phase.id == phaseId then
            return phaseId
        end
    end
    return nil
end

--- Phase id a character of the given level should see by default: the numeric phase with the smallest level that is
--- >= the player's level. Above every numeric phase, or with a missing/invalid level, the final phase wins; phases
--- without a numeric level (e.g. "current") count as endgame and sort after all numeric ones. Nil for an unknown route.
function Model.phaseForLevel(route, level)
    local numeric, endgame = {}, {}
    for index, phase in ipairs(Model.phases(route)) do
        if numericLevel(phase) then
            numeric[#numeric + 1] = { id = phase.id, level = phase.level, index = index }
        else
            endgame[#endgame + 1] = phase.id
        end
    end
    table.sort(numeric, function(a, b)
        if a.level ~= b.level then
            return a.level < b.level
        end
        return a.index < b.index
    end)
    if type(level) == "number" and level == level and level >= 1 then
        for _, phase in ipairs(numeric) do
            if phase.level >= level then
                return phase.id
            end
        end
    end
    if #endgame > 0 then
        return endgame[#endgame]
    end
    return numeric[#numeric] and numeric[#numeric].id or nil
end

--- Phase the UI shows: the saved choice when the route has it, otherwise the one for the player's level.
function Model.effectivePhase(route, savedPhase, level)
    return Model.availablePhase(route, savedPhase) or Model.phaseForLevel(route, level)
end

function Model.label(route)
    local label = routeEntry(route).label
    return type(label) == "string" and label or nil
end

local function sourceText(source)
    return type(source) == "table" and type(source.text) == "string" and source.text or ""
end

local function legacySlot(slot)
    if type(slot) ~= "table" or type(slot.slot) ~= "string" then
        return nil
    end
    local items = {}
    for _, item in ipairs(asTable(slot.items)) do
        if type(item) == "table" and type(item.name) == "string" then
            items[#items + 1] = { item.name, sourceText(item.source) }
        end
    end
    local enchants = {}
    for _, enchant in ipairs(asTable(slot.enchants)) do
        if type(enchant) == "table" and type(enchant.effect) == "string" then
            local row = { enchant.effect, enchant.spell or "", enchant.source or "" }
            row[4] = enchant.formulaId
            enchants[#enchants + 1] = row
        end
    end
    if #enchants > 0 then
        return { slot.slot, items, enchants }
    end
    return { slot.slot, items }
end

--- A list in the legacy shape the UI reads: { title, slots = { { slotName, items[, enchants] }, ... } }.
--- Without a phase id the latest available phase is used. Returns nil when the data does not exist.
function Model.list(route, phaseId)
    phaseId = phaseId or Model.defaultPhase(route)
    local phase = phaseId and asTable(routeEntry(route).phases)[phaseId]
    if type(phase) ~= "table" then
        return nil
    end
    local slots = {}
    for _, slot in ipairs(asTable(phase.slots)) do
        slots[#slots + 1] = legacySlot(slot)
    end
    return { title = phase.title, slots = slots }
end

local function sortedRoutes()
    local routes = {}
    for route in pairs(asTable(rootData().lists)) do
        if type(route) == "string" then
            routes[#routes + 1] = route
        end
    end
    table.sort(routes)
    return routes
end

local bisIndex -- built lazily from ForeverBiSData; reset by buildLegacy

local function addIndexEntry(bucket, key, entry)
    local list = bucket[key]
    if not list then
        list = {}
        bucket[key] = list
    end
    list[#list + 1] = entry
end

--- Reverse index: item id -> entries, plus item name -> entries for rows that carry no id.
local function buildBisIndex()
    local index = { byId = {}, byName = {} }
    for _, route in ipairs(sortedRoutes()) do
        local class = route:match("^[^/]+") or route
        local label = Model.label(route) or route
        for _, phase in ipairs(Model.phases(route)) do
            for _, slot in ipairs(asTable(asTable(routeEntry(route).phases[phase.id]).slots)) do
                local slotName = type(slot) == "table" and slot.slot
                if type(slotName) == "string" then
                    local seen = {} -- an item repeated inside one slot list keeps only its best rank
                    for rank, item in ipairs(asTable(slot.items)) do
                        if type(item) == "table" then
                            local byId = type(item.id) == "number"
                            local key = byId and item.id or item.name
                            if (byId or type(key) == "string") and not seen[key] then
                                seen[key] = true
                                addIndexEntry(byId and index.byId or index.byName, key, {
                                    route = route,
                                    class = class,
                                    phase = phase.id,
                                    phaseLabel = phase.label or phase.id,
                                    slot = slotName,
                                    rank = rank,
                                    label = label,
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    return index
end

--- Every place an item is BiS, as { route, class, phase, phaseLabel, slot, rank, label } in route, phase and slot order.
--- The id is matched first; the exact name only matches data rows that have no id. Unknown items give an empty list.
function Model.bisEntries(itemId, itemName)
    bisIndex = bisIndex or buildBisIndex()
    local found
    if type(itemId) == "number" then
        found = bisIndex.byId[itemId]
    end
    if not found and type(itemName) == "string" then
        found = bisIndex.byName[itemName]
    end
    local result = {}
    for _, entry in ipairs(found or {}) do
        local copy = {}
        for field, value in pairs(entry) do
            copy[field] = value
        end
        result[#result + 1] = copy
    end
    return result
end

local slotAliases = {
    ["head"] = "Head",
    ["neck"] = "Neck",
    ["shoulder"] = "Shoulder",
    ["back"] = "Back",
    ["chest"] = "Chest",
    ["wrist"] = "Wrist",
    ["hands"] = "Hands",
    ["waist"] = "Waist",
    ["legs"] = "Legs",
    ["feet"] = "Feet",
    ["finger"] = "Finger",
    ["trinket"] = "Trinket",
    ["relic"] = "Ranged",
    ["main hand"] = "Main Hand",
    ["mainhand"] = "Main Hand",
    ["two-hand weapon"] = "Main Hand",
    ["two-handed weapon"] = "Main Hand",
    ["two hand weapon"] = "Main Hand",
    ["two handed weapon"] = "Main Hand",
    ["off hand"] = "Off Hand",
    ["offhand"] = "Off Hand",
    ["off hand: held item"] = "Off Hand",
    ["off hand: shield"] = "Off Hand",
    ["ranged"] = "Ranged",
}

--- Canonical slot key of a list slot name ("Two-hand weapon" is "Main Hand"); unknown names come back unchanged.
function Model.slotKey(name)
    return slotAliases[string.lower(name or "")] or name
end

-- Equipment positions that count towards progress, with how many inventory slots each one has.
local slotCapacity = {
    ["Head"] = 1,
    ["Neck"] = 1,
    ["Shoulder"] = 1,
    ["Back"] = 1,
    ["Chest"] = 1,
    ["Wrist"] = 1,
    ["Hands"] = 1,
    ["Waist"] = 1,
    ["Legs"] = 1,
    ["Feet"] = 1,
    ["Finger"] = 2,
    ["Trinket"] = 2,
    ["Main Hand"] = 1,
    ["Off Hand"] = 1,
    ["Ranged"] = 1,
}

local function itemIdOf(owned, name)
    local resolver = owned.itemId
    local id
    if type(resolver) == "function" then
        id = resolver(name)
    elseif type(ForeverBiSItemIDs) == "table" then
        id = ForeverBiSItemIDs[name]
    end
    return type(id) == "number" and id or nil
end

local function inBags(owned, id)
    local count = type(owned.bags) == "function" and owned.bags(id)
    return type(count) == "number" and count > 0
end

--- Progress of one list slot (one variant) for a position that has `capacity` inventory slots.
--- The weakest equipped rank (nil entries count as infinitely bad) decides which listed items would be upgrades.
local function evaluateVariant(slot, capacity, owned, equippedIds)
    local items, rankById = {}, {}
    for _, item in ipairs(asTable(slot[2])) do
        if type(item) == "table" and type(item[1]) == "string" then
            local id = itemIdOf(owned, item[1])
            local rank = #items + 1
            items[rank] = { name = item[1], source = type(item[2]) == "string" and item[2] or "", id = id, rank = rank }
            if id and not rankById[id] then
                rankById[id] = rank
            end
        end
    end
    local equippedRanks, equipped = {}, {}
    for _, id in ipairs(equippedIds) do
        if type(id) == "number" and not equipped[id] and #equippedRanks < capacity then
            equipped[id] = true
            equippedRanks[#equippedRanks + 1] = rankById[id] or math.huge
        end
    end
    local best, weakest = math.huge, #equippedRanks < capacity and math.huge or 0
    for _, rank in ipairs(equippedRanks) do
        best = math.min(best, rank)
        weakest = math.max(weakest, rank)
    end
    local target
    for _, item in ipairs(items) do
        local isCandidate = item.rank < weakest and not (item.id and equipped[item.id])
        if isCandidate then
            local held = item.id and inBags(owned, item.id)
            if held then
                target = { name = item.name, rank = item.rank, source = item.source, inBags = true }
                break
            end
            target = target or { name = item.name, rank = item.rank, source = item.source }
        end
    end
    return { rank = best < math.huge and best or nil, target = target, done = target == nil, score = best }
end

--- How close the player is to a list. `list` is the legacy shape; `owned` describes the player without any game call:
---   owned.equipped  table: canonical slot key ("Head", "Finger", "Main Hand", see slotKey) -> array of equipped item ids
---   owned.bags      function(itemId) -> number of copies in bags (optional)
---   owned.itemId    function(itemName) -> item id or nil (optional; defaults to ForeverBiSItemIDs)
--- Positions are the paper-doll ones: every list slot whose name maps to the same key (Main hand, Two-hand weapon,
--- Off hand: shield...) is a variant of one position, counted once, and the variant the player is closest to wins.
--- Returns { total, bis, listed, slots = { { slot, rank, target, done }, ... } }.
function Model.progress(list, owned)
    owned = asTable(owned)
    local equippedBySlot = asTable(owned.equipped)
    local order, variants = {}, {}
    for _, slot in ipairs(asTable(asTable(list).slots)) do
        local key = type(slot) == "table" and type(slot[1]) == "string" and Model.slotKey(slot[1])
        if key and slotCapacity[key] and type(slot[2]) == "table" and #slot[2] > 0 then
            if not variants[key] then
                variants[key] = {}
                order[#order + 1] = key
            end
            variants[key][#variants[key] + 1] = slot
        end
    end
    local result = { total = 0, bis = 0, listed = 0, slots = {} }
    for _, key in ipairs(order) do
        local equippedIds = asTable(equippedBySlot[key])
        local chosen
        for _, slot in ipairs(variants[key]) do
            local outcome = evaluateVariant(slot, slotCapacity[key], owned, equippedIds)
            if not chosen or outcome.score < chosen.score then
                chosen = outcome
            end
        end
        result.total = result.total + 1
        if chosen.done then
            result.bis = result.bis + 1
        end
        if chosen.rank then
            result.listed = result.listed + 1
        end
        result.slots[#result.slots + 1] = { slot = key, rank = chosen.rank, target = chosen.target, done = chosen.done }
    end
    return result
end

--- (Re)build ForeverBiSLists, ForeverBiSItemIDs and ForeverBiSBuildLabels from ForeverBiSData.
function Model.buildLegacy()
    bisIndex = nil
    local lists, itemIDs, labels = {}, {}, {}
    for _, route in ipairs(sortedRoutes()) do
        lists[route] = Model.list(route)
        labels[route] = Model.label(route)
        for _, phase in ipairs(Model.phases(route)) do
            for _, slot in ipairs(asTable(routeEntry(route).phases[phase.id].slots)) do
                for _, item in ipairs(asTable(asTable(slot).items)) do
                    if type(item) == "table" and type(item.name) == "string" and type(item.id) == "number" then
                        itemIDs[item.name] = item.id
                    end
                end
            end
        end
    end
    ForeverBiSLists, ForeverBiSItemIDs, ForeverBiSBuildLabels = lists, itemIDs, labels
end

Model.buildLegacy()
