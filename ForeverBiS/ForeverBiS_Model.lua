-- Read model over ForeverBiSData (schema 2). It never touches ForeverBiSDB: saved variables are not
-- reliable while files execute. The UI still consumes the legacy globals built at the bottom of this file.
local Model = {}
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

--- (Re)build ForeverBiSLists, ForeverBiSItemIDs and ForeverBiSBuildLabels from ForeverBiSData.
function Model.buildLegacy()
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
