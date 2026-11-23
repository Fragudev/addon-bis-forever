-- What the player wears and carries. The only place that reads equipped slots and bag counts.
local _, ns = ...

local Inventory = {}
ns.Inventory = Inventory

-- Inventory slot ids per lowercase slot name; rings and trinkets have two.
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

-- Every inventory slot that holds gear (shirt and tabard included), for a snapshot of what a unit wears.
local LAST_GEAR_SLOT = 19

--- What `unit` wears right now as { [inventory slot id] = item id }, read once (an inspected unit can change).
function Inventory.wornBy(unit)
    local worn = {}
    if GetInventoryItemID then
        for inventorySlotID = 1, LAST_GEAR_SLOT do
            worn[inventorySlotID] = GetInventoryItemID(unit, inventorySlotID)
        end
    end
    return worn
end

--- Whether the item is worn in any of the slots the name covers ("Finger" covers both rings): by the player, or by
--- whoever `worn` (a wornBy snapshot) describes.
function Inventory.isEquippedInSlot(itemID, slotName, worn)
    if not itemID or not (worn or GetInventoryItemID) then
        return false
    end
    local slotIDs = equippedSlotIDs[string.lower(slotName or "")]
    if not slotIDs then
        return false
    end
    for _, inventorySlotID in ipairs(slotIDs) do
        local wornID = worn and worn[inventorySlotID] or not worn and GetInventoryItemID("player", inventorySlotID)
        if wornID == itemID then
            return true
        end
    end
    return false
end

--- The ids of what is worn in the slot ("Finger" covers both rings), in slot order; empty slots are skipped.
function Inventory.equippedIds(slotName)
    local ids = {}
    for _, inventorySlotID in ipairs(equippedSlotIDs[string.lower(slotName or "")] or {}) do
        local itemID = GetInventoryItemID and GetInventoryItemID("player", inventorySlotID)
        if itemID then
            ids[#ids + 1] = itemID
        end
    end
    return ids
end

--- Copies of the item in the bags (the equipped one is not counted).
function Inventory.bagCount(itemID)
    if not itemID or not GetItemCount then
        return 0
    end
    return GetItemCount(itemID, false) or 0
end
