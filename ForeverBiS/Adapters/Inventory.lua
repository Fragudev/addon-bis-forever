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

--- Whether the item is worn in any of the slots the name covers ("Finger" covers both rings).
function Inventory.isEquippedInSlot(itemID, slotName)
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

--- What the player has for the given slot keys, read with the same slot ids and counts the row marks use.
function Inventory.buildOwned(slotKeys)
    local equipped = {}
    for _, key in ipairs(slotKeys) do
        equipped[key] = Inventory.equippedIds(key)
    end
    return { equipped = equipped, bags = Inventory.bagCount, itemId = ns.Items.id }
end
