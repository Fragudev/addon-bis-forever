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

--- Replaces each class's builds with the labelled routes the data provides ({ [route] = label }).
--- A class the data does not mention keeps its built-in builds.
function Catalog.refreshBuilds(labels)
    if not labels then
        return
    end
    for _, class in ipairs(classes) do
        local refreshedBuilds = {}
        for route, label in pairs(labels) do
            if route == class.key or string.find(route, "^" .. class.key .. "/") then
                local suffix = string.sub(route, #class.key + 1)
                table.insert(refreshedBuilds, { suffix, label, suffix })
            end
        end
        if #refreshedBuilds > 0 then
            table.sort(refreshedBuilds, function(a, b)
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

-- Paper doll slots: { display name, list slot, column, row, rank among that list slot's items }.
Catalog.paperDollSlots = {
    { "Head", "Head", 1, 1 },
    { "Neck", "Neck", 1, 2 },
    { "Shoulder", "Shoulder", 1, 3 },
    { "Back", "Back", 1, 4 },
    { "Chest", "Chest", 1, 5 },
    { "Wrist", "Wrist", 1, 8 },
    { "Hands", "Hands", 2, 1 },
    { "Waist", "Waist", 2, 2 },
    { "Legs", "Legs", 2, 3 },
    { "Feet", "Feet", 2, 4 },
    { "Finger 1", "Finger", 2, 5, 1 },
    { "Finger 2", "Finger", 2, 6, 2 },
    { "Trinket 1", "Trinket", 2, 7, 1 },
    { "Trinket 2", "Trinket", 2, 8, 2 },
}
Catalog.weaponSlots = { "Main Hand", "Off Hand", "Ranged" }

--- Every distinct list slot a progress count covers: the paper doll slots, then the weapons.
function Catalog.progressKeys()
    local keys, seen = {}, {}
    for _, slotInfo in ipairs(Catalog.paperDollSlots) do
        if not seen[slotInfo[2]] then
            seen[slotInfo[2]] = true
            keys[#keys + 1] = slotInfo[2]
        end
    end
    for _, slotName in ipairs(Catalog.weaponSlots) do
        keys[#keys + 1] = slotName
    end
    return keys
end

Catalog.refreshBuilds(ForeverBiSBuildLabels)
