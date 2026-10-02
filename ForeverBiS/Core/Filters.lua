-- The item list filters and their predicate. Pure: the player's faction is passed in, never read from the client.
local _, ns = ...

local Filters = {}
ns.Filters = Filters

local Sources, L = ns.Sources, ns.L

Filters.makerLabels = { all = L["Maker: all"], only = L["Maker: only"], hide = L["Maker: hide"] }
local nextMakerMode = { all = "only", only = "hide", hide = "all" }

--- Shared by the filter bar (writes) and the item list (reads).
local state = { search = "", sources = {}, dungeon = "all", bothFactions = false, maker = "all" }
Filters.state = state

function Filters.reset()
    state.search, state.dungeon = "", "all"
    state.sources = {}
    state.bothFactions, state.maker = false, "all"
end

function Filters.setSearch(text)
    state.search = string.lower(text or "")
end

--- Turning the dungeon source off also clears the dungeon choice.
function Filters.toggleSource(category)
    if state.sources[category] then
        state.sources[category] = nil
        if category == "dungeon" then
            state.dungeon = "all"
        end
    else
        state.sources[category] = true
    end
end

function Filters.setDungeon(dungeon)
    state.dungeon = dungeon
end

function Filters.toggleBothFactions()
    state.bothFactions = not state.bothFactions
end

--- all -> only -> hide -> all.
function Filters.cycleMaker()
    state.maker = nextMakerMode[state.maker]
end

--- { match key, label } entries for the dungeon dropdown, starting with "all".
function Filters.dungeonOptions()
    local options = { { "all", L["All dungeons"] } }
    for _, dungeon in ipairs(Sources.dungeons) do
        table.insert(options, { dungeon[1], dungeon[2] })
    end
    return options
end

--- Whether an { name, source } item passes every active filter. playerFaction may be nil (no faction filtering).
function Filters.matches(item, playerFaction)
    local itemName, itemSource = item[1], item[2] or ""
    local lowerSource = string.lower(itemSource)
    if state.search ~= "" then
        local haystack = string.lower(itemName) .. " " .. lowerSource
        if not string.find(haystack, state.search, 1, true) then
            return false
        end
    end
    if playerFaction and not state.bothFactions then
        local exclusive = Sources.exclusiveFaction(itemSource)
        if exclusive and exclusive ~= playerFaction then
            return false
        end
    end
    if next(state.sources) and not state.sources[Sources.category(itemSource)] then
        return false
    end
    if state.dungeon ~= "all" and not string.find(lowerSource, state.dungeon, 1, true) then
        return false
    end
    local makerOnly = Sources.isMakerOnly(itemSource)
    if state.maker == "only" and not makerOnly then
        return false
    end
    if state.maker == "hide" and makerOnly then
        return false
    end
    return true
end
