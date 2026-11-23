-- Read model over ForeverBiSData (schema 3: several sources, each with schema 2 phases and lists). It never touches ForeverBiSDB: saved variables are not
-- reliable while files execute. The UI still consumes the legacy globals built at the bottom of this file.
local _, ns = ...

local Model = {}
ns.Model = Model
ForeverBiSModel = Model

local function asTable(value)
    return type(value) == "table" and value or {}
end

Model.DEFAULT_SOURCE = "leveling"

local activeId

-- The sources the data files registered, keyed by id; empty while the data is missing or has another schema.
local function allSources()
    local data = ForeverBiSData
    if type(data) == "table" and data.schema == 3 and type(data.sources) == "table" then
        return data.sources
    end
    return {}
end

local function rootData()
    local source = allSources()[activeId]
    return type(source) == "table" and source or {}
end

--- Available sources as { { id, label, url }, ... }, ordered by their `order` then id.
function Model.sources()
    local result = {}
    for id, source in pairs(allSources()) do
        if type(id) == "string" and type(source) == "table" then
            local order = type(source.order) == "number" and source.order or math.huge
            result[#result + 1] = {
                id = id,
                label = type(source.label) == "string" and source.label or id,
                url = type(source.url) == "string" and source.url or nil,
                order = order,
            }
        end
    end
    table.sort(result, function(a, b)
        if a.order ~= b.order then
            return a.order < b.order
        end
        return a.id < b.id
    end)
    for _, entry in ipairs(result) do
        entry.order = nil
    end
    return result
end

--- Id of the source the model currently reads (nil only when no data is available at all).
function Model.activeSource()
    return activeId
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

--- Bracket the BiS window shows by default: the numeric phase with the highest level at or below the player's level.
--- Below every bracket (or with a missing/invalid level) the lowest one wins. A route without numeric phases falls
--- back to its default phase; nil for an unknown route.
function Model.bracketForLevel(route, level)
    local best, lowest
    for _, phase in ipairs(Model.phases(route)) do
        local phaseLevel = numericLevel(phase)
        if phaseLevel then
            if not lowest or phaseLevel < lowest.level then
                lowest = { id = phase.id, level = phaseLevel }
            end
            if type(level) == "number" and phaseLevel <= level and (not best or phaseLevel > best.level) then
                best = { id = phase.id, level = phaseLevel }
            end
        end
    end
    local chosen = best or lowest
    return chosen and chosen.id or Model.defaultPhase(route)
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

--- The rows of the BiS window for a route and phase: { { slot, key, items = { { id, name, source }, ... } }, ... } in
--- list order, with at most `limit` items per slot (6 by default). `key` is the canonical slot key (see slotKey) and
--- `source` the source text. Empty for a route or phase without data.
function Model.gridSlots(route, phaseId, limit)
    limit = limit or 6
    phaseId = phaseId or Model.defaultPhase(route)
    local phase = phaseId and asTable(routeEntry(route).phases)[phaseId]
    local rows = {}
    for _, slot in ipairs(asTable(asTable(phase).slots)) do
        if type(slot) == "table" and type(slot.slot) == "string" then
            local items = {}
            for _, item in ipairs(asTable(slot.items)) do
                if #items >= limit then
                    break
                end
                if type(item) == "table" and type(item.name) == "string" then
                    items[#items + 1] = {
                        id = type(item.id) == "number" and item.id or nil,
                        name = item.name,
                        source = sourceText(item.source),
                    }
                end
            end
            rows[#rows + 1] = { slot = slot.slot, key = Model.slotKey(slot.slot), items = items }
        end
    end
    return rows
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
                                    source = type(item.source) == "table" and item.source or nil,
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

--- Every place an item is BiS, as { route, class, phase, phaseLabel, slot, rank, label, source } in route, phase and
--- slot order. The source is the data row's source table (read-only, shared), or nil when the row has none.
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

--- True when the route has a table for its default phase, i.e. Model.list(route) would return a list.
local function hasList(route)
    local phaseId = Model.defaultPhase(route)
    return phaseId ~= nil and type(asTable(routeEntry(route).phases)[phaseId]) == "table"
end

--- The routes of the active source that have a list, sorted.
function Model.routes()
    local routes = {}
    for _, route in ipairs(sortedRoutes()) do
        if hasList(route) then
            routes[#routes + 1] = route
        end
    end
    return routes
end

--- A stand-in for a route's legacy list that builds the real one the first time a field is read.
local function lazyList(route)
    local built
    return setmetatable({}, {
        __index = function(_, key)
            built = built or Model.list(route) or {}
            return built[key]
        end,
    })
end

--- (Re)build ForeverBiSLists, ForeverBiSItemIDs and ForeverBiSBuildLabels from ForeverBiSData. The lists are
--- built lazily, one route at a time, when something reads them: the addon itself resolves lists through Model.list.
function Model.buildLegacy()
    bisIndex = nil
    local lists, itemIDs, labels = {}, {}, {}
    for _, route in ipairs(sortedRoutes()) do
        if hasList(route) then
            lists[route] = lazyList(route)
        end
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

--- Makes the source the active one and rebuilds the legacy globals. False (and no change) for an unknown id.
function Model.select(id)
    if type(id) ~= "string" or type(allSources()[id]) ~= "table" then
        return false
    end
    activeId = id
    Model.buildLegacy()
    return true
end

if not Model.select(Model.DEFAULT_SOURCE) then
    local first = Model.sources()[1]
    if first then
        Model.select(first.id)
    else
        Model.buildLegacy()
    end
end
