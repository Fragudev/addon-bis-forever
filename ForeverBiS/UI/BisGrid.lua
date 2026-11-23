-- The BiS grid: one row per gear slot with its top 6 items as icons, ranked left to right. An equipped item gets a
-- green border, an item the inspected player wears a blue one. Hover shows the item tooltip; shift-click links it.
local _, ns = ...

local BisGrid = {}
ns.BisGrid = BisGrid

local Selectors, Inventory, Items, Chat, ItemWidgets, Pixel, Skin, Theme, L =
    ns.Selectors, ns.Inventory, ns.Items, ns.Chat, ns.ItemWidgets, ns.Pixel, ns.Skin, ns.Theme, ns.L

BisGrid.RANKS = 6
local LEFT, HEADER_TOP, GRID_TOP, BOTTOM = 20, -124, -144, 28
local SLOT_WIDTH, ICON, GAP = 150, 36, 10
local ROW_HEIGHT = ICON + GAP
local SCROLL_STEP = ROW_HEIGHT

-- Border color per mark: worn by the player (green) or by the inspected player (blue).
local MARK_COLORS = { equipped = "success", inspected = "accent" }

local scroll, content, emptyText
local offset, contentHeight = 0, 0
-- The route and bracket of the last draw: a different list starts from the first row.
local lastShown

local function scrollRange()
    return math.max(0, contentHeight - (scroll:GetHeight() or 0))
end

local function scrollTo(value)
    offset = math.max(0, math.min(value, scrollRange()))
    scroll:SetVerticalScroll(offset)
end

local function showTooltip(button)
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. button.bisItemId)
    GameTooltip:Show()
end

local function onClick(button)
    if Chat.linkModifierHeld() then
        Chat.insertLink(Items.linkById(button.bisItemId, button.bisName))
    end
end

--- Builds an item button once: icon, border and the hover and click scripts that read the item it shows now.
local function buildButton(button)
    button:SetSize(ICON, ICON)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints(button)
    -- Trims the icon's baked-in frame.
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.bisBorder = Pixel.Border(button, "border", "OVERLAY")
    button:SetScript("OnEnter", showTooltip)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", onClick)
end

--- Paints the border: 2px in the mark color for a worn item, otherwise the thin neutral border.
local function paintBorder(button, mark)
    local border = button.bisBorder
    border:Resize()
    local thickness = Pixel.Size(button) * (mark and 2 or 1)
    border.textures[1]:SetHeight(thickness)
    border.textures[2]:SetHeight(thickness)
    border.textures[3]:SetWidth(thickness)
    border.textures[4]:SetWidth(thickness)
    border:SetColor(mark and MARK_COLORS[mark] or "border")
end

--- "equipped" when the player wears the item in that slot, "inspected" when the inspected player does, else nil.
local function markOf(itemId, slotKey, worn)
    if worn then
        return Inventory.isEquippedInSlot(itemId, slotKey, worn) and "inspected" or nil
    end
    return Inventory.isEquippedInSlot(itemId, slotKey) and "equipped" or nil
end

local function drawItem(rowIndex, row, rank, item, worn)
    local itemId = item.id or Items.id(item.name)
    if not itemId then
        return
    end
    local button = ItemWidgets.frame(content, "item", "Button", buildButton)
    button:SetPoint("TOPLEFT", content, "TOPLEFT", SLOT_WIDTH + (rank - 1) * (ICON + GAP), -(rowIndex - 1) * ROW_HEIGHT)
    button.icon:SetTexture(Items.iconById(itemId))
    button.bisItemId, button.bisName, button.bisRow, button.bisRank, button.bisSlot =
        itemId, item.name, rowIndex, rank, row.slot
    button.bisMark = markOf(itemId, row.key, worn)
    paintBorder(button, button.bisMark)
end

local function drawRow(rowIndex, row, worn)
    local top = -(rowIndex - 1) * ROW_HEIGHT
    if rowIndex % 2 == 0 then
        local stripe = ItemWidgets.texture(content, "BACKGROUND")
        stripe:SetPoint("TOPLEFT", content, "TOPLEFT", -6, top + GAP / 2)
        stripe:SetSize(SLOT_WIDTH + BisGrid.RANKS * (ICON + GAP) + 2, ROW_HEIGHT)
        stripe:SetColorTexture(Theme.Color("stripe"))
    end
    local label = ItemWidgets.label(content, 13, "medium", "dim")
    label:SetPoint("LEFT", content, "TOPLEFT", 0, top - ICON / 2)
    label:SetWidth(SLOT_WIDTH - 12)
    label:SetJustifyH("LEFT")
    label:SetWordWrap(false)
    label:SetText(row.slot)
    for rank, item in ipairs(row.items) do
        drawItem(rowIndex, row, rank, item, worn)
    end
end

local function createHeaders(parent)
    for rank = 1, BisGrid.RANKS do
        local header = Skin.label(parent, 11, "semibold", "muted")
        header:SetPoint("TOP", parent, "TOPLEFT", LEFT + SLOT_WIDTH + (rank - 1) * (ICON + GAP) + ICON / 2, HEADER_TOP)
        header:SetText(L["Top %d"]:format(rank))
    end
end

function BisGrid.create(parent)
    offset, contentHeight, lastShown = 0, 0, nil
    createHeaders(parent)
    scroll = CreateFrame("ScrollFrame", "ForeverBiSGridScroll", parent)
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", LEFT, GRID_TOP)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -LEFT, BOTTOM)
    content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(SLOT_WIDTH + BisGrid.RANKS * (ICON + GAP))
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(_, delta)
        scrollTo(offset - delta * SCROLL_STEP)
    end)
    emptyText = Skin.label(parent, 13, "regular", "dim")
    emptyText:SetPoint("TOPLEFT", parent, "TOPLEFT", LEFT, GRID_TOP)
    emptyText:SetJustifyH("LEFT")
end

--- Draws the rows for what the selectors show, from the first row when the list changed. Returns the row count.
function BisGrid.refresh()
    local current = Selectors.current()
    local rows = ForeverBiSModel and ForeverBiSModel.gridSlots(current.route, current.phase, BisGrid.RANKS) or {}
    local shown = tostring(current.route) .. "|" .. tostring(current.phase)
    if shown ~= lastShown then
        lastShown, offset = shown, 0
    end
    ItemWidgets.release(content)
    for index, row in ipairs(rows) do
        drawRow(index, row, current.worn)
    end
    contentHeight = #rows * ROW_HEIGHT
    content:SetHeight(math.max(1, contentHeight))
    scrollTo(offset)
    emptyText:SetText(#rows == 0 and L["No BiS list is loaded for this build."] or "")
    return #rows
end
