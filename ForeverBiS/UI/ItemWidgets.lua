-- Pieces shared by the item list and the paper doll: quality border, ownership mark, item tooltip.
local _, ns = ...

local ItemWidgets = {}
ns.ItemWidgets = ItemWidgets

local Items, Inventory, Pixel, Skin, Theme, L = ns.Items, ns.Inventory, ns.Pixel, ns.Skin, ns.Theme, ns.L

--- A 1px border around an icon button in the item's rarity color, or the danger color when its slot is missing the
--- BiS item. Returns the border, so a button can tint it while hovered.
function ItemWidgets.addQualityBorder(button, itemName, missing)
    local color = missing and "danger" or { Items.qualityColor(itemName) }
    return Pixel.Border(button, color, "OVERLAY")
end

--- A check badge when the item is equipped in the slot, otherwise the bag count when carried.
--- Returns "equipped" or "bags" with the count, or nil.
function ItemWidgets.addOwnershipMark(button, itemName, slotName)
    local itemID = Items.id(itemName)
    if Inventory.isEquippedInSlot(itemID, slotName) then
        local badge = button:CreateTexture(nil, "OVERLAY")
        badge:SetSize(14, 14)
        badge:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        badge:SetColorTexture(Theme.Color("bg", 0.85))
        local check = button:CreateTexture(nil, "OVERLAY", nil, 1)
        check:SetSize(12, 12)
        check:SetPoint("CENTER", badge, "CENTER", 0, 0)
        Skin.icon(check, "check", "success")
        return "equipped", 0
    end
    local count = Inventory.bagCount(itemID)
    if count > 0 then
        local bagCount = Skin.label(button, 11, "semibold", "warning")
        bagCount:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -1)
        -- A soft shadow keeps the number readable over item art.
        bagCount:SetShadowOffset(1, -1)
        bagCount:SetShadowColor(0, 0, 0, 0.8)
        bagCount:SetText(L["x%d"]:format(count))
        return "bags", count
    end
    return nil, 0
end

--- Opens the shared tooltip on the item: its game tooltip when the id is known, otherwise just the name.
function ItemWidgets.showItemTooltip(owner, anchor, itemName)
    GameTooltip:SetOwner(owner, anchor)
    local itemID = Items.id(itemName)
    if itemID then
        GameTooltip:SetHyperlink("item:" .. itemID)
    else
        GameTooltip:SetText(itemName, 1, 1, 1)
    end
end

--- Appends "Currently equipped" or "In bags: n" to the open tooltip.
function ItemWidgets.addOwnershipTooltip(itemName, slotName)
    local itemID = Items.id(itemName)
    if Inventory.isEquippedInSlot(itemID, slotName) then
        GameTooltip:AddLine(L["Currently equipped"], 0.35, 1, 0.35)
    else
        local count = Inventory.bagCount(itemID)
        if count > 0 then
            GameTooltip:AddLine(L["In bags: %d"]:format(count), 1, 0.82, 0.2)
        end
    end
end
