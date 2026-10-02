-- The scrolling BiS list: slot headings with collapse buttons, item and enchant rows, the empty state and the
-- item counter. Filters and collapsed slots are read from shared state, never from other panels.
local _, ns = ...

local ItemList = {}
ns.ItemList = ItemList

local Filters, Settings, Player, ItemRows, L = ns.Filters, ns.Settings, ns.Player, ns.ItemRows, ns.L

local HEADING_X = 24
-- The list sits lower while the dungeon dropdown row is showing.
local SCROLL_TOP, SCROLL_TOP_WITH_DUNGEONS = -140, -166

local frame, scroll, content, countText
local slotTops = {}

--- Builds the scroll area and the item counter inside the window frame.
function ItemList.create(parent)
    frame = parent
    scroll = CreateFrame("ScrollFrame", "ForeverBiSScroll", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -96)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -384, 38)
    content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(500)
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    countText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    countText:SetPoint("TOPRIGHT", parent, "TOPLEFT", 376, -88)
    countText:SetWidth(96)
    countText:SetJustifyH("RIGHT")
end

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

local function layoutScroll()
    scroll:ClearAllPoints()
    scroll:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        20,
        Filters.state.sources.dungeon == true and SCROLL_TOP_WITH_DUNGEONS or SCROLL_TOP
    )
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -384, 38)
end

local function addMessage(text, y)
    local message = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    message:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    message:SetWidth(content:GetWidth())
    message:SetJustifyH("LEFT")
    message:SetText(text)
end

--- The slot heading with its collapse button and rule. Returns the y below it.
local function addSlotHeading(y, slotName, collapseKey, collapsed)
    local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", content, "TOPLEFT", HEADING_X, y)
    header:SetText("|cffffe35b" .. string.upper(slotName) .. "|r")
    local collapseButton = CreateFrame("Button", nil, content)
    collapseButton:SetSize(18, 18)
    collapseButton:SetPoint("LEFT", header, "LEFT", -23, -1)
    local buttonTexture = collapsed and "UI-PlusButton" or "UI-MinusButton"
    collapseButton:SetNormalTexture("Interface\\Buttons\\" .. buttonTexture .. "-Up")
    collapseButton:SetPushedTexture("Interface\\Buttons\\" .. buttonTexture .. "-Down")
    collapseButton:SetHighlightTexture("Interface\\Buttons\\" .. buttonTexture .. "-Highlight", "ADD")
    collapseButton:SetScript("OnClick", function()
        Settings.toggleCollapsed(collapseKey)
        ns.requestRender()
    end)
    y = y - 30
    local rule = content:CreateTexture(nil, "ARTWORK")
    rule:SetTexture("Interface\\Buttons\\WHITE8X8")
    rule:SetVertexColor(0.42, 0.49, 0.61, 0.9)
    rule:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    rule:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y)
    rule:SetHeight(1)
    return y - 6
end

local function addEmptyState(y)
    local empty = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    empty:SetPoint("TOPLEFT", content, "TOPLEFT", 8, y - 6)
    empty:SetWidth(content:GetWidth() - 16)
    empty:SetJustifyH("LEFT")
    empty:SetText(L["No items match the current search and filters."])
    local clearAll = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearAll:SetSize(100, 22)
    clearAll:SetPoint("TOPLEFT", content, "TOPLEFT", 8, y - 34)
    clearAll:SetText(L["Clear filters"])
    clearAll:SetScript("OnClick", function()
        Filters.reset()
        ns.requestRender()
    end)
    return y - 66
end

--- Draws one slot section when any of its items pass the filters. Returns the new y and how many items it drew.
local function addSlot(view, slot, y, faction)
    local slotKey = ns.Sources.normalizeSlotName(slot[1])
    local visibleItems = {}
    for rank, item in ipairs(slot[2]) do
        if Filters.matches(item, faction) then
            table.insert(visibleItems, { rank, item })
        end
    end
    if #visibleItems == 0 then
        return y, 0
    end

    y = y - 4
    local collapseKey = view.route .. ":" .. slot[1]
    local collapsed = Settings.isCollapsed(collapseKey)
    slotTops[slotKey] = y
    ItemRows.addEquipped(content, y, slotKey, slot[2])
    y = addSlotHeading(y, slot[1], collapseKey, collapsed)
    if collapsed then
        return y, #visibleItems
    end
    for _, rankedItem in ipairs(visibleItems) do
        y = ItemRows.addItem(content, y, rankedItem[1], rankedItem[2], slotKey)
    end
    local enchants = slot[3]
    if enchants and #enchants > 0 then
        y = ItemRows.addEnchants(content, y, enchants)
    end
    return y, #visibleItems
end

local function updateCounter(shown, total)
    if shown == total then
        countText:SetText(L["%d items"]:format(total))
    else
        countText:SetText("|cffffe35b" .. shown .. "|r/" .. total)
    end
end

local function settleScroll(previousScroll)
    if scroll.UpdateScrollChildRect then
        scroll:UpdateScrollChildRect()
    end
    local maxScroll = math.max(0, content:GetHeight() - scroll:GetHeight())
    scroll:SetVerticalScroll(math.min(previousScroll, maxScroll))
end

--- Scrolls so the slot's heading is at the top, when the slot is drawn.
function ItemList.jumpTo(slotKey)
    local top = slotTops[slotKey]
    if top then
        scroll:SetVerticalScroll(math.max(0, -top - 4))
    end
end

--- Redraws the list for the view (see Lists.view). Options: scrollTop starts again from the top; jumpTo is a
--- slot key to scroll to once drawn.
function ItemList.refresh(view, options)
    options = options or {}
    if options.scrollTop then
        scroll:SetVerticalScroll(0)
    end
    local previousScroll = scroll:GetVerticalScroll() or 0
    slotTops = {}
    layoutScroll()
    clearContent()
    content:SetWidth(view.width - 410)

    local y = -5
    if not view.data then
        addMessage(L["This installed version does not include the selected BiS list yet."], y)
        countText:SetText("")
        content:SetHeight(45)
        scroll:SetVerticalScroll(0)
        return
    end

    local faction = Player.faction()
    local totalItems, shownItems = 0, 0
    for _, slot in ipairs(view.data.slots) do
        local drawn
        y, drawn = addSlot(view, slot, y, faction)
        totalItems = totalItems + #slot[2]
        shownItems = shownItems + drawn
    end
    if shownItems == 0 then
        y = addEmptyState(y)
    end
    updateCounter(shownItems, totalItems)

    content:SetHeight(-y + 8)
    settleScroll(previousScroll)
    if options.jumpTo then
        ItemList.jumpTo(options.jumpTo)
    end
end
