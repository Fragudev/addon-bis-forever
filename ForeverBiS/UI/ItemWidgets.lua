-- Pieces shared by the item list and the paper doll: quality border, ownership mark, item tooltip.
local _, ns = ...

local ItemWidgets = {}
ns.ItemWidgets = ItemWidgets

local Items, Inventory, L = ns.Items, ns.Inventory, ns.L

-- Border of an icon whose slot still lacks its BiS item: subtle, but readable on every rarity and the brown frame.
local MISSING_BORDER = { 0.85, 0.2, 0.2 }

--- A 2px border around an icon button in the item's rarity color, or red when its slot is missing the BiS item.
function ItemWidgets.addQualityBorder(button, itemName, missing)
    local red, green, blue = Items.qualityColor(itemName)
    if missing then
        red, green, blue = MISSING_BORDER[1], MISSING_BORDER[2], MISSING_BORDER[3]
    end
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

--- A check when the item is equipped in the slot, otherwise the bag count when carried.
--- Returns "equipped" or "bags" with the count, or nil.
function ItemWidgets.addOwnershipMark(button, itemName, slotName, fullIconCheck)
    local itemID = Items.id(itemName)
    if Inventory.isEquippedInSlot(itemID, slotName) then
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
    local count = Inventory.bagCount(itemID)
    if count > 0 then
        local bagCount = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        bagCount:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -1)
        bagCount:SetText(L["x%d"]:format(count))
        bagCount:SetTextColor(1, 0.82, 0.2)
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
