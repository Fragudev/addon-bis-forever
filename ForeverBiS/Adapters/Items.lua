-- Item ids, icons and quality colors from the client. The only place that asks the client about items.
local _, ns = ...

local Items = {}
ns.Items = Items

local trackedItemIDs = {}
local requestedItemIDs = {}

local function knownIDs()
    return ForeverBiSItemIDs or {}
end

for _, itemID in pairs(knownIDs()) do
    trackedItemIDs[itemID] = true
end

--- The item id for a name: the bundled data first, then the client. Every id handed out is remembered as tracked.
function Items.id(itemName)
    local itemID = knownIDs()[itemName]
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

--- Whether an id came from the addon's own lists (so its arrival from the client is worth a redraw).
function Items.isTracked(itemID)
    return trackedItemIDs[itemID] == true
end

--- Asks the client to load an item once; the GET_ITEM_INFO_RECEIVED event announces it.
function Items.prefetch(itemID)
    if itemID and C_Item and C_Item.RequestLoadItemDataByID and not requestedItemIDs[itemID] then
        requestedItemIDs[itemID] = true
        C_Item.RequestLoadItemDataByID(itemID)
    end
end

--- Marks an id as worth a redraw when the client delivers it, and asks the client to load it.
function Items.track(itemID)
    trackedItemIDs[itemID] = true
    Items.prefetch(itemID)
end

--- The item name, or nil while the client has not loaded the item.
function Items.nameById(itemID)
    if itemID and GetItemInfo then
        return (GetItemInfo(itemID))
    end
    return nil
end

--- The item icon texture, or the question mark while the client has not loaded the item.
function Items.iconById(itemID)
    Items.prefetch(itemID)
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

--- The item icon for a name; see iconById.
function Items.icon(itemName)
    return Items.iconById(Items.id(itemName))
end

--- The red, green and blue of the item's rarity; white while the client has not loaded it.
function Items.qualityColorById(itemID)
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

--- The rarity color for a name; see qualityColorById.
function Items.qualityColor(itemName)
    return Items.qualityColorById(Items.id(itemName))
end

--- A clickable chat link for the item, built from its id when the client has not cached it. A name the addon
--- cannot resolve to an id stays plain text.
function Items.link(itemName)
    local itemID = Items.id(itemName)
    if not itemID then
        return "[" .. itemName .. "]"
    end
    if GetItemInfo then
        local _, link = GetItemInfo(itemID)
        if link then
            return link
        end
    end
    return "|cffffffff|Hitem:" .. itemID .. "::::::::|h[" .. itemName .. "]|h|r"
end
