-- Classes, builds and gear slots. Pure data and lookups: no frames, no WoW API, no saved variables.
local _, ns = ...

local Catalog = {}
ns.Catalog = Catalog

-- Each build is { key, label, route suffix }. The default build has an empty route suffix.
local classes = {
    {
        key = "warrior",
        label = "Warrior",
        builds = { { "pve", "PvE", "" }, { "pvp", "PvP", "/pvp" }, { "tank", "Tank", "/tank" } },
    },
    { key = "hunter", label = "Hunter", builds = { { "pve", "PvE", "" }, { "pvp", "PvP", "/pvp" } } },
    { key = "mage", label = "Mage", builds = { { "pve", "PvE", "" }, { "pvp", "PvP", "/pvp" } } },
    { key = "rogue", label = "Rogue", builds = { { "pve", "PvE", "" }, { "pvp", "PvP", "/pvp" } } },
    {
        key = "priest",
        label = "Priest",
        builds = {
            { "shadow-pve", "Shadow PvE", "" },
            { "shadow-pvp", "Shadow PvP", "/shadow-pvp" },
            { "holy-pve", "Holy PvE", "/holy" },
            { "holy-pvp", "Holy PvP", "/holy-pvp" },
        },
    },
    { key = "warlock", label = "Warlock", builds = { { "pve", "PvE", "" }, { "pvp", "PvP", "/pvp" } } },
    {
        key = "paladin",
        label = "Paladin",
        builds = {
            { "retribution-pve", "Retribution PvE", "" },
            { "retribution-pvp", "Retribution PvP", "/retribution-pvp" },
            { "holy-pve", "Holy PvE", "/holy" },
            { "holy-pvp", "Holy PvP", "/holy-pvp" },
            { "tank", "Tank", "/tank" },
        },
    },
    {
        key = "druid",
        label = "Druid",
        builds = {
            { "feral-pve", "Feral PvE", "" },
            { "feral-pvp", "Feral PvP", "/feral-pvp" },
            { "tank", "Tank", "/tank" },
            { "balance-pve", "Balance PvE", "/balance" },
            { "balance-pvp", "Balance PvP", "/balance-pvp" },
            { "restoration", "Restoration", "/restoration" },
        },
    },
    {
        key = "shaman",
        label = "Shaman",
        builds = {
            { "elemental-pve", "Elemental PvE", "" },
            { "elemental-pvp", "Elemental PvP", "/elemental-pvp" },
            { "enhancement-pve", "Enhancement PvE", "/enhancement" },
            { "enhancement-pvp", "Enhancement PvP", "/enhancement-pvp" },
            { "restoration", "Restoration", "/restoration" },
        },
    },
}
Catalog.classes = classes

-- The built-in builds, kept so refreshBuilds can start from them every time (the data source can change).
local defaultBuilds = {}
for _, class in ipairs(classes) do
    defaultBuilds[class.key] = class.builds
end

--- A build label for a route the data gives none for, from its suffix: "" -> "PvE", "/shadow-pvp" -> "Shadow PvP".
local function derivedLabel(suffix)
    local words = {}
    for word in string.gmatch(suffix, "[^/%-]+") do
        local lower = string.lower(word)
        if lower == "pvp" then
            words[#words + 1] = "PvP"
        elseif lower == "pve" then
            words[#words + 1] = "PvE"
        else
            words[#words + 1] = string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
        end
    end
    return #words > 0 and table.concat(words, " ") or "PvE"
end

--- Replaces each class's builds with the labelled routes the data provides ({ [route] = label }). A route listed
--- in `routes` without a usable label is kept under a label derived from its suffix. A class the data does not
--- mention keeps its built-in builds. Safe to call repeatedly: it always restores the built-in builds first, so
--- switching data sources never leaves routes of the previous one behind. The default build (empty suffix) comes
--- first, the rest sorted by label.
function Catalog.refreshBuilds(labels, routes)
    for _, class in ipairs(classes) do
        class.builds = defaultBuilds[class.key]
    end
    if not labels then
        return
    end
    local known = {}
    for route, label in pairs(labels) do
        known[route] = type(label) == "string" and label or false
    end
    for _, route in ipairs(routes or {}) do
        if not known[route] then
            known[route] = false
        end
    end
    for _, class in ipairs(classes) do
        local refreshedBuilds = {}
        for route, label in pairs(known) do
            if route == class.key or string.find(route, "^" .. class.key .. "/") then
                local suffix = string.sub(route, #class.key + 1)
                table.insert(refreshedBuilds, { suffix, label or derivedLabel(suffix), suffix })
            end
        end
        if #refreshedBuilds > 0 then
            table.sort(refreshedBuilds, function(a, b)
                if (a[3] == "") ~= (b[3] == "") then
                    return a[3] == ""
                end
                return a[2] < b[2]
            end)
            class.builds = refreshedBuilds
        end
    end
end

--- The class for a key; an unknown key falls back to the rogue.
function Catalog.findClass(key)
    for _, class in ipairs(classes) do
        if class.key == key then
            return class
        end
    end
    return classes[4]
end

--- The build for a key; an unknown key falls back to the default build, then to the first one.
function Catalog.findBuild(class, key)
    for _, build in ipairs(class.builds) do
        if build[1] == key or (key == "pve" and build[1] == "") then
            return build
        end
    end
    for _, build in ipairs(class.builds) do
        if build[1] == "" then
            return build
        end
    end
    return class.builds[1]
end

function Catalog.defaultBuild(class)
    for _, build in ipairs(class.builds) do
        if build[1] == "" then
            return build
        end
    end
    return class.builds[1]
end

--- Splits a build label into its mode and spec: "Holy PvP" -> "pvp", "Holy"; "Subtlety PvP, Dagger" -> "pvp",
--- "Subtlety, Dagger". A label without PvE or PvP ("Tank", "Restoration") is PvE. A bare "PvE" has no spec (nil).
function Catalog.splitBuild(label)
    local mode = "pve"
    if string.find(" " .. label .. " ", "[%s,][Pp][Vv][Pp][%s,]") then
        mode = "pvp"
    end
    local spec = (" " .. label .. " "):gsub("([%s,])[Pp][Vv][PpEe]([%s,])", "%1%2")
    spec = spec:gsub("%s+,", ","):gsub("%s+", " "):gsub("^[%s,]+", ""):gsub("[%s,]+$", "")
    return mode, spec ~= "" and spec or nil
end

--- The first build of a class accepted by `listed(build)`, or nil when none is.
function Catalog.firstListedBuild(class, listed)
    for _, build in ipairs(class.builds) do
        if listed(build) then
            return build
        end
    end
    return nil
end

--- The data route for a class and build, e.g. "druid/tank".
function Catalog.routeKey(class, build)
    return class.key .. build[3]
end

--- Resolves possibly stale class and build keys to known ones. Returns class, build and the route key.
function Catalog.resolve(classKey, buildKey)
    local class = Catalog.findClass(classKey)
    local build = Catalog.findBuild(class, buildKey)
    return class, build, Catalog.routeKey(class, build)
end

--- The class and build a data route ("rogue/combat") belongs to, or nil when no class offers that route.
function Catalog.fromRoute(route)
    if type(route) ~= "string" then
        return nil
    end
    for _, class in ipairs(classes) do
        for _, build in ipairs(class.builds) do
            if Catalog.routeKey(class, build) == route then
                return class, build
            end
        end
    end
    return nil
end

Catalog.refreshBuilds(ForeverBiSBuildLabels, ForeverBiSModel and ForeverBiSModel.routes())
