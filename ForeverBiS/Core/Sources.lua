-- Reads item source text ("Boss, Zone", "Quest: ...", professions). Pure string logic: no frames, no WoW API.
local _, ns = ...

local Sources = {}
ns.Sources = Sources

local professionSourceIcons = {
    { "alchemy", "Interface\\Icons\\Trade_Alchemy" },
    { "blacksmithing", "Interface\\Icons\\Trade_BlackSmithing" },
    { "cooking", "Interface\\Icons\\Trade_Cooking" },
    { "enchanting", "Interface\\Icons\\Trade_Engraving" },
    { "engineering", "Interface\\Icons\\Trade_Engineering" },
    { "fishing", "Interface\\Icons\\Trade_Fishing" },
    { "herbalism", "Interface\\Icons\\Trade_Herbalism" },
    { "leatherworking", "Interface\\Icons\\Trade_LeatherWorking" },
    { "mining", "Interface\\Icons\\Trade_Mining" },
    { "skinning", "Interface\\Icons\\Trade_Skinning" },
    { "tailoring", "Interface\\Icons\\Trade_Tailoring" },
}

--- Dungeons the source filter knows: { lowercase match text, display name }.
Sources.dungeons = {
    { "the deadmines", "The Deadmines" },
    { "wailing caverns", "Wailing Caverns" },
    { "shadowfang keep", "Shadowfang Keep" },
    { "blackfathom deeps", "Blackfathom Deeps" },
    { "ragefire chasm", "Ragefire Chasm" },
    { "ruins of lordaeron", "Ruins of Lordaeron" },
}

--- Icon of each source category, shared by the filter bar and the progress tooltip.
Sources.categoryIcons = {
    quest = "Interface\\GossipFrame\\AvailableQuestIcon",
    dungeon = "Interface\\AddOns\\ForeverBiS\\ForeverBiSDungeonIcon.tga",
    world = "Interface\\WorldMap\\UI-World-Icon",
    profession = "Interface\\Icons\\Trade_Engineering",
}

--- Categories in display order.
Sources.categories = { "quest", "dungeon", "world", "profession" }

--- The lookup key of a list slot name.
function Sources.normalizeSlotName(name)
    return ForeverBiSModel.slotKey(name)
end

--- "quest", "profession", "dungeon" or "world".
function Sources.category(sourceText)
    local lowerSource = string.lower(sourceText or "")
    if string.find(lowerSource, "quest", 1, true) then
        return "quest"
    end
    for _, profession in ipairs(professionSourceIcons) do
        if string.find(lowerSource, profession[1], 1, true) then
            return "profession"
        end
    end
    for _, dungeon in ipairs(Sources.dungeons) do
        if string.find(lowerSource, dungeon[1], 1, true) then
            return "dungeon"
        end
    end
    return "world"
end

function Sources.icon(sourceText)
    local category = Sources.category(sourceText)
    if category == "quest" then
        return "Interface\\GossipFrame\\AvailableQuestIcon"
    end
    if category == "dungeon" then
        return "Interface\\AddOns\\ForeverBiS\\ForeverBiSDungeonIcon.tga"
    end
    if category == "world" then
        return "Interface\\WorldMap\\UI-World-Icon"
    end
    local lowerSource = string.lower(sourceText or "")
    for _, profession in ipairs(professionSourceIcons) do
        if string.find(lowerSource, profession[1], 1, true) then
            return profession[2]
        end
    end
end

--- "Horde" or "Alliance" when the source names only one faction, otherwise nil.
function Sources.exclusiveFaction(sourceText)
    local lowerSource = string.lower(sourceText or "")
    local hasHorde = string.find(lowerSource, "horde", 1, true) ~= nil
    local hasAlliance = string.find(lowerSource, "alliance", 1, true) ~= nil
    if hasHorde and not hasAlliance then
        return "Horde"
    end
    if hasAlliance and not hasHorde then
        return "Alliance"
    end
end

--- Colors the boss and the location of a "Boss, Location" source; quests and other text stay plain.
function Sources.format(sourceText)
    sourceText = sourceText:gsub("(%d+%.?%d*%%) in Classic", "%1")
    local source, location = sourceText:match("^([^,]+),%s*(.+)$")
    if not source or sourceText:find("Quest:", 1, true) then
        return sourceText
    end
    return "|cffffd100" .. source .. "|r, |cff65d9ff" .. location .. "|r"
end

--- Whether only the player who crafted the item can wear it.
function Sources.isMakerOnly(sourceText)
    return string.find(string.lower(sourceText or ""), "only its maker can wear it", 1, true) ~= nil
end

--- Counts the slots still missing their BiS item by the category of the item to get.
--- slots is the progress result's list; returns { { category, count }, ... } in display order, zeros left out.
function Sources.remainingByCategory(slots)
    local counts = {}
    for _, slot in ipairs(slots) do
        if not slot.done and slot.target then
            local category = Sources.category(slot.target.source)
            counts[category] = (counts[category] or 0) + 1
        end
    end
    local result = {}
    for _, category in ipairs(Sources.categories) do
        if counts[category] then
            result[#result + 1] = { category, counts[category] }
        end
    end
    return result
end
