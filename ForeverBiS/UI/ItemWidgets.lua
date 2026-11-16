-- Pieces shared by the item list and the paper doll: quality border, ownership mark, item tooltip.
local _, ns = ...

local ItemWidgets = {}
ns.ItemWidgets = ItemWidgets

local Items, Inventory, Pixel, Skin, Theme, L = ns.Items, ns.Inventory, ns.Pixel, ns.Skin, ns.Theme, ns.L

-- Widgets are never freed by the client, so every drawn widget comes from a per-container pool: release() hides the
-- ones taken since the last release and parks them under a hidden holder, and the next draw takes them back.
local holder

local function holderFrame()
    if not holder then
        holder = CreateFrame("Frame")
        holder:Hide()
    end
    return holder
end

local function poolOf(container)
    local pool = container.widgetPool
    if not pool then
        pool = { free = {}, active = {} }
        container.widgetPool = pool
    end
    return pool
end

--- A pooled widget of the kind `key` inside container: a free one when there is, else the result of create().
local function take(container, key, create)
    local pool = poolOf(container)
    local free = pool.free[key]
    local widget = free and table.remove(free)
    if widget then
        widget:SetParent(container)
        widget:Show()
    else
        widget = create()
        widget.poolKey = key
    end
    table.insert(pool.active, widget)
    return widget
end

--- Hides and parks every widget taken from the container since the last release.
function ItemWidgets.release(container)
    local pool = container.widgetPool
    if not pool then
        return
    end
    -- Parked back to front, so the next draw takes the widgets in the order they were drawn.
    for index = #pool.active, 1, -1 do
        local widget = pool.active[index]
        if widget.poolReset then
            widget:poolReset()
        end
        widget:Hide()
        widget:ClearAllPoints()
        widget:SetParent(holderFrame())
        local free = pool.free[widget.poolKey]
        if not free then
            free = {}
            pool.free[widget.poolKey] = free
        end
        table.insert(free, widget)
    end
    pool.active = {}
end

--- A pooled frame of frameType. build(frame) runs once when it is created; it may set frame.poolReset, called on
--- release. Pooled frames are created in any order, so creation order cannot keep a row's buttons above the frame
--- that washes the row on hover: each draw sets the level explicitly instead. `levelOffset` (default 2) is added to
--- the container's level; the hover frame passes 1 so the buttons over it keep the mouse and their tooltips.
function ItemWidgets.frame(container, key, frameType, build, levelOffset)
    local frame = take(container, key, function()
        local created = CreateFrame(frameType, nil, container)
        build(created)
        return created
    end)
    frame:SetFrameLevel(container:GetFrameLevel() + (levelOffset or 2))
    return frame
end

--- A pooled texture on the given draw layer (and sublevel), clean of what it showed before.
function ItemWidgets.texture(container, layer, sublevel)
    return take(container, "texture:" .. layer .. ":" .. (sublevel or 0), function()
        local texture = container:CreateTexture(nil, layer, nil, sublevel)
        texture.poolReset = function(self)
            self:SetTexture(nil)
            self:SetVertexColor(1, 1, 1, 1)
            self:SetDesaturated(false)
            self:SetSize(0, 0)
        end
        return texture
    end)
end

--- A pooled font string styled by Skin.label, clean of the text, width and alignment it had before.
function ItemWidgets.label(container, size, weight, token, layer)
    local label = take(container, "label:" .. (layer or "OVERLAY"), function()
        local fontString = Skin.label(container, size, weight, token, layer)
        fontString.poolReset = function(self)
            self:SetText("")
            self:SetWidth(0)
            self:SetJustifyH("CENTER")
            self:SetWordWrap(true)
            self:SetShadowOffset(0, 0)
        end
        return fontString
    end)
    return Skin.text(label, size, weight, token)
end

--- A 1px border around an icon button in the item's rarity color, or the danger color when its slot is missing the
--- BiS item. Returns the border, so a button can tint it while hovered. A button keeps one border and repaints it.
function ItemWidgets.addQualityBorder(button, itemName, missing)
    local color = missing and "danger" or { Items.qualityColor(itemName) }
    local border = button.qualityBorder
    if border then
        border:SetColor(color)
        return border
    end
    border = Pixel.Border(button, color, "OVERLAY")
    button.qualityBorder = border
    return border
end

--- The marks an icon button can carry, made once and shown or hidden as the item needs.
local function ownershipParts(button)
    local parts = button.ownership
    if parts then
        return parts
    end
    local badge = button:CreateTexture(nil, "OVERLAY")
    badge:SetSize(14, 14)
    badge:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
    badge:SetColorTexture(Theme.Color("bg", 0.85))
    local check = button:CreateTexture(nil, "OVERLAY", nil, 1)
    check:SetSize(12, 12)
    check:SetPoint("CENTER", badge, "CENTER", 0, 0)
    Skin.icon(check, "check", "success")
    local bagCount = Skin.label(button, 11, "semibold", "warning")
    bagCount:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -1)
    -- A soft shadow keeps the number readable over item art.
    bagCount:SetShadowOffset(1, -1)
    bagCount:SetShadowColor(0, 0, 0, 0.8)
    parts = { badge = badge, check = check, bagCount = bagCount }
    button.ownership = parts
    return parts
end

--- A check badge when the item is equipped in the slot, otherwise the bag count when carried.
--- Returns "equipped" or "bags" with the count, or nil.
function ItemWidgets.addOwnershipMark(button, itemName, slotName)
    local parts = ownershipParts(button)
    parts.badge:Hide()
    parts.check:Hide()
    parts.bagCount:Hide()
    local itemID = Items.id(itemName)
    if Inventory.isEquippedInSlot(itemID, slotName) then
        parts.badge:Show()
        parts.check:Show()
        return "equipped", 0
    end
    local count = Inventory.bagCount(itemID)
    if count > 0 then
        parts.bagCount:SetText(L["x%d"]:format(count))
        parts.bagCount:Show()
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
