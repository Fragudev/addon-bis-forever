-- Dungeon names in item source text ("Boss, Zone") and list slot keys. Pure string logic: no frames, no WoW API.
local _, ns = ...

local Sources = {}
ns.Sources = Sources

--- Dungeons the zone notice knows: { lowercase match text, display name }.
Sources.dungeons = {
    { "the deadmines", "The Deadmines" },
    { "wailing caverns", "Wailing Caverns" },
    { "shadowfang keep", "Shadowfang Keep" },
    { "blackfathom deeps", "Blackfathom Deeps" },
    { "ragefire chasm", "Ragefire Chasm" },
    { "ruins of lordaeron", "Ruins of Lordaeron" },
    { "gnomeregan", "Gnomeregan" },
    { "the stockade", "The Stockade" },
    { "razorfen kraul", "Razorfen Kraul" },
    { "razorfen downs", "Razorfen Downs" },
    { "scarlet monastery", "Scarlet Monastery" },
    { "uldaman", "Uldaman" },
    { "zul'farrak", "Zul'Farrak" },
    { "maraudon", "Maraudon" },
    { "the temple of atal'hakkar", "The Temple of Atal'Hakkar" },
    { "blackrock depths", "Blackrock Depths" },
    { "blackrock spire", "Blackrock Spire" },
    { "dire maul", "Dire Maul" },
    { "stratholme", "Stratholme" },
    { "scholomance", "Scholomance" },
    { "molten core", "Molten Core" },
    { "onyxia's lair", "Onyxia's Lair" },
    { "blackwing lair", "Blackwing Lair" },
    { "zul'gurub", "Zul'Gurub" },
    { "ruins of ahn'qiraj", "Ruins of Ahn'Qiraj" },
    { "temple of ahn'qiraj", "Temple of Ahn'Qiraj" },
    { "naxxramas", "Naxxramas" },
}

--- The lookup key of a list slot name.
function Sources.normalizeSlotName(name)
    return ForeverBiSModel.slotKey(name)
end

local function squashName(name)
    local lower = string.lower(name or ""):gsub("^%s*the%s+", "")
    return (lower:gsub("[^%w]", ""))
end

--- The dungeon entry ({ match text, display name }) an instance name refers to, ignoring case,
--- punctuation and a leading "The" ("Deadmines" and "The Deadmines" are the same); nil for any other name.
function Sources.matchDungeon(instanceName)
    local wanted = squashName(instanceName)
    if wanted == "" then
        return nil
    end
    for _, dungeon in ipairs(Sources.dungeons) do
        if squashName(dungeon[1]) == wanted then
            return dungeon
        end
    end
    return nil
end

--- How many listed items come from the dungeon (by a lowercase text match on the item source).
function Sources.countForDungeon(slots, dungeonKey)
    local count = 0
    for _, slot in ipairs(slots) do
        for _, item in ipairs(slot[2]) do
            if string.find(string.lower(item[2] or ""), dungeonKey, 1, true) then
                count = count + 1
            end
        end
    end
    return count
end
