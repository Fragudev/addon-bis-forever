ForeverBiSDB = ForeverBiSDB or { class = "rogue", build = "pve" }
ForeverBiSDB.minimap = ForeverBiSDB.minimap or {}
local collapsedSections = type(ForeverBiSDB.collapsed) == "table" and ForeverBiSDB.collapsed or {}
ForeverBiSDB.collapsed = collapsedSections

local lists = {
    ["rogue"] = {
        title = "Rogue PvE — Level 20",
        slots = {
            {
                "Head",
                {
                    { "Brawler's Leather Hood", "Leatherworking (100)" },
                    { "Solomon's Comfortable Hat", "Location unknown" },
                    { "Defender's Leather Hood", "Leatherworking (100)" },
                    { "Taurajo Headband", "Quest: Field to Clear (Horde)" },
                    { "Lucky Fishing Hat", "Fishing quest in Booty Bay" },
                },
            },
            {
                "Neck",
                {
                    { "Erudite's Amulet", "Quest: Friend of the Library" },
                    { "Snake Eye Kaleidoscope", "Lady Anacondra, Wailing Caverns" },
                    { "Tarnished Locket", "Quest: Remember That I Love You (Alliance)" },
                    { "Ephemeral Choker", "Faldrim Anvilmar, Hall of Thanes" },
                },
            },
            {
                "Shoulder",
                {
                    { "Serpent's Shoulders", "Lady Anacondra, Wailing Caverns" },
                    { "Tanned Shoulderpads", "Quest: Deathstalkers in Shadowfang (Horde)" },
                },
            },
            {
                "Back",
                {
                    { "Glowing Lizardscale Cloak", "Skum, Wailing Caverns" },
                    { "Cape of the Brotherhood", "Edwin VanCleef, The Deadmines" },
                    { "Spritekin Cloak", "Quest: Bloodfury Bloodline (Horde)" },
                    { "Spiritwraith Drape", "Faldrim Anvilmar, Hall of Thanes" },
                },
            },
            {
                "Chest",
                {
                    { "Tunic of Westfall", "Quest: The Defias Brotherhood (Alliance)" },
                    { "Panther Armor", "Quest: The Den (Horde)" },
                    { "Bloodied Chestwraps", "Viktor the Vile, Ruins of Lordaeron" },
                    { "Blackened Defias Armor", "Edwin VanCleef, The Deadmines" },
                },
            },
            {
                "Wrist",
                {
                    { "Staghide Armguards", "Quest: Researching the Corruption (Alliance)" },
                    { "Cultist's Armguards", "Quest: Blackfathom Villainy" },
                    { "Bravo's Armbands", "Quest: Underground Assault (Alliance)" },
                    { "Spare Part Bindings", "Quest: Light's Justice (Horde)" },
                    { "Witherbite Bracers", "Witherfang, Ruins of Lordaeron" },
                },
            },
            {
                "Hands",
                {
                    { "Gloves of the Fang", "Trash mobs, Wailing Caverns" },
                    { "Fletcher's Gloves", "Leatherworking" },
                    { "Brawler's Leather Gloves", "Leatherworking (75)" },
                    { "Nimble Leather Gloves", "Leatherworking" },
                },
            },
            {
                "Waist",
                {
                    { "Blackened Defias Belt", "Captain Greenskin, The Deadmines" },
                    { "Deviate Scale Belt", "Leatherworking (90)" },
                    { "Beastmaster's Girdle", "Quest: Isha Awak (Horde)" },
                    { "Brawler's Leather Belt", "Leatherworking (60)" },
                },
            },
            {
                "Legs",
                {
                    { "Leggings of the Fang", "Lord Cobrahn, Wailing Caverns" },
                    { "Duty Bound Leggings", "Quest: Bloodied Insignia (Alliance)" },
                    { "Blackened Defias Leggings", "Trash mobs, The Deadmines" },
                },
            },
            {
                "Feet",
                {
                    { "Footpads of the Fang", "Lord Serpentis, Wailing Caverns" },
                    { "Trailblazer Boots", "Quest: Horde Presence (Horde)" },
                    { "Brawler's Leather Boots", "Leatherworking (85)" },
                    { "Blackened Defias Boots", "Trash mobs, The Deadmines" },
                },
            },
            {
                "Finger",
                {
                    { "Field Researcher's Loop", "Quest: Greater Friend of the Library" },
                    { "Pyrewood Signet Ring", "Rogue quest: The Horn of Xelthos" },
                    { "Malignant Root", "Nightveiled Rotheap, Wetlands (Alliance)" },
                    { "Band of the Fist", "Quest: Allegiance to the Old Gods (Horde)" },
                    { "First Mate Band", "Mr. Smite, The Deadmines" },
                    { "Seal of Sylvanas", "Quest: Arugal Must Die (Horde)" },
                },
            },
            {
                "Trinket",
                { { "Minor Recombobulator", "Engineering (140)" }, { "Lookie's Spyglass", "Cookie, The Deadmines" } },
            },
            {
                "Main Hand",
                {
                    { "Cruel Barb", "Edwin VanCleef, The Deadmines" },
                    { "Butcher's Slicer", "Razorclaw the Butcher, Shadowfang Keep" },
                    { "Shadowfang", "Trash mobs, Shadowfang Keep" },
                    { "Stinging Viper", "Lord Pythas, Wailing Caverns" },
                    { "Wingblade", "Quest: Leaders of the Fang (Horde)" },
                },
            },
            {
                "Off Hand",
                {
                    { "Butcher's Cleaver", "Razorclaw the Butcher, Shadowfang Keep" },
                    { "Shoni's Disarming Tool", "Quest: Gyrodrillmatic Excavationators (Alliance)" },
                    { "Assassin's Blade", "Trash mobs, Shadowfang Keep" },
                    { "Edward's Knife", "Quest: A Frightened Request (Horde)" },
                    { "Thief's Blade", "Mr. Smite, The Deadmines" },
                },
            },
            {
                "Ranged",
                {
                    { "Lil Timmy's Peashooter", "World drop; Auction House" },
                    { "Dull Sawblade", "Sneed's Shredder, The Deadmines" },
                    { "Bow of Plunder", "Quest: Dangerous! (Horde)" },
                    { "Privateer Musket", "Quest: The Guns of Northwatch (Horde)" },
                    { "Venomstrike", "Lord Serpentis, Wailing Caverns" },
                },
            },
        },
    },
    ["rogue/pvp"] = {
        title = "Rogue PvP — Level 20",
        slots = {
            {
                "Head",
                {
                    { "Brawler's Leather Hood", "Leatherworking (100)" },
                    { "Solomon's Comfortable Hat", "Location unknown" },
                    { "Defender's Leather Hood", "Leatherworking (100)" },
                    { "Taurajo Headband", "Quest: Field to Clear (Horde)" },
                    { "Lucky Fishing Hat", "Fishing quest in Booty Bay" },
                },
            },
            {
                "Neck",
                {
                    { "Erudite's Amulet", "Quest: Friend of the Library" },
                    { "Tarnished Locket", "Quest: Remember That I Love You (Alliance)" },
                    { "Snake Eye Kaleidoscope", "Lady Anacondra, Wailing Caverns" },
                    { "Ephemeral Choker", "Faldrim Anvilmar, Hall of Thanes" },
                },
            },
            {
                "Shoulder",
                {
                    { "Serpent's Shoulders", "Lady Anacondra, Wailing Caverns" },
                    { "Tanned Shoulderpads", "Quest: Deathstalkers in Shadowfang (Horde)" },
                },
            },
            {
                "Back",
                {
                    { "Cape of the Brotherhood", "Edwin VanCleef, The Deadmines" },
                    { "Glowing Lizardscale Cloak", "Skum, Wailing Caverns" },
                    { "Spritekin Cloak", "Quest: Bloodfury Bloodline (Horde)" },
                    { "Grave Shroud", "Quest: Abominable Creatures (Alliance)" },
                },
            },
            {
                "Chest",
                {
                    { "Tunic of Westfall", "Quest: The Defias Brotherhood (Alliance)" },
                    { "Panther Armor", "Quest: The Den (Horde)" },
                    { "Blackened Defias Armor", "Edwin VanCleef, The Deadmines" },
                    { "Bloodied Chestwraps", "Viktor the Vile, Ruins of Lordaeron" },
                },
            },
            {
                "Wrist",
                {
                    { "Cultist's Armguards", "Quest: Blackfathom Villainy" },
                    { "Staghide Armguards", "Quest: Researching the Corruption (Alliance)" },
                    { "Spare Part Bindings", "Quest: Light's Justice (Horde)" },
                    { "Bravo's Armbands", "Quest: Underground Assault (Alliance)" },
                    { "Witherbite Bracers", "Witherfang, Ruins of Lordaeron" },
                },
            },
            {
                "Hands",
                {
                    { "Gloves of the Fang", "Trash mobs, Wailing Caverns" },
                    { "Fletcher's Gloves", "Leatherworking" },
                    { "Brawler's Leather Gloves", "Leatherworking (75)" },
                    { "Nimble Leather Gloves", "Leatherworking" },
                },
            },
            {
                "Waist",
                {
                    { "Deviate Scale Belt", "Leatherworking (90)" },
                    { "Blackened Defias Belt", "Captain Greenskin, The Deadmines" },
                    { "Beastmaster's Girdle", "Quest: Isha Awak (Horde)" },
                    { "Brawler's Leather Belt", "Leatherworking (60)" },
                },
            },
            {
                "Legs",
                {
                    { "Leggings of the Fang", "Lord Cobrahn, Wailing Caverns" },
                    { "Duty Bound Leggings", "Quest: Bloodied Insignia (Alliance)" },
                },
            },
            {
                "Feet",
                {
                    { "Footpads of the Fang", "Lord Serpentis, Wailing Caverns" },
                    { "Grizzled Boots", "Quest: The Book of Ur (Horde)" },
                    { "Trailblazer Boots", "Quest: Horde Presence (Horde)" },
                    { "Brawler's Leather Boots", "Leatherworking (85)" },
                },
            },
            {
                "Finger",
                {
                    { "Field Researcher's Loop", "Quest: Greater Friend of the Library" },
                    { "Pyrewood Signet Ring", "Rogue quest: The Horn of Xelthos" },
                    { "Malignant Root", "Nightveiled Rotheap, Wetlands (Alliance)" },
                    { "Seal of Sylvanas", "Quest: Arugal Must Die (Horde)" },
                    { "Slain Baron's Signet", "Quest: Abominable Creatures (Alliance)" },
                    { "Band of the Fist", "Quest: Allegiance to the Old Gods (Horde)" },
                },
            },
            {
                "Trinket",
                { { "Minor Recombobulator", "Engineering (140)" }, { "Lookie's Spyglass", "Cookie, The Deadmines" } },
            },
            {
                "Main Hand",
                {
                    { "Cruel Barb", "Edwin VanCleef, The Deadmines" },
                    { "Assassin's Blade", "Trash mobs, Shadowfang Keep" },
                    { "Butcher's Slicer", "Razorclaw the Butcher, Shadowfang Keep" },
                    { "Edward's Knife", "Quest: A Frightened Request (Horde)" },
                    { "Meathook Slicer", "The Baron, Ruins of Lordaeron" },
                },
            },
            {
                "Off Hand",
                {
                    { "Butcher's Cleaver", "Razorclaw the Butcher, Shadowfang Keep" },
                    { "Edward's Knife", "Quest: A Frightened Request (Horde)" },
                    { "Shoni's Disarming Tool", "Quest: Gyrodrillmatic Excavationators (Alliance)" },
                    { "Tail Spike", "Skum, Wailing Caverns" },
                    { "Thief's Blade", "Mr. Smite, The Deadmines" },
                },
            },
            {
                "Ranged",
                {
                    { "Dull Sawblade", "Sneed's Shredder, The Deadmines" },
                    { "Lil Timmy's Peashooter", "World drop; Auction House" },
                    { "Bow of Plunder", "Quest: Dangerous! (Horde)" },
                    { "Owlsight Rifle", "Quest: The Sleeper Has Awakened (Alliance)" },
                    { "Venomstrike", "Lord Serpentis, Wailing Caverns" },
                },
            },
        },
    },
}

for key, data in pairs(ForeverBiSLists or {}) do
    lists[key] = data
end

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

if ForeverBiSBuildLabels then
    for _, class in ipairs(classes) do
        local refreshedBuilds = {}
        for route, label in pairs(ForeverBiSBuildLabels) do
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

local function findClass(key)
    for _, class in ipairs(classes) do
        if class.key == key then
            return class
        end
    end
    return classes[4]
end

local function findBuild(class, key)
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

local function defaultBuild(class)
    for _, build in ipairs(class.builds) do
        if build[1] == "" then
            return build
        end
    end
    return class.builds[1]
end

local function currentListKey()
    local class = findClass(ForeverBiSDB.class)
    local build = findBuild(class, ForeverBiSDB.build)
    ForeverBiSDB.class, ForeverBiSDB.build = class.key, build[1]
    return class.key .. build[3]
end

local function currentPlayerLevel()
    return UnitLevel and UnitLevel("player") or nil
end

--- Phase shown for a route: the saved choice when available, otherwise the one matching the player's level.
local function effectivePhaseFor(route)
    if not ForeverBiSModel then
        return nil
    end
    return ForeverBiSModel.effectivePhase(route, ForeverBiSDB.phase, currentPlayerLevel())
end

local itemIDs = {
    ["Brawler's Leather Hood"] = 252504,
    ["Solomon's Comfortable Hat"] = 277219,
    ["Defender's Leather Hood"] = 252447,
    ["Taurajo Headband"] = 279391,
    ["Lucky Fishing Hat"] = 19972,
    ["Erudite's Amulet"] = 277204,
    ["Tarnished Locket"] = 279870,
    ["Snake Eye Kaleidoscope"] = 273088,
    ["Ephemeral Choker"] = 270227,
    ["Serpent's Shoulders"] = 5404,
    ["Tanned Shoulderpads"] = 270023,
    ["Cape of the Brotherhood"] = 5193,
    ["Glowing Lizardscale Cloak"] = 6449,
    ["Spritekin Cloak"] = 16990,
    ["Spiritwraith Drape"] = 271097,
    ["Grave Shroud"] = 279865,
    ["Tunic of Westfall"] = 2041,
    ["Panther Armor"] = 6670,
    ["Bloodied Chestwraps"] = 271212,
    ["Blackened Defias Armor"] = 10399,
    ["Staghide Armguards"] = 270021,
    ["Cultist's Armguards"] = 270032,
    ["Bravo's Armbands"] = 270015,
    ["Spare Part Bindings"] = 279875,
    ["Gloves of the Fang"] = 10413,
    ["Fletcher's Gloves"] = 7348,
    ["Brawler's Leather Gloves"] = 252494,
    ["Nimble Leather Gloves"] = 7285,
    ["Blackened Defias Belt"] = 10403,
    ["Deviate Scale Belt"] = 6468,
    ["Beastmaster's Girdle"] = 5355,
    ["Brawler's Leather Belt"] = 252428,
    ["Leggings of the Fang"] = 10410,
    ["Duty Bound Leggings"] = 279868,
    ["Blackened Defias Leggings"] = 10400,
    ["Footpads of the Fang"] = 10411,
    ["Witherbite Bracers"] = 271202,
    ["Grizzled Boots"] = 6335,
    ["Trailblazer Boots"] = 10653,
    ["Slain Baron's Signet"] = 279867,
    ["Meathook Slicer"] = 271204,
    ["Tail Spike"] = 6448,
    ["Owlsight Rifle"] = 15205,
    ["Brawler's Leather Boots"] = 252439,
    ["Blackened Defias Boots"] = 10402,
    ["Field Researcher's Loop"] = 281634,
    ["Pyrewood Signet Ring"] = 277210,
    ["Malignant Root"] = 282283,
    ["Band of the Fist"] = 17694,
    ["First Mate Band"] = 284715,
    ["Seal of Sylvanas"] = 6414,
    ["Minor Recombobulator"] = 4381,
    ["Lookie's Spyglass"] = 273298,
    ["Cruel Barb"] = 5191,
    ["Butcher's Slicer"] = 6633,
    ["Shadowfang"] = 1482,
    ["Stinging Viper"] = 6472,
    ["Wingblade"] = 6504,
    ["Butcher's Cleaver"] = 1292,
    ["Shoni's Disarming Tool"] = 9608,
    ["Assassin's Blade"] = 1935,
    ["Edward's Knife"] = 251485,
    ["Thief's Blade"] = 5192,
    ["Lil Timmy's Peashooter"] = 13136,
    ["Dull Sawblade"] = 285292,
    ["Bow of Plunder"] = 3742,
    ["Privateer Musket"] = 5309,
    ["Venomstrike"] = 6469,
}

for itemName, itemID in pairs(ForeverBiSItemIDs or {}) do
    itemIDs[itemName] = itemID
end

local trackedItemIDs = {}
local function getItemID(itemName)
    local itemID = itemIDs[itemName]
    if not itemID then
        if C_Item and C_Item.GetItemInfoInstant then
            itemID = C_Item.GetItemInfoInstant(itemName)
        elseif GetItemInfoInstant then
            itemID = GetItemInfoInstant(itemName)
        end
    end
    if itemID then
        trackedItemIDs[itemID] = true
    end
    return itemID
end

local requestedItemIDs = {}
local function getItemIcon(itemName)
    local itemID = getItemID(itemName)
    if itemID and C_Item and C_Item.RequestLoadItemDataByID and not requestedItemIDs[itemID] then
        requestedItemIDs[itemID] = true
        C_Item.RequestLoadItemDataByID(itemID)
    end
    if itemID and C_Item and C_Item.GetItemIconByID then
        local texture = C_Item.GetItemIconByID(itemID)
        if texture then
            return texture
        end
    end
    if itemID and GetItemIcon then
        local texture = GetItemIcon(itemID)
        if texture then
            return texture
        end
    end
    if itemID and GetItemInfo then
        local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
        if texture then
            return texture
        end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function getItemQualityColor(itemName)
    local itemID = getItemID(itemName)
    local quality
    if itemID and GetItemInfo then
        local _, itemLink, itemQuality = GetItemInfo(itemID)
        quality = itemQuality
        local linkHex = itemLink and itemLink:match("|c(%x%x%x%x%x%x%x%x)|H")
        if linkHex then
            return tonumber(linkHex:sub(3, 4), 16) / 255,
                tonumber(linkHex:sub(5, 6), 16) / 255,
                tonumber(linkHex:sub(7, 8), 16) / 255
        end
    end
    if not quality and itemID and C_Item and C_Item.GetItemQualityByID then
        quality = C_Item.GetItemQualityByID(itemID)
    end
    local color = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if color then
        return color.r or 1, color.g or 1, color.b or 1
    end
    return 1, 1, 1
end

local function addQualityBorder(button, itemName)
    local red, green, blue = getItemQualityColor(itemName)
    local width, height = button:GetWidth(), button:GetHeight()
    local borderSize = 2
    local function addEdge(point, edgeWidth, edgeHeight)
        local edge = button:CreateTexture(nil, "OVERLAY")
        edge:SetTexture("Interface\\Buttons\\WHITE8X8")
        edge:SetVertexColor(red, green, blue, 1)
        edge:SetPoint(point, button, point)
        edge:SetSize(edgeWidth, edgeHeight)
    end
    addEdge("TOPLEFT", width, borderSize)
    addEdge("BOTTOMLEFT", width, borderSize)
    addEdge("TOPLEFT", borderSize, height)
    addEdge("TOPRIGHT", borderSize, height)
end

local equippedSlotIDs = {
    ["head"] = { 1 },
    ["neck"] = { 2 },
    ["shoulder"] = { 3 },
    ["back"] = { 15 },
    ["chest"] = { 5 },
    ["wrist"] = { 9 },
    ["hands"] = { 10 },
    ["waist"] = { 6 },
    ["legs"] = { 7 },
    ["feet"] = { 8 },
    ["finger"] = { 11, 12 },
    ["finger 1"] = { 11 },
    ["finger 2"] = { 12 },
    ["trinket"] = { 13, 14 },
    ["trinket 1"] = { 13 },
    ["trinket 2"] = { 14 },
    ["main hand"] = { 16 },
    ["off hand"] = { 17 },
    ["ranged"] = { 18 },
}

local function isItemEquippedInSlot(itemID, slotName)
    if not itemID or not GetInventoryItemID then
        return false
    end
    local slotIDs = equippedSlotIDs[string.lower(slotName or "")]
    if not slotIDs then
        return false
    end
    for _, inventorySlotID in ipairs(slotIDs) do
        if GetInventoryItemID("player", inventorySlotID) == itemID then
            return true
        end
    end
    return false
end

local function getItemBagCount(itemID)
    if not itemID or not GetItemCount then
        return 0
    end
    return GetItemCount(itemID, false) or 0
end

local function addOwnershipMark(button, itemName, slotName, fullIconCheck)
    local itemID = getItemID(itemName)
    if isItemEquippedInSlot(itemID, slotName) then
        local check = button:CreateTexture(nil, "OVERLAY")
        check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
        if fullIconCheck then
            check:SetAllPoints(button)
        else
            check:SetSize(13, 13)
            check:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
        end
        return "equipped", 0
    end
    local count = getItemBagCount(itemID)
    if count > 0 then
        local bagCount = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        bagCount:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -1)
        bagCount:SetText("x" .. count)
        bagCount:SetTextColor(1, 0.82, 0.2)
        return "bags", count
    end
    return nil, 0
end

local function addOwnershipTooltip(itemName, slotName)
    local itemID = getItemID(itemName)
    if isItemEquippedInSlot(itemID, slotName) then
        GameTooltip:AddLine("Currently equipped", 0.35, 1, 0.35)
    else
        local count = getItemBagCount(itemID)
        if count > 0 then
            GameTooltip:AddLine("In bags: " .. count, 1, 0.82, 0.2)
        end
    end
end

local frame = CreateFrame("Frame", "ForeverBiSFrame", UIParent, "BackdropTemplate")
frame:SetWidth(760)
frame:SetHeight(500)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("DIALOG")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:SetResizable(true)
if frame.SetResizeBounds then
    frame:SetResizeBounds(760, 500, UIParent:GetWidth() - 40, UIParent:GetHeight() - 40)
else
    frame:SetMinResize(760, 500)
end
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
frame:SetScript("OnMouseDown", function()
    frame:StartMoving()
end)
frame:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
end)
frame:Hide()

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", frame, "TOP", 0, -18)
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)

local classLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
classLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -55)
classLabel:SetText("Class")
local classDrop = CreateFrame("Frame", "ForeverBiSClassDropDown", frame, "UIDropDownMenuTemplate")
classDrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 65, -46)
UIDropDownMenu_SetWidth(classDrop, 145)
local buildLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
buildLabel:SetPoint("LEFT", classDrop, "RIGHT", 5, 3)
buildLabel:SetText("Build")
local buildDrop = CreateFrame("Frame", "ForeverBiSBuildDropDown", frame, "UIDropDownMenuTemplate")
buildDrop:SetPoint("LEFT", buildLabel, "RIGHT", -5, -3)
UIDropDownMenu_SetWidth(buildDrop, 120)
-- No label: "Auto (Level 30)" explains itself and keeps the selector row short at the minimum width.
local phaseDrop = CreateFrame("Frame", "ForeverBiSPhaseDropDown", frame, "UIDropDownMenuTemplate")
phaseDrop:SetPoint("LEFT", buildDrop, "RIGHT", -12, 0)
UIDropDownMenu_SetWidth(phaseDrop, 105)

local helpButton = CreateFrame("Button", nil, frame)
helpButton:SetSize(20, 20)
helpButton:SetPoint("CENTER", frame, "TOPRIGHT", -32, -62)
local helpIcon = helpButton:CreateTexture(nil, "ARTWORK")
helpIcon:SetAllPoints(helpButton)
helpIcon:SetTexture("Interface\\Common\\help-i")
helpButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
local helpPinned = false

local function showAddonHelp()
    local function addHelpHeader(text)
        GameTooltip:AddLine("|cffffe35b" .. text .. "|r", 1, 1, 1, true)
        local lineNumber = GameTooltip:NumLines()
        local line = _G["GameTooltipTextLeft" .. lineNumber]
        if line then
            line:SetFont(STANDARD_TEXT_FONT, 12, "THICKOUTLINE")
            line:SetTextColor(1, 0.89, 0.35)
        end
    end
    GameTooltip:SetOwner(helpButton, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:SetText("BiS Forever Help", 1, 0.89, 0.35)
    addHelpHeader("CLASS & BUILD")
    GameTooltip:AddLine("Choose a class and specialization/build to load its BiS list.", 0.9, 0.9, 0.9, true)
    GameTooltip:AddLine(" ")
    addHelpHeader("SEARCH & FILTERS")
    GameTooltip:AddLine(
        "Search by item, boss or zone. The icon buttons filter by source and can be combined; the dungeon list appears with the dungeon button.",
        0.9,
        0.9,
        0.9,
        true
    )
    GameTooltip:AddLine(
        "The faction button hides items exclusive to the other faction. Maker only hides profession items that only their maker can wear.",
        0.9,
        0.9,
        0.9,
        true
    )
    GameTooltip:AddLine("Faction-exclusive items show a faction emblem and colored faction name.", 0.9, 0.9, 0.9, true)
    GameTooltip:AddLine(" ")
    addHelpHeader("ITEM LIST")
    GameTooltip:AddLine(
        "Numbers show rank. Item names use their rarity color; source colors distinguish the source from its location.",
        0.9,
        0.9,
        0.9,
        true
    )
    GameTooltip:AddLine(
        "Hover an item icon for its in-game tooltip. Yellow exclamation = quest; finder eye = dungeon/raid; map = world; profession icon = profession.",
        0.9,
        0.9,
        0.9,
        true
    )
    GameTooltip:AddLine("Green check = equipped in that slot; gold xN = copies in your bags.", 0.9, 0.9, 0.9, true)
    GameTooltip:AddLine("Click + or - beside a slot heading to collapse or expand its list.", 0.9, 0.9, 0.9, true)
    GameTooltip:AddLine(" ")
    addHelpHeader("BEST IN SLOT")
    GameTooltip:AddLine(
        "Click a gear icon to jump to its slot in the list; hover for item and source details.",
        0.9,
        0.9,
        0.9,
        true
    )
    GameTooltip:AddLine(
        "Equipped Only filters this panel to BiS items already worn. A BiS ring or trinket counts in either of its two equipment slots.",
        0.9,
        0.9,
        0.9,
        true
    )
    GameTooltip:AddLine(" ")
    addHelpHeader("WINDOW & MINIMAP")
    GameTooltip:AddLine(
        "Drag the title area to move the window; drag its bottom handle to resize vertically. Click the minimap icon to toggle the addon and drag it to reposition.",
        0.9,
        0.9,
        0.9,
        true
    )
    GameTooltip:AddLine("Click this help icon to keep the help open or close it.", 1, 0.82, 0.2, true)
    GameTooltip:Show()
end

helpButton:SetScript("OnEnter", showAddonHelp)
helpButton:SetScript("OnLeave", function()
    if not helpPinned then
        GameTooltip:Hide()
    end
end)
helpButton:SetScript("OnClick", function()
    helpPinned = not helpPinned
    if helpPinned then
        showAddonHelp()
    else
        GameTooltip:Hide()
    end
end)

local scroll = CreateFrame("ScrollFrame", "ForeverBiSScroll", frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -96)
scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -384, 38)
local content = CreateFrame("Frame", nil, scroll)
content:SetWidth(500)
content:SetHeight(1)
scroll:SetScrollChild(content)
local userSized = false
local render
local resetListFilters
local currentSlotTops = {}

local gearPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
gearPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -84)
gearPanel:SetSize(330, 390)
gearPanel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 18,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
gearPanel:SetBackdropColor(0.18, 0.12, 0.07, 0.92)
gearPanel:SetBackdropBorderColor(0.58, 0.39, 0.18, 1)
local gearTitle = gearPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gearTitle:SetPoint("TOP", gearPanel, "TOP", 0, -12)
gearTitle:SetText("|cffffe35bBEST IN SLOT|r")
local showEquippedOnly = false
local equippedOnlyButton = CreateFrame("Button", nil, gearPanel, "UIPanelButtonTemplate")
equippedOnlyButton:SetSize(142, 20)
equippedOnlyButton:SetPoint("TOP", gearPanel, "TOP", 0, -30)
local function updateEquippedOnlyButton()
    equippedOnlyButton:SetText(showEquippedOnly and "Equipped Only: On" or "Equipped Only: Off")
end
equippedOnlyButton:SetScript("OnClick", function()
    showEquippedOnly = not showEquippedOnly
    updateEquippedOnlyButton()
    if render then
        render()
    end
end)
equippedOnlyButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Equipped Only", 1, 0.89, 0.35)
    GameTooltip:AddLine("Show only BiS items already equipped in their matching slots.", 1, 1, 1, true)
    GameTooltip:Show()
end)
equippedOnlyButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
updateEquippedOnlyButton()
local gearContent = CreateFrame("Frame", nil, gearPanel)
gearContent:SetPoint("TOPLEFT", gearPanel, "TOPLEFT", 5, -55)
gearContent:SetPoint("BOTTOMRIGHT", gearPanel, "BOTTOMRIGHT", -5, 5)

local characterModel = CreateFrame("PlayerModel", nil, gearContent)
characterModel:SetSize(128, 190)
characterModel:SetPoint("TOP", gearContent, "TOP", 0, -42)
characterModel:SetScript("OnModelLoaded", function(self)
    if self.RefreshCamera then
        self:RefreshCamera()
    end
    if self.SetAnimation then
        self:SetAnimation(0)
    end
    if self.SetPaused then
        self:SetPaused(true)
    end
end)

local function refreshCharacterModel()
    if not characterModel:IsShown() then
        return
    end
    if characterModel.SetUnit then
        characterModel:SetUnit("player", false)
    end
    if characterModel.RefreshCamera then
        characterModel:RefreshCamera()
    end
end

characterModel:SetScript("OnShow", refreshCharacterModel)
local characterModelEvents = CreateFrame("Frame")
characterModelEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
characterModelEvents:RegisterEvent("UNIT_MODEL_CHANGED")
characterModelEvents:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
characterModelEvents:SetScript("OnEvent", function(_, event, unit)
    if event ~= "UNIT_MODEL_CHANGED" or unit == "player" then
        refreshCharacterModel()
    end
end)

local paperDollSlots = {
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
local weaponSlots = { "Main Hand", "Off Hand", "Ranged" }

-- Progress towards the selected list: "BiS 3/17" and a thin bar beside the Equipped Only button, with a tooltip.
local PROGRESS_TOOLTIP_LINES = 8
local PROGRESS_SOURCE_LENGTH = 36
local PROGRESS_BAR_WIDTH = 78
local progressKeys = {}
do
    local seen = {}
    for _, slotInfo in ipairs(paperDollSlots) do
        if not seen[slotInfo[2]] then
            seen[slotInfo[2]] = true
            progressKeys[#progressKeys + 1] = slotInfo[2]
        end
    end
    for _, slotName in ipairs(weaponSlots) do
        progressKeys[#progressKeys + 1] = slotName
    end
end

local progressFrame = CreateFrame("Frame", nil, gearPanel)
progressFrame:SetSize(PROGRESS_BAR_WIDTH, 20)
progressFrame:SetPoint("TOPLEFT", gearPanel, "TOPLEFT", 14, -30)
progressFrame:EnableMouse(true)
local progressText = progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
progressText:SetPoint("TOPLEFT", progressFrame, "TOPLEFT", 0, 0)
local progressTrack = progressFrame:CreateTexture(nil, "BACKGROUND")
progressTrack:SetTexture("Interface\\Buttons\\WHITE8X8")
progressTrack:SetVertexColor(0.05, 0.03, 0.02, 0.9)
progressTrack:SetSize(PROGRESS_BAR_WIDTH, 4)
progressTrack:SetPoint("BOTTOMLEFT", progressFrame, "BOTTOMLEFT", 0, 0)
local progressFill = progressFrame:CreateTexture(nil, "ARTWORK")
progressFill:SetTexture("Interface\\Buttons\\WHITE8X8")
progressFill:SetVertexColor(1, 0.82, 0.2, 1)
progressFill:SetHeight(4)
progressFill:SetPoint("BOTTOMLEFT", progressFrame, "BOTTOMLEFT", 0, 0)
local currentProgress, currentProgressLabel

--- What the player has, read with the same slot ids and counts the row marks use.
local function buildOwned()
    local equipped = {}
    for _, key in ipairs(progressKeys) do
        local ids = {}
        for _, inventorySlotID in ipairs(equippedSlotIDs[string.lower(key)] or {}) do
            local itemID = GetInventoryItemID and GetInventoryItemID("player", inventorySlotID)
            if itemID then
                ids[#ids + 1] = itemID
            end
        end
        equipped[key] = ids
    end
    return { equipped = equipped, bags = getItemBagCount, itemId = getItemID }
end

local function phaseLabelFor(route, phaseId)
    for _, phase in ipairs(ForeverBiSModel.phases(route)) do
        if phase.id == phaseId then
            return phase.label or phase.id
        end
    end
    return phaseId
end

--- Recomputes the line from a legacy list (nil hides it); the tooltip reads the stored result.
local function refreshProgress(data, route, phaseId)
    currentProgress = data and ForeverBiSModel.progress(data, buildOwned())
    if not currentProgress or currentProgress.total == 0 then
        currentProgress = nil
        progressFrame:Hide()
        return
    end
    local routeLabel = route and ForeverBiSModel.label(route)
    local phaseLabel = route and phaseId and phaseLabelFor(route, phaseId)
    currentProgressLabel = routeLabel and phaseLabel and (routeLabel .. " - " .. phaseLabel) or routeLabel or "BiS"
    progressText:SetText("BiS " .. currentProgress.bis .. "/" .. currentProgress.total)
    if currentProgress.bis > 0 then
        progressFill:SetWidth(PROGRESS_BAR_WIDTH * currentProgress.bis / currentProgress.total)
        progressFill:Show()
    else
        progressFill:Hide()
    end
    progressFrame:Show()
end

progressFrame:SetScript("OnEnter", function(self)
    if not currentProgress then
        return
    end
    local total = currentProgress.total
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText(currentProgressLabel, 1, 0.89, 0.35)
    GameTooltip:AddLine(
        "BiS: " .. currentProgress.bis .. "/" .. total .. " slots - Listed: " .. currentProgress.listed .. "/" .. total,
        1,
        1,
        1
    )
    local pending = {}
    for _, slot in ipairs(currentProgress.slots) do
        if not slot.done and slot.target then
            pending[#pending + 1] = slot
        end
    end
    for index = 1, math.min(#pending, PROGRESS_TOOLTIP_LINES) do
        local slot = pending[index]
        local source = slot.target.source or ""
        if #source > PROGRESS_SOURCE_LENGTH then
            source = source:sub(1, PROGRESS_SOURCE_LENGTH - 3) .. "..."
        end
        local line = slot.slot .. ": " .. (slot.target.inBags and "Equip: " or "") .. slot.target.name
        if source ~= "" then
            line = line .. " (" .. source .. ")"
        end
        GameTooltip:AddLine(line, 0.85, 0.85, 0.85)
    end
    if #pending > PROGRESS_TOOLTIP_LINES then
        GameTooltip:AddLine("+" .. (#pending - PROGRESS_TOOLTIP_LINES) .. " more", 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end)
progressFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local function normalizeSlotName(name)
    return ForeverBiSModel.slotKey(name)
end

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

local dungeonSourceNames = {
    { "the deadmines", "The Deadmines" },
    { "wailing caverns", "Wailing Caverns" },
    { "shadowfang keep", "Shadowfang Keep" },
    { "blackfathom deeps", "Blackfathom Deeps" },
    { "ragefire chasm", "Ragefire Chasm" },
    { "ruins of lordaeron", "Ruins of Lordaeron" },
}

local function getSourceCategory(sourceText)
    local lowerSource = string.lower(sourceText or "")
    if string.find(lowerSource, "quest", 1, true) then
        return "quest"
    end
    for _, profession in ipairs(professionSourceIcons) do
        if string.find(lowerSource, profession[1], 1, true) then
            return "profession"
        end
    end
    for _, dungeonName in ipairs(dungeonSourceNames) do
        if string.find(lowerSource, dungeonName[1], 1, true) then
            return "dungeon"
        end
    end
    return "world"
end

local function getSourceIcon(sourceText)
    local category = getSourceCategory(sourceText)
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

local function getExclusiveFaction(sourceText)
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

local function formatItemSource(sourceText)
    sourceText = sourceText:gsub("(%d+%.?%d*%%) in Classic", "%1")
    local source, location = sourceText:match("^([^,]+),%s*(.+)$")
    if not source or sourceText:find("Quest:", 1, true) then
        return sourceText
    end
    return "|cffffd100" .. source .. "|r, |cff65d9ff" .. location .. "|r"
end

local listFilters = { search = "", sources = {}, dungeon = "all", bothFactions = false, hideMaker = false }
local FILTER_LEFT, FILTER_RIGHT = 22, 376
local FILTER_ROW_SEARCH, FILTER_ROW_BUTTONS, FILTER_ROW_DUNGEON = -84, -110, -130

local function getPlayerFaction()
    return UnitFactionGroup and UnitFactionGroup("player") or nil
end

local searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
searchBox:SetSize(224, 20)
searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", FILTER_LEFT, FILTER_ROW_SEARCH)
searchBox:SetAutoFocus(false)
searchBox:SetMaxLetters(48)
searchBox:SetTextInsets(5, 22, 0, 0)
local searchHint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
searchHint:SetPoint("LEFT", searchBox, "LEFT", 6, 0)
searchHint:SetText("Search item, boss or zone")
local clearSearchButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
clearSearchButton:SetSize(16, 16)
clearSearchButton:SetPoint("RIGHT", searchBox, "RIGHT", 0, 0)
clearSearchButton:SetText("x")
clearSearchButton:Hide()
local countText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
countText:SetPoint("TOPRIGHT", frame, "TOPLEFT", FILTER_RIGHT, FILTER_ROW_SEARCH - 4)
countText:SetWidth(96)
countText:SetJustifyH("RIGHT")

local function refreshSearchWidgets()
    local hasText = (searchBox:GetText() or "") ~= ""
    if hasText then
        searchHint:Hide()
        clearSearchButton:Show()
    else
        searchHint:Show()
        clearSearchButton:Hide()
    end
end

searchBox:SetScript("OnTextChanged", function(self)
    listFilters.search = string.lower(self:GetText() or "")
    refreshSearchWidgets()
    scroll:SetVerticalScroll(0)
    if render then
        render()
    end
end)
searchBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
end)
searchBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)
clearSearchButton:SetScript("OnClick", function()
    searchBox:SetText("")
    searchBox:ClearFocus()
end)

local function setFilterActive(button, active)
    button.filterActive = active
    if active then
        button:LockHighlight()
    else
        button:UnlockHighlight()
    end
    local label = button:GetFontString()
    if label then
        if active then
            label:SetTextColor(1, 0.89, 0.35)
        else
            label:SetTextColor(0.75, 0.75, 0.75)
        end
    end
end

local function attachFilterTooltip(button, heading, description)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(heading, 1, 0.89, 0.35)
        GameTooltip:AddLine(description, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function createFilterButton(name, width)
    local button = CreateFrame("Button", name, frame, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    return button
end

local sourceChips = {
    { "quest", "Quests", "Interface\\GossipFrame\\AvailableQuestIcon" },
    { "dungeon", "Dungeons and raids", "Interface\\AddOns\\ForeverBiS\\ForeverBiSDungeonIcon.tga" },
    { "world", "World", "Interface\\WorldMap\\UI-World-Icon" },
    { "profession", "Professions", "Interface\\Icons\\Trade_Engineering" },
}
local sourceChipButtons = {}
local lastChip
for _, chip in ipairs(sourceChips) do
    local category, label, texture = chip[1], chip[2], chip[3]
    local button = createFilterButton("ForeverBiSFilter" .. category, 28)
    if lastChip then
        button:SetPoint("LEFT", lastChip, "RIGHT", 4, 0)
    else
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", FILTER_LEFT, FILTER_ROW_BUTTONS)
    end
    local icon = button:CreateTexture(nil, "OVERLAY")
    icon:SetTexture(texture)
    icon:SetSize(14, 14)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    attachFilterTooltip(
        button,
        label,
        "Show only " .. string.lower(label) .. " sources. Select several to combine them."
    )
    sourceChipButtons[category] = button
    lastChip = button
end

local factionButton = createFilterButton("ForeverBiSFilterFaction", 70)
local makerButton = createFilterButton("ForeverBiSFilterMaker", 92)
makerButton:SetText("Maker only")
attachFilterTooltip(
    makerButton,
    "Maker only",
    "Hide profession items that only their maker can wear. Items any player can use stay visible."
)
attachFilterTooltip(factionButton, "Faction", "Show items for your faction only. Click to show both factions.")

local dungeonDrop = CreateFrame("Frame", "ForeverBiSDungeonFilter", frame, "UIDropDownMenuTemplate")
dungeonDrop:SetPoint("TOPLEFT", frame, "TOPLEFT", FILTER_LEFT - 16, FILTER_ROW_DUNGEON)
UIDropDownMenu_SetWidth(dungeonDrop, 150)

local dungeonOptions = { { "all", "All dungeons" } }
for _, dungeon in ipairs(dungeonSourceNames) do
    table.insert(dungeonOptions, { dungeon[1], dungeon[2] })
end

local function updateDungeonText()
    for _, option in ipairs(dungeonOptions) do
        if option[1] == listFilters.dungeon then
            UIDropDownMenu_SetText(dungeonDrop, option[2])
            break
        end
    end
end

--- Syncs every filter widget with listFilters and places the list below the bar.
local function layoutFilterBar()
    for category, button in pairs(sourceChipButtons) do
        setFilterActive(button, listFilters.sources[category] == true)
    end

    local faction = getPlayerFaction()
    factionButton:ClearAllPoints()
    makerButton:ClearAllPoints()
    if faction then
        factionButton:Show()
        factionButton:SetPoint("LEFT", lastChip, "RIGHT", 10, 0)
        factionButton:SetText(listFilters.bothFactions and "Both" or faction)
        setFilterActive(factionButton, not listFilters.bothFactions)
        makerButton:SetPoint("LEFT", factionButton, "RIGHT", 4, 0)
    else
        factionButton:Hide()
        makerButton:SetPoint("LEFT", lastChip, "RIGHT", 10, 0)
    end
    setFilterActive(makerButton, listFilters.hideMaker)

    local showDungeons = listFilters.sources.dungeon == true
    if showDungeons then
        dungeonDrop:Show()
    else
        dungeonDrop:Hide()
    end
    updateDungeonText()

    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, showDungeons and -166 or -140)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -384, 38)
end

local function refreshList()
    layoutFilterBar()
    scroll:SetVerticalScroll(0)
    if render then
        render()
    end
end

for category, button in pairs(sourceChipButtons) do
    button:SetScript("OnClick", function()
        if listFilters.sources[category] then
            listFilters.sources[category] = nil
            if category == "dungeon" then
                listFilters.dungeon = "all"
            end
        else
            listFilters.sources[category] = true
        end
        refreshList()
    end)
end
factionButton:SetScript("OnClick", function()
    listFilters.bothFactions = not listFilters.bothFactions
    refreshList()
end)
makerButton:SetScript("OnClick", function()
    listFilters.hideMaker = not listFilters.hideMaker
    refreshList()
end)

UIDropDownMenu_Initialize(dungeonDrop, function(_, level)
    for _, option in ipairs(dungeonOptions) do
        local optionValue, optionLabel = option[1], option[2]
        local info = UIDropDownMenu_CreateInfo()
        info.text = optionLabel
        info.checked = listFilters.dungeon == optionValue
        info.func = function()
            listFilters.dungeon = optionValue
            updateDungeonText()
            scroll:SetVerticalScroll(0)
            if render then
                render()
            end
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)
layoutFilterBar()
refreshSearchWidgets()

local function isMakerOnly(sourceText)
    return string.find(string.lower(sourceText or ""), "only its maker can wear it", 1, true) ~= nil
end

local function itemMatchesFilters(item)
    local itemName, itemSource = item[1], item[2] or ""
    local lowerSource = string.lower(itemSource)
    if listFilters.search ~= "" then
        local haystack = string.lower(itemName) .. " " .. lowerSource
        if not string.find(haystack, listFilters.search, 1, true) then
            return false
        end
    end
    local faction = getPlayerFaction()
    if faction and not listFilters.bothFactions then
        local exclusive = getExclusiveFaction(itemSource)
        if exclusive and exclusive ~= faction then
            return false
        end
    end
    if next(listFilters.sources) and not listFilters.sources[getSourceCategory(itemSource)] then
        return false
    end
    if listFilters.dungeon ~= "all" and not string.find(lowerSource, listFilters.dungeon, 1, true) then
        return false
    end
    if listFilters.hideMaker and isMakerOnly(itemSource) then
        return false
    end
    return true
end

resetListFilters = function()
    listFilters.search, listFilters.dungeon = "", "all"
    listFilters.sources = {}
    listFilters.bothFactions, listFilters.hideMaker = false, false
    if searchBox:GetText() ~= "" then
        searchBox:SetText("")
    end
    layoutFilterBar()
    refreshSearchWidgets()
end

local function routePhases()
    local route = currentListKey()
    return ForeverBiSModel and ForeverBiSModel.phases(route) or {}, route
end

local function updateSelectors()
    local selectedClass = findClass(ForeverBiSDB.class)
    local selectedBuild = findBuild(selectedClass, ForeverBiSDB.build)
    UIDropDownMenu_SetText(classDrop, selectedClass.label)
    UIDropDownMenu_SetText(buildDrop, selectedBuild[2])

    local phases, route = routePhases()
    -- A saved phase this route does not have falls back to automatic.
    if ForeverBiSModel and not ForeverBiSModel.availablePhase(route, ForeverBiSDB.phase) then
        ForeverBiSDB.phase = nil
    end
    local effective = effectivePhaseFor(route)
    local effectiveLabel = effective
    for _, phase in ipairs(phases) do
        if phase.id == effective then
            effectiveLabel = phase.label or phase.id
        end
    end
    if effectiveLabel then
        UIDropDownMenu_SetText(phaseDrop, ForeverBiSDB.phase and effectiveLabel or "Auto (" .. effectiveLabel .. ")")
    end
    if #phases > 1 then
        phaseDrop:Show()
    else
        phaseDrop:Hide()
    end
end

UIDropDownMenu_Initialize(classDrop, function(_, level)
    for _, class in ipairs(classes) do
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.checked = class.label, class.key == ForeverBiSDB.class
        info.func = function()
            ForeverBiSDB.class, ForeverBiSDB.build = class.key, defaultBuild(class)[1]
            ForeverBiSDB.classChosen = true -- a manual pick turns off login auto-detection for good
            updateSelectors()
            scroll:SetVerticalScroll(0)
            render()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

UIDropDownMenu_Initialize(buildDrop, function(_, level)
    local selectedClass = findClass(ForeverBiSDB.class)
    for _, build in ipairs(selectedClass.builds) do
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.checked = build[2], build[1] == ForeverBiSDB.build
        info.func = function()
            ForeverBiSDB.build = build[1]
            updateSelectors()
            scroll:SetVerticalScroll(0)
            render()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

UIDropDownMenu_Initialize(phaseDrop, function(_, level)
    local phases, route = routePhases()
    local autoPhase = ForeverBiSModel and ForeverBiSModel.phaseForLevel(route, currentPlayerLevel())
    local autoLabel = autoPhase
    for _, phase in ipairs(phases) do
        if phase.id == autoPhase then
            autoLabel = phase.label or phase.id
        end
    end
    local info = UIDropDownMenu_CreateInfo()
    info.text, info.checked = "Auto (" .. tostring(autoLabel) .. ")", ForeverBiSDB.phase == nil
    info.func = function()
        ForeverBiSDB.phase = nil
        updateSelectors()
        scroll:SetVerticalScroll(0)
        render()
    end
    UIDropDownMenu_AddButton(info, level)
    for _, phase in ipairs(phases) do
        local phaseInfo = UIDropDownMenu_CreateInfo()
        phaseInfo.text, phaseInfo.checked = phase.label or phase.id, phase.id == ForeverBiSDB.phase
        phaseInfo.func = function()
            ForeverBiSDB.phase = phase.id
            updateSelectors()
            scroll:SetVerticalScroll(0)
            render()
        end
        UIDropDownMenu_AddButton(phaseInfo, level)
    end
end)

local function clearContent()
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, region in ipairs({ content:GetRegions() }) do
        region:Hide()
        region:SetParent(nil)
    end
end

render = function()
    local previousScroll = scroll:GetVerticalScroll() or 0
    currentSlotTops = {}
    local key = currentListKey()
    -- Prefer the selected phase's data; the bundled fallback lists cover a missing model or route.
    local phaseId = key and effectivePhaseFor(key)
    local data = key and (phaseId and ForeverBiSModel.list(key, phaseId) or lists[key])
    title:SetText("BiS Forever")
    refreshProgress(data, key, phaseId)
    clearContent()
    for _, child in ipairs({ gearContent:GetChildren() }) do
        if child ~= characterModel then
            child:Hide()
            child:SetParent(nil)
        end
    end
    for _, region in ipairs({ gearContent:GetRegions() }) do
        region:Hide()
        region:SetParent(nil)
    end

    local playerName, playerRealm
    if UnitFullName then
        playerName, playerRealm = UnitFullName("player")
    end
    if not playerName and UnitName then
        playerName, playerRealm = UnitName("player")
    end
    playerName = playerName or "Player"
    if (not playerRealm or playerRealm == "") and GetRealmName then
        playerRealm = GetRealmName()
    end
    local localizedClass, classToken = "", nil
    if UnitClass then
        localizedClass, classToken = UnitClass("player")
    end
    local playerLevel = UnitLevel and UnitLevel("player") or ""
    local nameLabel = gearContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOP", gearContent, "TOP", 0, -242)
    nameLabel:SetWidth(gearContent:GetWidth() - 24)
    nameLabel:SetJustifyH("CENTER")
    local fullPlayerName = playerName or "Player"
    if playerRealm and playerRealm ~= "" then
        fullPlayerName = fullPlayerName .. " " .. playerRealm
    end
    nameLabel:SetText(fullPlayerName)
    local playerClassLabel = gearContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    playerClassLabel:SetPoint("TOP", gearContent, "TOP", 0, -257)
    playerClassLabel:SetText(localizedClass or "")
    local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
    if classColor then
        playerClassLabel:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        playerClassLabel:SetTextColor(1, 1, 1)
    end
    local levelLabel = gearContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelLabel:SetPoint("TOP", gearContent, "TOP", 0, -272)
    levelLabel:SetText("Level " .. tostring(playerLevel or ""))
    levelLabel:SetTextColor(1, 0.89, 0.35)
    local screenW = UIParent:GetWidth()
    local screenH = UIParent:GetHeight()
    local width = userSized and frame:GetWidth() or math.min(760, screenW - 50)
    if not userSized then
        frame:SetWidth(width)
    end
    local listWidth = width - 410
    content:SetWidth(listWidth)

    local y = -5
    if not data then
        local msg = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        msg:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
        msg:SetWidth(content:GetWidth())
        msg:SetJustifyH("LEFT")
        msg:SetText("This installed version does not include the selected BiS list yet.")
        countText:SetText("")
        content:SetHeight(45)
        scroll:SetVerticalScroll(0)
        if not userSized then
            frame:SetHeight(math.min(500, screenH - 50))
        end
        return
    end

    local sourceX = 86
    local sourceWidth = content:GetWidth() - sourceX - 8
    local bestItems = {}
    local rankedItems = {}
    local slotDisplayNames = {}
    local anyFilteredItems = false
    local totalItems, shownItems = 0, 0
    for _, slot in ipairs(data.slots) do
        local slotKey = normalizeSlotName(slot[1])
        bestItems[slotKey] = slot[2][1]
        rankedItems[slotKey] = slot[2]
        slotDisplayNames[slotKey] = slot[1]
        local visibleItems = {}
        for rank, item in ipairs(slot[2]) do
            if itemMatchesFilters(item) then
                table.insert(visibleItems, { rank, item })
            end
        end

        totalItems = totalItems + #slot[2]
        shownItems = shownItems + #visibleItems
        if #visibleItems > 0 then
            anyFilteredItems = true
            y = y - 4
            local collapseKey = key .. ":" .. slot[1]
            local collapsed = collapsedSections[collapseKey]
            local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            header:SetPoint("TOPLEFT", content, "TOPLEFT", 24, y)
            header:SetText("|cffffe35b" .. string.upper(slot[1]) .. "|r")
            local collapseButton = CreateFrame("Button", nil, content)
            collapseButton:SetSize(18, 18)
            collapseButton:SetPoint("LEFT", header, "LEFT", -23, -1)
            local buttonTexture = collapsed and "UI-PlusButton" or "UI-MinusButton"
            collapseButton:SetNormalTexture("Interface\\Buttons\\" .. buttonTexture .. "-Up")
            collapseButton:SetPushedTexture("Interface\\Buttons\\" .. buttonTexture .. "-Down")
            collapseButton:SetHighlightTexture("Interface\\Buttons\\" .. buttonTexture .. "-Highlight", "ADD")
            collapseButton:SetScript("OnClick", function()
                if collapsedSections[collapseKey] then
                    collapsedSections[collapseKey] = nil
                else
                    collapsedSections[collapseKey] = true
                end
                render()
            end)
            currentSlotTops[slotKey] = y
            y = y - 30
            local rule = content:CreateTexture(nil, "ARTWORK")
            rule:SetTexture("Interface\\Buttons\\WHITE8X8")
            rule:SetVertexColor(0.42, 0.49, 0.61, 0.9)
            rule:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
            rule:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y)
            rule:SetHeight(1)
            y = y - 6

            if not collapsed then
                for _, rankedItem in ipairs(visibleItems) do
                    local rank, item = rankedItem[1], rankedItem[2]
                    local rowTop = y
                    local rankText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    rankText:SetPoint("TOPLEFT", content, "TOPLEFT", 0, rowTop - 9)
                    rankText:SetWidth(28)
                    rankText:SetJustifyH("RIGHT")
                    rankText:SetText(tostring(rank))

                    local itemName, itemSource = item[1], item[2]
                    local itemID = getItemID(itemName)
                    local iconButton = CreateFrame("Button", nil, content)
                    iconButton:SetSize(38, 38)
                    iconButton:SetPoint("TOPLEFT", content, "TOPLEFT", 32, rowTop - 2)
                    local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
                    iconTexture:SetAllPoints(iconButton)
                    iconTexture:SetTexture(getItemIcon(itemName))
                    addQualityBorder(iconButton, itemName)
                    addOwnershipMark(iconButton, itemName, slotKey, true)
                    iconButton:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        if itemID then
                            GameTooltip:SetHyperlink("item:" .. itemID)
                        else
                            GameTooltip:SetText(itemName, 1, 1, 1)
                        end
                        GameTooltip:AddLine("Source: " .. itemSource, 0.85, 0.85, 0.85, true)
                        addOwnershipTooltip(itemName, slotKey)
                        GameTooltip:Show()
                    end)
                    iconButton:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)

                    local name = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    name:SetPoint("TOPLEFT", content, "TOPLEFT", sourceX, rowTop - 4)
                    local faction = getExclusiveFaction(itemSource)
                    local nameWidth = faction and math.max(80, sourceWidth - 66) or sourceWidth
                    name:SetWidth(nameWidth)
                    name:SetJustifyH("LEFT")
                    name:SetWordWrap(true)
                    name:SetText(itemName)
                    name:SetTextColor(getItemQualityColor(itemName))

                    if faction then
                        local factionIcon = content:CreateTexture(nil, "ARTWORK")
                        factionIcon:SetSize(14, 14)
                        factionIcon:SetPoint("TOPLEFT", content, "TOPLEFT", sourceX + nameWidth + 3, rowTop - 5)
                        factionIcon:SetTexture(
                            faction == "Horde" and "Interface\\TargetingFrame\\UI-PVP-Horde"
                                or "Interface\\TargetingFrame\\UI-PVP-Alliance"
                        )
                        local factionLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        factionLabel:SetPoint("LEFT", factionIcon, "RIGHT", 2, 0)
                        factionLabel:SetText(faction)
                        factionLabel:SetFont(STANDARD_TEXT_FONT, 11, "THICKOUTLINE")
                        if faction == "Horde" then
                            factionLabel:SetTextColor(1, 0.2, 0.2)
                        else
                            factionLabel:SetTextColor(0.3, 0.65, 1)
                        end
                    end

                    local source = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    local sourceTop = rowTop - name:GetStringHeight() - 8
                    local sourceIcon = content:CreateTexture(nil, "ARTWORK")
                    sourceIcon:SetSize(16, 16)
                    sourceIcon:SetPoint("TOPLEFT", content, "TOPLEFT", sourceX, sourceTop + 1)
                    sourceIcon:SetTexture(getSourceIcon(itemSource))
                    source:SetPoint("TOPLEFT", content, "TOPLEFT", sourceX + 20, sourceTop)
                    source:SetWidth(sourceWidth - 20)
                    source:SetJustifyH("LEFT")
                    source:SetWordWrap(true)
                    source:SetText(formatItemSource(itemSource))

                    local rowHeight = math.max(48, name:GetStringHeight() + source:GetStringHeight() + 12)
                    y = rowTop - rowHeight
                    local separator = content:CreateTexture(nil, "ARTWORK")
                    separator:SetTexture("Interface\\Buttons\\WHITE8X8")
                    separator:SetVertexColor(0.35, 0.42, 0.53, 0.85)
                    separator:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
                    separator:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y)
                    separator:SetHeight(1)
                    y = y - 3
                end

                local enchants = slot[3]
                if enchants and #enchants > 0 then
                    local enchantHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    enchantHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 32, y - 4)
                    enchantHeader:SetText("|cff8fb3ffENCHANTS|r")
                    y = y - 22
                    for _, enchant in ipairs(enchants) do
                        local effect, spellName, enchantSource, formulaID =
                            enchant[1], enchant[2], enchant[3], enchant[4]
                        local rowTop = y
                        local iconButton = CreateFrame("Button", nil, content)
                        iconButton:SetSize(28, 28)
                        iconButton:SetPoint("TOPLEFT", content, "TOPLEFT", 36, rowTop - 2)
                        local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
                        iconTexture:SetAllPoints(iconButton)
                        iconTexture:SetTexture("Interface\\Icons\\Trade_Engraving")
                        iconButton:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            if formulaID then
                                GameTooltip:SetHyperlink("item:" .. formulaID)
                            else
                                GameTooltip:SetText(spellName, 1, 1, 1)
                            end
                            GameTooltip:AddLine("Source: " .. enchantSource, 0.85, 0.85, 0.85, true)
                            GameTooltip:Show()
                        end)
                        iconButton:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)

                        local effectText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        effectText:SetPoint("TOPLEFT", content, "TOPLEFT", sourceX, rowTop - 2)
                        effectText:SetWidth(sourceWidth)
                        effectText:SetJustifyH("LEFT")
                        effectText:SetWordWrap(true)
                        effectText:SetText(effect)
                        effectText:SetTextColor(0.12, 1, 0)

                        local detailText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                        detailText:SetPoint(
                            "TOPLEFT",
                            content,
                            "TOPLEFT",
                            sourceX,
                            rowTop - effectText:GetStringHeight() - 6
                        )
                        detailText:SetWidth(sourceWidth)
                        detailText:SetJustifyH("LEFT")
                        detailText:SetWordWrap(true)
                        detailText:SetText(spellName .. " - " .. enchantSource)

                        y = rowTop - math.max(36, effectText:GetStringHeight() + detailText:GetStringHeight() + 10)
                    end
                    y = y - 3
                end
            end
        end
    end

    if not anyFilteredItems then
        local empty = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        empty:SetPoint("TOPLEFT", content, "TOPLEFT", 8, y - 6)
        empty:SetWidth(content:GetWidth() - 16)
        empty:SetJustifyH("LEFT")
        empty:SetText("No items match the current search and filters.")
        local clearAll = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        clearAll:SetSize(100, 22)
        clearAll:SetPoint("TOPLEFT", content, "TOPLEFT", 8, y - 34)
        clearAll:SetText("Clear filters")
        clearAll:SetScript("OnClick", function()
            resetListFilters()
            render()
        end)
        y = y - 66
    end
    if shownItems == totalItems then
        countText:SetText(totalItems .. " items")
    else
        countText:SetText("|cffffe35b" .. shownItems .. "|r/" .. totalItems)
    end

    local equippedBisShown = false
    for _, slotInfo in ipairs(paperDollSlots) do
        local displayName, listSlot, column, row, rank = unpack(slotInfo)
        local itemRank = rank or 1
        local bestItem = rankedItems[listSlot] and rankedItems[listSlot][itemRank]
        if bestItem and (not showEquippedOnly or isItemEquippedInSlot(getItemID(bestItem[1]), listSlot)) then
            equippedBisShown = true
            local targetSlot, targetItem, slotLabel = listSlot, bestItem, displayName
            local x = column == 1 and 5 or gearContent:GetWidth() - 37
            local yOffset = -((row - 1) * 37)
            local button = CreateFrame("Button", nil, gearContent)
            button:SetSize(32, 32)
            button:SetPoint("TOPLEFT", gearContent, "TOPLEFT", x, yOffset)
            local texture = button:CreateTexture(nil, "ARTWORK")
            texture:SetAllPoints(button)
            texture:SetTexture(getItemIcon(bestItem[1]))
            addQualityBorder(button, bestItem[1])
            addOwnershipMark(button, bestItem[1], listSlot)
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                local itemID = getItemID(targetItem[1])
                if itemID then
                    GameTooltip:SetHyperlink("item:" .. itemID)
                else
                    GameTooltip:SetText(targetItem[1], 1, 1, 1)
                end
                GameTooltip:AddLine("Best in slot: " .. slotLabel, 1, 0.89, 0.35)
                GameTooltip:AddLine("Source: " .. targetItem[2], 0.85, 0.85, 0.85, true)
                addOwnershipTooltip(targetItem[1], slotLabel)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            button:SetScript("OnClick", function()
                if not itemMatchesFilters(targetItem) then
                    resetListFilters()
                    if not itemMatchesFilters(targetItem) then
                        listFilters.bothFactions = true
                        layoutFilterBar()
                    end
                    render()
                end
                local sectionName = slotDisplayNames[targetSlot] or targetSlot
                local collapseKey = key .. ":" .. sectionName
                if collapsedSections[collapseKey] then
                    collapsedSections[collapseKey] = nil
                    render()
                end
                local target = currentSlotTops[targetSlot]
                if target then
                    scroll:SetVerticalScroll(math.max(0, -target - 4))
                end
            end)
        end
    end

    local weaponCenter = math.floor(gearContent:GetWidth() / 2)
    local weaponPositions = { weaponCenter - 57, weaponCenter - 19, weaponCenter + 19 }
    for index, slotName in ipairs(weaponSlots) do
        local bestItem = bestItems[slotName]
        if bestItem and (not showEquippedOnly or isItemEquippedInSlot(getItemID(bestItem[1]), slotName)) then
            equippedBisShown = true
            local targetSlot, targetItem = slotName, bestItem
            local displaySlot = slotName == "Ranged" and (slotDisplayNames[slotName] or slotName) or slotName
            local button = CreateFrame("Button", nil, gearContent)
            button:SetSize(32, 32)
            button:SetPoint("TOPLEFT", gearContent, "TOPLEFT", weaponPositions[index], -292)
            local texture = button:CreateTexture(nil, "ARTWORK")
            texture:SetAllPoints(button)
            texture:SetTexture(getItemIcon(targetItem[1]))
            addQualityBorder(button, targetItem[1])
            addOwnershipMark(button, targetItem[1], slotName)
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                local itemID = getItemID(targetItem[1])
                if itemID then
                    GameTooltip:SetHyperlink("item:" .. itemID)
                else
                    GameTooltip:SetText(targetItem[1], 1, 1, 1)
                end
                GameTooltip:AddLine("Best in slot: " .. displaySlot, 1, 0.89, 0.35)
                GameTooltip:AddLine("Source: " .. targetItem[2], 0.85, 0.85, 0.85, true)
                addOwnershipTooltip(targetItem[1], targetSlot)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            button:SetScript("OnClick", function()
                if not itemMatchesFilters(targetItem) then
                    resetListFilters()
                    if not itemMatchesFilters(targetItem) then
                        listFilters.bothFactions = true
                        layoutFilterBar()
                    end
                    render()
                end
                local sectionName = slotDisplayNames[targetSlot] or targetSlot
                local collapseKey = key .. ":" .. sectionName
                if collapsedSections[collapseKey] then
                    collapsedSections[collapseKey] = nil
                    render()
                end
                local target = currentSlotTops[targetSlot]
                if target then
                    scroll:SetVerticalScroll(math.max(0, -target - 4))
                end
            end)
        end
    end

    if showEquippedOnly and not equippedBisShown then
        local emptyGear = gearContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        emptyGear:SetPoint("CENTER", gearContent, "CENTER", 0, 0)
        emptyGear:SetWidth(gearContent:GetWidth() - 36)
        emptyGear:SetJustifyH("CENTER")
        emptyGear:SetWordWrap(true)
        emptyGear:SetText("No equipped BiS items found.")
    end

    content:SetHeight(-y + 8)
    if scroll.UpdateScrollChildRect then
        scroll:UpdateScrollChildRect()
    end
    local maxScroll = math.max(0, content:GetHeight() - scroll:GetHeight())
    scroll:SetVerticalScroll(math.min(previousScroll, maxScroll))
    if not userSized then
        frame:SetHeight(math.min(500, screenH - 50))
    end
end

local resizeHandle = CreateFrame("Button", nil, frame)
resizeHandle:SetSize(36, 14)
resizeHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 5)
for index, barWidth in ipairs({ 22, 16, 10 }) do
    local gripBar = resizeHandle:CreateTexture(nil, "OVERLAY")
    gripBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    gripBar:SetVertexColor(0.72, 0.58, 0.32, 0.9)
    gripBar:SetSize(barWidth, 1)
    gripBar:SetPoint("CENTER", resizeHandle, "CENTER", 0, 4 - index * 3)
end
resizeHandle:SetScript("OnMouseDown", function()
    userSized = true
    frame:StartSizing("BOTTOM")
end)
resizeHandle:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    render()
end)
resizeHandle:SetScript("OnHide", function()
    frame:StopMovingOrSizing()
end)

local function toggleAddonFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        updateSelectors()
        render()
    end
end

local minimapButton = CreateFrame("Button", "ForeverBiSMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 8)
minimapButton:RegisterForClicks("LeftButtonUp")
minimapButton:RegisterForDrag("LeftButton")

local minimapIcon = minimapButton:CreateTexture(nil, "ARTWORK")
minimapIcon:SetTexture("Interface\\AddOns\\ForeverBiS\\ForeverBiSMinimapIcon.tga")
minimapIcon:SetSize(28, 28)
minimapIcon:SetPoint("CENTER")

local function updateMinimapButtonPosition()
    local angle = math.rad(ForeverBiSDB.minimap.angle or 220)
    local radius = Minimap:GetWidth() / 2 + 2
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Forever BiS", 1, 0.89, 0.35)
    GameTooltip:AddLine("Click to open or close", 1, 1, 1)
    GameTooltip:AddLine("Drag to move the button", 0.75, 0.75, 0.75)
    GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
minimapButton:SetScript("OnDragStart", function(self)
    self.dragMoved = false
    self.startCursorX, self.startCursorY = GetCursorPosition()
    self:SetScript("OnUpdate", function(button)
        local cursorX, cursorY = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        cursorX, cursorY = cursorX / scale, cursorY / scale
        local startX, startY = button.startCursorX / scale, button.startCursorY / scale
        if math.abs(cursorX - startX) + math.abs(cursorY - startY) > 4 then
            button.dragMoved = true
        end
        local centerX, centerY = Minimap:GetCenter()
        if centerX and centerY then
            local angle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX))
            ForeverBiSDB.minimap.angle = angle
            updateMinimapButtonPosition()
        end
    end)
end)
minimapButton:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    self.suppressNextClick = self.dragMoved
end)
minimapButton:SetScript("OnClick", function(self)
    if self.suppressNextClick then
        self.suppressNextClick = false
        return
    end
    toggleAddonFrame()
end)
updateMinimapButtonPosition()
if ForeverBiSDB.minimap.hide then
    minimapButton:Hide()
end

for _, itemID in pairs(itemIDs) do
    trackedItemIDs[itemID] = true
end
local itemDataWatcher = CreateFrame("Frame")
itemDataWatcher:RegisterEvent("GET_ITEM_INFO_RECEIVED")
itemDataWatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
itemDataWatcher:RegisterEvent("BAG_UPDATE")
-- Item data arrives in bursts (one event per requested item); coalesce them into a single render per burst.
local renderPending = false
local function scheduleRender()
    if renderPending then
        return
    end
    renderPending = true
    C_Timer.After(0.2, function()
        renderPending = false
        if frame:IsShown() then
            render()
        end
    end)
end

itemDataWatcher:SetScript("OnEvent", function(_, event, itemID, success)
    if not frame:IsShown() then
        return
    end
    if event == "GET_ITEM_INFO_RECEIVED" then
        if success and trackedItemIDs[itemID] then
            scheduleRender()
        end
    else
        scheduleRender()
    end
end)

-- Saved variables are only reliable once the client has loaded them, which happens after this file executes
-- (the global may even be replaced wholesale), so re-bind and auto-detect the class at PLAYER_LOGIN.
local function detectPlayerClass()
    if ForeverBiSDB.classChosen == true or not UnitClass then
        return
    end
    local _, token = UnitClass("player")
    if type(token) ~= "string" then
        return
    end
    local key = string.lower(token)
    for _, class in ipairs(classes) do
        -- The build is reset only when the class actually changes, so a build picked by hand survives.
        if class.key == key and ForeverBiSDB.class ~= key then
            ForeverBiSDB.class, ForeverBiSDB.build = key, defaultBuild(class)[1]
        end
    end
end

local loginWatcher = CreateFrame("Frame")
loginWatcher:RegisterEvent("PLAYER_LOGIN")
loginWatcher:SetScript("OnEvent", function()
    ForeverBiSDB = ForeverBiSDB or { class = "rogue", build = "pve" }
    ForeverBiSDB.minimap = ForeverBiSDB.minimap or {}
    collapsedSections = type(ForeverBiSDB.collapsed) == "table" and ForeverBiSDB.collapsed or {}
    ForeverBiSDB.collapsed = collapsedSections
    detectPlayerClass()
    updateMinimapButtonPosition()
    if ForeverBiSDB.minimap.hide then
        minimapButton:Hide()
    end
    updateSelectors()
    render()
end)

SLASH_FOREVERBIS1 = "/bis"
SLASH_FOREVERBIS2 = "/foreverbis"

--- /bis tooltip toggles the BiS tooltip block, /bis tooltip all toggles other classes in it; anything else toggles the window.
local function handleSlashCommand(message)
    local command, argument = string.lower(message or ""):match("^%s*(%S+)%s*(%S*)")
    if command == "tooltip" and argument == "all" then
        ForeverBiSDB.tooltipAllClasses = ForeverBiSDB.tooltipAllClasses ~= true
        print("Forever BiS tooltips: " .. (ForeverBiSDB.tooltipAllClasses and "all classes" or "your class only"))
    elseif command == "tooltip" and argument == "" then
        ForeverBiSDB.tooltip = ForeverBiSDB.tooltip == false
        print("Forever BiS tooltips: " .. (ForeverBiSDB.tooltip and "on" or "off"))
    else
        toggleAddonFrame()
    end
end

SlashCmdList["FOREVERBIS"] = handleSlashCommand
updateSelectors()
render()
